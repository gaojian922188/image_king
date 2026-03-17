import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_event.dart';
import 'package:image_king/blocs/image_list/image_list_state.dart';
import 'package:image_king/models/image_item.dart';
import 'package:image_king/services/image_service.dart';

class ImageListBloc extends Bloc<ImageListEvent, ImageListState> {
  final ImageService _imageService;

  ImageListBloc({required ImageService imageService})
      : _imageService = imageService,
        super(const ImageListState()) {
    on<ImagesAdded>(_onImagesAdded);
    on<ImageRemoved>(_onImageRemoved);
    on<ImagesClear>(_onImagesClear);
    on<ImageToggleSelected>(_onImageToggleSelected);
    on<ImagesSelectAll>(_onImagesSelectAll);
    on<ImagesDeselectAll>(_onImagesDeselectAll);
    on<ImagesSorted>(_onImagesSorted);
  }

  Future<void> _onImagesAdded(
    ImagesAdded event,
    Emitter<ImageListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final existingPaths = state.images.map((i) => i.path).toSet();
    final newPaths =
        event.paths.where((p) => !existingPaths.contains(p)).toList();

    final newImages = <ImageItem>[];
    for (final path in newPaths) {
      try {
        final item = await _imageService.loadImageInfo(path);
        newImages.add(item);
      } catch (_) {
        // Skip files that can't be loaded
      }
    }

    emit(state.copyWith(
      images: [...state.images, ...newImages],
      isLoading: false,
    ));
  }

  void _onImageRemoved(ImageRemoved event, Emitter<ImageListState> emit) {
    final images = List.of(state.images);
    if (event.index >= 0 && event.index < images.length) {
      images.removeAt(event.index);
      emit(state.copyWith(images: images));
    }
  }

  void _onImagesClear(ImagesClear event, Emitter<ImageListState> emit) {
    emit(const ImageListState());
  }

  void _onImageToggleSelected(
    ImageToggleSelected event,
    Emitter<ImageListState> emit,
  ) {
    final images = List.of(state.images);
    if (event.index >= 0 && event.index < images.length) {
      final item = images[event.index];
      images[event.index] = item.copyWith(isSelected: !item.isSelected);
      emit(state.copyWith(images: images));
    }
  }

  void _onImagesSelectAll(
    ImagesSelectAll event,
    Emitter<ImageListState> emit,
  ) {
    final images = state.images.map((i) => i.copyWith(isSelected: true)).toList();
    emit(state.copyWith(images: images));
  }

  void _onImagesDeselectAll(
    ImagesDeselectAll event,
    Emitter<ImageListState> emit,
  ) {
    final images =
        state.images.map((i) => i.copyWith(isSelected: false)).toList();
    emit(state.copyWith(images: images));
  }

  void _onImagesSorted(ImagesSorted event, Emitter<ImageListState> emit) {
    // Toggle direction if same field, otherwise default ascending
    final ascending = state.sortField == event.field
        ? !state.sortAscending
        : true;

    final images = List.of(state.images);
    switch (event.field) {
      case SortField.size:
        images.sort((a, b) => ascending
            ? a.fileSize.compareTo(b.fileSize)
            : b.fileSize.compareTo(a.fileSize));
      case SortField.dimension:
        images.sort((a, b) {
          final aPixels = a.width * a.height;
          final bPixels = b.width * b.height;
          return ascending
              ? aPixels.compareTo(bPixels)
              : bPixels.compareTo(aPixels);
        });
    }

    emit(state.copyWith(
      images: images,
      sortField: event.field,
      sortAscending: ascending,
    ));
  }
}
