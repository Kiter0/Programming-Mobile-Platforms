import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/journal_entry.dart';
import '../models/tag.dart';
import '../widgets/mood_selector.dart';

class EntryFormScreen extends StatefulWidget {
  final JournalEntry? entry;

  const EntryFormScreen({super.key, this.entry});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final DatabaseHelper _database = DatabaseHelper.instance;

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _contentController = TextEditingController();

  List<Tag> _availableTags = [];
  final Set<int> _selectedTagIds = {};

  String _selectedMood = 'Happy';
  bool _isSaving = false;

  bool get _isEditing => widget.entry != null;

  int get _wordCount {
    return JournalEntry.countWords(_contentController.text);
  }

  @override
  void initState() {
    super.initState();

    final entry = widget.entry;

    if (entry != null) {
      _titleController.text = entry.title;
      _contentController.text = entry.content;
      _selectedMood = entry.mood;

      for (final tag in entry.tags) {
        if (tag.id != null) {
          _selectedTagIds.add(tag.id!);
        }
      }
    }

    _loadTags();
    _contentController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    setState(() {});
  }

  Future<void> _loadTags() async {
    try {
      var tags = await _database.getTags();

      // Add starter tags if the database is empty.
      if (tags.isEmpty) {
        final starterTags = [
          Tag(name: 'Personal', color: '#567C68'),
          Tag(name: 'Work', color: '#6488B5'),
          Tag(name: 'Family', color: '#D68A79'),
          Tag(name: 'Travel', color: '#C29A54'),
          Tag(name: 'Ideas', color: '#9677B5'),
          Tag(name: 'Health', color: '#6A9B9B'),
        ];

        for (final tag in starterTags) {
          await _database.insertTag(tag);
        }

        tags = await _database.getTags();
      }

      if (!mounted) return;

      setState(() {
        _availableTags = tags;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load tags: $error')));
    }
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final selectedTags = _availableTags
          .where((tag) => _selectedTagIds.contains(tag.id))
          .toList();

      final now = DateTime.now();

      final entry = JournalEntry(
        id: widget.entry?.id,
        title: title,
        content: content,
        mood: _selectedMood,
        createdAt: widget.entry?.createdAt ?? now,
        updatedAt: now,
        isFavorite: widget.entry?.isFavorite ?? false,
        wordCount: _wordCount,
        tags: selectedTags,
      );

      if (_isEditing) {
        await _database.updateEntry(entry);
      } else {
        await _database.insertEntry(entry);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save entry: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Color _parseColor(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);

    if (value == null) return const Color(0xFF567C68);

    return Color(value <= 0xFFFFFF ? 0xFF000000 | value : value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit entry' : 'New entry'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveEntry,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Give your memory a title',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What happened today?',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Write your thoughts',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                minLines: 8,
                maxLines: 15,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Write about your day, thoughts and feelings...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_wordCount words',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF89948C),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
              const SizedBox(height: 12),
              MoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() => _selectedMood = mood);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Add tags',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26382E),
                ),
              ),
              const SizedBox(height: 12),
              if (_availableTags.isEmpty)
                const Text(
                  'Loading tags...',
                  style: TextStyle(color: Colors.grey),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTagIds.contains(tag.id);

                    final color = _parseColor(tag.color);

                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      selectedColor: color.withValues(alpha: 0.2),
                      checkmarkColor: color,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTagIds.add(tag.id!);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveEntry,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_isEditing ? 'Update entry' : 'Save entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
