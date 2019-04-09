import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';
import 'package:miicha_app/screen/home/home_page.dart';

void main() {
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
  enableFlutterDriverExtension();
  runApp(
    BlocProvider<AuthenticationBloc>(
      creator: (_context, _bag) => AuthenticationBloc(),
      child: MyApp(),
      )
    );
}

class MyApp extends StatelessWidget {
  final title = 'Miicha';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage()
    );
  }
}
