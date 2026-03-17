import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_king/blocs/compress/compress_bloc.dart';
import 'package:image_king/blocs/compress/compress_event.dart';
import 'package:image_king/blocs/compress/compress_state.dart';
import 'package:image_king/blocs/image_list/image_list_bloc.dart';
import 'package:image_king/blocs/image_list/image_list_state.dart';
import 'package:image_king/core/constants.dart';
import 'package:image_king/di/injection.dart';
import 'package:image_king/models/image_item.dart';
import 'package:image_king/services/file_service.dart';
import 'package:image_king/ui/widgets/compress_progress.dart';

class CompressSettingsPanel extends StatefulWidget {
  const CompressSettingsPanel({super.key});

  @override
  State<CompressSettingsPanel> createState() => _CompressSettingsPanelState();
}

class _CompressSettingsPanelState extends State<CompressSettingsPanel> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompressBloc, CompressState>(
      listener: (context, state) {
        if (state.status == CompressStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<CompressBloc>().add(const CompressReset());
        }
        if (state.status == CompressStatus.done) {
          final successCount =
              state.results.where((r) => r.success && !r.skipped).length;
          final skippedCount =
              state.results.where((r) => r.skipped).length;
          final msg = skippedCount > 0
              ? '压缩完成！成功 $successCount 张，跳过 $skippedCount 张'
              : '压缩完成！成功 $successCount / ${state.total} 张';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.green),
          );
        }
      },
      builder: (context, compressState) {
        final settings = compressState.settings;
        final isCompressing =
            compressState.status == CompressStatus.compressing;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section: Resize
              _buildSectionTitle(context, '尺寸调整'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: '目标宽度',
                        suffixText: 'px',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !isCompressing,
                      onChanged: (v) => _updateSettings(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: '目标高度',
                        suffixText: 'px',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !isCompressing,
                      onChanged: (v) => _updateSettings(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: settings.keepAspectRatio,
                    onChanged: isCompressing
                        ? null
                        : (v) {
                            context.read<CompressBloc>().add(
                                  CompressSettingsChanged(
                                    settings.copyWith(keepAspectRatio: v),
                                  ),
                                );
                          },
                  ),
                  const Text('保持比例'),
                ],
              ),

              const SizedBox(height: 20),
              // Section: File size
              _buildSectionTitle(context, '文件大小'),
              const SizedBox(height: 12),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: '目标大小（留空则不限制）',
                  suffixText: 'KB',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !isCompressing,
                onChanged: (v) => _updateSettings(context),
              ),

              const SizedBox(height: 20),
              // Section: Output format
              _buildSectionTitle(context, '输出格式'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: settings.outputFormat,
                decoration: const InputDecoration(
                  labelText: '格式',
                ),
                items: AppConstants.outputFormats
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(
                            AppConstants.outputFormatLabels[f] ??
                                f.toUpperCase(),
                          ),
                        ))
                    .toList(),
                onChanged: isCompressing
                    ? null
                    : (v) {
                        if (v != null) {
                          context.read<CompressBloc>().add(
                                CompressSettingsChanged(
                                  settings.copyWith(outputFormat: v),
                                ),
                              );
                        }
                      },
              ),

              const SizedBox(height: 20),
              // Section: Quality
              _buildSectionTitle(context, '质量 (${settings.quality})'),
              const SizedBox(height: 4),
              Slider(
                value: settings.quality.toDouble(),
                min: AppConstants.minQuality.toDouble(),
                max: AppConstants.maxQuality.toDouble(),
                divisions: AppConstants.maxQuality - AppConstants.minQuality,
                label: '${settings.quality}',
                onChanged: isCompressing
                    ? null
                    : (v) {
                        context.read<CompressBloc>().add(
                              CompressSettingsChanged(
                                settings.copyWith(quality: v.toInt()),
                              ),
                            );
                      },
              ),

              const SizedBox(height: 20),
              // Section: Output dir
              _buildSectionTitle(context, '保存位置'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      compressState.outputDir.isEmpty
                          ? '未选择'
                          : compressState.outputDir,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed:
                        isCompressing ? null : () => _pickOutputDir(context),
                    child: const Text('选择...'),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: settings.overwrite,
                    onChanged: isCompressing
                        ? null
                        : (v) {
                            context.read<CompressBloc>().add(
                                  CompressSettingsChanged(
                                    settings.copyWith(overwrite: v),
                                  ),
                                );
                          },
                  ),
                  const Text('覆盖同名文件'),
                ],
              ),

              const SizedBox(height: 24),
              // Compress buttons
              BlocBuilder<ImageListBloc, ImageListState>(
                builder: (context, imageState) {
                  return Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: isCompressing ||
                                  imageState.selectedCount == 0
                              ? null
                              : () => _startCompress(
                                  context, imageState.selectedImages),
                          child: Text('压缩选中 (${imageState.selectedCount})'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed:
                              isCompressing || imageState.images.isEmpty
                                  ? null
                                  : () => _startCompress(
                                      context, imageState.images),
                          child: const Text('全部压缩'),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              // Progress
              const CompressProgress(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  void _updateSettings(BuildContext context) {
    final w = int.tryParse(_widthController.text);
    final h = int.tryParse(_heightController.text);
    final s = int.tryParse(_sizeController.text);

    final current = context.read<CompressBloc>().state.settings;
    context.read<CompressBloc>().add(
          CompressSettingsChanged(
            CompressSettings(
              targetWidth: w,
              targetHeight: h,
              keepAspectRatio: current.keepAspectRatio,
              targetSizeKB: s,
              quality: current.quality,
              outputFormat: current.outputFormat,
              overwrite: current.overwrite,
            ),
          ),
        );
  }

  Future<void> _pickOutputDir(BuildContext context) async {
    final fileService = getIt<FileService>();
    final dir = await fileService.pickDirectory();
    if (dir != null && context.mounted) {
      context.read<CompressBloc>().add(CompressOutputDirChanged(dir));
    }
  }

  void _startCompress(BuildContext context, List<ImageItem> images) {
    context.read<CompressBloc>().add(CompressStarted(images));
  }
}
