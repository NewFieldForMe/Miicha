import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';
import 'package:bloc_provider/bloc_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthenticationBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<AuthenticationBloc>(context)
      ..getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Container(
        child: StreamBuilder<FirebaseUser>(
          stream: bloc.currentUser,
          initialData: bloc.currentUser.value,
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
                  bloc.signOut();
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
            bloc.handleSignIn();
          },
        )),
      ],
    );
  }
}
