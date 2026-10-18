
import 'dart:async';
import 'dart:math';

import '../models/download_file.dart';

class DownloadService {
  DownloadService({this.failureRate = 0.2, Random? random})
    : _random = random ?? Random();

  final double failureRate;
  final Random _random;

  final Map<int, Timer> _timers = {};
  final Map<int, StreamController<double>> _controllers = {};
  bool _disposed = false;

  Future<List<DownloadFile>> loadFiles() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (_disposed) {
      throw StateError('Сервіс уже закрито');
    }

    if (_random.nextDouble() < failureRate) {
      throw StateError('Не вдалося отримати список файлів');
    }

    return const [
      DownloadFile(id: 1, name: 'Flutter_guide.pdf', sizeMb: 12.5),
      DownloadFile(id: 2, name: 'Project_archive.zip', sizeMb: 85.2),
      DownloadFile(id: 3, name: 'Design_mockup.fig', sizeMb: 24.8),
      DownloadFile(id: 4, name: 'Presentation.pptx', sizeMb: 18.4),
      DownloadFile(id: 5, name: 'Video_tutorial.mp4', sizeMb: 145.7),
      DownloadFile(id: 6, name: 'Source_code.zip', sizeMb: 32.1),
    ];
  }

  Stream<double> startDownload(int fileId) {
    if (_disposed) {
      throw StateError('Сервіс уже закрито');
    }

    cancelDownload(fileId);

    final controller = StreamController<double>();
    _controllers[fileId] = controller;

    var progress = 0.0;

    _timers[fileId] = Timer.periodic(
      const Duration(milliseconds: 180),
      (timer) {
        if (_disposed || controller.isClosed) {
          timer.cancel();
          return;
        }

        if (_random.nextDouble() < failureRate / 20) {
          timer.cancel();
          _timers.remove(fileId);

          controller.addError(
            StateError('Помилка завантаження файлу'),
          );
          unawaited(controller.close());
          _controllers.remove(fileId);
          return;
        }

        progress = min(
          1.0,
          progress + 0.04 + _random.nextDouble() * 0.10,
        );

        controller.add(progress);

        if (progress >= 1.0) {
          timer.cancel();
          _timers.remove(fileId);
          unawaited(controller.close());
          _controllers.remove(fileId);
        }
      },
    );

    return controller.stream.timeout(
      const Duration(seconds: 3),
      onTimeout: (sink) {
        sink.addError(
          TimeoutException('Немає оновлень прогресу завантаження'),
        );
        sink.close();
        cancelDownload(fileId);
      },
    );
  }

  void cancelDownload(int fileId) {
    _timers.remove(fileId)?.cancel();

    final controller = _controllers.remove(fileId);

    if (controller != null && !controller.isClosed) {
      unawaited(controller.close());
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;

    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    for (final controller in _controllers.values) {
      if (!controller.isClosed) {
        unawaited(controller.close());
      }
    }
    _controllers.clear();
  }
}
