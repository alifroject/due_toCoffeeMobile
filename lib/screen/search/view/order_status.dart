import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_detail_page.dart'; // Import the TransactionDetailPage

class FoodOrderStatusList extends StatefulWidget {
  const FoodOrderStatusList({super.key});

  @override
  State<FoodOrderStatusList> createState() => _FoodOrderStatusListState();
}

class _FoodOrderStatusListState extends State<FoodOrderStatusList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Listen for real-time changes in the transactions collection
  void _fetchTransactions() {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not authenticated");
      return;
    }

    _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'queue_status': data['queue_status'] ?? {},
          // Add all required fields
          'created_at': data['created_at'],
          'item_details': data['item_details'] ?? [],
          'gross_amount': data['gross_amount'],
          'status': data['status'],
          'order_id': data['order_id'],
        };
      }).toList();

      setState(() {
        _orders = orders;
      });
    });
  }

  // Build each step with circular icons, checkmarks, and labels
  Widget _buildStep(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.all(4), // Smaller padding for a compact look
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6), // Smaller border radius
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 8, // Smaller radius for the icon
                backgroundColor: isActive ? Colors.green : Colors.grey,
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_checked,
                  size: 12, // Smaller icon size
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4), // Smaller space between icon and label
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Smaller text size
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Food Orders")),
      body: _orders.isEmpty
          ? const Center(child: Text("No Orders Found"))
          : SingleChildScrollView(
              // Making the page scrollable
              child: Column(
                children: _orders.map((order) {
                  final status = order['queue_status'];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the transaction detail page when clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionDetailPage(data: order),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8), // Smaller margin
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${order['id']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8), // Smaller gap
                            // Using a ListView to avoid overflow inside the Row
                            SingleChildScrollView(
                              // Scroll horizontally
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildStep(
                                      "Order Received",
                                      status['accepted'] == true,
                                      status['accepted'] == true),
                                  const SizedBox(
                                      width: 8), // Small gap between steps
                                  _buildStep(
                                      "In Progress",
                                      status['in_progress'] == true,
                                      status['in_progress'] == true),
                                  const SizedBox(
                                      width: 8), // Small gap between steps
                                  _buildStep(
                                      "Almost Ready",
                                      status['almost_ready'] == true,
                                      status['almost_ready'] == true),
                                  const SizedBox(
                                      width: 8), // Small gap between steps
                                  _buildStep(
                                      "Ready for Pickup",
                                      status['ready_for_pickup'] == true,
                                      status['ready_for_pickup'] == true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
