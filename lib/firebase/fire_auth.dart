import 'package:firebase_auth/firebase_auth.dart';

class FireAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      user!
          .sendEmailVerification(); //Se manda email para la verificacion de 2 pasos
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      // if (user != null && !user.emailVerified) {
      //   await _auth.signOut();
      //   throw FirebaseAuthException(
      //     code: "Email-not-verified",
      //     message: "El email no se verifico",
      //   );
      // }
      return user;
    } catch (e) {
      return null;
    }
  }
}
