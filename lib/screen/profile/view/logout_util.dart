import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () async {
              Navigator.of(context).pop(); // close dialog

              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Sign out from Google
              await GoogleSignIn().signOut();

              // Optional: revoke token access (extra security)
              try {
                await GoogleSignIn().disconnect();
              } catch (_) {}

              // Navigate to the AuthChecker/root screen
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      );
    },
  );
}
