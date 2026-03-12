import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../main.dart' show kPrimary, kSecondary, kTextPri, kTextSec;
import '../models/favorite.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../state/favorites_notifier.dart';
import '../widgets/glass_card.dart';
import '../widgets/shared.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  List<Song>? _songs;
  String? _error;
  bool _loading = true;
  String _searchQuery = '';

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
    FavoritesNotifier.instance.addListener(_onFavoritesChanged);
    _loadSongs();
  }

  @override
  void dispose() {
    FavoritesNotifier.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSongs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = await _auth.getUserId();
      final songs = await _api.getSongs();
      if (userId != null) {
        final favs = await _api.getFavorites(userId: userId);
        FavoritesNotifier.instance.setFavorites(favs);
      }
      setState(() {
        _songs = songs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    final userId = await _auth.getUserId();
    if (userId == null) return;

    final isFav = FavoritesNotifier.instance.favoritedIds.contains(song.id);

    if (isFav) {
      final removed = FavoritesNotifier.instance.remove(song.id);
      try {
        await _api.removeFavorite(userId: userId, songId: song.id);
      } catch (_) {
        if (removed != null) FavoritesNotifier.instance.add(removed);
      }
    } else {
      final tempFav = Favorite(
        userId: userId,
        songId: song.id,
        title: song.title,
        year: song.year,
        language: song.language,
        artistName: song.artistName,
      );
      FavoritesNotifier.instance.add(tempFav);
      try {
        await _api.addFavorite(userId: userId, songId: song.id);
      } catch (_) {
        FavoritesNotifier.instance.remove(song.id);
      }
    }
  }

  Color _colorForId(int id) => _palette[id % _palette.length];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenTitle(title: 'Chansons'),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SearchField(
              hint: 'Rechercher une chanson...',
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: _loading
                ? _buildShimmer()
                : _error != null
                    ? ErrorState(message: _error!)
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.12),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final songs = _songs!;
    final favIds = FavoritesNotifier.instance.favoritedIds;
    final filtered = _searchQuery.isEmpty
        ? songs
        : songs
            .where((s) =>
                s.title.toLowerCase().contains(_searchQuery) ||
                (s.artistName?.toLowerCase().contains(_searchQuery) ?? false))
            .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.music_off,
        message: 'Aucune chanson trouvée',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSongs,
      color: kPrimary,
      backgroundColor: const Color(0xFF1A1035),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final song = filtered[index];
          final color = _colorForId(song.id);
          return _SongTile(
            song: song,
            accentColor: color,
            isFavorited: favIds.contains(song.id),
            onToggleFavorite: () => _toggleFavorite(song),
          );
        },
      ),
    );
  }
}

// ── Tile chanson ──────────────────────────────────────────────────────────────
class _SongTile extends StatelessWidget {
  final Song song;
  final Color accentColor;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;

  const _SongTile({
    required this.song,
    required this.accentColor,
    required this.isFavorited,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (song.artistName != null) song.artistName!,
      if (song.year != null) '${song.year}',
    ];
    final subtitle = parts.join(' • ');

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: kTextPri,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: kTextSec),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          if (song.language != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _LangBadge(language: song.language!),
            ),

          GestureDetector(
            onTap: onToggleFavorite,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isFavorited
                    ? kPrimary.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFavorited
                      ? kPrimary.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? kPrimary : kTextSec,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge langue ──────────────────────────────────────────────────────────────
class _LangBadge extends StatelessWidget {
  final String language;
  const _LangBadge({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kSecondary.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kSecondary.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        language.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: kSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
