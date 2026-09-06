import 'package:flutter/material.dart';

class ExportDialog extends StatefulWidget {
  final Function(String) onExport;

  const ExportDialog({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedQuality = 'High';

  @override
  Widget build(BuildContext context) {
    final qualities = ['Low', 'Medium', 'High', 'Ultra'];

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Quality',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: qualities.map((quality) {
                final isSelected = _selectedQuality == quality;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedQuality = quality;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyanAccent.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.cyanAccent
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: quality,
                          groupValue: _selectedQuality,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedQuality = value;
                              });
                            }
                          },
                          activeColor: Colors.cyanAccent,
                        ),
                        Text(
                          quality,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // ১. প্রথমে এক্সপোর্ট ডায়ালগ বন্ধ করবে
                    Navigator.pop(context);
                    // ২. এরপর এক্সপোর্ট কলব্যাক ফাংশন রান করবে
                    widget.onExport(_selectedQuality);
                  },
                  child: const Text(
                    'Export',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
