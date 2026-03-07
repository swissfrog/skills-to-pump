import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final openTasks = store.openTasks;
        final completedTasks = store.completedTasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks', style: LN.h2),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: LN.primary,
              labelColor: LN.primary,
              unselectedLabelColor: LN.label3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Open (${openTasks.length})'),
                Tab(text: 'Done (${completedTasks.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _TaskList(tasks: openTasks, isCompleted: false),
              _TaskList(tasks: completedTasks, isCompleted: true),
            ],
          ),
        );
      },
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<LifeTask> tasks;
  final bool isCompleted;
  const _TaskList({required this.tasks, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isCompleted ? Icons.check_circle_outline : Icons.assignment_outlined, 
                 size: 64, color: LN.label3.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(isCompleted ? 'No completed tasks yet' : 'Everything done!', 
                 style: LN.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _TaskCard(task: tasks[i]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final LifeTask task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();
    final isDone = task.status == TaskStatus.completed;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LN.surface,
          borderRadius: LN.r24,
          border: Border.all(color: LN.divider),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isDone,
                activeColor: LN.success,
                shape: const CircleBorder(),
                onChanged: (v) {
                  store.updateTaskStatus(task.id, v! ? TaskStatus.completed : TaskStatus.open);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: LN.body.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? LN.label3 : LN.label1,
                    ),
                  ),
                  if (task.deadline != null && !isDone)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Due: ${task.deadline!.day}.${task.deadline!.month}.',
                        style: LN.label.copyWith(color: task.isOverdue ? LN.danger : LN.highlight),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: LN.label3),
          ],
        ),
      ),
    );
  }
}
