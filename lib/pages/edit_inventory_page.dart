import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import '../models/inventory_item_model.dart';
import '../services/inventory_service.dart';

class EditInventoryPage extends StatefulWidget {
  final InventoryItem item;

  EditInventoryPage({required this.item});

  @override
  _EditInventoryPageState createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String noasset;
  late String noserial;
  late String type;
  late String details;
  late String imageUrl;

  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final firebase_storage.Reference _storageRef =
      firebase_storage.FirebaseStorage.instance.ref('inventory_images');

  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    noasset = widget.item.noasset;
    noserial = widget.item.noserial;
    type = widget.item.type;
    details = widget.item.details;
    imageUrl = widget.item.imageUrl;
  }

  Future<void> _uploadImage() async {
    try {
      if (_imageBytes != null) {
        // Gunakan nilai noasset sebagai bagian dari nama file
        final DateTime now = DateTime.now();
        final String formattedDate = '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
        final String fileName = '${noasset}_$formattedDate'; // Gabungan noasset dan waktu sekarang
        
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
      appBar: AppBar(title: Text('Edit Inventory Item')),
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
                  initialValue: noserial,
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
                  items: ['Device', 'Software'].map((String value) {
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
                  initialValue: details,
                  decoration: InputDecoration(labelText: 'Details'),
                  onSaved: (value) {
                    details = value!;
                  },
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (_imageBytes != null) {
                        await _uploadImage();
                      }
                      await updateInventoryItem(
                        InventoryItem(
                          id: widget.item.id,
                          noasset: noasset,
                          noserial: noserial,
                          type: type,
                          details: details,
                          imageUrl: imageUrl,
                        ),
                      );
                      Navigator.pop(context);
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
