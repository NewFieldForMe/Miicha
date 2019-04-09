import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miicha_app/screen/login_page.dart';
import 'package:miicha_app/screen/home/home_drawer.dart';
import 'package:miicha_app/screen/post/post_page.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';
import 'package:bloc_provider/bloc_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key,}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthenticationBloc bloc;
  final title = 'HOME';

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<AuthenticationBloc>(context)
      ..getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: HomePageDrawer(),
      /// Todo: flatingActionButtonをログイン状態で切り分けるのをもう少し綺麗に実装したい
      floatingActionButton: StreamBuilder<FirebaseUser>(
          stream: bloc.currentUser,
          initialData: bloc.currentUser.value,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }));
                },
                child: const Icon(Icons.add),
              );
            } else {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PostPage();
                  }));
                },
                child: const Icon(Icons.add),
              );
            }
          }),
      );
  }
}