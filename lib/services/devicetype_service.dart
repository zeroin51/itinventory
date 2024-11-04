import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/models/devicetype_item_model.dart';

class DevicetypeService {
  final CollectionReference _deviceTypeCollection =
      FirebaseFirestore.instance.collection('devicetype');

  Future<void> addDeviceType(DeviceType deviceType) async {
    await _deviceTypeCollection.add(deviceType.toMap());
  }

  Future<void> updateDeviceType(DeviceType deviceType) async {
    await _deviceTypeCollection
        .doc(deviceType.id)
        .update(deviceType.toMap());
  }

  Future<void> deleteDeviceType(String id) async {
    await _deviceTypeCollection.doc(id).delete();
  }

  Stream<List<DeviceType>> getDeviceType() {
    return _deviceTypeCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => 
          DeviceType.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        ).toList());
  }

  Future<DeviceType?> getDeviceTypeById(String id) async {
    DocumentSnapshot doc = await _deviceTypeCollection.doc(id).get();
    if (doc.exists) {
      return DeviceType.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
