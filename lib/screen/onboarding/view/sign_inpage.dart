import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<void> handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCred.user;
      if (user == null) return;

      final fcmToken = await FirebaseMessaging.instance.getToken();

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': user.photoURL ?? '',
          'role': 'customer',
          'isProfileComplete': false,
          'fcmToken': fcmToken, // tambahkan token di awal
        });
      } else {
        // kalau user udah ada, update fcmToken aja
        await userDoc.update({'fcmToken': fcmToken});
      }

      Navigator.pushReplacementNamed(context, '/entry');
    } catch (e) {
      debugPrint('Sign in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () =>
              handleSignIn(context), // Ensure the method is called correctly
        ),
      ),
    );
  }
}
