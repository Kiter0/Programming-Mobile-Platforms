import '../repositories/task_repository.dart';

class AnalyticsService {
  final TaskRepository _repository;

  AnalyticsService(this._repository);

  // Загальна кількість задач.
  int get totalTasks => _repository.getAllTasks().length;

  // Кількість виконаних задач.
  int get completedTasks =>
      _repository.getAllTasks().where((task) => task.isCompleted).length;

  // Кількість невиконаних задач.
  int get incompleteTasks =>
      _repository.getAllTasks().where((task) => !task.isCompleted).length;

  // Кількість прострочених невиконаних задач.
  int get overdueTasks {
    final now = DateTime.now();

    return _repository.getAllTasks().where((task) {
      return !task.isCompleted && task.dueDate.isBefore(now);
    }).length;
  }

  // Відсоток виконання задач.
  double get completionPercentage {
    final total = totalTasks;

    if (total == 0) return 0;

    return completedTasks / total * 100;
  }

  // Середній час виконання задач у днях.
  double get averageCompletionDays {
    final completed = _repository
        .getAllTasks()
        .where((task) => task.isCompleted && task.completedAt != null)
        .toList();

    if (completed.isEmpty) return 0;

    final totalDuration = completed.fold<int>(0, (sum, task) {
      return sum + task.completedAt!.difference(task.createdAt).inSeconds;
    });

    final averageSeconds = totalDuration / completed.length;

    return averageSeconds / Duration.secondsPerDay;
  }

  // Отримання всієї статистики одним об'єктом.
  Map<String, dynamic> getStatistics() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'incompleteTasks': incompleteTasks,
      'overdueTasks': overdueTasks,
      'completionPercentage': completionPercentage,
      'averageCompletionDays': averageCompletionDays,
    };
  }
}
