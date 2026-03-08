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
                Text('Sven', style: LN.h2),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Life Score Card
          ListenableBuilder(
            listenable: p,
            builder: (context, _) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LN.surface,
                borderRadius: LN.r24,
                border: Border.all(color: LN.primary.withValues(alpha: 0.3)),
                boxShadow: LN.shadow(LN.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Life Score', style: LN.label),
                      Text(
                        '${p.lifeScore}',
                        style: LN.h1.copyWith(color: LN.primary, fontSize: 36),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.lifeScoreLevel,
                    style: LN.h3.copyWith(color: LN.label2, fontSize: 18),
                  ),
                  if (p.lifeScorePointsToNextLevel > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${p.lifeScorePointsToNextLevel} Punkte bis ${_nextLevelName(p)}',
                          style: LN.bodySmall.copyWith(color: LN.label3, fontSize: 11),
                        ),
                        Text(
                          '${(p.lifeScoreLevelProgress * 100).toInt()}%',
                          style: LN.bodySmall.copyWith(color: LN.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: p.lifeScoreLevelProgress,
                        minHeight: 8,
                        backgroundColor: LN.surface2,
                        valueColor: const AlwaysStoppedAnimation<Color>(LN.primary),
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Max Level erreicht!',
                        style: LN.bodySmall.copyWith(color: LN.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _Stat(label: 'Done', value: '${s.completedTasks.length}', color: LN.success),
              const SizedBox(width: 12),
              _Stat(label: 'Open', value: '${s.openTasks.length}', color: LN.highlight),
              const SizedBox(width: 12),
              _Stat(label: 'Events', value: '${s.events.length}', color: LN.label2),
            ],
          ),

          const SizedBox(height: 20),

          // Time Saved Card
          ListenableBuilder(
            listenable: p,
            builder: (context, _) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [LN.success.withValues(alpha: 0.2), LN.success.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: LN.r24,
                border: Border.all(color: LN.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LN.success.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.schedule, color: LN.success, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zeit gespart', style: LN.label),
                        const SizedBox(height: 4),
                        Text(
                          p.totalTimeSavedFormatted,
                          style: LN.h2.copyWith(color: LN.success),
                        ),
                        Text(
                          'Recherche & Bürokratie',
                          style: LN.bodySmall.copyWith(color: LN.label3, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

String _nextLevelName(UserProgress p) {
  const levels = ['Beginner', 'Organizer', 'Planner', 'Explorer', 'Life Navigator'];
  final current = p.lifeScoreLevel;
  final idx = levels.indexOf(current);
  return idx >= 0 && idx < levels.length - 1 ? levels[idx + 1] : 'Life Navigator';
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
