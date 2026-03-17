import 'package:file_picker/file_picker.dart';
import 'package:image_king/core/constants.dart';

class FileService {
  Future<List<String>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedExtensions,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  Future<String?> pickDirectory() async {
    return FilePicker.platform.getDirectoryPath(dialogTitle: '选择保存位置');
  }
}
