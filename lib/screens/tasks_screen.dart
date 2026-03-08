import 'package:flutter/material.dart';
import '../services/life_store.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    var tasks = LifeStore.getTasks();
    if (_filter == 'pending') tasks = tasks.where((t) => t['completed'] != true).toList();
    if (_filter == 'completed') tasks = tasks.where((t) => t['completed'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No tasks yet', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add a task'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                final task = tasks[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    value: task['completed'] == true,
                    onChanged: (v) {
                      task['completed'] = v;
                      LifeStore.updateTask(task['key'] ?? i, task);
                      setState(() {});
                    },
                    title: Text(task['title'] ?? 'Untitled'),
                    subtitle: Text(task['category'] ?? 'General'),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        LifeStore.deleteTask(task['key'] ?? i);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Task title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                LifeStore.addTask({'title': ctrl.text, 'completed': false, 'category': 'General'});
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}