import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/device_item_model.dart';
import 'edit_device_page.dart';

class DeviceDetailPage extends StatelessWidget {
  final DeviceItem item;

  DeviceDetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Device'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditDevicePage(item: item),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getImageUrlFromFirestore(item.id), // Fetching imageUrl from Firestore
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
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
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to an online placeholder if the Firebase image fails
                        return Image.network(
                          'https://via.placeholder.com/300',
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'No Asset: ${item.noasset}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'No Serial: ${item.noserial}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Type: ${item.type}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Detail: ${item.details}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }
          }

          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
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
    // Query Firestore to get the document with the imageUrl
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('device').doc(itemId).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      // Check if imageUrl exists in Firestore
      if (data.containsKey('imageUrl') && data['imageUrl'].toString().isNotEmpty) {
        return data['imageUrl'];
      }
    }

    // Fallback to a placeholder image if no imageUrl is found
    return 'https://via.placeholder.com/300'; // Online placeholder
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
                _deleteItem(context);
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

  void _deleteItem(BuildContext context) {
    FirebaseFirestore.instance.collection('device').doc(item.id).delete().then((_) {
      Navigator.of(context).pop(); // Pop once to go back to the list
    });
  }
}
