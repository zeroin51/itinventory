import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<void> deleteDeviceItem(String id) async {
  CollectionReference device = FirebaseFirestore.instance.collection('device');
  await device.doc(id).delete();
}
