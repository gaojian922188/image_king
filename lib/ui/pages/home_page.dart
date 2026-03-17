import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:image_king/blocs/compress/compress_bloc.dart';
import 'package:image_king/blocs/compress/compress_state.dart';
import 'package:image_king/blocs/image_list/image_list_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_event.dart';
import 'package:image_king/blocs/image_list/image_list_state.dart';
import 'package:image_king/core/constants.dart';
import 'package:image_king/core/utils/file_utils.dart';
import 'package:image_king/ui/widgets/compress_settings_panel.dart';
import 'package:image_king/ui/widgets/image_list_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) async {
        final rawPaths = details.files.map((f) => f.path).toList();
        final paths = await FileUtils.resolveImagePaths(rawPaths);
        if (paths.isNotEmpty && context.mounted) {
          context.read<ImageListBloc>().add(ImagesAdded(paths));
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppConstants.appTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left: Image list panel
                  const Expanded(
                    flex: 3,
                    child: ImageListPanel(),
                  ),
                  // Divider
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  // Right: Compress settings panel
                  const Expanded(
                    flex: 2,
                    child: CompressSettingsPanel(),
                  ),
                ],
              ),
            ),
            // Status bar
            _buildStatusBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return BlocBuilder<ImageListBloc, ImageListState>(
      builder: (context, imageState) {
        return BlocBuilder<CompressBloc, CompressState>(
          builder: (context, compressState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '共 ${imageState.images.length} 张图片',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '已选 ${imageState.selectedCount} 张',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '总大小 ${FileUtils.formatFileSize(imageState.totalSize)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (compressState.status == CompressStatus.compressing)
                    Text(
                      '压缩中 ${compressState.completed}/${compressState.total}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  if (compressState.status == CompressStatus.done)
                    Text(
                      '压缩完成',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
