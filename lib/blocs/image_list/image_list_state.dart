import 'package:equatable/equatable.dart';
import 'package:image_king/blocs/image_list/image_list_event.dart';
import 'package:image_king/models/image_item.dart';

class ImageListState extends Equatable {
  final List<ImageItem> images;
  final bool isLoading;
  final SortField? sortField;
  final bool sortAscending;

  const ImageListState({
    this.images = const [],
    this.isLoading = false,
    this.sortField,
    this.sortAscending = true,
  });

  ImageListState copyWith({
    List<ImageItem>? images,
    bool? isLoading,
    SortField? sortField,
    bool? sortAscending,
    bool clearSort = false,
  }) {
    return ImageListState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      sortField: clearSort ? null : (sortField ?? this.sortField),
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  int get selectedCount => images.where((i) => i.isSelected).length;

  int get totalSize => images.fold(0, (sum, i) => sum + i.fileSize);

  List<ImageItem> get selectedImages =>
      images.where((i) => i.isSelected).toList();

  @override
  List<Object?> get props => [images, isLoading, sortField, sortAscending];
}
