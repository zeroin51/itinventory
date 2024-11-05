import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itinventory/models/software_item_model.dart';
import 'package:itinventory/services/software_service.dart';
import 'edit_software_page.dart';

class SoftwareDetailPage extends StatelessWidget {
  final SoftwareItem item;

  SoftwareDetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Software'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditSoftwarePage(item: item),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getImageUrlFromFirestore(item.id), // Fetching imageUrl from Firestore
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(
                    snapshot.data!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'No Asset: ${item.noasset}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'No Serial: ${item.noserial}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Type: ${item.type}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Asset Description: ${item.assetdesc}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Cost Center: ${item.costcenter}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Company Code: ${item.companycode}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'PIC Name: ${item.picname}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Location Code: ${item.loccode}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Location Description: ${item.locdesc}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Kondisi: ${item.kondisi}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Label: ${item.label}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Note: ${item.note}',
                      style: TextStyle(fontSize: 18),
                    ),
                  Text(
                    'Expired Date: ${item.expdate}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Gambar tidak tersedia.'),
              ),
            );
          }
        },
      ),
      persistentFooterButtons: <Widget>[
        ElevatedButton(
          onPressed: () {
            _showDeleteConfirmationDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text('Hapus'),
        ),
      ],
    );
  }

  Future<String> _getImageUrlFromFirestore(String itemId) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('software').doc(itemId).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('imageUrl') && data['imageUrl'].toString().isNotEmpty) {
        return data['imageUrl'];
      }
    }

    return 'https://via.placeholder.com/300';
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus item ini?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog konfirmasi
                _deleteItem(context); // Lanjutkan penghapusan item
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Hapus'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus item dengan memanggil deleteSoftware Item dari software_service.dart
 Future<void> _deleteItem(BuildContext context) async {
    try {
      await deleteSoftwareItem(item.id, item.imagename);
      Navigator.of(context).pop(); // Kembali ke halaman sebelumnya setelah berhasil menghapus
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus item: $e'),
        ),
      );
    }
  }
}