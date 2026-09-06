import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:news_template_maker/core/constants/app_constants.dart';
import 'package:news_template_maker/core/models/video_project.dart';
import 'package:news_template_maker/services/ffmpeg_service.dart';
import 'package:news_template_maker/features/editor/services/bg_removal_service.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/media_crop_dialog.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/resolution_selector.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/template_selector.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/timeline_editor.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/export_dialog.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late VideoProject _currentProject;
  String _selectedResolution = AppConstants.resolutionFullHD;
  String _selectedTemplate = AppConstants.frameTypeNewsHeadline;
  final List<String> _mediaFiles = [];
  VideoPlayerController? _videoController;

  bool _isVideo = false;
  String _headlineText = "";
  Color _textColor = Colors.white;
  Color _textBgColor = Colors.redAccent;
  double _fontSize = 16.0;

  // Position for draggable headline
  Offset _textPosition = const Offset(20, 180);

  // Selected Aspect Ratio for preview
  double? _selectedAspectRatio;

  double _renderProgress = 0.0;
  String _renderStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeProject();
    _requestPermissions();
  }

  void _initializeProject() {
    _currentProject = VideoProject(
      id: uuid.v4(),
      title: 'Untitled Project',
      description: '',
      templateType: _selectedTemplate,
      resolution: _selectedResolution,
      durationInSeconds: AppConstants.defaultVideoDuration,
      mediaFilePaths: [],
      audioTracks: [],
      createdAt: DateTime.now(),
    );
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.photos.request();
    await Permission.storage.request();
  }

  Future<void> _pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      setState(() {
        _mediaFiles.add(path);
      });
      _setupPreview(path);
    }
  }

  Future<void> _setupPreview(String filePath) async {
    final lower = filePath.toLowerCase();
    final isVid = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi');

    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }

    if (isVid) {
      _videoController = VideoPlayerController.file(File(filePath));
      await _videoController!.initialize();
      _videoController!.play();
      _videoController!.setLooping(true);
      if (mounted) {
        setState(() {
          _isVideo = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isVideo = false;
        });
      }
    }
  }

  // Crop Action Handler with dynamic aspect ratio update
  void _openCropDialog(int index, String mediaPath) {
    showDialog(
      context: context,
      builder: (context) => MediaCropDialog(
        mediaPath: mediaPath,
        onCropSelected: (x, y, w, h, aspectRatio) {
          setState(() {
            _selectedAspectRatio = aspectRatio;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aspect Ratio Applied: ${aspectRatio != null ? aspectRatio.toStringAsFixed(2) : "Original"}'),
            ),
          );
        },
      ),
    );
  }

  // Remove BG Main Options Popup
  void _removeBackground(int index, String inputPath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Background Removal Method',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Option 1: Auto BG Removal
              ListTile(
                leading: const Icon(Icons.auto_fix_high, color: Colors.cyanAccent),
                title: const Text('Auto BG Removal', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Removes image/video background automatically', style: TextStyle(color: Colors.grey, fontSize: 12)),
                tileColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.pop(context);
                  _processAutoBgRemoval(index, inputPath);
                },
              ),

              const SizedBox(height: 12),

              // Option 2: Chroma Key Sliders Control
              ListTile(
                leading: const Icon(Icons.tune, color: Colors.greenAccent),
                title: const Text('Chroma Key (Green Screen)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Adjust green screen edge, blend & brightness manually', style: TextStyle(color: Colors.grey, fontSize: 12)),
                tileColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.pop(context);
                  _openChromaKeySliderDialog(index, inputPath);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. Auto BG Removal Process with Corner Progress HUD
  void _processAutoBgRemoval(int index, String inputPath) async {
    double bgProgress = 0.0;
    bool isPreparing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Stack(
            children: [
              Positioned(
                bottom: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.cyanAccent, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isPreparing
                              ? "Preparing media..."
                              : "Removing BG: ${(bgProgress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) isPreparing = false;
    });

    String outputPath = inputPath.replaceAll(RegExp(r'\.(mp4|mov|avi|jpg|png|jpeg)$'), '_nobg.mp4');

    String? result = await BgRemovalService.removeAutoBg(
      inputPath: inputPath,
      outputPath: outputPath,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            bgProgress = progress;
          });
        }
      },
    );

    if (mounted) Navigator.pop(context);

    if (result != null) {
      setState(() {
        _mediaFiles[index] = result;
      });
      await _setupPreview(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Background removed successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove background')),
        );
      }
    }
  }

  // 2. Manual Chroma Key Fine Tuning BottomSheet Dialog
  void _openChromaKeySliderDialog(int index, String inputPath) {
    double similarity = 0.3;
    double blend = 0.15;
    double brightness = 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chroma Key Fine Tuning',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Slider 1: Green Intensity Cut
                  Text('Green Cut Intensity: ${similarity.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Slider(
                    value: similarity,
                    min: 0.1,
                    max: 0.7,
                    activeColor: Colors.greenAccent,
                    onChanged: (val) => setModalState(() => similarity = val),
                  ),

                  // Slider 2: Edge Smooth & Blend
                  Text('Edge Smooth & Blend: ${blend.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Slider(
                    value: blend,
                    min: 0.0,
                    max: 0.5,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setModalState(() => blend = val),
                  ),

                  // Slider 3: Brightness / Color Match
                  Text('Subject Brightness: ${brightness.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Slider(
                    value: brightness,
                    min: -0.5,
                    max: 0.5,
                    activeColor: Colors.orangeAccent,
                    onChanged: (val) => setModalState(() => brightness = val),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                      onPressed: () async {
                        Navigator.pop(context);

                        String outputPath = inputPath.replaceAll(RegExp(r'\.(mp4|mov|avi|jpg|png|jpeg)$'), '_chroma.mp4');

                        String? result = await BgRemovalService.applyChromaKeyWithSliders(
                          inputPath: inputPath,
                          outputPath: outputPath,
                          similarity: similarity,
                          blend: blend,
                          brightness: brightness,
                        );

                        if (result != null) {
                          setState(() {
                            _mediaFiles[index] = result;
                          });
                          await _setupPreview(result);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chroma Key applied successfully!')),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to apply Chroma Key')),
                            );
                          }
                        }
                      },
                      child: const Text('Apply Chroma Key', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

  void _showTextEditor() {
    TextEditingController textController = TextEditingController(text: _headlineText);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Edit News Headline', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter News Headline...',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Font Size:', style: TextStyle(color: Colors.white)),
                      Slider(
                        value: _fontSize,
                        min: 10,
                        max: 32,
                        activeColor: Colors.cyanAccent,
                        onChanged: (val) {
                          setDialogState(() => _fontSize = val);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                onPressed: () {
                  setState(() {
                    _headlineText = textController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startRendering() async {
    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add media before exporting')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportDialog(
        onExport: (quality) async {
          Navigator.pop(context);
          _showRenderProgress();

          final ffmpegService = FFmpegService();
          await ffmpegService.generateVideo(
            inputMedia: _mediaFiles.first,
            resolution: _selectedResolution,
            textOverlay: _headlineText,
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _renderProgress = progress;
                  _renderStatus = 'Processing video... (${(progress * 100).toInt()}%)';
                });
              }
            },
          );
        },
      ),
    );
  }

  void _showRenderProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenderProgressDialog(
        projectTitle: _currentProject.title,
        progress: _renderProgress,
        status: _renderStatus,
      ),
    );
  }

  void _showResolutionSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ResolutionSelector(
        selectedResolution: _selectedResolution,
        onResolutionSelected: (resolution) {
          setState(() {
            _selectedResolution = resolution;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => TemplateSelector(
        selectedTemplate: _selectedTemplate,
        onTemplateSelected: (template) {
          setState(() {
            _selectedTemplate = template;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(_currentProject.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.cyanAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project saved successfully')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dynamic Interactive Preview Screen Frame
            Container(
              height: 280,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _mediaFiles.isNotEmpty
                        ? AspectRatio(
                            aspectRatio: _selectedAspectRatio ??
                                (_isVideo && _videoController != null && _videoController!.value.isInitialized
                                    ? _videoController!.value.aspectRatio
                                    : 16 / 9),
                            child: _isVideo
                                ? (_videoController != null && _videoController!.value.isInitialized
                                    ? VideoPlayer(_videoController!)
                                    : const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)))
                                : Image.file(
                                    File(_mediaFiles.last),
                                    fit: BoxFit.contain,
                                  ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.video_library, size: 54, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Select Media to Preview', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),

                  // Draggable & Customizable Headline Overlay Text
                  if (_headlineText.isNotEmpty)
                    Positioned(
                      left: _textPosition.dx,
                      top: _textPosition.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _textPosition += details.delta;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _textBgColor.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Text(
                            _headlineText,
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: _fontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Timeline Tracks Component
            TimelineEditor(
              mediaFiles: _mediaFiles,
              onClipSelected: (index) {
                _setupPreview(_mediaFiles[index]);
              },
              onClipRemoved: (index) {
                setState(() {
                  _mediaFiles.removeAt(index);
                  if (_mediaFiles.isNotEmpty) {
                    _setupPreview(_mediaFiles.last);
                  } else {
                    _videoController?.dispose();
                    _videoController = null;
                  }
                });
              },
              onCropTap: (index, path) => _openCropDialog(index, path),
              onRemoveBgTap: (index, path) => _removeBackground(index, path),
            ),

            // Quick Tools Grid Controls
            Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _QuickToolButton(
                    icon: Icons.add_photo_alternate,
                    label: 'Add Media',
                    onTap: _pickMedia,
                  ),
                  _QuickToolButton(
                    icon: Icons.crop_rotate,
                    label: 'Crop / Ratio',
                    onTap: () {
                      if (_mediaFiles.isNotEmpty) {
                        _openCropDialog(_mediaFiles.length - 1, _mediaFiles.last);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add media first')),
                        );
                      }
                    },
                  ),
                  _QuickToolButton(
                    icon: Icons.auto_fix_high,
                    label: 'Remove BG',
                    onTap: () {
                      if (_mediaFiles.isNotEmpty) {
                        _removeBackground(_mediaFiles.length - 1, _mediaFiles.last);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add media first')),
                        );
                      }
                    },
                  ),
                  _QuickToolButton(
                    icon: Icons.monitor,
                    label: 'Resolution',
                    onTap: _showResolutionSelector,
                  ),
                  _QuickToolButton(
                    icon: Icons.grid_view_rounded,
                    label: 'Template',
                    onTap: _showTemplateSelector,
                  ),
                  _QuickToolButton(
                    icon: Icons.text_fields,
                    label: 'Headline',
                    onTap: _showTextEditor,
                  ),
                ],
              ),
            ),

            // Export Button Container
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _startRendering,
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text(
                    'Render & Export',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.cyanAccent),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class RenderProgressDialog extends StatelessWidget {
  final String projectTitle;
  final double progress;
  final String status;

  const RenderProgressDialog({
    Key? key,
    required this.projectTitle,
    required this.progress,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toStringAsFixed(0);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              projectTitle,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              color: Colors.cyanAccent,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    status.isEmpty ? 'Processing...' : status,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
