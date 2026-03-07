import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/life_store.dart';
import '../services/user_progress.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = UserProgress();
    final s = LifeStore();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined))
      ]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          
          // User Info
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [LN.primary, Color(0xFF004BBD)]),
                    shape: BoxShape.circle,
                    boxShadow: LN.shadow(LN.primary),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 16),
                const Text('Sven', style: LN.h2),
                Text('Level ${p.level} Explorer', style: const TextStyle(color: LN.primary)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stats
          Row(
            children: [
              _Stat(label: 'Done', value: '${s.completedTasks.length}', color: LN.success),
              const SizedBox(width: 12),
              _Stat(label: 'Open', value: '${s.openTasks.length}', color: LN.highlight),
              const SizedBox(width: 12),
              _Stat(label: 'Events', value: '${s.events.length}', color: LN.info),
            ],
          ),

          const SizedBox(height: 32),

          Text('ACCOUNT', style: LN.label),
          const SizedBox(height: 12),
          _LinkTile(icon: Icons.notifications_outlined, title: 'Reminders'),
          _LinkTile(icon: Icons.lock_outline, title: 'Security'),
          _LinkTile(icon: Icons.info_outline, title: 'App Version v1.0.0'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value; final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: LN.surface, borderRadius: LN.r16),
        child: Column(
          children: [
            Text(value, style: LN.h3.copyWith(color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: LN.label3)),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon; final String title;
  const _LinkTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: LN.surface, borderRadius: LN.r16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: LN.label2),
          const SizedBox(width: 16),
          Text(title, style: LN.body.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: LN.label3),
        ],
      ),
    );
  }
}
