import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup with email + password and save extra details in Firestore
  Future<User?> signUpWithEmailPassword({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Save user info in Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "phone": phone,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }

  // Login
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
