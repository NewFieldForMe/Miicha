import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String nickName;
  String imageUrl;
  String email;

  User (FirebaseUser firebaseUser) {
    id = firebaseUser.uid;
    nickName = firebaseUser.displayName;
    imageUrl = firebaseUser.photoUrl;
    email = firebaseUser.email;
  }

  User.fromDocumentSnapshot (DocumentSnapshot ds) {
    id = ds.data['id'] as String;
    nickName = ds.data['nick_name'] as String;
    imageUrl = ds.data['image_url'] as String;
    email = ds.data['email'] as String;
  }
}