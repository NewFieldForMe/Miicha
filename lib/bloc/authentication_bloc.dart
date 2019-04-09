import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_provider/bloc_provider.dart';

class AuthenticationBloc implements Bloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _userController = BehaviorSubject<FirebaseUser>();
  ValueObservable<FirebaseUser> get currentUser => _userController;

  AuthenticationBloc() {
    _auth.onAuthStateChanged.pipe(_userController);
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
  }
}