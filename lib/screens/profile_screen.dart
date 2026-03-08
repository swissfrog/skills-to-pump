import 'package:flutter/material.dart';
import '../services/life_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = LifeStore.getTasks();
    final completed = tasks.where((t) => t['completed'] == true).length;
    final pending = tasks.where((t) => t['completed'] != true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text('User', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 32),
            
            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat('Total', tasks.length.toString()),
                    _Stat('Done', completed.toString()),
                    _Stat('Pending', pending.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Menu
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.notifications), title: const Text('Notifications'), onTap: () {}),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.backup), title: const Text('Backup'), onTap: () {}),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}