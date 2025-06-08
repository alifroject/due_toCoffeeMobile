import 'package:flutter/material.dart';
import '../widgets/queue_list_widget.dart';

class QueuePage extends StatelessWidget {
  final String currentUserQueue;

  const QueuePage({required this.currentUserQueue, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue List')),
      body: QueueListWidget(currentUserQueue: currentUserQueue),
    );
  }
}
