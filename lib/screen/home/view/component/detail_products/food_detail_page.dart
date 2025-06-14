import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    bool itemAlreadyInCart = false;
    final userId = user.uid;
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartRef);

      if (!snapshot.exists) {
        final newItem = {
          'productId': foodId,
          'name': name,
          'price': price,
          'quantity': 1,
          'imageUrl': imageUrl,
        };

        transaction.set(cartRef, {
          'userId': userId,
          'items': [newItem],
          'totalQuantity': 1,
          'totalPrice': price,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> items = data['items'] ?? [];

        final index = items.indexWhere((item) => item['productId'] == foodId);

        if (index >= 0) {
          itemAlreadyInCart = true;
          return;
        }

        final newItem = {
          'productId': foodId,
          'name': name,
          'price': price,
          'quantity': 1,
          'imageUrl': imageUrl,
        };
        items.add(newItem);

        int totalQuantity = 0;
        double totalPrice = 0;

        for (var item in items) {
          final itemQuantity = ((item['quantity'] ?? 0) as num).toInt();
          final itemPrice = (item['price'] ?? 0).toDouble();

          totalQuantity += itemQuantity;
          totalPrice += itemQuantity * itemPrice;
        }

        transaction.update(cartRef, {
          'items': items,
          'totalQuantity': totalQuantity,
          'totalPrice': totalPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    if (itemAlreadyInCart) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Produk sudah ada di keranjang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Produk berhasil ditambahkan ke keranjang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => addToCart(context),
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text("Tambah ke Keranjang", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
