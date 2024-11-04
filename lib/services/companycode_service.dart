import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/models/companycode_item_model.dart';

class CompanyCodeService {
  final CollectionReference _companyCodeCollection =
      FirebaseFirestore.instance.collection('companycodes');

  Future<void> addCompanyCode(CompanyCode companyCode) async {
    await _companyCodeCollection.add(companyCode.toMap());
  }

  Future<void> updateCompanyCode(CompanyCode companyCode) async {
    await _companyCodeCollection
        .doc(companyCode.id)
        .update(companyCode.toMap());
  }

  Future<void> deleteCompanyCode(String id) async {
    await _companyCodeCollection.doc(id).delete();
  }

  Stream<List<CompanyCode>> getCompanyCodes() {
    return _companyCodeCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => 
          CompanyCode.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        ).toList());
  }

  Future<CompanyCode?> getCompanyCodeById(String id) async {
    DocumentSnapshot doc = await _companyCodeCollection.doc(id).get();
    if (doc.exists) {
      return CompanyCode.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
