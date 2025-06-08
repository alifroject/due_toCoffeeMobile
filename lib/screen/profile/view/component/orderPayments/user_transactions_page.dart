import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_detail_page.dart'; // Import the TransactionDetailPage
import 'package:intl/intl.dart';

class UserTransactionsPage extends StatelessWidget {
  const UserTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If user is not logged in, show an error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
      });
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Transactions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Black text for better contrast
          ),
        ),
        backgroundColor: Colors.white, // White background for the app bar
        elevation: 0,
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // Left arrow icon
          onPressed: () {
            Navigator.pop(context); // Pop the current screen and go back
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // If there's an error loading the transactions, show an error message
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading transactions"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading transactions
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Retrying...")),
                      );
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data = transactions[index].data() as Map<String, dynamic>;

              // Skip transactions with status "pending"
              if (data['status'] == 'pending') {
                return const SizedBox.shrink(); // Don't show this item
              }

              // If status is "settlement", change it to "Payment Completed"
              String statusText = data['status'];
              if (statusText == 'paid') {
                statusText = 'Payment Completed';
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8, // Add more shadow for depth
                  color: Colors.white, // White background for a cleaner look
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    title: Text(
                      NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
                          .format(data['amount']),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText, // Use updated status text
                          style: TextStyle(
                            color: statusText == 'Payment Completed'
                                ? Colors.green
                                : Colors.orange, // Color based on status
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.containsKey('created_at')
                              ? (data['created_at'] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .substring(0, 16)
                              : 'No timestamp',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.exit_to_app, // Sleek chevron icon
                        color: Colors.blue, // Matching icon color
                        size: 28, // Bigger icon for impact
                      ),
                      onPressed: () {
                        // Navigate to TransactionDetailPage with data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TransactionDetailPage(data: data),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
