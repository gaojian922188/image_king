import 'dart:io';

import 'package:image_king/core/constants.dart';
import 'package:image_king/core/utils/file_utils.dart';
import 'package:image_king/core/utils/image_utils.dart';
import 'package:image_king/models/image_item.dart';

class ImageService {
  Future<ImageItem> loadImageInfo(String path) async {
    final file = File(path);
    final fileSize = await file.length();
    final name = FileUtils.getFileName(path);
    final format = FileUtils.getExtension(path);
    final dims = await ImageUtils.getImageDimensions(path);
    final thumbnail = await ImageUtils.generateThumbnail(
      path,
      AppConstants.thumbnailSize,
    );

    return ImageItem(
      path: path,
      name: name,
      fileSize: fileSize,
      width: dims.width,
      height: dims.height,
      format: format,
      thumbnail: thumbnail,
    );
  }

  Future<CompressResult> compressImage({
    required ImageItem item,
    required CompressSettings settings,
    required String outputDir,
  }) async {
    try {
      // Resolve 'original' to the source file's format
      final actualFormat = settings.outputFormat == 'original'
          ? item.format
          : settings.outputFormat;

      // Check if dimensions are already below target — skip if so
      final bool widthOk = settings.targetWidth == null ||
          item.width <= settings.targetWidth!;
      final bool heightOk = settings.targetHeight == null ||
          item.height <= settings.targetHeight!;
      final bool sizeOk = settings.targetSizeKB == null ||
          item.fileSize <= settings.targetSizeKB! * 1024;

      if (widthOk && heightOk && sizeOk) {
        final reasons = <String>[];
        if (settings.targetWidth != null) {
          reasons.add('宽 ${item.width} <= ${settings.targetWidth}');
        }
        if (settings.targetHeight != null) {
          reasons.add('高 ${item.height} <= ${settings.targetHeight}');
        }
        if (settings.targetSizeKB != null) {
          reasons.add('大小已低于 ${settings.targetSizeKB}KB');
        }
        return CompressResult(
          originalPath: item.path,
          originalSize: item.fileSize,
          outputWidth: item.width,
          outputHeight: item.height,
          success: true,
          skipped: true,
          skipReason: '尺寸/大小已满足: ${reasons.join(', ')}',
        );
      }

      final inputBytes = await File(item.path).readAsBytes();
      final compressed = await ImageUtils.compressImage(
        inputBytes: inputBytes,
        targetWidth: settings.targetWidth,
        targetHeight: settings.targetHeight,
        keepAspectRatio: settings.keepAspectRatio,
        quality: settings.quality,
        outputFormat: actualFormat,
        targetSizeKB: settings.targetSizeKB,
      );

      if (compressed.isEmpty) {
        return CompressResult(
          originalPath: item.path,
          originalSize: item.fileSize,
          success: false,
          error: '图片解码失败',
        );
      }

      final baseName = FileUtils.getFileNameWithoutExtension(item.path);
      final ext = actualFormat;
      final outputName =
          settings.overwrite ? item.name : '${baseName}_compressed.$ext';
      final outputPath = '$outputDir/$outputName';

      await File(outputPath).writeAsBytes(compressed);

      // Get output dimensions
      final outDims = await ImageUtils.getImageDimensions(outputPath);

      return CompressResult(
        originalPath: item.path,
        outputPath: outputPath,
        originalSize: item.fileSize,
        compressedSize: compressed.length,
        outputWidth: outDims.width,
        outputHeight: outDims.height,
        success: true,
      );
    } catch (e) {
      return CompressResult(
        originalPath: item.path,
        originalSize: item.fileSize,
        success: false,
        error: e.toString(),
      );
    }
  }
}
