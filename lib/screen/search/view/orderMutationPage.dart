import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryMutationPage extends StatefulWidget {
  const HistoryMutationPage({super.key});

  @override
  State<HistoryMutationPage> createState() => _HistoryMutationPageState();
}

class _HistoryMutationPageState extends State<HistoryMutationPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime? fromDate;
  DateTime? toDate;
  String statusFilter = 'both';
  List<Map<String, dynamic>> _transactions = [];

  void _pickDateRange() async {
    final today = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: today.subtract(const Duration(days: 7)),
      end: today,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 31)),
      lastDate: today,
      initialDateRange: initialDateRange,
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
      _fetchFilteredTransactions();
    }
  }

  Future<void> _fetchFilteredTransactions() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not authenticated");
      return;
    }

    Query query = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'paid');

    final snapshot = await query.get();
    final docs =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    List<Map<String, dynamic>> filtered = docs.where((doc) {
      final queueStatus = doc['queue_number_status'] ?? '';

      if (statusFilter != 'both' && queueStatus != statusFilter) {
        return false;
      }

      if (fromDate != null && toDate != null) {
        final createdAt = doc['created_at'];
        if (createdAt is Timestamp) {
          final dt = createdAt.toDate();
          return dt.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
              dt.isBefore(toDate!.add(const Duration(days: 1)));
        } else {
          return false;
        }
      }
      return true;
    }).toList();

    setState(() {
      _transactions = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFilteredTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Date Picker
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDateRange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 20, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    fromDate != null && toDate != null
                                        ? "${DateFormat('yyyy-MM-dd').format(fromDate!)} - ${DateFormat('yyyy-MM-dd').format(toDate!)}"
                                        : "select_date_range".tr(),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Status Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: statusFilter,
                            underline: Container(),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(
                                  value: 'both', child: Text("both".tr())),
                              DropdownMenuItem(
                                  value: 'picked up',
                                  child: Text("picked_up".tr())),
                              DropdownMenuItem(
                                  value: 'expired',
                                  child: Text("expired".tr())),
                            ],
                            onChanged: (value) {
                              setState(() {
                                statusFilter = value!;
                              });
                              _fetchFilteredTransactions();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Result List
          Expanded(
            child: _transactions.isEmpty
                ? Center(child: Text("No transactions found.".tr()))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final txn = _transactions[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long,
                                color: Colors.blueAccent, size: 28),
                          ),
                          title: Text(
                            "Order ID: ${txn['order_id'] ?? '-'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Status: ${txn['queue_number_status'] ?? '-'}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
