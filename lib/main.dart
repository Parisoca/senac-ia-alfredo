import 'package:flutter/material.dart';

import 'config.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/logs_screen.dart';
import 'services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: const Color(0xFF6B4E3D),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F1EA),
      useMaterial3: true,
    );

    return MaterialApp(
      title: kAppDisplayName,
      theme: theme,
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: kDemoSafeModeNotifier,
          builder: (context, isDemo, _) {
            if (child == null) return const SizedBox.shrink();
            return Banner(
              message: isDemo ? 'DEMO' : 'AO VIVO',
              location: BannerLocation.topEnd,
              color: isDemo ? const Color(0xFFB26B35) : const Color(0xFF3D5A80),
              child: child,
            );
          },
        );
      },
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    ChatScreen(),
    BookmarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final titles = ['Conversa', 'Favoritos'];
    return Scaffold(
      appBar: AppBar(
        title: Text('$kAppDisplayName • ${titles[_currentIndex]}'),
        actions: [
          IconButton(
            tooltip: 'Registros',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LogsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
