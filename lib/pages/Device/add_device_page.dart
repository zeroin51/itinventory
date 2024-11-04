import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:itinventory/pages/crop_image.dart';
import '/models/device_item_model.dart';
import '/services/device_service.dart';

class AddDevicePage extends StatefulWidget {
  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();
  String noasset = '';
  String noserial = '';
  String type = 'Komputer';
  String assetdesc = '';
  String costcenter = '';
  String companycode = '';
  String picname = '';
  String loccode = '';
  String locdesc = '';
  String kondisi = 'Berfungsi';
  String label = 'Ada';
  String note = '';
  String imageUrl = '';

  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final firebase_storage.Reference _storageRef = firebase_storage.FirebaseStorage.instance.ref('images');
  Uint8List? _imageBytes;
  final CropController cropController = CropController(aspectRatio: 1.0);

  // Fungsi untuk mengambil data dropdown dari Firestore
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

  // Fungsi kompresi gambar
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

  // Fungsi memilih gambar dan cropping
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

  // Fungsi upload gambar ke Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageBytes != null && noasset.isNotEmpty) {
      final DateTime now = DateTime.now();
      final String formattedDate = '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
      final String fileName = '${noasset}_$formattedDate';

      final imageRef = _storageRef.child('$fileName.png');
      await imageRef.putData(_imageBytes!);
      imageUrl = await imageRef.getDownloadURL();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Item Device')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Widget untuk gambar
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
                          : Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey[600],
                            ),
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

                // Input Nomor Asset
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nomor Asset'),
                  onSaved: (value) => noasset = value!,
                  validator: (value) => value == null || value.isEmpty ? 'Masukkan Nomor Asset' : null,
                ),

                // Input Nomor Serial
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nomor Serial'),
                  onSaved: (value) => noserial = value!,
                  validator: (value) => value == null || value.isEmpty ? 'Masukkan Nomor Serial' : null,
                ),

                //Dropdown Device Type dari Firestore
                FutureBuilder<List<String>>(
                  future: _getDevicetype(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No Device Type available');
                    }
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(type) ? type : null,
                      onChanged: (value) => setState(() => type = value!),
                      decoration: InputDecoration(labelText: 'Device Type'),
                      items: snapshot.data!.map((center) => DropdownMenuItem(value: center, child: Text(center))).toList(),
                    );
                  },
                ),

                // Dropdown Company Code dari Firestore
                FutureBuilder<List<String>>(
                  future: _getCompanyCodes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No Company Codes available');
                    }
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(companycode) ? companycode : null,
                      onChanged: (value) => setState(() => companycode = value!),
                      decoration: InputDecoration(labelText: 'Company Code'),
                      items: snapshot.data!.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
                    );
                  },
                ),

                // Dropdown Cost Center dari Firestore
                FutureBuilder<List<String>>(
                  future: _getCostCenters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No Cost Centers available');
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

                // Dropdown Location Code dari Firestore
                FutureBuilder<List<String>>(
                  future: _getLocCodes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No Location Codes available');
                    }
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(loccode) ? loccode : null,
                      onChanged: (value) => setState(() => loccode = value!),
                      decoration: InputDecoration(labelText: 'Location Code'),
                      items: snapshot.data!.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                    );
                  },
                ),

                // Field tambahan lainnya
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location Description'),
                  onSaved: (value) => locdesc = value!,
                ),
                TextFormField(
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
                  decoration: InputDecoration(labelText: 'Note'),
                  onSaved: (value) => note = value!,
                ),
                SizedBox(height: 20),

                // Tombol untuk menambah data
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _uploadImage();
                      // Simpan data device ke Firestore
                      final deviceItem = DeviceItem(
                        id: '',
                        noasset: noasset,
                        noserial: noserial,
                        type: type,
                        assetdesc: assetdesc,
                        companycode: companycode,
                        costcenter: costcenter,
                        picname: picname,
                        loccode: loccode,
                        locdesc: locdesc,
                        kondisi: kondisi,
                        label: label,
                        note: note,
                        imageUrl: imageUrl,
                      );
                      await addDeviceItem(deviceItem);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Tambah Device'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
