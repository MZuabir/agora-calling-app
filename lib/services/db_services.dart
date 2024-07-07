import 'package:calling_app/models/user_model.dart';
import 'package:calling_app/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DBServices {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  addUser(UserModel user) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(user.email)
          .set(user.toJson());
    } catch (e) {
      Logger.error(e);
      throw ();
    }
  }

  Stream<QuerySnapshot> getAllUsers() {
    return firebaseFirestore
        .collection("users")
        .where('email', isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriends() {
    return firebaseFirestore
        .collection("users")
        .where('email', isNotEqualTo: FirebaseAuth.instance.currentUser?.email)
        // .where('friends',
        //     arrayContains: FirebaseAuth.instance.currentUser?.email)
        .snapshots();
  }

  sendFriendRequest(String docId) {
    firebaseFirestore.collection("users").doc(docId).update({
      "friendRequests":
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.email]),
    });
  }

  addToFriends(String friendId) async {
    await firebaseFirestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({
      "friends": FieldValue.arrayUnion([friendId]),
    });
  }

  removeFromFriendReq(String requestToRemove) async {
    await firebaseFirestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({
      "friendRequests": FieldValue.arrayRemove([requestToRemove]),
    });
  }

  Stream<DocumentSnapshot> currentUserSnapshot() {
    return firebaseFirestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.email)
        .snapshots();
  }
}
