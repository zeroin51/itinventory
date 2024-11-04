import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/software_item_model.dart'; // Import model SoftwareItem

Future<void> addSoftwareItem(SoftwareItem item) async {
  CollectionReference software = FirebaseFirestore.instance.collection('software');
  await software.add(item.toMap());
}

Stream<List<SoftwareItem>> getSoftwareItems() {
  return FirebaseFirestore.instance
      .collection('software')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SoftwareItem.fromMap(doc.data(), doc.id))
          .toList());
}

Future<void> updateSoftwareItem(SoftwareItem item) async {
  CollectionReference software = FirebaseFirestore.instance.collection('software');
  await software.doc(item.id).update(item.toMap());
}

// Fungsi untuk menghapus SoftwareItem dan gambar terkait di Firebase Storage
Future<void> deleteSoftwareItem(String id, String imageUrl) async {
  CollectionReference software = FirebaseFirestore.instance.collection('software');
  
  try {
    // Hapus dokumen dari Firestore
    await software.doc(id).delete();
    print('Document with ID $id successfully deleted from Firestore.');

    // Jika imageUrl tidak kosong, hapus gambar dari Firebase Storage
    if (imageUrl.isNotEmpty) {
      Uri uri = Uri.parse(imageUrl);
      String filePath = uri.path.substring(1); // Hapus leading slash dari path

      firebase_storage.Reference imageRef = firebase_storage.FirebaseStorage.instance.ref(filePath);
      await imageRef.delete();
      print('Image successfully deleted from Firebase Storage.');
    }
  } catch (e) {
    print('Error occurred while deleting: $e');
  }
}