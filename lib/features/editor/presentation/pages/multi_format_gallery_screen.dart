import 'package:flutter/material.dart';
import 'package:news_template_maker/features/editor/presentation/pages/editor_screen.dart';
import 'package:news_template_maker/features/editor/presentation/widgets/news_template_designs.dart';

enum AspectRatioType { vertical916, horizontal169 }

class MultiFormatGalleryScreen extends StatefulWidget {
  final String categoryName;

  const MultiFormatGalleryScreen({Key? key, this.categoryName = 'All'}) : super(Key: key);

  @override
  State<MultiFormatGalleryScreen> createState() => _MultiFormatGalleryScreenState();
}

class _MultiFormatGalleryScreenState extends State<MultiFormatGalleryScreen> {
  AspectRatioType _selectedRatio = AspectRatioType.vertical916;

  // Master Template List with category tags
  final List<Map<String, dynamic>> _allTemplates = [
    // 9:16 Vertical Templates
    {
      'id': 'v1',
      'title': 'Split Comparison News',
      'category': 'Politics',
      'aspectRatio': AspectRatioType.vertical916,
      'builder': (context) => NewsTemplateDesigns.buildSplitComparisonTemplate(context, {
            'mainHeader': 'POLITICAL DEBATE',
            'footerText': 'Both leaders respond to national election claims.',
          }),
    },
    {
      'id': 'v2',
      'title': 'Cyberpunk Reel Alert',
      'category': 'Technology',
      'aspectRatio': AspectRatioType.vertical916,
      'builder': (context) => NewsTemplateDesigns.buildCyberpunkReelTemplate(context, {
            'newsBody': 'Tech Stocks reach record high in market surge.',
          }),
    },
    {
      'id': 'v3',
      'title': 'Breaking News Reel',
      'category': 'Breaking News',
      'aspectRatio': AspectRatioType.vertical916,
      'builder': (context) => NewsTemplateDesigns.buildSplitComparisonTemplate(context, {
            'mainHeader': 'BREAKING NEWS',
            'footerText': 'Major developments unfolding right now.',
          }),
    },

    // 16:9 Horizontal Templates
    {
      'id': 'h1',
      'title': 'Studio Anchor TV Live',
      'category': 'Studio',
      'aspectRatio': AspectRatioType.horizontal169,
      'builder': (context) => NewsTemplateDesigns.buildStudioAnchor169(context, {
            'tickerText': 'URGENT: Prime Minister announces new policy changes.',
          }),
    },
    {
      'id': 'h2',
      'title': 'Minimalist World News',
      'category': 'International',
      'aspectRatio': AspectRatioType.horizontal169,
      'builder': (context) => NewsTemplateDesigns.buildMinimalistBroadcast169(context, {
            'category': 'INTERNATIONAL',
            'headline': 'Global Summit discussions begin on environment.',
          }),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Dynamically Filter Templates by Category & Selected Aspect Ratio
    final activeTemplates = _allTemplates.where((template) {
      bool matchRatio = template['aspectRatio'] == _selectedRatio;
      bool matchCategory = widget.categoryName == 'All' ||
          widget.categoryName == 'Templates' ||
          template['category'].toString().toLowerCase() == widget.categoryName.toLowerCase();
      return matchRatio && matchCategory;
    }).toList();

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

          // Dynamic Template Grid Display
          Expanded(
            child: activeTemplates.isNotEmpty
                ? GridView.builder(
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
                          // Navigate to Editor with selected template info
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditorScreen(),
                            ),
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
                                  color: Colors.black.withOpacity(0.75),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  child: Text(
                                    template['title'],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No templates found for "${widget.categoryName}"',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
