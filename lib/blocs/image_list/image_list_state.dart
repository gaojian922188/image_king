import 'package:equatable/equatable.dart';
import 'package:image_king/models/image_item.dart';

class ImageListState extends Equatable {
  final List<ImageItem> images;
  final bool isLoading;

  const ImageListState({
    this.images = const [],
    this.isLoading = false,
  });

  ImageListState copyWith({
    List<ImageItem>? images,
    bool? isLoading,
  }) {
    return ImageListState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get selectedCount => images.where((i) => i.isSelected).length;

  int get totalSize => images.fold(0, (sum, i) => sum + i.fileSize);

  List<ImageItem> get selectedImages =>
      images.where((i) => i.isSelected).toList();

  @override
  List<Object?> get props => [images, isLoading];
}
