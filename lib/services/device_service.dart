import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/device_item_model.dart'; // Import model DeviceItem

Future<void> addDeviceItem(DeviceItem item) async {
  CollectionReference device = FirebaseFirestore.instance.collection('device');
  await device.add(item.toMap());
}

Stream<List<DeviceItem>> getDeviceItems() {
  return FirebaseFirestore.instance
      .collection('device')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DeviceItem.fromMap(doc.data(), doc.id))
          .toList());
}

Future<void> updateDeviceItem(DeviceItem item) async {
  CollectionReference device = FirebaseFirestore.instance.collection('device');
  await device.doc(item.id).update(item.toMap());
}

Future<void> deleteDeviceItem(String id, String imagename) async {
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
    CollectionReference device = FirebaseFirestore.instance.collection('device');
    await device.doc(id).delete();
    print('Device item successfully deleted from Firestore.');
  } catch (e) {
    print('Error deleting document from Firestore: $e');
    throw ('Gagal menghapus item dari Firestore: $e');
  }
}
