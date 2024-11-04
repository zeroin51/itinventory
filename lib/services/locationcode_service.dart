import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/models/locationcode_item_model.dart';

class LocationCodeService {
  final CollectionReference _locationCodeCollection =
      FirebaseFirestore.instance.collection('locationcodes');

  Future<void> addLocationCode(LocationCode locationCode) async {
    await _locationCodeCollection.add(locationCode.toMap());
  }

  Future<void> updateLocationCode(LocationCode locationCode) async {
    await _locationCodeCollection
        .doc(locationCode.id)
        .update(locationCode.toMap());
  }

  Future<void> deleteLocationCode(String id) async {
    await _locationCodeCollection.doc(id).delete();
  }

  Stream<List<LocationCode>> getLocationCodes() {
    return _locationCodeCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => 
          LocationCode.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        ).toList());
  }

  Future<LocationCode?> getLocationCodeById(String id) async {
    DocumentSnapshot doc = await _locationCodeCollection.doc(id).get();
    if (doc.exists) {
      return LocationCode.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
