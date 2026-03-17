import 'package:equatable/equatable.dart';
import 'package:image_king/models/image_item.dart';

enum CompressStatus { idle, compressing, done, error }

class CompressState extends Equatable {
  final CompressSettings settings;
  final String outputDir;
  final CompressStatus status;
  final int total;
  final int completed;
  final List<CompressResult> results;
  final String? errorMessage;

  const CompressState({
    this.settings = const CompressSettings(),
    this.outputDir = '',
    this.status = CompressStatus.idle,
    this.total = 0,
    this.completed = 0,
    this.results = const [],
    this.errorMessage,
  });

  CompressState copyWith({
    CompressSettings? settings,
    String? outputDir,
    CompressStatus? status,
    int? total,
    int? completed,
    List<CompressResult>? results,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CompressState(
      settings: settings ?? this.settings,
      outputDir: outputDir ?? this.outputDir,
      status: status ?? this.status,
      total: total ?? this.total,
      completed: completed ?? this.completed,
      results: results ?? this.results,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  double get progress => total == 0 ? 0 : completed / total;

  @override
  List<Object?> get props =>
      [settings, outputDir, status, total, completed, results, errorMessage];
}
