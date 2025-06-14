import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PastryDetailPage extends StatelessWidget {
  final String pastryId;

  const PastryDetailPage({super.key, required this.pastryId});

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('pastries').doc(pastryId);

    return FutureBuilder<DocumentSnapshot>(
      future: docRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Product not found.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] ?? '';
        final name = data['name'] ?? 'No name';
        final description = data['description'] ?? '';
        final price = data['price'] ?? 0;

        final priceFormatted = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
        ).format(price);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Produk'),
            backgroundColor: const Color.fromARGB(255, 164, 99, 1),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  priceFormatted,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in first')),
                      );
                      return;
                    }

                    final userId = user.uid;
                    final cartDoc = FirebaseFirestore.instance
                        .collection('carts')
                        .doc(userId);

                    final cartSnapshot = await cartDoc.get();
                    final newItem = {
                      'productId': pastryId,
                      'name': name,
                      'price': price,
                      'quantity': 1,
                      'imageUrl': imageUrl,
                    };

                    if (cartSnapshot.exists) {
                      List items = cartSnapshot.data()?['items'] ?? [];
                      final index =
                          items.indexWhere((item) => item['name'] == name);

                      if (index >= 0) {
                        items[index]['quantity'] += 1;
                      } else {
                        items.add(newItem);
                      }

                      await cartDoc.update({'items': items});
                    } else {
                      await cartDoc.set({
                        'userId': userId,
                        'items': [newItem],
                        'status': 'pending',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Tambah ke Keranjang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
