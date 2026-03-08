import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  final dynamic task;
  final void Function(dynamic)? onCompletedEvent;
  const TaskDetailScreen({
    super.key,
    required this.task,
    this.onCompletedEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: const Center(child: Text('Task Detail Screen')),
    );
  }
}