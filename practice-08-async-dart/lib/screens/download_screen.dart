import 'dart:async';

import 'package:flutter/material.dart';

import '../models/download_file.dart';
import '../services/download_service.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final DownloadService _service = DownloadService();

  late Future<List<DownloadFile>> _filesFuture;

  List<DownloadFile> _files = [];
  final Map<int, Stream<double>> _streams = {};
  final Map<int, StreamSubscription<double>> _subscriptions = {};
  final Map<int, Completer<bool>> _completers = {};

  bool _batchRunning = false;
  String? _batchSummary;

  @override
  void initState() {
    super.initState();
    _filesFuture = _loadFiles();
  }

  Future<List<DownloadFile>> _loadFiles() async {
    final files = await _service.loadFiles().timeout(
      const Duration(seconds: 5),
    );

    if (!mounted) return files;

    setState(() {
      _files = files;
    });

    return files;
  }

  void _retryLoading() {
    setState(() {
      _files = [];
      _batchSummary = null;
      _filesFuture = _loadFiles();
    });
  }

  void _updateFile(int id, DownloadFile Function(DownloadFile) update) {
    if (!mounted) return;

    setState(() {
      final index = _files.indexWhere((file) => file.id == id);
      if (index != -1) {
        _files[index] = update(_files[index]);
      }
    });
  }

  Future<bool> _startDownload(int id) {
    final fileIndex = _files.indexWhere((file) => file.id == id);
    if (fileIndex == -1) return Future.value(false);

    final file = _files[fileIndex];
    if (file.status == DownloadStatus.completed) {
      return Future.value(true);
    }

    final existing = _completers[id];
    if (existing != null) return existing.future;

    final completer = Completer<bool>();
    _completers[id] = completer;

    try {
      final stream = _service.startDownload(id);
      _streams[id] = stream;

      _updateFile(
        id,
        (current) => current.copyWith(
          progress: 0,
          status: DownloadStatus.downloading,
          clearError: true,
        ),
      );

      late StreamSubscription<double> subscription;

      subscription = stream.listen(
        (progress) {
          _updateFile(id, (current) {
            final completed = progress >= 1;
            return current.copyWith(
              progress: progress,
              status: completed
                  ? DownloadStatus.completed
                  : DownloadStatus.downloading,
            );
          });

          if (progress >= 1 && !completer.isCompleted) {
            completer.complete(true);
            if (identical(_completers[id], completer)) {
              _completers.remove(id);
            }
          }
        },
        onError: (Object error) {
          _updateFile(
            id,
            (current) => current.copyWith(
              status: DownloadStatus.failed,
              errorMessage: error.toString(),
            ),
          );

          if (!completer.isCompleted) completer.complete(false);
          if (identical(_completers[id], completer)) {
            _completers.remove(id);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            _updateFile(
              id,
              (current) => current.copyWith(
                status: DownloadStatus.failed,
                errorMessage: 'Завантаження завершилося передчасно',
              ),
            );
            completer.complete(false);
          }

          if (identical(_subscriptions[id], subscription)) {
            _subscriptions.remove(id);
          }
          if (identical(_completers[id], completer)) {
            _completers.remove(id);
          }
        },
      );

      _subscriptions[id] = subscription;
    } catch (error) {
      _updateFile(
        id,
        (current) => current.copyWith(
          status: DownloadStatus.failed,
          errorMessage: error.toString(),
        ),
      );

      if (!completer.isCompleted) completer.complete(false);
      _completers.remove(id);
    }

    return completer.future;
  }

  Future<void> _cancelDownload(int id) async {
    final completer = _completers.remove(id);
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }

    final subscription = _subscriptions.remove(id);
    if (subscription != null) {
      await subscription.cancel();
    }

    if (!mounted) return;

    _service.cancelDownload(id);

    setState(() {
      _streams.remove(id);

      final index = _files.indexWhere((file) => file.id == id);
      if (index != -1) {
        _files[index] = _files[index].copyWith(
          progress: 0,
          status: DownloadStatus.waiting,
          clearError: true,
        );
      }
    });
  }

  Future<void> _downloadAll() async {
    if (_batchRunning || _files.isEmpty) return;

    final pending = _files
        .where((file) => file.status != DownloadStatus.completed)
        .toList();

    if (pending.isEmpty) {
      setState(() {
        _batchSummary = 'Усі файли вже завантажено.';
      });
      return;
    }

    final stopwatch = Stopwatch()..start();

    setState(() {
      _batchRunning = true;
      _batchSummary = null;
    });

    // Кожне завантаження повертає true/false, тому помилка
    // одного файлу не перериває решту паралельних завантажень.
    final results = await Future.wait(
      pending.map((file) => _startDownload(file.id)),
    );

    stopwatch.stop();

    if (!mounted) return;

    final successCount = results.where((result) => result).length;
    final errorCount = results.length - successCount;

    setState(() {
      _batchRunning = false;
      _batchSummary =
          'Завершено за ${stopwatch.elapsed.inSeconds} с. '
          'Успішно: $successCount, помилок або скасувань: $errorCount.';
    });
  }

  String _statusText(DownloadFile file) {
    switch (file.status) {
      case DownloadStatus.waiting:
        return 'Очікує';
      case DownloadStatus.downloading:
        return 'Завантажується';
      case DownloadStatus.completed:
        return 'Завершено';
      case DownloadStatus.failed:
        return 'Помилка';
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions.values) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();

    for (final completer in _completers.values) {
      if (!completer.isCompleted) completer.complete(false);
    }
    _completers.clear();

    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер завантажень'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DownloadFile>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Завантаження списку файлів...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'Не вдалося завантажити список.\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _retryLoading,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Спробувати ще раз'),
                    ),
                  ],
                ),
              ),
            );
          }

          final files = snapshot.data ?? [];

          if (files.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 56),
                  SizedBox(height: 12),
                  Text('Файлів поки немає'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _batchRunning ? null : _downloadAll,
                    icon: const Icon(Icons.download_for_offline),
                    label: Text(
                      _batchRunning
                          ? 'Завантаження всіх файлів...'
                          : 'Завантажити всі',
                    ),
                  ),
                ),
              ),
              if (_batchSummary != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.summarize),
                      title: const Text('Підсумок завантаження'),
                      subtitle: Text(_batchSummary!),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        '${file.sizeMb.toStringAsFixed(1)} MB'
                                        ' • ${_statusText(file)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            StreamBuilder<double>(
                              stream: _streams[file.id],
                              initialData: file.progress,
                              builder: (context, progressSnapshot) {
                                final progress =
                                    (progressSnapshot.data ?? file.progress)
                                        .clamp(0.0, 1.0);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 7,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${(progress * 100).round()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (file.errorMessage != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                file.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: file.status == DownloadStatus.downloading
                                  ? OutlinedButton.icon(
                                      onPressed: () => _cancelDownload(file.id),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Скасувати'),
                                    )
                                  : file.status == DownloadStatus.completed
                                  ? const Chip(
                                      avatar: Icon(
                                        Icons.check_circle,
                                        size: 18,
                                      ),
                                      label: Text('Завантажено'),
                                    )
                                  : FilledButton.icon(
                                      onPressed: () => _startDownload(file.id),
                                      icon: Icon(
                                        file.status == DownloadStatus.failed
                                            ? Icons.refresh
                                            : Icons.download,
                                      ),
                                      label: Text(
                                        file.status == DownloadStatus.failed
                                            ? 'Повторити'
                                            : 'Завантажити',
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
