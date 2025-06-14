import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

final formatCurrency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

class TransactionDetailPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const TransactionDetailPage({
    Key? key,
    required this.orderId,
    required this.data,
  }) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

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

class _TransactionDetailPageState extends State<TransactionDetailPage> {
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
    String display = status.toLowerCase() == 'settlement' || status == 'paid'
        ? 'Payment Received'
        : status;
    Color color = display == 'Payment Received' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(display,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

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

  Widget _buildQRorExpired(Map<String, dynamic> data) {
    final status = data['queue_number_status']?.toString().toLowerCase();
    final queueNumber = data['queue_number']?.toString().toLowerCase();

    if (status == 'waiting') {
      return Column(
        children: [
          Text(
            'Queue No: $queueNumber',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("📲 Show this QR Code at the counter"),
          const SizedBox(height: 10),
          QrImageView(
            data: widget.orderId,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ],
      );
    } else if (status == 'expired') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "❌ QR Expired",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _cafeRulesWidget(data),
        ],
      );
    } else if (status == 'picked up') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Box utama
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: const [
                      SizedBox(height: 40), // ruang buat icon atas
                      Text(
                        "Your order has been picked up.\nThank you!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon di luar box
                Positioned(
                  top: -30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text("✅", style: TextStyle(fontSize: 48)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _cafeRulesWidget(data),
        ],
      );
    } else if (status == null || (status != 'expired' && status != 'waiting')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Box utama
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.brown[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: const [
                      SizedBox(height: 40), // supaya ada ruang buat icon atas
                      Text(
                        "You will be given a queue number\nuntil your order is ready for pickup",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Icon di luar box
                Positioned(
                  top: -30, // jarak icon dari box
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text("⏳", style: TextStyle(fontSize: 48)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _cafeRulesWidget(data),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("Order is Already Picked Up",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          _cafeRulesWidget(data),
        ],
      );
    }
  }

  Widget _cafeRulesWidget(Map<String, dynamic> data) {
    final status = data['queue_number_status']?.toString().toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("⚠️ Status Order Anda",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          const SizedBox(height: 8),
          if (status == 'expired') ...[
            const Text(
                "❌ Order Anda telah *expired* karena tidak diambil dalam waktu 30 menit setelah status 'Ready For PickUp'.",
                style: TextStyle(color: Colors.red)),
            const SizedBox(height: 4),
            const Text(
                "• Pesanan yang sudah expired tidak dapat diambil lagi."),
            const SizedBox(height: 4),
            const Text(
                "• Mohon melakukan pemesanan ulang jika masih ingin menikmati produk kami."),
          ] else if (status == 'picked up') ...[
            const Text(
                "✅ Order Anda sudah *diambil* oleh Anda atau pihak yang berwenang.",
                style: TextStyle(color: Colors.green)),
            const SizedBox(height: 4),
            const Text(
                "• Terima kasih telah berkunjung dan semoga Anda puas dengan pesanan Anda."),
            const SizedBox(height: 4),
            const Text(
                "• Jika ada keluhan atau masalah, silakan hubungi customer service kami."),
          ],
          const SizedBox(height: 12),
          const Text("📜 Aturan Cafe",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              "• Tunjukkan QR Code atau Orderan mu saat mengambil pesanan."),
          const SizedBox(height: 4),
          const Text(
              "• Pesanan akan hangus jika tidak diambil dalam 30 menit setelah status 'Ready For PickUp'."),
          const SizedBox(height: 4),
          const Text("• Dilarang merokok di area cafe."),
          const SizedBox(height: 4),
          const Text("• Jaga kebersihan dan kenyamanan bersama."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data()!;
        final timestamp = data['created_at']?.toDate();
        final queueStatus = data['queue_status'] ?? {};
        final itemList = data['items'] ?? [];

        return FutureBuilder<Map<String, dynamic>>(
          future: fetchItemDetails(itemList),
          builder: (context, itemSnapshot) {
            if (!itemSnapshot.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            final itemData = itemSnapshot.data!;

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
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/coffee_Logo.png',
                        height: 140,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Transaction Info
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _row("Amount",
                                formatCurrency.format(data['amount'])),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text("Status:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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

                    // Order Progress
                    const Text(
                      "Order Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStep("Order Received",
                                  queueStatus['accepted'] == true, true),
                              const SizedBox(width: 8),
                              _buildStep("In Progress",
                                  queueStatus['in_progress'] == true, true),
                              const SizedBox(width: 8),
                              _buildStep("Almost Ready",
                                  queueStatus['almost_ready'] == true, true),
                              const SizedBox(width: 8),
                              _buildStep(
                                  "Ready For PickUp",
                                  queueStatus['ready_for_pickup'] == true,
                                  true),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // kalau sebelumnya kamu pakai ini
                      children: [
                        // ...
                        Center(child: _buildQRorExpired(data)),
                        const SizedBox(height: 30),
                        // ...
                      ],
                    ),

                    // Items Purchased
                    const Text(
                      "Items Purchased",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Divider(thickness: 1.2, color: Colors.grey[400]),
                    const SizedBox(height: 10),

                    ...itemList.map<Widget>((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item['imageUrl'] != null
                                    ? Image.network(
                                        item['imageUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? "Unknown Item",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text("Qty: ${item['quantity']}"),
                                        const SizedBox(width: 16),
                                        Text(
                                          "Rp ${formatCurrency.format(item['price'])}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.receipt_long,
                                  color: Colors.blueAccent),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
