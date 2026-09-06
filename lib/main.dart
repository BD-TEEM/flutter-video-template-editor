import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_template_maker/core/theme/app_theme.dart';
import 'package:news_template_maker/core/constants/app_constants.dart';
import 'package:news_template_maker/features/editor/presentation/pages/editor_screen.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  final permissions = [
    Permission.camera,
    Permission.microphone,
    Permission.photos,
    Permission.storage,
    Permission.mediaLibrary,
  ];

  for (final permission in permissions) {
    await permission.request();
  }
}

Future<void> initializeApp() async {
  await Hive.initFlutter();
  await requestPermissions();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(Key? key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({Key? key}) : super(Key? key);

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const HomeScreen(),
      const SavedProjectsScreen(),
      const EditorScreen(),
      const FavoritesScreen(),
      const FramesScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EditorScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_special),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36, color: Colors.cyanAccent),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Frames',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ১. আপডেট করা হোম স্ক্রিন (ফোল্ডার ভিউ)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(Key? key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ক্যাটাগরিগুলোকে এখন আলাদা ফোল্ডার আকারে সাজানো হলো
  final List<Map<String, dynamic>> _folders = [
    {
      'id': 'breaking',
      'name': 'Breaking News',
      'itemCount': 12,
      'color': Colors.redAccent,
      'icon': Icons.newspaper,
    },
    {
      'id': 'festival',
      'name': 'Festival Greeting',
      'itemCount': 8,
      'color': Colors.orangeAccent,
      'icon': Icons.celebration,
    },
    {
      'id': 'political',
      'name': 'Political & Speech',
      'itemCount': 15,
      'color': Colors.blueAccent,
      'icon': Icons.how_to_vote,
    },
    {
      'id': 'sports',
      'name': 'Sports Live',
      'itemCount': 10,
      'color': Colors.greenAccent,
      'icon': Icons.sports_cricket,
    },
    {
      'id': 'entertainment',
      'name': 'Entertainment Headline',
      'itemCount': 9,
      'color': Colors.purpleAccent,
      'icon': Icons.movie,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.live_tv, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text(
              'News Template Maker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            Container(
              margin: const EdgeInsets.all(16),
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.video_camera_back_sharp,
                      size: 130,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Create Professional\nNews Videos in Seconds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditorScreen(),
                              ),
                            );
                          },
                          child: const Text('Start Creating'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Template Categories (Folders)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Category Folders Grid
            GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return GestureDetector(
                  onTap: () {
                    // ফোল্ডারে ক্লিক করলে ফোল্ডারের পেজ খুলবে
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryTemplatesScreen(
                          categoryName: folder['name'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (folder['color'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                folder['icon'] as IconData,
                                color: folder['color'] as Color,
                                size: 28,
                              ),
                            ),
                            const Icon(Icons.folder, color: Colors.amber),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              folder['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${folder['itemCount']} Templates',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ২. ফোল্ডারের ভেতরের টেমপ্লেট দেখানোর স্ক্রিন
// ==========================================
class CategoryTemplatesScreen extends StatelessWidget {
  final String categoryName;

  const CategoryTemplatesScreen({Key? key, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> templates = [
      {
        'title': '$categoryName Main Layout',
        'tag': 'Hot',
        'color': Colors.redAccent,
        'icon': Icons.movie_creation_outlined,
      },
      {
        'title': '$categoryName Ticker Frame',
        'tag': 'New',
        'color': Colors.cyanAccent,
        'icon': Icons.slideshow,
      },
      {
        'title': '$categoryName Studio Style',
        'tag': 'Pro',
        'color': Colors.purpleAccent,
        'icon': Icons.video_label,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(categoryName),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return GestureDetector(
            onTap: () {
              // মূল অরিজিনাল টেমপ্লেটে ক্লিক করলে Editor Screen ওপেন হবে
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (template['color'] as Color).withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          template['icon'] as IconData,
                          size: 48,
                          color: template['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      template['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SavedProjectsScreen extends StatelessWidget {
  const SavedProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Saved Projects'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No projects yet', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Create your first video to get started', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No favorites yet', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Mark templates as favorites', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class FramesScreen extends StatelessWidget {
  const FramesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Frames'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Frame Library', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Browse available frames', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
