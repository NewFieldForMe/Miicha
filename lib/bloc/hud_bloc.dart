import 'package:rxdart/rxdart.dart';
import 'package:bloc_provider/bloc_provider.dart';

class HUDBloc implements Bloc {
  final _showHUDController = BehaviorSubject<bool>();
  ValueObservable<bool> get isShowHUD => _showHUDController;

  void showHUD() {
    _showHUDController.add(true);
  }

  void hideHUD() {
    _showHUDController.add(false);
  }

  @override
  void dispose() async { }
}