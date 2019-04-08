import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc_provider/bloc_provider.dart';

class AuthenticationBloc implements Bloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _userController = BehaviorSubject<FirebaseUser>();
  ValueObservable<FirebaseUser> get currentUser => _userController;

  AuthenticationBloc() {
    _auth.onAuthStateChanged.pipe(_userController);
  }

  void handleSignIn() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  void getCurrentUser() {
    _auth.currentUser();
  }

  void signOut() {
    _auth.signOut().then((_) {
      _googleSignIn.signOut();
    }).catchError(print);
  }

  @override
  void dispose() async{
    await _userController.close();
  }
}