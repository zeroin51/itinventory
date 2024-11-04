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

Future<void> deleteDeviceItem(String id, String imageUrl) async {
  CollectionReference device = FirebaseFirestore.instance.collection('device');
  
  // Delete the document from Firestore
  await device.doc(id).delete();

  // Check if the imageUrl is not empty before attempting to delete the image from Storage
  if (imageUrl.isNotEmpty) {
    try {
      // Extract the path from the imageUrl
      Uri uri = Uri.parse(imageUrl);
      String filePath = uri.path.substring(1); // Remove leading slash from path

      // Create a reference to the file in Firebase Storage
      final firebase_storage.Reference imageRef =
          firebase_storage.FirebaseStorage.instance.ref(filePath);
      await imageRef.delete();
      print('Image successfully deleted from Firebase Storage.');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
