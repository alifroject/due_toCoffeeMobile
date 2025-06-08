import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatCurrency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionDetailPage({super.key, required this.data});

  Future<Map<String, dynamic>> fetchItemDetails(List<dynamic> items) async {
    final collections = ['coffees', 'drinks', 'foods', 'pastries'];
    final Map<String, dynamic> result = {};

    for (var item in items) {
      final id = item['id'];
      for (var col in collections) {
        final doc =
            await FirebaseFirestore.instance.collection(col).doc(id).get();
        if (doc.exists) {
          result[id] = doc.data();
          result[id]!['category'] = col;
          break;
        }
      }
    }
    return result;
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    String display =
        status.toLowerCase() == 'settlement' ? 'Payment Received' : status;
    Color color = display == 'Payment Received' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        display,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = data['created_at']?.toDate();
    final itemList = data['items'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text("Transaction Details",
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchItemDetails(itemList),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final itemData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Centered Company Logo
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Image.asset(
                      'assets/images/coffee_Logo.png', // make sure the image is available in assets
                      height: 140,
                    ),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row("Amount", formatCurrency.format(data['amount'])),
                        Row(
                          children: [
                            const Text("Status:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            _statusBadge(data['status']),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _row("Order ID", data['order_id'] ?? '-'),
                        if (timestamp != null)
                          _row(
                            "Created At",
                            "${timestamp.day}/${timestamp.month}/${timestamp.year} "
                                "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Items Purchased",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                ...itemList.map<Widget>((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item != null && item['imageUrl'] != null
                            ? Image.network(item['imageUrl'],
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 50),
                      ),
                      title: Text(item['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          "Qty: ${item['quantity']} - Rp ${item['price']}"),
                      trailing:
                          const Icon(Icons.receipt_long, color: Colors.blue),
                    ),
                  );
                }).toList()
              ],
            ),
          );
        },
      ),
    );
  }
}
