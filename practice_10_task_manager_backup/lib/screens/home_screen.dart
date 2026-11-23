import 'package:flutter/material.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

class HomeScreen extends StatefulWidget {
  final TaskRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _priorityFilter = 'all';
  String _statusFilter = 'all';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _subtasksController = TextEditingController();
  final TextEditingController _newSubtaskController =
      TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtasksController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  List<Task> get _tasks {
    return widget.repository.getTasks(
      priority: _priorityFilter,
      isCompleted: _statusFilter == 'all' ? null : _statusFilter == 'completed',
    );
  }

  Future<void> _refresh() async {
    if (mounted) setState(() {});
  }

  Future<void> _showTaskDialog({Task? task}) async {
    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';
    _subtasksController.text = task?.subtasks.join('\n') ?? '';

    String priority = task?.priority ?? 'medium';
    DateTime dueDate =
        task?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(task == null ? 'Нова задача' : 'Редагування задачі'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Назва задачі',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введіть назву задачі';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Опис',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(
                          labelText: 'Пріоритет',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'low',
                            child: Text('Низький'),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text('Середній'),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Text('Високий'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => priority = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Дата виконання'),
                        subtitle: Text(_formatDate(dueDate)),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (selected != null && context.mounted) {
                            setDialogState(() {
                              dueDate = DateTime(
                                selected.year,
                                selected.month,
                                selected.day,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subtasksController,
                        decoration: const InputDecoration(
                          labelText: 'Підзадачі',
                          hintText: 'Кожну підзадачу з нового рядка',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Скасувати'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Зберегти'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      try {
        final subtasks = _subtasksController.text
            .split('\n')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();

        if (task == null) {
          await widget.repository.addTask(
            Task(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              dueDate: dueDate,
              priority: priority,
              subtasks: subtasks,
            ),
          );
        } else {
          task
            ..title = _titleController.text.trim()
            ..description = _descriptionController.text.trim()
            ..dueDate = dueDate
            ..priority = priority
            ..subtasks = subtasks;

          await widget.repository.updateTask(task);
        }

        await _refresh();
      } catch (error) {
        _showMessage(error.toString());
      }
    }
  }

  Future<void> _toggleTask(Task task) async {
    try {
      await widget.repository.toggleTaskCompletion(task);
      await _refresh();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити задачу?'),
        content: Text('Задачу "${task.title}" буде видалено.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.repository.deleteTask(task);
      await _refresh();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _addSubtask(Task task) async {
    _newSubtaskController.clear();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Нова підзадача'),
        content: TextField(
          controller: _newSubtaskController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Назва підзадачі'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                _newSubtaskController.text.trim(),
              );
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );

    if (value == null || value.trim().isEmpty || !mounted) return;

    try {
      await widget.repository.addSubtask(task, value);
      await _refresh();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _removeSubtask(Task task, int index) async {
    try {
      await widget.repository.removeSubtask(task, index);
      await _refresh();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _priorityName(String priority) {
    switch (priority) {
      case 'low':
        return 'Низький';
      case 'high':
        return 'Високий';
      default:
        return 'Середній';
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'high':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  Widget _buildTaskCard(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );

    final isOverdue = !task.isCompleted && taskDate.isBefore(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => _toggleTask(task),
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showTaskDialog(task: task);
                    } else if (value == 'delete') {
                      _deleteTask(task);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Редагувати')),
                    PopupMenuItem(value: 'delete', child: Text('Видалити')),
                  ],
                ),
              ],
            ),
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(task.description),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Chip(
                    label: Text(_priorityName(task.priority)),
                    backgroundColor: _priorityColor(task.priority)
                        .withValues(alpha: 0.12),
                    labelStyle: TextStyle(color: _priorityColor(task.priority)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 15),
                    label: Text(_formatDate(task.dueDate)),
                  ),
                  if (isOverdue)
                    const Chip(
                      avatar: Icon(
                        Icons.warning_amber,
                        size: 15,
                        color: Colors.red,
                      ),
                      label: Text('Прострочено'),
                    ),
                ],
              ),
            ),
            if (task.subtasks.isNotEmpty) ...[
              const Divider(),
              ...task.subtasks.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.value)),
                      IconButton(
                        tooltip: 'Видалити підзадачу',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _removeSubtask(task, entry.key);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _addSubtask(task),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Додати підзадачу'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Менеджер завдань',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _priorityFilter,
                  decoration: const InputDecoration(
                    labelText: 'Фільтр за пріоритетом',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Усі пріоритети'),
                    ),
                    DropdownMenuItem(value: 'low', child: Text('Низький')),
                    DropdownMenuItem(value: 'medium', child: Text('Середній')),
                    DropdownMenuItem(value: 'high', child: Text('Високий')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priorityFilter = value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'all',
                      label: Text('Усі'),
                      icon: Icon(Icons.list),
                    ),
                    ButtonSegment(
                      value: 'incomplete',
                      label: Text('Активні'),
                      icon: Icon(Icons.pending_actions),
                    ),
                    ButtonSegment(
                      value: 'completed',
                      label: Text('Виконані'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                  ],
                  selected: {_statusFilter},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _statusFilter = selection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Задачі: ${tasks.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showTaskDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Нова задача'),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Задач поки немає',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Створіть першу задачу',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        tooltip: 'Створити задачу',
        child: const Icon(Icons.add),
      ),
    );
  }
}
