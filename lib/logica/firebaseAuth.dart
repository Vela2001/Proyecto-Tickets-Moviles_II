
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e.code, e.message ?? ''));
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e.code, e.message ?? ''));
    }
  }

  String _handleError(String code, String message) {
    switch (code) {
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Cuenta deshabilitada';
      case 'user-not-found':
        return 'Usuario no registrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Correo ya está en uso';
      default:
        return message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
