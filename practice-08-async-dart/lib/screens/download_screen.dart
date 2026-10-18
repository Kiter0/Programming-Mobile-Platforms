
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
  DateTime? _batchStart;

  @override
  void initState() {
    super.initState();
    _filesFuture = _loadFiles();
  }

  Future<List<DownloadFile>> _loadFiles() {
    return _service.loadFiles().timeout(
      const Duration(seconds: 5),
    );
  }

  void _retryLoad() {
    setState(() {
      _files = [];
      _batchSummary = null;
      _filesFuture = _loadFiles();
    });
  }

  void _updateFile(
    int id,
    DownloadFile Function(DownloadFile) update,
  ) {
    if (!mounted) return;

    final index = _files.indexWhere((file) => file.id == id);
    if (index == -1) return;

    setState(() {
      _files[index] = update(_files[index]);
    });
  }

  Future<bool> _startDownload(int id) {
    final existing = _completers[id];

    if (existing != null && !existing.isCompleted) {
      return existing.future;
    }

    final index = _files.indexWhere((file) => file.id == id);
    if (index == -1) return Future.value(false);

    if (_files[index].status == DownloadStatus.completed) {
      return Future.value(true);
    }

    final completer = Completer<bool>();
    _completers[id] = completer;

    try {
      // Важливо: broadcast дозволяє слухати потік
      // одночасно через listen() та StreamBuilder.
      final stream = _service.startDownload(id).asBroadcastStream();
      _streams[id] = stream;

      _updateFile(
        id,
        (file) => file.copyWith(
          progress: 0,
          status: DownloadStatus.downloading,
          errorMessage: null,
        ),
      );

      late final StreamSubscription<double> subscription;

      subscription = stream.listen(
        (progress) {
          _updateFile(
            id,
            (file) => file.copyWith(
              progress: progress,
              status: progress >= 1
                  ? DownloadStatus.completed
                  : DownloadStatus.downloading,
              errorMessage: null,
            ),
          );

          if (progress >= 1 && !completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (Object error) {
          _updateFile(
            id,
            (file) => file.copyWith(
              status: DownloadStatus.failed,
              errorMessage: error.toString(),
            ),
          );

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onDone: () {
          final currentIndex = _files.indexWhere(
            (file) => file.id == id,
          );

          if (currentIndex != -1 &&
              _files[currentIndex].status ==
                  DownloadStatus.downloading) {
            _updateFile(
              id,
              (file) => file.copyWith(
                status: DownloadStatus.failed,
                errorMessage: 'Завантаження перервано',
              ),
            );

            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }

          if (identical(_subscriptions[id], subscription)) {
            _subscriptions.remove(id);
          }
        },
      );

      _subscriptions[id] = subscription;
    } catch (error) {
      _updateFile(
        id,
        (file) => file.copyWith(
          status: DownloadStatus.failed,
          errorMessage: error.toString(),
        ),
      );

      if (!completer.isCompleted) {
        completer.complete(false);
      }
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

    _service.cancelDownload(id);
    _streams.remove(id);

    _updateFile(
      id,
      (file) => file.copyWith(
        progress: 0,
        status: DownloadStatus.waiting,
        errorMessage: null,
      ),
    );
  }

  Future<void> _downloadAll() async {
    if (_batchRunning) return;

    final pending = _files
        .where((file) => file.status != DownloadStatus.completed)
        .toList();

    if (pending.isEmpty) {
      setState(() {
        _batchSummary = 'Усі файли вже завантажено.';
      });
      return;
    }

    setState(() {
      _batchRunning = true;
      _batchSummary = null;
      _batchStart = DateTime.now();
    });

    try {
      final results = await Future.wait<bool>(
        pending.map((file) => _startDownload(file.id)),
      );

      if (!mounted) return;

      final successful = results.where((result) => result).length;
      final failed = results.length - successful;
      final elapsed = DateTime.now().difference(_batchStart!);

      setState(() {
        _batchSummary =
            'Завершено: $successful із ${results.length}. '
            'Помилок або скасувань: $failed. '
            'Час: ${elapsed.inSeconds} с.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _batchRunning = false;
        });
      }
    }
  }

  String _statusText(DownloadFile file) {
    switch (file.status) {
      case DownloadStatus.waiting:
        return 'Очікує завантаження';
      case DownloadStatus.downloading:
        return 'Завантажується';
      case DownloadStatus.completed:
        return 'Завантажено';
      case DownloadStatus.failed:
        return 'Помилка';
    }
  }

  Color _statusColor(DownloadFile file) {
    switch (file.status) {
      case DownloadStatus.waiting:
        return Colors.grey;
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
    }
  }

  Widget _buildFileCard(DownloadFile file) {
    final isDownloading =
        file.status == DownloadStatus.downloading;
    final isCompleted =
        file.status == DownloadStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${file.sizeMb.toStringAsFixed(1)} МБ'),
                    ],
                  ),
                ),
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : isDownloading
                          ? Icons.downloading
                          : file.status == DownloadStatus.failed
                              ? Icons.error
                              : Icons.cloud_download,
                  color: _statusColor(file),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<double>(
              stream: _streams[file.id],
              initialData: file.progress,
              builder: (context, snapshot) {
                final progress =
                    (snapshot.data ?? file.progress).clamp(0.0, 1.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_statusText(file)),
                        Text('${(progress * 100).round()}%'),
                      ],
                    ),
                  ],
                );
              },
            ),
            if (file.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                file.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isDownloading
                  ? OutlinedButton.icon(
                      onPressed: () => _cancelDownload(file.id),
                      icon: const Icon(Icons.close),
                      label: const Text('Скасувати'),
                    )
                  : ElevatedButton.icon(
                      onPressed: isCompleted
                          ? null
                          : () => _startDownload(file.id),
                      icon: Icon(
                        isCompleted ? Icons.check : Icons.download,
                      ),
                      label: Text(
                        isCompleted
                            ? 'Завантажено'
                            : file.status == DownloadStatus.failed
                                ? 'Повторити'
                                : 'Завантажити',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final completer in _completers.values) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    for (final subscription in _subscriptions.values) {
      unawaited(subscription.cancel());
    }

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
                    const Icon(
                      Icons.cloud_off,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Не вдалося завантажити список:\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _retryLoad,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Спробувати ще раз'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedFiles = snapshot.data ?? [];

          if (loadedFiles.isEmpty) {
            return const Center(
              child: Text('Список файлів порожній.'),
            );
          }

          if (_files.isEmpty) {
            _files = List<DownloadFile>.from(loadedFiles);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    _batchSummary!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    return _buildFileCard(_files[index]);
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
