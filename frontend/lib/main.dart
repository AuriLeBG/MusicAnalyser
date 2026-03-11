import 'package:flutter/material.dart';

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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Music Analyser 🎵'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (int index) {},
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isWideScreen ? Icons.desktop_windows : Icons.smartphone,
                        size: 100,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isWideScreen ? "Mode PC / Tablette" : "Mode Mobile",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 15),
                      const Text("TEST"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWideScreen
              ? null
              : BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.mic),
                      label: "Artistes",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: "Favoris",
                    ),
                  ],
                ),
        );
      },
    );
  }
}
