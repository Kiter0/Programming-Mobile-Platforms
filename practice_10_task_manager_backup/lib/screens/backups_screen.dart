import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/backup_service.dart';

class BackupsScreen extends StatefulWidget {
  final BackupService backupService;
  final VoidCallback? onDataChanged;

  const BackupsScreen({
    super.key,
    required this.backupService,
    this.onDataChanged,
  });

  @override
  State<BackupsScreen> createState() => _BackupsScreenState();
}

class _BackupsScreenState extends State<BackupsScreen> {
  List<File> _backupFiles = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    try {
      final files = await widget.backupService.getBackupFiles();

      if (!mounted) return;

      setState(() {
        _backupFiles = files;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isProcessing = true);

    try {
      final file = await widget.backupService.exportBackup();

      if (!mounted) return;

      await _loadBackups();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Резервну копію створено: ${_fileName(file)}')),
      );
    } catch (error) {
      _showError('Не вдалося створити копію: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _importBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Імпорт резервної копії'),
          content: const Text(
            'Поточний список задач буде замінено даними '
            'з вибраного JSON-файлу. Продовжити?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Продовжити'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final importedCount = await widget.backupService.importBackup();

      if (!mounted) return;

      if (importedCount == null) {
        _showMessage('Імпорт скасовано.');
      } else {
        widget.onDataChanged?.call();
        _showMessage('Імпортовано задач: $importedCount');
      }
    } catch (error) {
      _showError('Помилка імпорту: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _deleteBackup(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Видалити резервну копію?'),
          content: Text('Файл ${_fileName(file)} буде видалено.'),
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
        );
      },
    );

    if (confirmed != true) return;

    try {
      await widget.backupService.deleteBackup(file);

      if (!mounted) return;

      await _loadBackups();

      if (!mounted) return;

      _showMessage('Резервну копію видалено.');
    } catch (error) {
      _showError('Не вдалося видалити копію: $error');
    }
  }

  String _fileName(File file) {
    return file.uri.pathSegments.last;
  }

  String _fileDate(File file) {
    return DateFormat('dd.MM.yyyy HH:mm').format(file.lastModifiedSync());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Резервні копії',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadBackups,
            tooltip: 'Оновити список',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBackups,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Керування резервними копіями',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Створюйте копії задач, відновлюйте '
                            'дані з JSON-файлів та керуйте '
                            'збереженими резервними копіями.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isProcessing ? null : _createBackup,
                              icon: const Icon(Icons.backup),
                              label: const Text('Створити backup'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isProcessing ? null : _importBackup,
                              icon: const Icon(Icons.file_open),
                              label: const Text('Імпортувати JSON'),
                            ),
                          ),
                          if (_isProcessing) ...[
                            const SizedBox(height: 16),
                            const LinearProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Збережені копії',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${_backupFiles.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_backupFiles.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Резервних копій поки немає',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Створіть першу копію за допомогою кнопки вище.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._backupFiles.map(
                      (file) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.insert_drive_file),
                          ),
                          title: Text(
                            _fileName(file),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Створено: ${_fileDate(file)}'),
                          trailing: IconButton(
                            tooltip: 'Видалити',
                            onPressed: _isProcessing
                                ? null
                                : () => _deleteBackup(file),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
