import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ImageItem extends Equatable {
  final String path;
  final String name;
  final int fileSize;
  final int width;
  final int height;
  final String format;
  final Uint8List? thumbnail;
  final bool isSelected;

  const ImageItem({
    required this.path,
    required this.name,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.format,
    this.thumbnail,
    this.isSelected = false,
  });

  ImageItem copyWith({
    String? path,
    String? name,
    int? fileSize,
    int? width,
    int? height,
    String? format,
    Uint8List? thumbnail,
    bool? isSelected,
  }) {
    return ImageItem(
      path: path ?? this.path,
      name: name ?? this.name,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      format: format ?? this.format,
      thumbnail: thumbnail ?? this.thumbnail,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  String get sizeText {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get dimensionText => '${width}x$height';

  @override
  List<Object?> get props =>
      [path, name, fileSize, width, height, format, isSelected];
}

class CompressSettings extends Equatable {
  final int? targetWidth;
  final int? targetHeight;
  final bool keepAspectRatio;
  final int? targetSizeKB;
  final int quality;
  final String outputFormat;
  final bool overwrite;

  const CompressSettings({
    this.targetWidth,
    this.targetHeight,
    this.keepAspectRatio = true,
    this.targetSizeKB,
    this.quality = 85,
    this.outputFormat = 'original',
    this.overwrite = false,
  });

  CompressSettings copyWith({
    int? targetWidth,
    int? targetHeight,
    bool? keepAspectRatio,
    int? targetSizeKB,
    int? quality,
    String? outputFormat,
    bool? overwrite,
    bool clearTargetWidth = false,
    bool clearTargetHeight = false,
    bool clearTargetSizeKB = false,
  }) {
    return CompressSettings(
      targetWidth: clearTargetWidth ? null : (targetWidth ?? this.targetWidth),
      targetHeight:
          clearTargetHeight ? null : (targetHeight ?? this.targetHeight),
      keepAspectRatio: keepAspectRatio ?? this.keepAspectRatio,
      targetSizeKB:
          clearTargetSizeKB ? null : (targetSizeKB ?? this.targetSizeKB),
      quality: quality ?? this.quality,
      outputFormat: outputFormat ?? this.outputFormat,
      overwrite: overwrite ?? this.overwrite,
    );
  }

  @override
  List<Object?> get props => [
    targetWidth,
    targetHeight,
    keepAspectRatio,
    targetSizeKB,
    quality,
    outputFormat,
    overwrite,
  ];
}

class CompressResult extends Equatable {
  final String originalPath;
  final String? outputPath;
  final int originalSize;
  final int? compressedSize;
  final int? outputWidth;
  final int? outputHeight;
  final bool success;
  final bool skipped;
  final String? skipReason;
  final String? error;

  const CompressResult({
    required this.originalPath,
    this.outputPath,
    required this.originalSize,
    this.compressedSize,
    this.outputWidth,
    this.outputHeight,
    required this.success,
    this.skipped = false,
    this.skipReason,
    this.error,
  });

  @override
  List<Object?> get props => [
    originalPath,
    outputPath,
    originalSize,
    compressedSize,
    success,
    skipped,
    error,
  ];
}
