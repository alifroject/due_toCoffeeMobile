import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueListWidget extends StatelessWidget {
  final String currentUserQueue;

  const QueueListWidget({required this.currentUserQueue, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('queue_number_status', isEqualTo: 'waiting')
          .orderBy('queue_number')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final queueList = snapshot.data!.docs
            .map((doc) => doc['queue_number']?.toString() ?? '')
            .toList();

        if (queueList.isEmpty) {
          return Center(child: Text("No one is currently in the queue."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: queueList.length,
          itemBuilder: (context, index) {
            final queue = queueList[index];
            final isUserQueue = queue == currentUserQueue;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUserQueue ? Colors.redAccent : Colors.blue.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Queue #$queue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isUserQueue ? Colors.white : Colors.black87,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
