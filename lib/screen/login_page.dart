import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// 現在ログインしているユーザー
  FirebaseUser _user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Container(
        child: _user == null ? _buildGoogleSignInButton() : _userInfoScreen(),
      ),
    );
  }

  Widget _userInfoScreen() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            maxRadius: 60,
            backgroundImage: NetworkImage(_user.photoUrl),
          ),
          const SizedBox(height: 24),
          Text(_user.displayName),
          const SizedBox(height: 8),
          Text(_user.email),
          const SizedBox(height: 32),
          RaisedButton(
            child: const Text('SignOut'),
            onPressed: (_showConfirmSignOutDialog),
          ),
          const SizedBox(height: 32),
        ],
      )
    ]);
  }

  // サインアウトの確認ダイアログを表示する
  void _showConfirmSignOutDialog() {
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
                  _auth.signOut().then((_) {
                    setState(() {
                      _googleSignIn.signOut();
                      _user = null;
                    });
                  }).catchError(print);
                },
              ),
            ],
          );
        });
  }

  /// GoogleLoginを実行するボタンのWidgetを作成する
  Widget _buildGoogleSignInButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
            child: RaisedButton(
          child: const Text('Google Sign In'),
          onPressed: () {
            _handleSignIn().then((user) {
              setState(() {
                _user = user;
              });
            }).catchError(print);
          },
        )),
      ],
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = await _auth.signInWithCredential(credential);
    print('signed in $user.displayName');
    return user;
  }
}
