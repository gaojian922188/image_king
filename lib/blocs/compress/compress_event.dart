import 'package:equatable/equatable.dart';
import 'package:image_king/models/image_item.dart';

abstract class CompressEvent extends Equatable {
  const CompressEvent();

  @override
  List<Object?> get props => [];
}

class CompressSettingsChanged extends CompressEvent {
  final CompressSettings settings;

  const CompressSettingsChanged(this.settings);

  @override
  List<Object?> get props => [settings];
}

class CompressOutputDirChanged extends CompressEvent {
  final String dir;

  const CompressOutputDirChanged(this.dir);

  @override
  List<Object?> get props => [dir];
}

class CompressStarted extends CompressEvent {
  final List<ImageItem> images;

  const CompressStarted(this.images);

  @override
  List<Object?> get props => [images];
}

class CompressReset extends CompressEvent {
  const CompressReset();
}
