import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_king/core/constants.dart';
import 'package:window_manager/window_manager.dart';

class FileService {
  Future<List<String>> pickImages() async {
    await _workaroundMacOSDialog();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedExtensions,
      allowMultiple: true,
    );
    await _restoreMacOSDialog();
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  Future<String?> pickDirectory() async {
    await _workaroundMacOSDialog();
    final dir =
        await FilePicker.platform.getDirectoryPath(dialogTitle: '选择保存位置');
    await _restoreMacOSDialog();
    return dir;
  }

  /// macOS 上 window_manager 与 file_picker 存在兼容性问题，
  /// NSOpenPanel 可能被主窗口遮挡。通过临时设置 alwaysOnTop 来解决。
  Future<void> _workaroundMacOSDialog() async {
    if (Platform.isMacOS) {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setAlwaysOnTop(false);
    }
  }

  Future<void> _restoreMacOSDialog() async {
    if (Platform.isMacOS) {
      await windowManager.focus();
    }
  }
}
