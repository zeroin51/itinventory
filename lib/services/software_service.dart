import 'package:cloud_firestore/cloud_firestore.dart';
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

Future<void> deleteSoftwareItem(String id) async {
  CollectionReference software = FirebaseFirestore.instance.collection('software');
  await software.doc(id).delete();
}
