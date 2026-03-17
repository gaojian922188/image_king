import 'package:get_it/get_it.dart';
import 'package:image_king/services/file_service.dart';
import 'package:image_king/services/image_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<FileService>(() => FileService());
  getIt.registerLazySingleton<ImageService>(() => ImageService());
}
