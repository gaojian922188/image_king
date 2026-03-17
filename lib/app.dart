import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/compress/compress_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_bloc.dart';
import 'package:image_king/di/injection.dart';
import 'package:image_king/services/image_service.dart';
import 'package:image_king/ui/pages/home_page.dart';
import 'package:image_king/ui/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final imageService = getIt<ImageService>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ImageListBloc(imageService: imageService),
        ),
        BlocProvider(
          create: (_) => CompressBloc(imageService: imageService),
        ),
      ],
      child: MaterialApp(
        title: 'Image King',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
