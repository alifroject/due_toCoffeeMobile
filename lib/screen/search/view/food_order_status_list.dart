import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_detail_page.dart';
import './components/food_waste_main.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodOrderStatusList extends StatefulWidget {
  const FoodOrderStatusList({super.key});

  @override
  State<FoodOrderStatusList> createState() => _FoodOrderStatusListState();
}

class _FoodOrderStatusListState extends State<FoodOrderStatusList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _orders = [];
  int pickedUpCount = 0;
  int expiredCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not authenticated");
      return;
    }

    // Get today's date range
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

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
          'queue_number_status': data['queue_number_status'] ?? '',
          'created_at': data['created_at'],
          'item_details': data['item_details'] ?? [],
          'gross_amount': data['gross_amount'],
          'status': data['status'],
          'order_id': data['order_id'],
        };
      }).toList();

      int picked = orders
          .where((order) => order['queue_number_status'] == 'picked up')
          .length;
      int expired = orders
          .where((order) => order['queue_number_status'] == 'expired')
          .length;

      setState(() {
        _orders = orders;
        pickedUpCount = picked;
        expiredCount = expired;
      });
    });
  }

  Widget _buildStep(String label, bool isActive, bool isCompleted) {
    IconData statusIcon;
    switch (label) {
      case "Order Received":
        statusIcon = Icons.check_circle;
        break;
      case "In Progress":
        statusIcon = Icons.restaurant_menu;
        break;
      case "Almost Ready":
        statusIcon = Icons.hourglass_bottom;
        break;
      case "Ready for Pickup":
        statusIcon = Icons.shopping_bag;
        break;
      default:
        statusIcon = Icons.info_outline;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isActive ? Colors.green : Colors.grey,
                    child: Icon(
                      statusIcon,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (isCompleted)
                    const Positioned(
                      right: -2,
                      top: -2,
                      child: Icon(
                        Icons.check_circle,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
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

  Widget _buildStatusSummary() {
    bool _showParagraph = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("picked_up".tr(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        pickedUpCount.toString(),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      Text("expired".tr(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        expiredCount.toString(),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("waste_food_overview".tr(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(
                      _showParagraph
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _showParagraph = !_showParagraph;
                      });
                    },
                  ),
                ],
              ),
              if (_showParagraph) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text("waste_food_paragraph".tr(),
                      style: TextStyle(fontSize: 14)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FoodWasteMain()),
                      );
                    },
                    child: Text("see_more_reference".tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_orders.isEmpty) {
      return Center(
        child: Text("no_orders_found".tr()),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusSummary(),
          ..._orders.map((order) {
            final status = order['queue_status'];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetailPage(
                      orderId: order['order_id'],
                      data: order,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${order['id']}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildStep(
                              "order_received"
                                  .tr(), // key name instead of hardcoded text
                              status['accepted'] == true,
                              status['accepted'] == true,
                            ),
                            const SizedBox(width: 8),
                            _buildStep(
                              "in_progress".tr(),
                              status['in_progress'] == true,
                              status['in_progress'] == true,
                            ),
                            const SizedBox(width: 8),
                            _buildStep(
                              "almost_ready".tr(),
                              status['almost_ready'] == true,
                              status['almost_ready'] == true,
                            ),
                            const SizedBox(width: 8),
                            _buildStep(
                              "ready_for_pickup".tr(),
                              status['ready_for_pickup'] == true,
                              status['ready_for_pickup'] == true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
