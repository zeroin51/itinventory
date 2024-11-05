import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:crop_image/crop_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/pages/crop_image.dart';
import '/models/device_item_model.dart';
import '/services/device_service.dart';

class EditDevicePage extends StatefulWidget {
  final DeviceItem item;

  EditDevicePage({required this.item});

  @override
  _EditDevicePageState createState() => _EditDevicePageState();
}

class _EditDevicePageState extends State<EditDevicePage> {
  final _formKey = GlobalKey<FormState>();
  late String noasset, noserial, type, assetdesc, costcenter, companycode, picname, loccode, locdesc, kondisi, label, note, imageUrl, imagename;
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final firebase_storage.Reference _storageRef = firebase_storage.FirebaseStorage.instance.ref('images');
  Uint8List? _imageBytes;
  final CropController cropController = CropController(aspectRatio: 1.0);

  @override
  void initState() {
    super.initState();
    noasset = widget.item.noasset;
    noserial = widget.item.noserial;
    type = widget.item.type;
    assetdesc = widget.item.assetdesc;
    costcenter = widget.item.costcenter;
    companycode = widget.item.companycode;
    picname = widget.item.picname;
    loccode = widget.item.loccode;
    locdesc = widget.item.locdesc;
    kondisi = widget.item.kondisi;
    label = widget.item.label;
    note = widget.item.note;
    imageUrl = widget.item.imageUrl;
    imagename = widget.item.imagename;
  }

  Future<List<String>> _getDevicetype() async {
    final snapshot = await FirebaseFirestore.instance.collection('devicetype').get();
    return snapshot.docs.map((doc) => doc['devicetype'] as String).toList();
  }

  Future<List<String>> _getCompanyCodes() async {
    final snapshot = await FirebaseFirestore.instance.collection('companycodes').get();
    return snapshot.docs.map((doc) => doc['comcode'] as String).toList();
  }

  Future<List<String>> _getCostCenters() async {
    final costCentersSnapshot = await FirebaseFirestore.instance.collection('costcenters').get();
    return costCentersSnapshot.docs.map((doc) {
      final data = doc.data();
      final kodeCC = data['kodeCC'] ?? '';
      final detail = data['detail'] ?? '';
      return '$kodeCC-$detail';
    }).toList();
  }

  Future<List<String>> _getLocCodes() async {
    final snapshot = await FirebaseFirestore.instance.collection('locationcodes').get();
    return snapshot.docs.map((doc) => doc['loccode'] as String).toList();
  }

  Future<Uint8List?> _compressImage(Uint8List imageBytes) async {
    try {
      final List<int>? compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        format: CompressFormat.jpeg,
        quality: 70,
      );
      return compressedBytes != null ? Uint8List.fromList(compressedBytes) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImagePage(
            imageBytes: imageBytes,
            cropController: cropController,
            onImageCropped: (croppedBytes) async {
              final Uint8List? compressedImage = await _compressImage(croppedBytes);
              setState(() {
                _imageBytes = compressedImage ?? croppedBytes;
              });
            },
          ),
        ),
      );
    }
  }

  // Fungsi upload gambar ke Firebase Storage dan menyimpan imagename
  // Fungsi upload gambar baru dan menghapus gambar lama
  Future<void> _uploadImage() async {
    if (_imageBytes != null && noasset.isNotEmpty) {
      // Hapus gambar lama jika imagename lama ada
      if (imagename.isNotEmpty) {
        final oldImageRef = _storageRef.child(imagename);
        try {
          await oldImageRef.delete();
          print('Old image successfully deleted from Firebase Storage.');
        } catch (e) {
          print('Error deleting old image: $e');
        }
      }

      // Upload gambar baru
      final DateTime now = DateTime.now();
      final String formattedDate = '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
      imagename = '${noasset}_$formattedDate.png';

      final imageRef = _storageRef.child(imagename);
      await imageRef.putData(_imageBytes!);
      imageUrl = await imageRef.getDownloadURL();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Device Item')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: _imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.memory(
                                _imageBytes!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    imageUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: Colors.grey[600],
                                )),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Gambar'),
                ),

                TextFormField(
                  initialValue: noasset,
                  decoration: InputDecoration(labelText: 'Nomor Asset'),
                  onSaved: (value) => noasset = value!,
                  validator: (value) => value == null || value.isEmpty ? 'Masukkan Nomor Asset' : null,
                ),

                TextFormField(
                  initialValue: noserial,
                  decoration: InputDecoration(labelText: 'Nomor Serial'),
                  onSaved: (value) => noserial = value!,
                  validator: (value) => value == null || value.isEmpty ? 'Masukkan Nomor Serial' : null,
                ),

                TextFormField(
                  initialValue: assetdesc,
                  decoration: InputDecoration(labelText: 'Asset Description'),
                  onSaved: (value) => assetdesc = value!,
                  validator: (value) => value == null || value.isEmpty ? 'Masukkan Asset Description' : null,
                ),

                FutureBuilder<List<String>>(
                  future: _getDevicetype(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(type) ? type : null,
                      onChanged: (value) => setState(() => type = value!),
                      decoration: InputDecoration(labelText: 'Device Type'),
                      items: snapshot.data!.map((center) => DropdownMenuItem(value: center, child: Text(center))).toList(),
                    );
                  },
                ),

                FutureBuilder<List<String>>(
                  future: _getCompanyCodes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: companycode,
                      onChanged: (value) => setState(() => companycode = value!),
                      decoration: InputDecoration(labelText: 'Company Code'),
                      items: snapshot.data!.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
                    );
                  },
                ),

                FutureBuilder<List<String>>(
                  future: _getCostCenters(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(costcenter) ? costcenter : null,
                      onChanged: (value) => setState(() => costcenter = value!),
                      decoration: InputDecoration(labelText: 'Cost Center'),
                      items: snapshot.data!
                          .map((center) => DropdownMenuItem(value: center, child: Text(center)))
                          .toList(),
                    );
                  },
                ),
                FutureBuilder<List<String>>(
                  future: _getLocCodes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: loccode,
                      onChanged: (value) => setState(() => loccode = value!),
                      decoration: InputDecoration(labelText: 'Location Code'),
                      items: snapshot.data!.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                    );
                  },
                ),

                TextFormField(
                  initialValue: locdesc,
                  decoration: InputDecoration(labelText: 'Location Description'),
                  onSaved: (value) => locdesc = value!,
                ),

                TextFormField(
                  initialValue: picname,
                  decoration: InputDecoration(labelText: 'PIC Name'),
                  onSaved: (value) => picname = value!,
                ),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Kondisi'),
                  value: kondisi,
                  items: ['Berfungsi', 'Tidak Berfungsi'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => kondisi = value!),
                ),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Label'),
                  value: label,
                  items: ['Ada', 'Tidak Ada'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => label = value!),
                ),

                TextFormField(
                  initialValue: note,
                  decoration: InputDecoration(labelText: 'Note'),
                  onSaved: (value) => note = value!,
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _uploadImage();
                      final updatedDevice = DeviceItem(
                        id: widget.item.id,
                        noasset: noasset,
                        noserial: noserial,
                        type: type,
                        assetdesc: assetdesc,
                        costcenter: costcenter,
                        companycode: companycode,
                        picname: picname,
                        loccode: loccode,
                        locdesc: locdesc,
                        kondisi: kondisi,
                        label: label,
                        note: note,
                        imageUrl: imageUrl,
                        imagename: imagename,
                      );
                      await updateDeviceItem(updatedDevice);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
