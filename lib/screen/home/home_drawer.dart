import 'package:flutter/material.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:miicha_app/screen/login_page.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';
import 'package:miicha_app/model/user.dart';

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
    return StreamBuilder<User>(
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

  Widget _buildLoginStateDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 32,
                  backgroundImage: NetworkImage(user.imageUrl),
                ),
                const SizedBox(height: 8),
                Text(user.nickName, style: TextStyle(color: Colors.white),),
              ],
            ),
            decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: const Text('プロフィール'),
              onTap: () { },
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