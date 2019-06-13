import 'package:flutter/material.dart';
import 'package:miicha_app/screen/login_page.dart';
import 'package:miicha_app/screen/home/home_drawer.dart';
import 'package:miicha_app/screen/post/post_page.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return bloc.authState == AuthenticationState.signOut
              ? LoginPage()
              : PostPage();
            }));
          },
          child: const Icon(Icons.add),
      ),
      body: _buildArticleList(),
    );
  }

  Widget _loader(BuildContext context, String url) {
    // return Container(height: 480,);
    return new Center(
      child: 
      Container(
        height: 200,
        )
    );
  }

  double calculateImageHeight({double imageWidth, double imageHeight}) {
    final _t = (imageHeight / imageWidth) * MediaQuery.of(context).size.width;
    return _t;
  }

  Widget _buildArticleList() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('articles').orderBy('createDateTime', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return const Text('読み込み中...');
          default:
          return ListView(
            children: snapshot.data.documents.map( (document) {
              return Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(child:
                      Align(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            fit: BoxFit.fitHeight,
                            height: calculateImageHeight(
                              imageWidth: (document['imageWidth'] as int).toDouble(),
                              imageHeight: (document['imageHeight'] as int).toDouble()),
                            placeholder: _loader,
                            imageUrl: document['imageUrl'] as String,
                          ),
                        )
                      )
                      ,height: calculateImageHeight(
                        imageWidth: (document['imageWidth'] as int).toDouble(),
                        imageHeight: (document['imageHeight'] as int).toDouble()
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(document['message'] as String)
                    )
                  ],
                )
              );
            }).toList(),
          );
        }
      }
    );
  }
}