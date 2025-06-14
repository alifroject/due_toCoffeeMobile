import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CartItem extends StatefulWidget {
  final String imageUrl;
  final String title;
  final int price; // <-- raw price as int
  final int quantity;
  final VoidCallback onDelete;

  const CartItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.quantity = 1,
    required this.onDelete,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  late int currentQuantity;

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.quantity;
  }

  void increaseQuantity() {
    setState(() {
      currentQuantity++;
    });
    updateQuantityInFirestore(currentQuantity);
  }

  void decreaseQuantity() {
    if (currentQuantity > 1) {
      setState(() {
        currentQuantity--;
      });
      updateQuantityInFirestore(currentQuantity);
    }
  }

  void updateQuantityInFirestore(int newQuantity) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);
    final cartDoc = await cartRef.get();
    final cartData = cartDoc.data();

    if (cartData == null) return;

    List items = cartData['items'];

    for (var item in items) {
      if (item['name'] == widget.title) {
        item['quantity'] = newQuantity;
        // (optional): no need to store total price
      }
    }

    await cartRef.update({'items': items});
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = widget.price * currentQuantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ],
        ),
        title: Text(widget.title),
        subtitle: Text(
          NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
              .format(totalPrice),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
              onPressed: decreaseQuantity,
            ),
            Text('$currentQuantity', style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: increaseQuantity,
            ),
          ],
        ),
      ),
    );
  }
}
