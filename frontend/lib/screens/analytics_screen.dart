import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show kPrimary, kSecondary, kTextPri, kTextSec;
import '../models/analytics.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/shared.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  late Future<List<ViewsByYear>> _viewsByYearFuture;
  late Future<List<TopArtist>>  _topArtistsFuture;
  late Future<List<TopGenre>>   _topGenresFuture;

  @override
  void initState() {
    super.initState();
    _tabController       = TabController(length: 3, vsync: this);
    _viewsByYearFuture   = _api.getViewsByYear();
    _topArtistsFuture    = _api.getTopArtists();
    _topGenresFuture     = _api.getTopGenres();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenTitle(title: 'Analytics'),
          const SizedBox(height: 8),

          // ── TabBar glass ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: GlassCard(
              padding: const EdgeInsets.all(4),
              borderRadius: BorderRadius.circular(14),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kPrimary.withValues(alpha: 0.50),
                    width: 1,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: kTextPri,
                unselectedLabelColor: kTextSec,
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
                tabs: const [
                  Tab(text: 'Vues / Année'),
                  Tab(text: 'Top Artistes'),
                  Tab(text: 'Top Genres'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Contenu ─────────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ViewsByYearTab(future: _viewsByYearFuture),
                _TopArtistsTab(future: _topArtistsFuture),
                _TopGenresTab(future: _topGenresFuture),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient violet→cyan réutilisé sur toutes les barres ─────────────────────
const _kBarGradient = LinearGradient(
  colors: [kPrimary, kSecondary],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

// Couleurs distinctes pour Top Artistes (une par barre)
const List<List<Color>> _kArtistGradients = [
  [Color(0xFF7C3AED), Color(0xFF06B6D4)],
  [Color(0xFFEC4899), Color(0xFFF59E0B)],
  [Color(0xFF10B981), Color(0xFF06B6D4)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  [Color(0xFFEF4444), Color(0xFFEC4899)],
  [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
  [Color(0xFF06B6D4), Color(0xFF10B981)],
  [Color(0xFFF59E0B), Color(0xFF10B981)],
  [Color(0xFFEC4899), Color(0xFF7C3AED)],
];

// ── Styles communs des axes ───────────────────────────────────────────────────
TextStyle _axisStyle() => GoogleFonts.inter(
      fontSize: 10,
      color: kTextSec,
      fontWeight: FontWeight.w500,
    );

FlGridData _darkGrid(double interval) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (_) => FlLine(
        color: Colors.white.withValues(alpha: 0.08),
        strokeWidth: 1,
      ),
    );

BarTouchTooltipData _darkTooltip(String Function(double) label) =>
    BarTouchTooltipData(
      getTooltipColor: (_) => const Color(0xFF1A1035),
      tooltipRoundedRadius: 8,
      tooltipBorder: BorderSide(
        color: kPrimary.withValues(alpha: 0.40),
        width: 1,
      ),
      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
        label(rod.toY),
        GoogleFonts.inter(
          color: kTextPri,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );

// ── Titre de section interne ──────────────────────────────────────────────────
Widget _sectionLabel(String text) => Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: kTextSec,
        letterSpacing: 1.2,
      ),
    );

// ── Vues par année ────────────────────────────────────────────────────────────
class _ViewsByYearTab extends StatelessWidget {
  final Future<List<ViewsByYear>> future;
  const _ViewsByYearTab({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ViewsByYear>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return snapshot.hasError
              ? ErrorState(message: '${snapshot.error}')
              : const LoadingState();
        }
        final data = snapshot.data!;
        if (data.isEmpty) return const EmptyState(icon: Icons.bar_chart, message: 'Pas de données');

        final maxY = data.map((e) => e.totalViews).reduce((a, b) => a > b ? a : b) * 1.25;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Vues totales par année'),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      backgroundColor: Colors.transparent,
                      barTouchData: BarTouchData(
                        touchTooltipData: _darkTooltip(
                          (y) => '${(y / 1000000).toStringAsFixed(1)}M',
                        ),
                      ),
                      barGroups: data.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.totalViews.toDouble(),
                              gradient: _kBarGradient,
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= data.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('${data[idx].year}', style: _axisStyle()),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                '${(value / 1000000).toStringAsFixed(0)}M',
                                style: _axisStyle(),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: _darkGrid(maxY / 4),
                      borderData: FlBorderData(show: false),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Top Artistes ──────────────────────────────────────────────────────────────
class _TopArtistsTab extends StatelessWidget {
  final Future<List<TopArtist>> future;
  const _TopArtistsTab({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TopArtist>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return snapshot.hasError
              ? ErrorState(message: '${snapshot.error}')
              : const LoadingState();
        }
        final data = snapshot.data!;
        if (data.isEmpty) return const EmptyState(icon: Icons.bar_chart, message: 'Pas de données');

        final maxY = data.map((e) => e.totalViews).reduce((a, b) => a > b ? a : b) * 1.25;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Top 10 artistes par vues'),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      backgroundColor: Colors.transparent,
                      barTouchData: BarTouchData(
                        touchTooltipData: _darkTooltip(
                          (y) => '${(y / 1000000).toStringAsFixed(1)}M',
                        ),
                      ),
                      barGroups: data.asMap().entries.map((e) {
                        final grad = _kArtistGradients[e.key % _kArtistGradients.length];
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.totalViews.toDouble(),
                              gradient: LinearGradient(
                                colors: grad,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 20,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= data.length) return const SizedBox();
                              final name = data[idx].artist.split(' ').first;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  name,
                                  style: _axisStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                '${(value / 1000000).toStringAsFixed(0)}M',
                                style: _axisStyle(),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: _darkGrid(maxY / 4),
                      borderData: FlBorderData(show: false),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Top Genres ────────────────────────────────────────────────────────────────
class _TopGenresTab extends StatelessWidget {
  final Future<List<TopGenre>> future;
  const _TopGenresTab({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TopGenre>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return snapshot.hasError
              ? ErrorState(message: '${snapshot.error}')
              : const LoadingState();
        }
        final data = snapshot.data!;
        if (data.isEmpty) return const EmptyState(icon: Icons.bar_chart, message: 'Pas de données');

        final maxY = data.map((e) => e.totalViews).reduce((a, b) => a > b ? a : b) * 1.25;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Vues par genre musical'),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      backgroundColor: Colors.transparent,
                      barTouchData: BarTouchData(
                        touchTooltipData: _darkTooltip(
                          (y) => '${(y / 1000000).toStringAsFixed(0)}M',
                        ),
                      ),
                      barGroups: data.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.totalViews.toDouble(),
                              gradient: _kBarGradient,
                              width: 36,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= data.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(data[idx].genre, style: _axisStyle()),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                '${(value / 1000000).toStringAsFixed(0)}M',
                                style: _axisStyle(),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: _darkGrid(maxY / 4),
                      borderData: FlBorderData(show: false),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
