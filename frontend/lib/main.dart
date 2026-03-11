import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/artists_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/songs_screen.dart';
import 'screens/analytics_screen.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const kBg       = Color(0xFF08080F);
const kBgGrad   = Color(0xFF1A1035);
const kPrimary  = Color(0xFF7C3AED);
const kSecondary= Color(0xFF06B6D4);
const kTextPri  = Color(0xFFF8FAFC);
const kTextSec  = Color(0xFF94A3B8);
const kSurface  = Color(0xFF0F0F1A);

void main() => runApp(const MusicAnalyserApp());

class MusicAnalyserApp extends StatelessWidget {
  const MusicAnalyserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return MaterialApp(
      title: 'Music Analyser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kPrimary,
          secondary: kSecondary,
          surface: kSurface,
          onPrimary: kTextPri,
          onSurface: kTextPri,
          onSecondary: kTextPri,
        ),
        scaffoldBackgroundColor: kBg,
        textTheme: base.copyWith(
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: kTextPri,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: kTextPri,
          ),
          bodyMedium: base.bodyMedium?.copyWith(height: 1.5, color: kTextPri),
          bodySmall: base.bodySmall?.copyWith(height: 1.5, color: kTextSec),
          labelSmall: base.labelSmall?.copyWith(color: kTextSec),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.all(kTextPri),
            elevation: WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            overlayColor: WidgetStateProperty.all(kPrimary.withValues(alpha: 0.2)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ── Background avec gradient + blobs ─────────────────────────────────────────
class _AppBackground extends StatelessWidget {
  final Widget child;
  const _AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient de fond
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kBg, kBgGrad],
            ),
          ),
        ),
        // Blob violet haut-gauche
        Positioned(
          top: -80,
          left: -60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Blob cyan bas-droit
        Positioned(
          bottom: -60,
          right: -40,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: kSecondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Blob violet milieu
        Positioned(
          top: 250,
          right: 60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ArtistsScreen(),
    SongsScreen(),
    FavoritesScreen(),
    AnalyticsScreen(),
  ];

  static const _destinations = [
    (icon: Icons.mic_outlined,       active: Icons.mic,       label: 'Artistes'),
    (icon: Icons.music_note_outlined, active: Icons.music_note, label: 'Chansons'),
    (icon: Icons.favorite_outline,   active: Icons.favorite,  label: 'Favoris'),
    (icon: Icons.bar_chart_outlined, active: Icons.bar_chart,  label: 'Analytics'),
  ];

  void _onTap(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Music Analyser',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: kTextPri,
                    fontSize: 20,
                  ),
            ),
          ),
          body: _AppBackground(
            child: Row(
              children: [
                if (wide)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onTap,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.transparent,
                    indicatorColor: kPrimary.withValues(alpha: 0.30),
                    selectedIconTheme: const IconThemeData(color: kPrimary),
                    unselectedIconTheme: IconThemeData(color: kTextSec),
                    selectedLabelTextStyle: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: kTextSec,
                      fontSize: 12,
                    ),
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.active),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                if (wide)
                  VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : _GlassNavBar(
                  selectedIndex: _selectedIndex,
                  onTap: _onTap,
                  destinations: _destinations,
                ),
        );
      },
    );
  }
}

// ── Bottom nav bar glass ──────────────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, IconData active, String label})> destinations;

  const _GlassNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              for (int i = 0; i < destinations.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    splashColor: kPrimary.withValues(alpha: 0.2),
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == selectedIndex
                              ? destinations[i].active
                              : destinations[i].icon,
                          color: i == selectedIndex ? kPrimary : kTextSec,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          destinations[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            color: i == selectedIndex ? kPrimary : kTextSec,
                            fontWeight: i == selectedIndex
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
