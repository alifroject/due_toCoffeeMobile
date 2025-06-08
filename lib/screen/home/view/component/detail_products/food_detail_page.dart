import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the price
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDetailPage extends StatelessWidget {
  final String foodId;
  final String imageUrl;
  final String name;
  final String description;
  final int price;

  const FoodDetailPage({
    super.key,
    required this.foodId,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    // Format the price into Rupiah currency
    final priceFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    ).format(price);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Produk"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
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

            // Food Name
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),

            // Food Description
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Food Price
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

            // Button to Add Food to Cart
            ElevatedButton.icon(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  // User not logged in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in first')),
                  );
                  return;
                }

                try {
                  final userId = user.uid;

                  // Reference to the user's cart document
                  final cartDoc = FirebaseFirestore.instance
                      .collection('carts')
                      .doc(userId);

                  final cartSnapshot = await cartDoc.get();

                  // New food item to add
                  final newItem = {
                    'productId': foodId,
                    'name': name,
                    'price': price,
                    'quantity': 1,
                    'imageUrl': imageUrl, // ✅ Add this line
                  };

                  if (cartSnapshot.exists) {
                    // If cart already exists, update it
                    List items = cartSnapshot.data()?['items'] ?? [];

                    // Check if food item already exists in the cart
                    final index =
                        items.indexWhere((item) => item['foodId'] == foodId);

                    if (index >= 0) {
                      // If already exists, just increment the quantity
                      items[index]['quantity'] += 1;
                    } else {
                      // If not exists, add as new item
                      items.add(newItem);
                    }

                    await cartDoc.update({'items': items});
                  } else {
                    // If cart doesn't exist, create a new one
                    await cartDoc.set({
                      'userId': userId,
                      'items': [newItem],
                      'status': 'pending', // pending, completed, etc
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  }

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                } catch (e) {
                  // If any error occurs
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Add to Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
