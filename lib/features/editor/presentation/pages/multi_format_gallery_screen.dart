import 'package:flutter/material.dart';
import 'package:news_template_maker/features/editor/presentation/pages/editor_screen.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/news_template_designs.dart';

enum AspectRatioType { vertical916, horizontal169 }

class MultiFormatGalleryScreen extends StatefulWidget {
  final String categoryName;

  const MultiFormatGalleryScreen({Key? key, this.categoryName = 'Templates'}) : super(key: key);

  @override
  State<MultiFormatGalleryScreen> createState() => _MultiFormatGalleryScreenState();
}

class _MultiFormatGalleryScreenState extends State<MultiFormatGalleryScreen> {
  AspectRatioType _selectedRatio = AspectRatioType.vertical916;

  final List<Map<String, dynamic>> _verticalTemplates = [
    {
      'id': 'v1',
      'title': 'Split Comparison News',
      'builder': (context) => NewsTemplateDesigns.buildSplitComparisonTemplate(context, {
            'mainHeader': 'POLITICAL DEBATE',
            'footerText': 'Both leaders respond to national election claims.',
          }),
    },
    {
      'id': 'v2',
      'title': 'Cyberpunk Reel Alert',
      'builder': (context) => NewsTemplateDesigns.buildCyberpunkReelTemplate(context, {
            'newsBody': 'Tech Stocks reach record high in market surge.',
          }),
    },
  ];

  final List<Map<String, dynamic>> _horizontalTemplates = [
    {
      'id': 'h1',
      'title': 'Studio Anchor TV Live',
      'builder': (context) => NewsTemplateDesigns.buildStudioAnchor169(context, {
            'tickerText': 'URGENT: Prime Minister announces new policy changes.',
          }),
    },
    {
      'id': 'h2',
      'title': 'Minimalist World News',
      'builder': (context) => NewsTemplateDesigns.buildMinimalistBroadcast169(context, {
            'category': 'INTERNATIONAL',
            'headline': 'Global Summit discussions begin on environment.',
          }),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeTemplates =
        _selectedRatio == AspectRatioType.vertical916 ? _verticalTemplates : _horizontalTemplates;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Aspect Ratio Switcher Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('9:16 (Reels/Story)'),
                selected: _selectedRatio == AspectRatioType.vertical916,
                selectedColor: Colors.cyanAccent,
                labelStyle: TextStyle(
                  color: _selectedRatio == AspectRatioType.vertical916 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedRatio = AspectRatioType.vertical916);
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('16:9 (Landscape)'),
                selected: _selectedRatio == AspectRatioType.horizontal169,
                selectedColor: Colors.cyanAccent,
                labelStyle: TextStyle(
                  color: _selectedRatio == AspectRatioType.horizontal169 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedRatio = AspectRatioType.horizontal169);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Template Dynamic Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _selectedRatio == AspectRatioType.vertical916 ? 2 : 1,
                childAspectRatio: _selectedRatio == AspectRatioType.vertical916 ? (9 / 16) : (16 / 9),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: activeTemplates.length,
              itemBuilder: (context, index) {
                final template = activeTemplates[index];
                final Widget Function(BuildContext) builder = template['builder'];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditorScreen()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(child: builder(context)),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Text(
                              template['title'],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
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
