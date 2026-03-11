import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show kPrimary, kSecondary, kTextPri, kTextSec;
import '../models/artist.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/shared.dart';
import 'artist_detail_screen.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  late Future<List<Artist>> _artistsFuture;
  Timer? _debounce;

  static const List<Color> _palette = [
    kPrimary,
    kSecondary,
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];

  @override
  void initState() {
    super.initState();
    _artistsFuture = ApiService().getArtists();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _artistsFuture = ApiService().getArtists(search: value.isEmpty ? null : value);
      });
    });
  }

  Color _colorFor(String name) =>
      _palette[name.hashCode.abs() % _palette.length];

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenTitle(title: 'Artistes'),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SearchField(
              hint: 'Rechercher un artiste...',
              onChanged: _onSearchChanged,
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Artist>>(
              future: _artistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }
                if (snapshot.hasError) {
                  return ErrorState(message: '${snapshot.error}');
                }

                final artists = snapshot.data!;

                if (artists.isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_search,
                    message: 'Aucun artiste trouvé',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: artists.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    final color = _colorFor(artist.name);
                    return _ArtistTile(
                      artist: artist,
                      accentColor: color,
                      initials: _initials(artist.name),
                      animIndex: index,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtistDetailScreen(artist: artist),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile artiste ──────────────────────────────────────────────────────────────
class _ArtistTile extends StatefulWidget {
  final Artist artist;
  final Color accentColor;
  final String initials;
  final int animIndex;
  final VoidCallback? onTap;

  const _ArtistTile({
    required this.artist,
    required this.accentColor,
    required this.initials,
    required this.animIndex,
    this.onTap,
  });

  @override
  State<_ArtistTile> createState() => _ArtistTileState();
}

class _ArtistTileState extends State<_ArtistTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 50 * widget.animIndex), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: widget.accentColor.withValues(alpha: 0.2),
          highlightColor: Colors.transparent,
          onTap: widget.onTap,
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar gradient
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      widget.initials,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Nom + genre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.artist.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: kTextPri,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.artist.genre != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.artist.genre!,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: kTextSec),
                        ),
                      ],
                    ],
                  ),
                ),

                // Année de naissance
                if (widget.artist.birthYear != null)
                  ColorChip(
                    label: '${widget.artist.birthYear}',
                    color: widget.accentColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
