import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_event.dart';
import 'package:image_king/models/image_item.dart';
import 'package:image_king/ui/widgets/image_preview_dialog.dart';

class ImageListTile extends StatelessWidget {
  final ImageItem item;
  final int index;

  const ImageListTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPreview(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: item.isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: item.isSelected,
                onChanged: (_) {
                  context
                      .read<ImageListBloc>()
                      .add(ImageToggleSelected(index));
                },
              ),
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                    ? Image.memory(
                        item.thumbnail!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        child: const Icon(Icons.image, size: 24),
                      ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.dimensionText}  |  ${item.sizeText}  |  ${item.format.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  context.read<ImageListBloc>().add(ImageRemoved(index));
                },
                tooltip: '移除',
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ImagePreviewDialog(item: item),
    );
  }
}
