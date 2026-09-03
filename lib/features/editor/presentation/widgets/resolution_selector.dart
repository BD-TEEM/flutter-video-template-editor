import 'package:flutter/material.dart';

class ResolutionSelector extends StatelessWidget {
  final String selectedResolution;
  final Function(String) onResolutionSelected;

  const ResolutionSelector({
    Key? key,
    required this.selectedResolution,
    required this.onResolutionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolutions = [
      '1920x1080 (Full HD)',
      '1280x720 (HD)',
      '3840x2160 (4K)',
      '720x1280 (Portrait)',
      '1080x1920 (Portrait Full HD)',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Resolution',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: resolutions.length,
              itemBuilder: (context, index) {
                final resolution = resolutions[index];
                final isSelected = selectedResolution == resolution;
                return ListTile(
                  title: Text(resolution),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.blueAccent)
                      : null,
                  onTap: () {
                    onResolutionSelected(resolution);
                  },
                  tileColor: isSelected
                      ? Colors.blueAccent.withOpacity(0.1)
                      : Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
