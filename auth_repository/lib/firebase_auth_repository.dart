import 'package:auth_repository/auth_exception.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:auth_repository/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository(this._auth);

  @override
  Future<void> loginWithEmailAndPassword(String email, String password) {
    return _doAuth(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  @override
  Future<void> loginWithFacebook() {
    return _doAuth(() async {
      // TODO: implement loginWithFacebook
    });
  }

  @override
  Future<void> loginWithGoogle() {
    return _doAuth(() async {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await _auth.signInWithCredential(credential);
    });
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return;
    } on FirebaseAuthException catch (e) {
      _rethrowException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> registerWithEmailAndPassword(String email, String password) {
    return _doAuth(() async {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    });
  }

  Future<void> _doAuth(Function authMethod) async {
    try {
      await authMethod();
      return;
    } on FirebaseAuthException catch (e) {
      _rethrowException(e);
    } catch (e) {
      rethrow;
    }
  }

  _rethrowException(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        throw AuthPasswordException(Strings.validationInvalidPassword);
      case 'invalid-email':
        throw AuthEmailException(Strings.invalidEmail);
      case 'user-not-found':
        throw AuthEmailException(Strings.validationUserNotFound);
      case 'weak-password':
        throw AuthPasswordException(Strings.invalidPasswordWeak);
      case 'email-already-in-use':
        throw AuthEmailException(Strings.validationEmailInUse);
      case 'too-many-requests':
        throw AuthNetworkException(Strings.errorToManyRequest);
      case 'network-request-failed':
        throw AuthNetworkException(Strings.errorCheckConnection);
      case 'account-exists-with-different-credential':
        throw AuthException(Strings.errorAccountExistsDiferentCredentials);
      default:
        throw AuthException(e.message);
    }
  }
}
