import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String nickName;
  String imageUrl;
  String email;

  User (FirebaseUser firebaseUser) {
    uid = firebaseUser.uid;
    nickName = firebaseUser.displayName;
    imageUrl = firebaseUser.photoUrl;
    email = firebaseUser.email;
  }

  User.fromDocumentSnapshot (DocumentSnapshot ds) {
    uid = ds.data['uid'] as String;
    nickName = ds.data['nick_name'] as String;
    imageUrl = ds.data['image_url'] as String;
    email = ds.data['email'] as String;
  }
}