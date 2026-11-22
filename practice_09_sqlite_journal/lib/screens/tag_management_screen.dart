
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tag.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Tag> _tags = [];
  bool _isLoading = true;

  static const List<String> _availableColors = [
    '#567C68',
    '#E57373',
    '#64B5F6',
    '#BA68C8',
    '#FFB74D',
    '#4DB6AC',
    '#F06292',
    '#7986CB',
    '#A1887F',
    '#90A4AE',
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _databaseHelper.getTags();

      if (!mounted) return;

      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Failed to load tags: $error');
    }
  }

  Color _parseColor(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showTagDialog({Tag? tag}) async {
    final isEditing = tag != null;

    final result = await showDialog<_TagFormResult>(
      context: context,
      builder: (_) => _TagDialog(
        initialName: tag?.name ?? '',
        initialColor: tag?.color ?? _availableColors.first,
        availableColors: _availableColors,
        parseColor: _parseColor,
      ),
    );

    if (result == null) return;

    try {
      if (isEditing) {
        await _databaseHelper.updateTag(
          Tag(
            id: tag.id,
            name: result.name,
            color: result.color,
            createdAt: tag.createdAt,
            usageCount: tag.usageCount,
          ),
        );
      } else {
        await _databaseHelper.insertTag(
          Tag(
            name: result.name,
            color: result.color,
          ),
        );
      }

      await _loadTags();

      if (mounted) {
        _showMessage(
          isEditing
              ? 'Tag updated successfully'
              : 'Tag created successfully',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Could not save tag. A tag with this name may already exist.',
        );
      }
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(
          'Are you sure you want to delete "${tag.name}"?\n\n'
          'This tag will also be removed from journal entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && tag.id != null) {
      try {
        await _databaseHelper.deleteTag(tag.id!);
        await _loadTags();

        if (mounted) {
          _showMessage('Tag deleted successfully');
        }
      } catch (error) {
        if (mounted) {
          _showMessage('Could not delete tag: $error');
        }
      }
    }
  }

  Widget _buildTagCard(Tag tag) {
    final tagColor = _parseColor(tag.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.label,
                color: tagColor,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tag.usageCount} '
                    '${tag.usageCount == 1 ? 'entry' : 'entries'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit tag',
              onPressed: () => _showTagDialog(tag: tag),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete tag',
              onPressed: () => _deleteTag(tag),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadTags,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tags.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.label_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tags yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first tag to organize journal entries.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => _showTagDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Create tag'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTags,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Your tags',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_tags.length} tags available',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ..._tags.map(_buildTagCard),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTagDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add tag'),
      ),
    );
  }
}

class _TagFormResult {
  final String name;
  final String color;

  const _TagFormResult({
    required this.name,
    required this.color,
  });
}

class _TagDialog extends StatefulWidget {
  final String initialName;
  final String initialColor;
  final List<String> availableColors;
  final Color Function(String) parseColor;

  const _TagDialog({
    required this.initialName,
    required this.initialColor,
    required this.availableColors,
    required this.parseColor,
  });

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  late final TextEditingController _controller;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    Navigator.pop(
      context,
      _TagFormResult(
        name: name,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName.isNotEmpty;

    return AlertDialog(
      title: Text(isEditing ? 'Edit tag' : 'Create new tag'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 30,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Tag name',
                hintText: 'Enter tag name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose color',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.availableColors.map((color) {
                final isSelected = _selectedColor == color;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.parseColor(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget
                    .parseColor(_selectedColor)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.label,
                    color: widget.parseColor(_selectedColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _controller.text.isEmpty
                        ? 'Tag preview'
                        : _controller.text,
                    style: TextStyle(
                      color: widget.parseColor(_selectedColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty ? null : _save,
          child: Text(isEditing ? 'Save changes' : 'Create'),
        ),
      ],
    );
  }
}
