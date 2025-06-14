import 'package:flutter/material.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const zigzagHeight = 10.0;
    const zigzagWidth = 20.0;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - zigzagHeight);

    double x = 0;
    bool isZig = true;

    while (x < size.width) {
      x += zigzagWidth / 2;
      path.lineTo(x, isZig ? size.height : size.height - zigzagHeight);
      isZig = !isZig;
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(
            fontFamily: 'Inika',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF210F0F),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carts')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Cart is empty.'));
          }

          final items = (snapshot.data!.docs.first.data()
                      as Map<String, dynamic>)['items']
                  ?.cast<Map<String, dynamic>>() ??
              [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItem(
                      imageUrl: item['imageUrl'] ?? '',
                      title: item['name'] ?? 'No name',
                      price: item['price'] ?? 0,
                      quantity: item['quantity'] ?? 1,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              content: const Text(
                                "Are you sure you want to delete this item?",
                                textAlign: TextAlign.center,
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Yes",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId == null) return;

                          final cartRef = FirebaseFirestore.instance
                              .collection('carts')
                              .doc(userId);
                          final cartDoc = await cartRef.get();
                          final cartData = cartDoc.data();

                          if (cartData == null) return;

                          List items = cartData['items'];
                          items.removeWhere(
                              (cartItem) => cartItem['name'] == item['name']);
                          await cartRef.update({'items': items});
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ClipPath(
                  clipper: ZigZagClipper(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF8D6E63), // nice coffee-like brown
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inika',
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(
                            items.fold(
                                0,
                                (sum, item) =>
                                    sum +
                                    ((item['price'] ?? 0) *
                                        (item['quantity'] ?? 1))),
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inika',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    final userData = userDoc.data();

                    if (userData == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User data not found')),
                      );
                      return;
                    }

                    double totalAmount = 0;
                    for (var item in items) {
                      double price = (item['price'] ?? 0).toDouble();
                      int quantity = (item['quantity'] ?? 1);
                      totalAmount += price * quantity;
                    }

                    String cartId = snapshot.data!.docs.first.id;

                    Map<String, double> userLocationMap = {
                      'latitude': 0.0,
                      'longitude': 0.0
                    };

                    showLocationCheckPopup(
                      context,
                      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
                      amount: totalAmount.toInt(),
                      cartId: cartId,
                      userName: userData['name'] ?? 'No Name',
                      userPhone: userData['phone'] ?? 'No Phone',
                      userEmail: user.email ?? 'No Email',
                      userId: user.uid,
                      items: items,
                      location: userLocationMap,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF620404),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inika',
                      color: Color(0xFFDAC5C5),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
