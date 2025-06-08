import 'package:flutter/material.dart';
import 'payment_result.dart'; // Ensure correct import
import 'package:intl/intl.dart'; // Add this import

class PaymentPage extends StatelessWidget {
  final PaymentResult paymentResult;

  const PaymentPage({Key? key, required this.paymentResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Receipt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 50),
                    const SizedBox(height: 8),
                    Text(
                      'Payment Successful',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (paymentResult.createdAt != null)
                      Text(
                        DateFormat('MMM dd, yyyy - HH:mm').format(paymentResult.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Information', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    _buildInfoRow('Order ID', paymentResult.orderId),
                    _buildInfoRow('Status', paymentResult.status.toUpperCase()),
                    if (paymentResult.paymentType != null)
                      _buildInfoRow('Payment Method', paymentResult.paymentType!),
                    if (paymentResult.bank != null)
                      _buildInfoRow('Bank', paymentResult.bank!),
                    if (paymentResult.vaNumber != null)
                      _buildInfoRow('VA Number', paymentResult.vaNumber!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Information', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    if (paymentResult.userName != null)
                      _buildInfoRow('Name', paymentResult.userName!),
                    if (paymentResult.userEmail != null)
                      _buildInfoRow('Email', paymentResult.userEmail!),
                    if (paymentResult.userPhone != null)
                      _buildInfoRow('Phone', paymentResult.userPhone!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items
            if (paymentResult.items != null && paymentResult.items!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Items', style: Theme.of(context).textTheme.titleMedium),
                      const Divider(),
                      ...paymentResult.items!.map((item) => _buildItemRow(item)),
                      const SizedBox(height: 8),
                      if (paymentResult.grossAmount != null)
                        _buildInfoRow(
                          'Total Amount',
                          'Rp${NumberFormat('#,##0').format(paymentResult.grossAmount)}',
                          isTotal: true,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          )),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }

  Widget _buildItemRow(Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rp${NumberFormat('#,##0').format(item.price)}',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}