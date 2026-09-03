import 'package:flutter/material.dart';

class TimelineEditor extends StatefulWidget {
  final List<String> mediaFiles;
  final Function(int, int) onTimelineUpdate;

  const TimelineEditor({
    Key? key,
    required this.mediaFiles,
    required this.onTimelineUpdate,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Playhead indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Text(
                  '${(_playheadPosition / 1000).toStringAsFixed(2)}s',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
          // Timeline clips
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.mediaFiles.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedClipIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedClipIndex = index;
                    });
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library,
                          color: isSelected ? Colors.blueAccent : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clip ${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
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
