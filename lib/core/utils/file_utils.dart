import 'dart:io';

import 'package:image_king/core/constants.dart';

class FileUtils {
  FileUtils._();

  /// Recursively scan paths (files and directories) and return all supported image file paths.
  static Future<List<String>> resolveImagePaths(List<String> paths) async {
    final result = <String>[];
    for (final p in paths) {
      final type = await FileSystemEntity.type(p);
      if (type == FileSystemEntityType.directory) {
        await for (final entity in Directory(p).list(recursive: true)) {
          if (entity is File) {
            final ext = getExtension(entity.path);
            if (AppConstants.supportedExtensions.contains(ext)) {
              result.add(entity.path);
            }
          }
        }
      } else if (type == FileSystemEntityType.file) {
        final ext = getExtension(p);
        if (AppConstants.supportedExtensions.contains(ext)) {
          result.add(p);
        }
      }
    }
    return result;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static String getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  static String getFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final lastSlash = normalized.lastIndexOf('/');
    if (lastSlash == -1) return normalized;
    return normalized.substring(lastSlash + 1);
  }

  static String getFileNameWithoutExtension(String path) {
    final name = getFileName(path);
    final lastDot = name.lastIndexOf('.');
    if (lastDot == -1) return name;
    return name.substring(0, lastDot);
  }

  static String getDirectory(String path) {
    final normalized = path.replaceAll('\\', '/');
    final lastSlash = normalized.lastIndexOf('/');
    if (lastSlash == -1) return normalized;
    return normalized.substring(0, lastSlash);
  }
}
