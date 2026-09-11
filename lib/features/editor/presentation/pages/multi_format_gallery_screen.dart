import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_template_maker/features/editor/presentation/pages/editor_screen.dart';

enum AspectRatioType { vertical916, horizontal169 }

class MultiFormatGalleryScreen extends StatefulWidget {
  final String categoryName;

  const MultiFormatGalleryScreen({Key? key, this.categoryName = 'All'}) : super(key: key);

  @override
  State<MultiFormatGalleryScreen> createState() => _MultiFormatGalleryScreenState();
}

class _MultiFormatGalleryScreenState extends State<MultiFormatGalleryScreen> {
  AspectRatioType _selectedRatio = AspectRatioType.vertical916;

  // গিটহাবের সরাসরি Raw JSON লিংক
  final String _githubUrl = 'https://raw.githubusercontent.com/BD-TEEN/news-templates/main/template.json';

  List<dynamic> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGithubTemplates();
  }

  // গিটহাব থেকে টেমপ্লেট ফেচ করার ফাংশন
  Future<void> _fetchGithubTemplates() async {
    try {
      final response = await http.get(Uri.parse(_githubUrl));
      if (response.statusCode == 200) {
        setState(() {
          _templates = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading templates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  )
                : _templates.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _selectedRatio == AspectRatioType.vertical916 ? 2 : 1,
                          childAspectRatio: _selectedRatio == AspectRatioType.vertical916 ? (9 / 16) : (16 / 9),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _templates.length,
                        itemBuilder: (context, index) {
                          final template = _templates[index];
                          
                          // গিটহাবের ইমেজ লিংক তৈরি করা (base_url + json['img'])
                          final baseUrl = template['base_url'] ?? '';
                          final imgName = template['json']?['img'] ?? '';
                          final imageUrl = '$baseUrl$imgName';

                          return GestureDetector(
                            onTap: () {
                              // নেভিগেট করে এডিটর স্ক্রিনে টেমপ্লেটের ডাটা পাঠানো
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
                                  // গিটহাব থেকে থাম্বনেইল ছবি লোড
                                  Positioned.fill(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.video_library, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.75),
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Text(
                                        template['name'] ?? 'Template',
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
