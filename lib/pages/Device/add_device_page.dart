import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
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
  String details = '';

  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final firebase_storage.Reference _storageRef =
      firebase_storage.FirebaseStorage.instance.ref('images');

  Uint8List? _imageBytes; // Untuk menyimpan byte array gambar
  String imageUrl = ''; // URL gambar yang diunggah

  Future<void> _uploadImage() async {
    try {
      if (_imageBytes != null && noasset.isNotEmpty) {
        // Menggunakan nilai noasset dan timestamp untuk nama file
        final DateTime now = DateTime.now();
        final String formattedDate = '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
        final String fileName = '${noasset}_$formattedDate'; // Gabungan noasset dan timestamp

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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
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
                DropdownButtonFormField<String>(
                  value: type,
                  items: ['Komputer', 'Laptop', 'Switch', 'Router'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      type = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Details'),
                  onSaved: (value) {
                    details = value!;
                  },
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _uploadImage();
                      if (imageUrl.isNotEmpty) {
                        await addDeviceItem(
                          DeviceItem(
                            id: '',
                            noasset: noasset,
                            noserial: noserial,
                            type: type,
                            details: details,
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
