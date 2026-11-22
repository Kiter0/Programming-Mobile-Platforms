
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/notes_file_manager.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NotesFileManager _fileManager = NotesFileManager();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введіть назву нотатки')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final oldNote = widget.note!;

        // Якщо назва змінилася, перейменовуємо файл.
        if (title != oldNote.title) {
          final renamedNote = await _fileManager.renameNote(
            oldNote.fileName,
            title,
          );

          await _fileManager.updateNote(
            renamedNote.fileName,
            content,
          );
        } else {
          await _fileManager.updateNote(
            oldNote.fileName,
            content,
          );
        }
      } else {
        await _fileManager.createNote(title, content);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка збереження: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагування нотатки' : 'Нова нотатка'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveNote,
            tooltip: 'Зберегти',
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Назва нотатки',
                hintText: 'Введіть назву',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Текст нотатки',
                  hintText: 'Почніть писати...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveNote,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'Збереження...' : 'Зберегти нотатку'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
