import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show kPrimary, kSecondary, kTextPri, kTextSec;
import '../models/artist.dart';
import '../models/favorite.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../state/favorites_notifier.dart';
import '../widgets/glass_card.dart';
import '../widgets/shared.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  List<Song>? _songs;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    FavoritesNotifier.instance.addListener(_onFavoritesChanged);
    _loadData();
  }

  @override
  void dispose() {
    FavoritesNotifier.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    try {
      final songs = await _api.getSongsByArtist(widget.artist.id);
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
        artistName: song.artistName ?? widget.artist.name,
      );
      FavoritesNotifier.instance.add(tempFav);
      try {
        await _api.addFavorite(userId: userId, songId: song.id);
      } catch (_) {
        FavoritesNotifier.instance.remove(song.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.artist.name,
          style: GoogleFonts.inter(
            color: kTextPri,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: kTextPri),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0A1E), Color(0xFF1A1035), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const LoadingState()
              : _error != null
                  ? ErrorState(message: _error!)
                  : _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    final songs = _songs!;
    if (songs.isEmpty) {
      return const EmptyState(
        icon: Icons.music_off,
        message: 'Aucune chanson trouvée',
      );
    }
    final favIds = FavoritesNotifier.instance.favoritedIds;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: songs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final song = songs[index];
        return _SongDetailTile(
          song: song,
          isFavorited: favIds.contains(song.id),
          onToggle: () => _toggleFavorite(song),
        );
      },
    );
  }
}

class _SongDetailTile extends StatelessWidget {
  final Song song;
  final bool isFavorited;
  final VoidCallback onToggle;

  const _SongDetailTile({
    required this.song,
    required this.isFavorited,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (song.year != null) '${song.year}',
      if (song.language != null) song.language!,
    ];
    final subtitle = parts.join(' • ');

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kPrimary.withValues(alpha: 0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 20),
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
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (song.language != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kSecondary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: kSecondary.withValues(alpha: 0.35), width: 1),
                ),
                child: Text(
                  song.language!.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          GestureDetector(
            onTap: onToggle,
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
