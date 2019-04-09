import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:miicha_app/screen/login_page.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';

class HomePageDrawer extends StatefulWidget {
  @override
  _HomePageDrawerState createState() => _HomePageDrawerState();
}

class _HomePageDrawerState extends State<HomePageDrawer> {
  AuthenticationBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<AuthenticationBloc>(context)
      ..getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: bloc.currentUser,
      initialData: bloc.currentUser.value,
      builder: (context, snapshot) {
        return snapshot.data == null
        ? _buildLogoutStateDrawer()
        : _buildLoginStateDrawer(snapshot.data);
      }
    );
  }

  Widget _buildLogoutStateDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: const Text('ログインしていません'),
            decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: const Text('ログイン'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
              },
            ),
        ],),
    );
  }

  Widget _buildLoginStateDrawer(FirebaseUser user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: const Text('ログインしています'),
            decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: const Text('ログアウト'),
              onTap: () {
                bloc.showConfirmSignOutDialog(context);
              },
            ),
        ],),
    );
  }
}