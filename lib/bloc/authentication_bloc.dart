import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthenticationState { signIn, signOut }

class AuthenticationBloc implements Bloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthenticationState authState = AuthenticationState.signOut;

  final _userController = BehaviorSubject<FirebaseUser>();
  ValueObservable<FirebaseUser> get currentUser => _userController;

  AuthenticationBloc() {
    _auth.onAuthStateChanged.pipe(_userController);
    _userController.listen((user) {
      authState = user == null
      ? AuthenticationState.signOut
      : AuthenticationState.signIn;
    });
  }

  void handleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential)
      .then((user) {
        // ユーザーテーブルに存在しなければ登録する
        Firestore.instance.collection('users')
          .where('uid', isEqualTo: user.uid)
          .getDocuments()
          .then((ds) {
            if (ds.documents.isEmpty) {
              Firestore.instance.collection('users').document()
                .setData({
                  'uid': user.uid,
                  'nick_name': user.displayName,
                  'image_url': user.photoUrl
                });
            }
          });
        });
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
  }
}