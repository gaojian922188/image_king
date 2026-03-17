import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageUtils {
  ImageUtils._();

  static Future<img.Image?> decodeImageFile(String path) async {
    final bytes = await File(path).readAsBytes();
    return Isolate.run(() => img.decodeImage(bytes));
  }

  static Future<({int width, int height})> getImageDimensions(
    String path,
  ) async {
    final bytes = await File(path).readAsBytes();
    final result = Isolate.run(() {
      final image = img.decodeImage(bytes);
      if (image == null) return (width: 0, height: 0);
      return (width: image.width, height: image.height);
    });
    return result;
  }

  static Future<Uint8List> generateThumbnail(
    String path,
    int size,
  ) async {
    final bytes = await File(path).readAsBytes();
    return Isolate.run(() {
      final image = img.decodeImage(bytes);
      if (image == null) return Uint8List(0);
      final thumbnail = img.copyResize(
        image,
        width: size,
        height: size,
        maintainAspect: true,
      );
      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 70));
    });
  }

  static Future<Uint8List> compressImage({
    required Uint8List inputBytes,
    int? targetWidth,
    int? targetHeight,
    bool keepAspectRatio = true,
    int quality = 85,
    String outputFormat = 'jpg',
    int? targetSizeKB,
  }) async {
    return Isolate.run(() {
      return _compressSync(
        inputBytes: inputBytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        keepAspectRatio: keepAspectRatio,
        quality: quality,
        outputFormat: outputFormat,
        targetSizeKB: targetSizeKB,
      );
    });
  }

  static Uint8List _compressSync({
    required Uint8List inputBytes,
    int? targetWidth,
    int? targetHeight,
    bool keepAspectRatio = true,
    int quality = 85,
    String outputFormat = 'jpg',
    int? targetSizeKB,
  }) {
    var image = img.decodeImage(inputBytes);
    if (image == null) return Uint8List(0);

    // Resize if target dimensions specified
    if (targetWidth != null || targetHeight != null) {
      if (keepAspectRatio) {
        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          maintainAspect: true,
        );
      } else {
        image = img.copyResize(
          image,
          width: targetWidth ?? image.width,
          height: targetHeight ?? image.height,
        );
      }
    }

    // If target file size specified, use binary search on quality
    if (targetSizeKB != null && (outputFormat == 'jpg' || outputFormat == 'jpeg')) {
      return _compressToTargetSize(image, targetSizeKB, outputFormat);
    }

    return Uint8List.fromList(_encode(image, outputFormat, quality));
  }

  static Uint8List _compressToTargetSize(
    img.Image image,
    int targetSizeKB,
    String format,
  ) {
    final targetBytes = targetSizeKB * 1024;
    int low = 1;
    int high = 100;
    Uint8List? bestResult;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final encoded = Uint8List.fromList(_encode(image, format, mid));

      if (encoded.length <= targetBytes) {
        bestResult = encoded;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    // If even quality=1 is too big, return the smallest we can get
    return bestResult ?? Uint8List.fromList(_encode(image, format, 1));
  }

  static List<int> _encode(img.Image image, String format, int quality) {
    switch (format.toLowerCase()) {
      case 'png':
        return img.encodePng(image);
      case 'webp':
        // image package does not support lossy webp encoding with quality;
        // fall back to PNG-level lossless WebP
        return img.encodePng(image);
      case 'bmp':
        return img.encodeBmp(image);
      case 'jpg':
      case 'jpeg':
      default:
        return img.encodeJpg(image, quality: quality);
    }
  }
}
