import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miicha_app/model/user.dart';

enum AuthenticationState { signIn, signOut }

class AuthenticationBloc implements Bloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthenticationState authState = AuthenticationState.signOut;

  final _userController = BehaviorSubject<User>();
  ValueObservable<User> get currentUser => _userController;

  // Todo: FirebaseUser -> Userのモデル変換のより良い方法を考える
  final _firebaseUserController = BehaviorSubject<FirebaseUser>();
  ValueObservable<FirebaseUser> get currentFirebaseUser => _firebaseUserController;

  AuthenticationBloc() {
    _auth.onAuthStateChanged
      .pipe(_firebaseUserController);
    _userController.listen((user) {
      authState = user == null
      ? AuthenticationState.signOut
      : AuthenticationState.signIn;
    });
    currentFirebaseUser.listen((firebaseUser) {
      if (firebaseUser == null) { 
        _userController.add(null); 
        return;
      }
      _convertUser(firebaseUser);
    });
  }

  Future _convertUser(FirebaseUser firebaseUser) {
    return Firestore.instance.collection('users')
          .where('uid', isEqualTo: firebaseUser.uid)
          .getDocuments()
          .then((ds) {
            if (ds.documents.isEmpty) {
              Firestore.instance.collection('users').document()
                .setData({
                  'uid': firebaseUser.uid,
                  'nick_name': firebaseUser.displayName,
                  'image_url': firebaseUser.photoUrl,
                  'email': firebaseUser.email
                });
              return User(firebaseUser);
            } else {
              return User.fromDocumentSnapshot(ds.documents.first);
            }
          })
          .then(_userController.add);
  }

  void handleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  void getCurrentUser() {
    _auth.currentUser();
  }

  // サインアウトの確認ダイアログを表示する
  void showConfirmSignOutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('サインアウト'),
            content: const Text('サインアウトすると、アプリのいくつかの機能が使用できなくなります。'),
            actions: <Widget>[
              FlatButton(
                child: const Text('サインアウトしない'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text('サインアウトする'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _signOut();
                },
              ),
            ],
          );
        });
  }

  void _signOut() {
    _auth.signOut().then((_) {
      _googleSignIn.signOut();
    }).catchError(print);
  }

  @override
  void dispose() async{
    await _userController.close();
    await _firebaseUserController.close();
  }
}