import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationBloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _userController = BehaviorSubject<FirebaseUser>(sync: true);
  ValueObservable<FirebaseUser> get currentUser => _userController;

  void handleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = await _auth.signInWithCredential(credential);
    _userController.add(user);
  }

  void getCurrentUser() {
    _auth.currentUser().then(_userController.add);
  }

  void signOut() {
    _auth.signOut().then((_) {
      _googleSignIn.signOut();
      _userController.add(null);
    }).catchError(print);
  }

  void dispose() {
    _userController.close();
  }
}

class LoginPage extends StatefulWidget {
  AuthenticationBloc bloc = AuthenticationBloc();

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    widget.bloc.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Container(
        child: StreamBuilder<FirebaseUser>(
          stream: widget.bloc.currentUser,
          initialData: widget.bloc.currentUser.value,
          builder: (context, snapshot) {
            return snapshot.data == null 
            ? _buildGoogleSignInButton() 
            : _userInfoScreen(snapshot.data);
          }),
      ),
    );
  }

  Widget _userInfoScreen(FirebaseUser _user) {
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
                  widget.bloc.signOut();
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
            widget.bloc.handleSignIn(); 
          },
        )),
      ],
    );
  }
}
