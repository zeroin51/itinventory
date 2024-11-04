import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/models/softwaretype_item_model.dart';

class SoftwaretypeService {
  final CollectionReference _softwareTypeCollection =
      FirebaseFirestore.instance.collection('softwaretype');

  Future<void> addSoftwareType(SoftwareType softwareType) async {
    await _softwareTypeCollection.add(softwareType.toMap());
  }

  Future<void> updateSoftwareType(SoftwareType softwareType) async {
    await _softwareTypeCollection
        .doc(softwareType.id)
        .update(softwareType.toMap());
  }

  Future<void> deleteSoftwareType(String id) async {
    await _softwareTypeCollection.doc(id).delete();
  }

  Stream<List<SoftwareType>> getSoftwareType() {
    return _softwareTypeCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => 
          SoftwareType.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        ).toList());
  }

  Future<SoftwareType?> getSoftwareTypeById(String id) async {
    DocumentSnapshot doc = await _softwareTypeCollection.doc(id).get();
    if (doc.exists) {
      return SoftwareType.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
