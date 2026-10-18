enum DownloadStatus { waiting, downloading, completed, failed }

class DownloadFile {
  const DownloadFile({
    required this.id,
    required this.name,
    required this.sizeMb,
    this.progress = 0,
    this.status = DownloadStatus.waiting,
    this.errorMessage,
  });

  final int id;
  final String name;
  final double sizeMb;
  final double progress;
  final DownloadStatus status;
  final String? errorMessage;

  DownloadFile copyWith({
    double? progress,
    DownloadStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DownloadFile(
      id: id,
      name: name,
      sizeMb: sizeMb,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
