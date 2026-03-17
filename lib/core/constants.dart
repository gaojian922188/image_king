class AppConstants {
  AppConstants._();

  static const String appTitle = 'Image King - 图片处理工具';

  static const List<String> supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
  ];

  static const List<String> outputFormats = ['original', 'jpg', 'png', 'webp', 'bmp'];

  static const Map<String, String> outputFormatLabels = {
    'original': '保持原格式',
    'jpg': 'JPG',
    'png': 'PNG',
    'webp': 'WEBP',
    'bmp': 'BMP',
  };

  static const int defaultQuality = 85;
  static const int minQuality = 1;
  static const int maxQuality = 100;

  static const double minWindowWidth = 1000;
  static const double minWindowHeight = 700;
  static const double defaultWindowWidth = 1200;
  static const double defaultWindowHeight = 800;

  static const int thumbnailSize = 80;
}
