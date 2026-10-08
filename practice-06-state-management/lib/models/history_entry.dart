enum HistoryAction { increment, decrement, reset }

class HistoryEntry {
  final DateTime time;
  final HistoryAction action;
  final int before;
  final int after;

  const HistoryEntry({
    required this.time,
    required this.action,
    required this.before,
    required this.after,
  });

  String get actionLabel => switch (action) {
        HistoryAction.increment => 'Збільшення',
        HistoryAction.decrement => 'Зменшення',
        HistoryAction.reset => 'Скидання',
      };
}