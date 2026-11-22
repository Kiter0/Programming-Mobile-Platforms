import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/note.dart';
import '../services/notes_file_manager.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotesFileManager _fileManager = NotesFileManager();
  final TextEditingController _searchController = TextEditingController();

  List<Note> _notes = [];
  DateTime? _selectedDate;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = _searchController.text.trim();

      List<Note> notes = query.isEmpty
          ? await _fileManager.getAllNotes()
          : await _fileManager.searchNotes(query);

      if (_selectedDate != null) {
        notes = notes.where((note) {
          return note.lastModified.year == _selectedDate!.year &&
              note.lastModified.month == _selectedDate!.month &&
              note.lastModified.day == _selectedDate!.day;
        }).toList();
      }

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openEditor([Note? note]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );

    if (result == true && mounted) {
      await _loadNotes();
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
      helpText: 'Оберіть дату',
      cancelText: 'Скасувати',
      confirmText: 'Обрати',
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });

      await _loadNotes();
    }
  }

  Future<void> _clearDateFilter() async {
    setState(() {
      _selectedDate = null;
    });

    await _loadNotes();
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Видалити нотатку?'),
        content: Text(
          'Ви дійсно хочете видалити "${note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _fileManager.deleteNote(note.fileName);
      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нотатку видалено')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка видалення: $e')),
      );
    }
  }

  Future<void> _exportNote(Note note) async {
    try {
      final json = await _fileManager.exportNoteToJson(note.fileName);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Експорт нотатки у JSON'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: json),
                );

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON скопійовано в буфер обміну'),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Копіювати'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Закрити'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка експорту: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year о $hour:$minute';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes Б';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openEditor(note),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Дії',
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _openEditor(note);
                        case 'export':
                          _exportNote(note);
                        case 'delete':
                          _deleteNote(note);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Редагувати'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          leading: Icon(Icons.data_object),
                          title: Text('Експорт у JSON'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Видалити'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content.isEmpty ? 'Порожня нотатка' : note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 15),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _formatDate(note.lastModified),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Icon(Icons.insert_drive_file_outlined, size: 15),
                  const SizedBox(width: 5),
                  FutureBuilder<int>(
                    future: _fileManager.getNoteSize(note.fileName),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Помилка',
                          style: TextStyle(fontSize: 12),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 35,
                          height: 14,
                          child: LinearProgressIndicator(),
                        );
                      }

                      return Text(
                        _formatSize(snapshot.data!),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _searchController.text.isNotEmpty ||
        _selectedDate != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.note_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'Нотаток не знайдено'
                  : 'Поки що немає нотаток',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Спробуйте змінити пошуковий запит або фільтр'
                  : 'Натисніть кнопку нижче, щоб створити першу нотатку',
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  _clearDateFilter();
                },
                child: const Text('Скинути фільтри'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мої нотатки'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadNotes,
            tooltip: 'Оновити список',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadNotes(),
              decoration: InputDecoration(
                hintText: 'Пошук нотаток...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Очистити пошук',
                  onPressed: () {
                    _searchController.clear();
                    _loadNotes();
                  },
                  icon: const Icon(Icons.close),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _selectedDate == null
                        ? 'Фільтр за датою'
                        : '${_selectedDate!.day.toString().padLeft(2, '0')}.'
                            '${_selectedDate!.month.toString().padLeft(2, '0')}.'
                            '${_selectedDate!.year}',
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _clearDateFilter,
                    tooltip: 'Скинути дату',
                    icon: const Icon(Icons.filter_alt_off),
                  ),
                ],
                const Spacer(),
                Text(
                  'Нотаток: ${_notes.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _loadNotes,
                                child: const Text('Спробувати ще раз'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _notes.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadNotes,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _notes.length,
                              itemBuilder: (context, index) {
                                return _buildNoteCard(_notes[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Нова нотатка'),
      ),
    );
  }
}
