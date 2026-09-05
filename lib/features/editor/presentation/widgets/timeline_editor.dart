import 'dart:io';
import 'package:flutter/material.dart';

class TimelineEditor extends StatefulWidget {
  final List<String> mediaFiles;
  final Function(int) onClipSelected;
  final Function(int)? onClipRemoved;

  const TimelineEditor({
    Key? key,
    required this.mediaFiles,
    required this.onClipSelected,
    this.onClipRemoved,
  }) : super(key: key);

  @override
  State<TimelineEditor> createState() => _TimelineEditorState();
}

class _TimelineEditorState extends State<TimelineEditor> {
  late ScrollController _scrollController;
  int _selectedClipIndex = 0;
  double _playheadPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.mkv');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Playhead & Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.view_timeline, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Timeline Tracks',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${widget.mediaFiles.length} item(s)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blueAccent,
                      ),
                ),
              ],
            ),
          ),
          
          // Timeline Clips List
          Expanded(
            child: widget.mediaFiles.isEmpty
                ? Center(
                    child: Text(
                      'No media added to timeline',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: widget.mediaFiles.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedClipIndex == index;
                      final filePath = widget.mediaFiles[index];
                      final isVideoFile = _isVideo(filePath);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedClipIndex = index;
                          });
                          widget.onClipSelected(index);
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.grey.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isVideoFile ? Icons.video_camera_back : Icons.image,
                                    color: isSelected ? Colors.blueAccent : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      isVideoFile ? 'Video ${index + 1}' : 'Image ${index + 1}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.onClipRemoved != null)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => widget.onClipRemoved!(index),
                                    child: const Icon(
                                      Icons.cancel,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
