import 'dart:io';
import 'package:flutter/material.dart';

class TimelineEditor extends StatefulWidget {
  final List<String> mediaFiles;
  final Function(int) onClipSelected;
  final Function(int)? onClipRemoved;
  final Function(int index, String path)? onCropTap;
  final Function(int index, String path)? onRemoveBgTap;

  const TimelineEditor({
    Key? key,
    required this.mediaFiles,
    required this.onClipSelected,
    this.onClipRemoved,
    this.onCropTap,
    this.onRemoveBgTap,
  }) : super(key: key);

  @override
  State<TimelineEditor> createState() => _TimelineEditorState();
}

class _TimelineEditorState extends State<TimelineEditor> {
  late ScrollController _scrollController;
  int _selectedClipIndex = 0;

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
      height: 200,
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Playhead & Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.view_timeline, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Timeline Tracks',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const Spacer(),
                Text(
                  '${widget.mediaFiles.length} item(s)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.cyanAccent,
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 130,
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.cyanAccent : Colors.grey.withOpacity(0.2),
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
                                    color: isSelected ? Colors.cyanAccent : Colors.grey,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      isVideoFile ? 'Video ${index + 1}' : 'Image ${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  
                                  // Selected Clip Action Buttons (Crop & Remove BG)
                                  if (isSelected) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Crop Button
                                        InkWell(
                                          onTap: () {
                                            if (widget.onCropTap != null) {
                                              widget.onCropTap!(index, filePath);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(Icons.crop, size: 14, color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Remove BG Button
                                        InkWell(
                                          onTap: () {
                                            if (widget.onRemoveBgTap != null) {
                                              widget.onRemoveBgTap!(index, filePath);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(Icons.auto_fix_high, size: 14, color: Colors.cyanAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                              
                              // Delete Clip Cross Icon
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
