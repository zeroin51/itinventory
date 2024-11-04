import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/models/costcenter_item_model.dart';

class CostCenterService {
  final CollectionReference _costCenterCollection =
      FirebaseFirestore.instance.collection('costcenters');

  Future<void> addCostCenter(CostCenter costCenter) async {
    await _costCenterCollection.add(costCenter.toMap());
  }

  Future<void> updateCostCenter(CostCenter costCenter) async {
    await _costCenterCollection
        .doc(costCenter.id)
        .update(costCenter.toMap());
  }

  Future<void> deleteCostCenter(String id) async {
    await _costCenterCollection.doc(id).delete();
  }

  Stream<List<CostCenter>> getCostCenters() {
    return _costCenterCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => 
          CostCenter.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        ).toList());
  }

  Future<CostCenter?> getCostCenterById(String id) async {
    DocumentSnapshot doc = await _costCenterCollection.doc(id).get();
    if (doc.exists) {
      return CostCenter.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
