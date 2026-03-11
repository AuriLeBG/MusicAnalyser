import 'package:flutter/material.dart';
import 'screens/artists_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  runApp(const MusicAnalyserApp());
}

class MusicAnalyserApp extends StatelessWidget {
  const MusicAnalyserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Analyser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ArtistsScreen(),
    FavoritesScreen(),
  ];

  static const List<String> _titles = ['Artistes', 'Favoris'];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: Text('Music Analyser — ${_titles[_selectedIndex]}'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.mic),
                      label: Text('Artistes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favoris'),
                    ),
                  ],
                ),
              if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWideScreen
              ? null
              : BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onDestinationSelected,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.mic),
                      label: 'Artistes',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Favoris',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
