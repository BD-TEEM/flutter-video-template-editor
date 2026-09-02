import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_template_maker/core/theme/app_theme.dart';
import 'package:news_template_maker/core/constants/app_constants.dart';
import 'package:news_template_maker/features/home/presentation/pages/home_screen.dart';
import 'package:news_template_maker/features/editor/presentation/pages/editor_screen.dart';
import 'package:permission_handler/permission_handler.dart';

future<void> requestPermissions() async {
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

future<void> initializeApp() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Request Permissions
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
  const MyApp({Key? key}) : super(key: key);

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
  const MainNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SavedProjectsScreen(),
    EditorScreen(),
    FavoritesScreen(),
    FramesScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Create button - navigate to editor
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Frames',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditorScreen()),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class SavedProjectsScreen extends StatelessWidget {
  const SavedProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Projects')),
      body: const Center(child: Text('Saved Projects Coming Soon')),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('Favorites Coming Soon')),
    );
  }
}

class FramesScreen extends StatelessWidget {
  const FramesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frames')),
      body: const Center(child: Text('Frames Coming Soon')),
    );
  }
}
