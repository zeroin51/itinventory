import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itinventory/models/user_item_model.dart';

class UserService {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> getUsers() {
    return _userCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addUser(UserModel user) {
    return _userCollection.doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) {
    return _userCollection.doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String id) {
    return _userCollection.doc(id).delete();
  }
}
