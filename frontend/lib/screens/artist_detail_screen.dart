import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show kPrimary, kSecondary, kTextPri, kTextSec;
import '../models/artist.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/shared.dart';

class ArtistDetailScreen extends StatelessWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          artist.name,
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
          child: FutureBuilder<List<Song>>(
            future: ApiService().getSongsByArtist(artist.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingState();
              }
              if (snapshot.hasError) {
                return ErrorState(message: '${snapshot.error}');
              }

              final songs = snapshot.data!;
              if (songs.isEmpty) {
                return const EmptyState(
                  icon: Icons.music_off,
                  message: 'Aucune chanson trouvée',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: songs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return _SongDetailTile(song: song);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SongDetailTile extends StatelessWidget {
  final Song song;
  const _SongDetailTile({required this.song});

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ],
      ),
    );
  }
}
