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
  // null = Original ratio (কোনো রেশিও চেঞ্জ হবে না)
  double? _selectedAspectRatio; 
  String _selectedLabel = 'Original';

  final List<Map<String, dynamic>> _ratioOptions = [
    {'label': 'Original', 'ratio': null, 'icon': Icons.aspect_ratio},
    {'label': '16:9', 'ratio': 16 / 9, 'icon': Icons.tv},
    {'label': '9:16', 'ratio': 9 / 16, 'icon': Icons.stay_current_portrait},
    {'label': '1:1', 'ratio': 1 / 1, 'icon': Icons.crop_square},
    {'label': '4:5', 'ratio': 4 / 5, 'icon': Icons.crop_portrait},
    {'label': '3:4', 'ratio': 3 / 4, 'icon': Icons.crop_3_2},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Select Aspect Ratio', style: TextStyle(color: Colors.white, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dynamic Preview Window
          AspectRatio(
            aspectRatio: _selectedAspectRatio ?? (16 / 9), // Original-এর জন্য ডিফল্ট ১৬:৯ প্রিভিউ দেখাবে
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyanAccent, width: 1.5),
              ),
              child: Center(
                child: Text(
                  'Preview Area\n$_selectedLabel',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Ratio Selection Buttons
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: _ratioOptions.map((option) {
              final isSelected = _selectedAspectRatio == option['ratio'];
              return ChoiceChip(
                avatar: Icon(
                  option['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.black : Colors.white,
                ),
                label: Text(
                  option['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.cyanAccent,
                backgroundColor: const Color(0xFF2C2C2C),
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedAspectRatio = option['ratio'] as double?;
                      _selectedLabel = option['label'] as String;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
          onPressed: () {
            // Selected Ratio and Crop Dimensions passing
            widget.onCropSelected(0, 0, 1, 1, _selectedAspectRatio);
            Navigator.pop(context);
          },
          child: const Text('Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
