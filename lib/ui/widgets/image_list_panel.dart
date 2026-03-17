import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_event.dart';
import 'package:image_king/blocs/image_list/image_list_state.dart';
import 'package:image_king/core/constants.dart';
import 'package:image_king/di/injection.dart';
import 'package:image_king/services/file_service.dart';
import 'package:image_king/ui/widgets/image_list_tile.dart';

class ImageListPanel extends StatelessWidget {
  const ImageListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageListBloc, ImageListState>(
      builder: (context, state) {
        return Column(
          children: [
            // Toolbar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _pickImages(context),
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: const Text('添加图片'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: state.images.isEmpty
                        ? null
                        : () => context
                            .read<ImageListBloc>()
                            .add(const ImagesSelectAll()),
                    child: const Text('全选'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: state.selectedCount == 0
                        ? null
                        : () => context
                            .read<ImageListBloc>()
                            .add(const ImagesDeselectAll()),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: state.images.isEmpty
                        ? null
                        : () => context
                            .read<ImageListBloc>()
                            .add(const ImagesClear()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('清空'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Image list or empty state
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.images.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          itemCount: state.images.length,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemBuilder: (context, index) {
                            return ImageListTile(
                              item: state.images[index],
                              index: index,
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '拖拽图片到这里，或点击"添加图片"按钮',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持格式: ${AppConstants.supportedExtensions.join(', ').toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final fileService = getIt<FileService>();
    final paths = await fileService.pickImages();
    if (paths.isNotEmpty && context.mounted) {
      context.read<ImageListBloc>().add(ImagesAdded(paths));
    }
  }
}
