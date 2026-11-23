import 'package:flutter/material.dart';

import '../services/analytics_service.dart';
import '../widgets/statistics_card.dart';

class DashboardScreen extends StatelessWidget {
  final AnalyticsService analyticsService;

  const DashboardScreen({super.key, required this.analyticsService});

  @override
  Widget build(BuildContext context) {
    final statistics = analyticsService.getStatistics();

    final total = statistics['totalTasks'] as int;
    final completed = statistics['completedTasks'] as int;
    final incomplete = statistics['incompleteTasks'] as int;
    final overdue = statistics['overdueTasks'] as int;
    final percentage = statistics['completionPercentage'] as double;
    final averageDays = statistics['averageCompletionDays'] as double;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Аналітика',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Огляд продуктивності',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Статистика ваших завдань',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                StatisticsCard(
                  title: 'Усього задач',
                  value: '$total',
                  icon: Icons.task_alt,
                  color: Colors.indigo,
                ),
                StatisticsCard(
                  title: 'Виконано',
                  value: '$completed',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatisticsCard(
                  title: 'Не виконано',
                  value: '$incomplete',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                StatisticsCard(
                  title: 'Прострочено',
                  value: '$overdue',
                  icon: Icons.warning_amber,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Продуктивність',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'виконано',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Виконано $completed із $total задач',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            StatisticsCard(
              title: 'Середній час виконання',
              value: '${averageDays.toStringAsFixed(1)} дн.',
              icon: Icons.timer_outlined,
              color: Colors.teal,
              subtitle: 'Від створення до завершення задачі',
            ),
          ],
        ),
      ),
    );
  }
}
