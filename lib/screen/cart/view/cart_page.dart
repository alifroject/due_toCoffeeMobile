import 'package:flutter/material.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
                      price: NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(item['price'] ?? 0),
                      quantity: item['quantity'] ?? 1,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Get current user
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    // 2. Fetch user profile data from Firestore (adjust collection & field names as needed)
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

                    // 3. Calculate totalAmount from cart items
                    int totalAmount = 0;
                    for (var item in items) {
                      int price = (item['price'] ?? 0);
                      int quantity = (item['quantity'] ?? 1);
                      totalAmount += price * quantity;
                    }

                    // 4. Get cartId from snapshot docs
                    String cartId = snapshot.data!.docs.first.id;

                    // 5. Define dummy location, replace later with actual location if available
                    Map<String, double> userLocationMap = {
                      'latitude': 0.0,
                      'longitude': 0.0
                    };

                    // 6. Now call your function with all parameters defined
                    showLocationCheckPopup(
                      context,
                      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
                      amount: totalAmount,
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
