import 'dart:io';
import 'package:flutter/material.dart';

class MediaCropDialog extends StatefulWidget {
  final String mediaPath;
  final Function(double x, double y, double w, double h, double? aspectRatio) onCropSelected;

  const MediaCropDialog({
    Key? key,
    required this.mediaPath,
    required this.onCropSelected,
  }) : super(key: key);

  @override
  State<MediaCropDialog> createState() => _MediaCropDialogState();
}

class _MediaCropDialogState extends State<MediaCropDialog> {
  double? _selectedAspectRatio = 16 / 9; // Default aspect ratio
  String _activeRatioName = '16:9';

  final Map<String, double?> _ratios = {
    'Free': null,
    '16:9': 16 / 9,
    '9:16': 9 / 16,
    '1:1': 1.0,
    '4:3': 4 / 3,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Crop & Aspect Ratio',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dynamic Aspect Ratio Preview Frame
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyanAccent, width: 1),
              ),
              child: Center(
                child: AspectRatio(
                  aspectRatio: _selectedAspectRatio ?? (16 / 9),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(widget.mediaPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.video_file,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Aspect Ratio Selector Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _ratios.entries.map((entry) {
                  final isSelected = _activeRatioName == entry.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(entry.key),
                      selected: isSelected,
                      selectedColor: Colors.cyanAccent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _activeRatioName = entry.key;
                            _selectedAspectRatio = entry.value;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                  onPressed: () {
                    // Pass crop metrics & ratio back to EditorScreen
                    widget.onCropSelected(0, 0, 100, 100, _selectedAspectRatio);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Crop', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
