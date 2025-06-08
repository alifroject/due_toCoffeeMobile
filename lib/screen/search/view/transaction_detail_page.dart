import 'package:flutter/material.dart';

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionDetailPage({super.key, required this.data});

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    String display = status.toLowerCase() == 'settlement' ? 'Payment Received' : status;
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

  // Copied from the list page
  Widget _buildStep(String label, bool isActive, bool isCompleted) {
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
              CircleAvatar(
                radius: 8,
                backgroundColor: isActive ? Colors.green : Colors.grey,
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_checked,
                  size: 12,
                  color: Colors.white,
                ),
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

  @override
  Widget build(BuildContext context) {
    final timestamp = data['created_at']?.toDate();
    final itemList = data['item_details'] ?? [];
    final queueStatus = data['queue_status'] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text("Transaction Details", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Image.asset(
                  'assets/images/coffee_Logo.png',
                  height: 140,
                ),
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row("Amount", "Rp ${data['gross_amount']}"),
                    Row(
                      children: [
                        const Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
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

            const SizedBox(height: 24),
            const Text("Order Progress", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStep(
                          "Order Received",
                          queueStatus['accepted'] == true,
                          queueStatus['accepted'] == true),
                      const SizedBox(width: 8),
                      _buildStep(
                          "In Progress",
                          queueStatus['in_progress'] == true,
                          queueStatus['in_progress'] == true),
                      const SizedBox(width: 8),
                      _buildStep(
                          "Almost Ready",
                          queueStatus['almost_ready'] == true,
                          queueStatus['almost_ready'] == true),
                      const SizedBox(width: 8),
                      _buildStep(
                          "Ready for Pickup",
                          queueStatus['ready_for_pickup'] == true,
                          queueStatus['ready_for_pickup'] == true),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Items Purchased", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...itemList.map<Widget>((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text("Qty: ${item['quantity']} - Rp ${item['price']}"),
                  trailing: const Icon(Icons.receipt_long, color: Colors.blue),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}
