import 'package:flutter/material.dart';

class CartItem extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;
  final int quantity;

  const CartItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.quantity = 1,
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
  }

  void decreaseQuantity() {
    if (currentQuantity > 1) {
      setState(() {
        currentQuantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: ClipRRect(
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
        title: Text(widget.title),
        subtitle: Text(widget.price),
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
