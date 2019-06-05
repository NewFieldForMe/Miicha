import 'dart:io';
import 'package:image/image.dart' as _im;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miicha_app/model/article.dart';
import 'package:miicha_app/ui_parts/hud.dart';
import 'package:miicha_app/bloc/hud_bloc.dart';
import 'package:miicha_app/bloc/authentication_bloc.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => new _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('記事を作る')),
      // GestureDetectorを使い、ソフトウェアキーボードが表示されている時に、
      // 入力領域以外をタップされたらキーボードを閉じる
      body: GestureDetector(
        onTap: () { FocusScope.of(context).requestFocus(FocusNode()); },
        child: Stack(
          children: <Widget>[
            PostForm(),
            HUD(),
          ],
        )
      )
    );
  }
}

class PostForm extends StatefulWidget {
  @override
  _PostFormState createState() => new _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final Article _data = Article();
  HUDBloc _hudBloc;
  AuthenticationBloc _authBloc;
  final FirebaseStorage _storage = FirebaseStorage(
    app: FirebaseApp.instance,
    storageBucket: 'gs://miicha-dev.appspot.com'
    );
  File _image;

  Future getImage(ImageSource source) async {
    final image = await ImagePicker.pickImage(
      source: source,
      maxHeight: 640,
      maxWidth: 640
      );

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();
    _hudBloc = BlocProvider.of<HUDBloc>(context);
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: _buildScrollableListForm()
    );
  }

  Widget _buildScrollableListForm() {
    return ListView(
      children: <Widget>[
        _buildImageView(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          _buildCameraButton(),
          _buildGalleryButton(),
        ],),
        _buildTextField(),
        _buildSubmitButton()
      ],
    );
  }

  Widget _buildImageView() {
    return Center(child: _image == null
    ? const Text('No image selected')
    : Image.file(_image)
    ,);
  }

  Widget _buildCameraButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
        child: Center(
          child: RaisedButton(
            color: Theme.of(context).primaryColorLight,
            child: const Text('撮影する'),
            onPressed: () => {
              getImage(ImageSource.camera)
            },
        ),)
    );
  }

  Widget _buildGalleryButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
        child: Center(
          child: RaisedButton(
            color: Theme.of(context).primaryColorLight,
            child: const Text('Galleryから選択する'),
            onPressed: () => {
              getImage(ImageSource.gallery)
            },
        ),)
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLength: 100,
        maxLines: null,
        onSaved: (value) {
          _data.message = value;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
        child: Center(
          child: RaisedButton(
            color: Theme.of(context).primaryColorLight,
            child: const Text('投稿する'),
            onPressed: _submit,
        ),)
    );
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _hudBloc.showHUD();
      final hash = _image.hashCode;
      final ref = _storage.ref().child('img').child('$hash.jpeg');
      final uploadTask = ref.putFile(_image);
      final imageData = _im.decodeImage(_image.readAsBytesSync());

      StorageTaskSnapshot storageTaskSnapshot;
      uploadTask.onComplete.then((snapshot) {
        storageTaskSnapshot = snapshot;
        return storageTaskSnapshot.ref.getDownloadURL();
      }).then((url) {
        _formKey.currentState.save(); // Save our form now.
        _data.createDateTime = DateTime.now();
        _authBloc.currentUser.listen((user) {
          Firestore.instance.collection('users').document(user.id)
            .collection('articles').document()
            .setData({
              'message': _data.message,
              'imageUrl': url,
              'imageHeight': imageData.height,
              'imageWidth': imageData.width,
              'createDateTime': _data.createDateTime
            }).then((_) {
              Navigator.of(context).pop();
            }).catchError((error) {
              _showSnackbarPostError();
              print(error);
            }).whenComplete(_hudBloc.hideHUD);
        });
      }).catchError((error) {
        _showSnackbarPostError();
        print(error);
      }).whenComplete(_hudBloc.hideHUD);
    }
  }

  void _showSnackbarPostError() {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: const Text('投稿に失敗しました。時間をおいて再度お試しください。'),)
    );
  }
}