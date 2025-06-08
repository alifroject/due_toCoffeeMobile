import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_popup.dart'; // <-- import it

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return {
        'name': doc.data()?['name'] ?? user.displayName ?? 'No Name',
        'email': user.email ?? 'No Email',
        'photoUrl': user.photoURL,
      };
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final userData = snapshot.data!;

        return Stack(
          children: [
            // 👤 Avatar Center
            Center(
              child: CircleAvatar(
                radius: 30,
                backgroundImage: userData['photoUrl'] != null
                    ? NetworkImage(userData['photoUrl'] as String)
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
              ),
            ),

            // 🧑‍💼 Name + Email
            Positioned(
              left: 20,
              top: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['email'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // ✏️ Edit Button
            Positioned(
              right: 20,
              top: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible:
                        false, // full screen, no outside tap to close
                    builder: (BuildContext context) {
                      return const EditProfilePopup();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                icon: const Icon(Icons.edit, color: Colors.brown),
                label: const Text(
                  "Edit",
                  style: TextStyle(color: Colors.brown),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
