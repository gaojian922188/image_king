import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/compress/compress_bloc.dart';
import 'package:image_king/blocs/compress/compress_state.dart';
import 'package:image_king/core/utils/file_utils.dart';

class CompressProgress extends StatelessWidget {
  const CompressProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompressBloc, CompressState>(
      builder: (context, state) {
        if (state.status == CompressStatus.idle) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.status == CompressStatus.compressing) ...[
              LinearProgressIndicator(value: state.progress),
              const SizedBox(height: 8),
              Text(
                '正在压缩... ${state.completed}/${state.total}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (state.status == CompressStatus.done &&
                state.results.isNotEmpty) ...[
              const Divider(),
              Text(
                '压缩结果',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...state.results.map((r) {
                if (r.skipped) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.skip_next,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                FileUtils.getFileName(r.originalPath),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '跳过',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.orange),
                            ),
                          ],
                        ),
                        if (r.skipReason != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: Text(
                              r.skipReason!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  );
                } else if (r.success) {
                  final savings = r.originalSize - (r.compressedSize ?? 0);
                  final percent = r.originalSize > 0
                      ? (savings / r.originalSize * 100).toStringAsFixed(1)
                      : '0';
                  final compressedSizeText = r.compressedSize != null
                      ? FileUtils.formatFileSize(r.compressedSize!)
                      : '-';
                  final dimensionText =
                      (r.outputWidth != null && r.outputHeight != null)
                          ? '${r.outputWidth}x${r.outputHeight}'
                          : '-';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                FileUtils.getFileName(r.originalPath),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '减少 $percent%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.green),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 22),
                          child: Text(
                            '$compressedSizeText | $dimensionText',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${FileUtils.getFileName(r.originalPath)}: ${r.error}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ],
          ],
        );
      },
    );
  }
}
