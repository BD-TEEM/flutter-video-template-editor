import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:news_template_maker/core/constants/app_constants.dart';
import 'package:news_template_maker/core/models/video_project.dart';
import 'package:news_template_maker/core/theme/app_theme.dart';
import 'package:news_template_maker/services/ffmpeg_service.dart';
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
  List<String> _mediaFiles = [];
  List<AudioTrack> _audioTracks = [];
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _mediaFiles.add(pickedFile.path);
      });
    }
  }

  Future<void> _playPreview() async {
    if (_mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add media first')),
      );
      return;
    }

    _videoController = VideoPlayerController.file(
      File(_mediaFiles.first),
    );

    await _videoController?.initialize();
    setState(() {
      _isPlaying = true;
    });

    if (mounted) {
      _videoController?.play();
    }
  }

  Future<void> _startRendering() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportDialog(
        onExport: (quality) async {
          // Export logic
          _showRenderProgress();
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
      appBar: AppBar(
        title: Text(_currentProject.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project saved')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Preview Section
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.black,
              child: _videoController != null && _videoController!.value.isInitialized
                  ? VideoPlayer(_videoController!)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Quick Tools Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _QuickToolButton(
                    icon: Icons.image,
                    label: 'Add Media',
                    onTap: _pickMedia,
                  ),
                  _QuickToolButton(
                    icon: Icons.play_circle,
                    label: 'Preview',
                    onTap: _playPreview,
                  ),
                  _QuickToolButton(
                    icon: Icons.monitor,
                    label: 'Resolution',
                    onTap: _showResolutionSelector,
                  ),
                  _QuickToolButton(
                    icon: Icons.template_rounded,
                    label: 'Template',
                    onTap: _showTemplateSelector,
                  ),
                  _QuickToolButton(
                    icon: Icons.text_fields,
                    label: 'Text',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text editor coming soon')),
                      );
                    },
                  ),
                  _QuickToolButton(
                    icon: Icons.music_note,
                    label: 'Audio',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio mixer coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Project Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Resolution',
                    value: _selectedResolution,
                    onTap: _showResolutionSelector,
                  ),
                  _DetailRow(
                    label: 'Template',
                    value: _selectedTemplate,
                    onTap: _showTemplateSelector,
                  ),
                  _DetailRow(
                    label: 'Duration',
                    value: '${_currentProject.durationInSeconds}s',
                    onTap: () {},
                  ),
                  _DetailRow(
                    label: 'Media Files',
                    value: '${_mediaFiles.length} added',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Export Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startRendering,
                  icon: const Icon(Icons.download),
                  label: const Text('Render & Export'),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueAccent,
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
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
    required this.projectTitle,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toStringAsFixed(0);
    final remainingTime =
        ((1 - progress) * 120).toStringAsFixed(0); // Assuming 2min render

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rendering',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              projectTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percentage% Complete',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '~${remainingTime}s left',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
