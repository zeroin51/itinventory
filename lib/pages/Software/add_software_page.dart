import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
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
  String details = '';
  DateTime? expdate; // For storing the selected expiration date
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final firebase_storage.Reference _storageRef =
      firebase_storage.FirebaseStorage.instance.ref('images');

  Uint8List? _imageBytes; // For storing the image bytes
  String imageUrl = ''; // URL of the uploaded image

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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
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
                DropdownButtonFormField<String>(
                  value: type,
                  items: ['Office', 'Adobe'].map((String value) {
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
