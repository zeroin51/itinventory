import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:crop_image/crop_image.dart';  // Import package untuk crop image
import '../crop_image.dart';
import '/models/software_item_model.dart';
import '/services/software_service.dart';
import 'package:intl/intl.dart'; // For formatting date strings

class AddSoftwarePage extends StatefulWidget {
  @override
  _AddSoftwarePageState createState() => _AddSoftwarePageState();
}

class _AddSoftwarePageState extends State<AddSoftwarePage> {
  final _formKey = GlobalKey<FormState>();
  String noasset = '';
  String noserial = '';
  String type = 'Office';
  String assetdesc = '';
  String costcenter = '';
  String companycode = '';
  String picname = '';
  String loccode = '';
  String locdesc = '';
  String kondisi = 'Berfungsi';
  String label = 'Ada';
  String note = '';
  DateTime? expdate; // For storing the selected expiration date
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final firebase_storage.Reference _storageRef =
      firebase_storage.FirebaseStorage.instance.ref('images');

  Uint8List? _imageBytes; // For storing the image bytes
  String imageUrl = ''; // URL of the uploaded image

  // Tambahkan controller untuk cropping
  final CropController cropController = CropController(
    aspectRatio: 1.0,  // Default aspect ratio 1:1 (square)
  );

  // Fungsi kompresi gambar dari in-memory data
  Future<Uint8List?> _compressImage(Uint8List imageBytes) async {
    try {
      final List<int>? compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        format: CompressFormat.jpeg,
        quality: 70, // Kompresi dengan kualitas 70
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
      
      // Tampilkan halaman cropping setelah gambar dipilih
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImagePage(
            imageBytes: imageBytes,
            cropController: cropController,
            onImageCropped: (croppedBytes) async {
              // Kompresi hasil crop sebelum disimpan
              final Uint8List? compressedImage = await _compressImage(croppedBytes);
              setState(() {
                _imageBytes = compressedImage ?? croppedBytes; // Set hasil crop dan kompresi image
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    try {
      if (_imageBytes != null && noasset.isNotEmpty) {
        final DateTime now = DateTime.now();
        final String formattedDate = '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
        final String fileName = '${noasset}_$formattedDate'; 

        final imageRef = _storageRef.child('$fileName.png');
        final uploadTask = imageRef.putData(_imageBytes!);

        await uploadTask;
        imageUrl = await imageRef.getDownloadURL();

        setState(() {
          imageUrl = imageUrl;
        });
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> _selectExpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expdate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != expdate) {
      setState(() {
        expdate = picked;
      });
    }
  }
  // Fungsi untuk mengambil data dropdown dari Firestore
  Future<List<String>> _getSoftwaretype() async {
    final snapshot = await FirebaseFirestore.instance.collection('softwaretype').get();
    return snapshot.docs.map((doc) => doc['softwaretype'] as String).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Item Software')),
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nomor Asset'),
                  onSaved: (value) {
                    noasset = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Nomor Asset';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nomor Serial'),
                  onSaved: (value) {
                    noserial = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Nomor Serial';
                    }
                    return null;
                  },
                ),
                //Dropdown Device Type dari Firestore
                FutureBuilder<List<String>>(
                  future: _getSoftwaretype(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No DevSoftwareice Type available');
                    }
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(type) ? type : null,
                      onChanged: (value) => setState(() => type = value!),
                      decoration: InputDecoration(labelText: 'Software Type'),
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
                    return DropdownButtonFormField<String>(
                      value: companycode.isNotEmpty ? companycode : null,
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
                    return DropdownButtonFormField<String>(
                      value: costcenter.isNotEmpty ? costcenter : null,
                      onChanged: (value) => setState(() => costcenter = value!),
                      decoration: InputDecoration(labelText: 'Cost Center'),
                      items: snapshot.data!.map((center) => DropdownMenuItem(value: center, child: Text(center))).toList(),
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
                    return DropdownButtonFormField<String>(
                      value: loccode.isNotEmpty ? loccode : null,
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
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Expire',
                    hintText: expdate != null ? dateFormat.format(expdate!) : 'Pilih Tanggal',
                  ),
                  onTap: () => _selectExpDate(context),
                  validator: (value) {
                    if (expdate == null) {
                      return 'Pilih tanggal expire';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Note'),
                  onSaved: (value) => note = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _uploadImage();
                      if (imageUrl.isNotEmpty && expdate != null) {
                        await addSoftwareItem(
                          SoftwareItem(
                            id: '',
                            noasset: noasset,
                            noserial: noserial,
                            type: type,
                            expdate: dateFormat.format(expdate!), // Format date as string
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
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Upload Gambar Dahulu')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
