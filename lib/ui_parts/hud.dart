import 'package:flutter/material.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:miicha_app/bloc/hud_bloc.dart';

class HUD extends StatefulWidget {
  @override
  _HUDState createState() => new _HUDState();
}

class _HUDState extends State<HUD> {
  HUDBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HUDBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: bloc.isShowHUD,
      initialData: false,
      builder: (context, snapshot) {
        return snapshot.data == true
        ? _buildHUD()
        : Container();
      }
    );
  }

  Widget _buildHUD() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: const ModalBarrier(dismissible: false, color: Colors.grey,),
        ),
        Center(
          child: const CircularProgressIndicator(),
        )
      ],
    );
  }
}