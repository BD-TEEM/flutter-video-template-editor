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
    // ডিলিট করার পর ইনডেক্স ঠিক রাখা
    if (_selectedClipIndex >= widget.mediaFiles.length && widget.mediaFiles.isNotEmpty) {
      _selectedClipIndex = widget.mediaFiles.length - 1;
    }

    return Container(
      height: 150, // স্ট্যান্ডার্ড রেসপন্সিভ হাইট
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Timeline Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.view_timeline, color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Timeline Tracks',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${widget.mediaFiles.length} item(s)',
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                ),
              ],
            ),
          ),

          // Timeline Clips List View
          Expanded(
            child: widget.mediaFiles.isEmpty
                ? Center(
                    child: Text(
                      'No media added to timeline',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                          width: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.cyanAccent : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // 1. Image Preview Background / Video Icon
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: isVideoFile
                                      ? Container(
                                          color: Colors.black45,
                                          child: const Center(
                                            child: Icon(Icons.play_circle_fill, color: Colors.cyanAccent, size: 28),
                                          ),
                                        )
                                      : Image.file(
                                          File(filePath),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                ),
                              ),

                              // Gradient Layer for Overlaying Text
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black38,
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // 2. Action Controls bottom layer
                              Positioned(
                                bottom: 4,
                                left: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Text(
                                      isVideoFile ? 'Vid ${index + 1}' : 'Img ${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => widget.onCropTap?.call(index, filePath),
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.crop, size: 12, color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () => widget.onRemoveBgTap?.call(index, filePath),
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(Icons.auto_fix_high, size: 12, color: Colors.cyanAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // 3. Remove Cross Icon Top-Right
                              if (widget.onClipRemoved != null)
                                Positioned(
                                  top: 3,
                                  right: 3,
                                  child: GestureDetector(
                                    onTap: () => widget.onClipRemoved!(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.redAccent,
                                      ),
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
