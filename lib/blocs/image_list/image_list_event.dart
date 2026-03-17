import 'package:equatable/equatable.dart';

abstract class ImageListEvent extends Equatable {
  const ImageListEvent();

  @override
  List<Object?> get props => [];
}

class ImagesAdded extends ImageListEvent {
  final List<String> paths;

  const ImagesAdded(this.paths);

  @override
  List<Object?> get props => [paths];
}

class ImageRemoved extends ImageListEvent {
  final int index;

  const ImageRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class ImagesClear extends ImageListEvent {
  const ImagesClear();
}

class ImageToggleSelected extends ImageListEvent {
  final int index;

  const ImageToggleSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class ImagesSelectAll extends ImageListEvent {
  const ImagesSelectAll();
}

class ImagesDeselectAll extends ImageListEvent {
  const ImagesDeselectAll();
}
