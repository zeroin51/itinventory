import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart'; // Import model InventoryItem

Future<void> addInventoryItem(InventoryItem item) async {
  CollectionReference inventory = FirebaseFirestore.instance.collection('inventory');
  await inventory.add(item.toMap());
}

Stream<List<InventoryItem>> getInventoryItems() {
  return FirebaseFirestore.instance
      .collection('inventory')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
          .toList());
}

Future<void> updateInventoryItem(InventoryItem item) async {
  CollectionReference inventory = FirebaseFirestore.instance.collection('inventory');
  await inventory.doc(item.id).update(item.toMap());
}

Future<void> deleteInventoryItem(String id) async {
  CollectionReference inventory = FirebaseFirestore.instance.collection('inventory');
  await inventory.doc(id).delete();
}
