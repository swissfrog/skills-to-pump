import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/life_store.dart';
import '../models/life_models.dart';
import '../services/premium_service.dart';
import '../widgets/ad_widgets.dart';
import 'task_detail_screen.dart';
import 'event_detail_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showCompletion(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Task completed', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: LN.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();
    final premium = PremiumService();
    
    // Show loading while store initializes
    if (!store.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final nextTask = store.nextTask;
        final todayTasks = store.todayTasks.take(3).toList();

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: LN.bg,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumUpgradeScreen())),
                    icon: Icon(Icons.star, color: premium.isPremium ? LN.highlight : LN.label3),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    children: [
                      Image.asset('assets/images/logo.jpg', width: 28, height: 28),
                      const SizedBox(width: 8),
                      Text('LifeNav', style: LN.h2.copyWith(fontSize: 22)),
                    ],
                  ),
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    if (nextTask != null) ...[
                      Text('NEXT IMPORTANT STEP', style: LN.label),
                      const SizedBox(height: 12),
                      _HeroTaskCard(
                        task: nextTask, 
                        onDone: () {
                          store.updateTaskStatus(nextTask.id, TaskStatus.completed);
                          _showCompletion(context);
                        }
                      ),
                      const SizedBox(height: 32),
                    ],

                    const AdBanner(),

                    if (todayTasks.isNotEmpty) ...[
                      Text('TODAY', style: LN.label),
                      const SizedBox(height: 12),
                      ...todayTasks.map((t) => _SmallTaskTile(
                        task: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t)),
                        ),
                      )),
                      const SizedBox(height: 32),
                    ],

                    Text('CHOOSE A JOURNEY', style: LN.label),
                    const SizedBox(height: 12),
                    _EventGrid(store: store),
                    
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroTaskCard extends StatelessWidget {
  final LifeTask task;
  final VoidCallback onDone;
  const _HeroTaskCard({required this.task, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LN.primary,
        borderRadius: LN.r24,
        boxShadow: LN.shadow(LN.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              IconButton(
                onPressed: onDone,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 32),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(task.title, style: LN.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(task.explanation, 
            style: LN.bodySmall.copyWith(color: Colors.white70),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: LN.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View Guide'),
          )
        ],
      ),
    );
  }
}

class _SmallTaskTile extends StatelessWidget {
  final LifeTask task;
  final VoidCallback onTap;
  const _SmallTaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: LN.surface, borderRadius: LN.r16),
        child: Row(
          children: [
            const Icon(Icons.radio_button_off, color: LN.label2, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(task.title, style: LN.body.copyWith(fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: LN.label3),
          ],
        ),
      ),
    );
  }
}

class _EventGrid extends StatelessWidget {
  final LifeStore store;
  const _EventGrid({required this.store});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _EventButton(store: store, type: LifeEventType.move, icon: Icons.home_outlined),
        _EventButton(store: store, type: LifeEventType.newJob, icon: Icons.work_outline),
        _EventButton(store: store, type: LifeEventType.taxYear, icon: Icons.description_outlined),
        _EventButton(store: store, type: LifeEventType.buyCar, icon: Icons.directions_car_outlined),
      ],
    );
  }
}

class _EventButton extends StatelessWidget {
  final LifeStore store;
  final LifeEventType type;
  final IconData icon;
  const _EventButton({required this.store, required this.type, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isActive = store.hasEvent(type);

    return GestureDetector(
      onTap: () {
        if (isActive) {
          final event = store.events.firstWhere((e) => e.type == type);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          );
        } else {
          final event = store.startEvent(type);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${type.label} gestartet!'), behavior: SnackBarBehavior.floating),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(color: LN.surface2, borderRadius: LN.r16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: LN.primary),
            const SizedBox(height: 8),
            Text(type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
