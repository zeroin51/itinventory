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

Future<void> deleteSoftwareItem(String id, String imagename) async {
  try {
    if (imagename.isNotEmpty) { // Hanya hapus jika imagename tidak kosong
      final firebase_storage.Reference imageRef =
          firebase_storage.FirebaseStorage.instance.ref('images/$imagename');
      await imageRef.delete();
      print('Image successfully deleted from Firebase Storage.');
    }
  } catch (e) {
    print('Error deleting image from Firebase Storage: $e');
    throw ('Gagal menghapus gambar: $e');
  }

  try {
    CollectionReference software = FirebaseFirestore.instance.collection('software');
    await software.doc(id).delete();
    print('Software item successfully deleted from Firestore.');
  } catch (e) {
    print('Error deleting document from Firestore: $e');
    throw ('Gagal menghapus item dari Firestore: $e');
  }
}