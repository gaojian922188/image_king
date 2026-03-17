import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/compress/compress_event.dart';
import 'package:image_king/blocs/compress/compress_state.dart';
import 'package:image_king/models/image_item.dart';
import 'package:image_king/services/image_service.dart';

class CompressBloc extends Bloc<CompressEvent, CompressState> {
  final ImageService _imageService;

  CompressBloc({required ImageService imageService})
      : _imageService = imageService,
        super(const CompressState()) {
    on<CompressSettingsChanged>(_onSettingsChanged);
    on<CompressOutputDirChanged>(_onOutputDirChanged);
    on<CompressStarted>(_onCompressStarted);
    on<CompressReset>(_onReset);
  }

  void _onSettingsChanged(
    CompressSettingsChanged event,
    Emitter<CompressState> emit,
  ) {
    emit(state.copyWith(settings: event.settings));
  }

  void _onOutputDirChanged(
    CompressOutputDirChanged event,
    Emitter<CompressState> emit,
  ) {
    emit(state.copyWith(outputDir: event.dir));
  }

  Future<void> _onCompressStarted(
    CompressStarted event,
    Emitter<CompressState> emit,
  ) async {
    if (event.images.isEmpty) {
      emit(state.copyWith(
        errorMessage: '没有选择要压缩的图片',
        status: CompressStatus.error,
      ));
      return;
    }

    if (state.outputDir.isEmpty) {
      emit(state.copyWith(
        errorMessage: '请先选择保存位置',
        status: CompressStatus.error,
      ));
      return;
    }

    emit(state.copyWith(
      status: CompressStatus.compressing,
      total: event.images.length,
      completed: 0,
      results: [],
      clearError: true,
    ));

    final results = <CompressResult>[];
    for (var i = 0; i < event.images.length; i++) {
      final result = await _imageService.compressImage(
        item: event.images[i],
        settings: state.settings,
        outputDir: state.outputDir,
      );
      results.add(result);
      emit(state.copyWith(
        completed: i + 1,
        results: List.of(results),
      ));
    }

    emit(state.copyWith(status: CompressStatus.done));
  }

  void _onReset(CompressReset event, Emitter<CompressState> emit) {
    emit(state.copyWith(
      status: CompressStatus.idle,
      total: 0,
      completed: 0,
      results: [],
      clearError: true,
    ));
  }
}
