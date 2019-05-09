import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miicha_app/screen/image_picker/image_picker_page.dart';
import 'package:miicha_app/model/article.dart';

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
        child: PostForm(),
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
        _buildCameraButton(),
        _buildTextField(),
        _buildSubmitButton()
      ],
    );
  }

  Widget _buildCameraButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
        child: Center(
          child: RaisedButton(
            color: Theme.of(context).primaryColorLight,
            child: const Text('撮影する'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ImagePickerPage();
              }));
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
      _formKey.currentState.save(); // Save our form now.
      _data.createDateTime = DateTime.now();
      Firestore.instance.collection('articles').document()
        .setData({
          'message': _data.message,
          'createDateTime': _data.createDateTime
        });
    }
  }
}