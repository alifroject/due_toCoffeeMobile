import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoffeeDetailPage extends StatefulWidget {
  final String productId;

  const CoffeeDetailPage({super.key, required this.productId});

  @override
  State<CoffeeDetailPage> createState() => _CoffeeDetailPageState();
}

class _CoffeeDetailPageState extends State<CoffeeDetailPage> {
  late Future<DocumentSnapshot> _coffeeFuture;
  String? selectedOption = 'Hot'; // default value

  @override
  void initState() {
    super.initState();
    _coffeeFuture = FirebaseFirestore.instance
        .collection('coffees')
        .doc(widget.productId)
        .get();
  }

  Future<void> addToCart(Map<String, dynamic> coffeeData) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tipe minuman: Ice atau Hot')),
      );
      return;
    }

    final userId = user.uid;
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);

    bool itemAlreadyInCart = false;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartRef);

      if (!snapshot.exists) {
        // Cart not exists — create new one
        final newItem = {
          'productId': widget.productId,
          'name': coffeeData['name'],
          'basePrice': coffeeData['price'],
          'price': coffeeData['price'],
          'quantity': 1,
          'imageUrl': coffeeData['imageUrl'] ?? '',
          'type': selectedOption,
        };

        transaction.set(cartRef, {
          'userId': userId,
          'items': [newItem],
          'totalQuantity': 1,
          'totalPrice': coffeeData['price'],
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> items = data['items'] ?? [];

        final index = items.indexWhere((item) =>
            item['productId'] == widget.productId &&
            item['type'] == selectedOption);

        if (index >= 0) {
          // Already exists
          itemAlreadyInCart = true;
          return;
        }

        // Add new item
        final newItem = {
          'productId': widget.productId,
          'name': coffeeData['name'],
          'price': coffeeData['price'],
          'quantity': 1,
          'imageUrl': coffeeData['imageUrl'] ?? '',
          'type': selectedOption,
        };
        items.add(newItem);

        // Recalculate totals
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

    // after transaction
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
                Icon(
                  Icons.shopping_cart,
                  color: Colors.orange,
                  size: 48,
                ),
                SizedBox(height: 16),
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
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                SizedBox(height: 16),
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
    return FutureBuilder<DocumentSnapshot>(
      future: _coffeeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Produk tidak ditemukan')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] ?? '';
        final name = data['name'] ?? 'Nama tidak tersedia';
        final description = data['description'] ?? 'Deskripsi tidak tersedia';
        final price = data['price'] ?? 0;

        final priceFormatted =
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(price);

        return Scaffold(
          appBar: AppBar(
            title: Text(name),
            backgroundColor: Colors.brown[700],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(priceFormatted,
                        style:
                            TextStyle(fontSize: 18, color: Colors.green[800])),
                    const SizedBox(height: 12),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    const Divider(height: 32, thickness: 1),

                    const Text("Tipe Minuman:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedOption,
                      items: ['Hot', 'Ice'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    const SizedBox(
                        height: 100), // add extra space for the button
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => addToCart(data),
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text('Add to Cart',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
