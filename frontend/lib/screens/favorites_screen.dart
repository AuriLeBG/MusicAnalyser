import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show kPrimary, kSecondary, kTextPri, kTextSec;
import '../models/favorite.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../state/favorites_notifier.dart';
import '../widgets/glass_card.dart';
import '../widgets/shared.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  String? _error;
  bool _loading = true;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = await _auth.getUserId();
      if (userId == null) {
        FavoritesNotifier.instance.setFavorites([]);
        setState(() => _loading = false);
        return;
      }
      final favorites = await _api.getFavorites(userId: userId);
      FavoritesNotifier.instance.setFavorites(favorites);
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _remove(Favorite fav) async {
    final userId = await _auth.getUserId();
    if (userId == null) return;
    final removed = FavoritesNotifier.instance.remove(fav.songId);
    try {
      await _api.removeFavorite(userId: userId, songId: fav.songId);
    } catch (_) {
      if (removed != null) FavoritesNotifier.instance.add(removed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenTitle(title: 'Favoris'),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingState();
    if (_error != null) return ErrorState(message: _error!);

    final favorites = FavoritesNotifier.instance.favorites;
    if (favorites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'Aucun favori pour cet utilisateur',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: kPrimary,
      backgroundColor: const Color(0xFF1A1035),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final fav = favorites[index];
          return _FavoriteTile(
            favorite: fav,
            animIndex: index,
            onRemove: () => _remove(fav),
          );
        },
      ),
    );
  }
}

// ── Tile favori ───────────────────────────────────────────────────────────────
class _FavoriteTile extends StatefulWidget {
  final Favorite favorite;
  final int animIndex;
  final VoidCallback onRemove;

  const _FavoriteTile({
    required this.favorite,
    required this.animIndex,
    required this.onRemove,
  });

  @override
  State<_FavoriteTile> createState() => _FavoriteTileState();
}

class _FavoriteTileState extends State<_FavoriteTile>
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
    final fav = widget.favorite;
    final title = fav.title ?? 'Chanson #${fav.songId}';
    final artist = fav.artistName ?? '';
    final year = fav.year;
    final lang = fav.language;

    final subtitleParts = <String>[
      if (artist.isNotEmpty) artist,
      if (year != null) '$year',
    ];
    final subtitle = subtitleParts.join(' • ');

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, kPrimary.withValues(alpha: 0.45)],
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
                      title,
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

              if (lang != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _LangBadge(language: lang),
                ),

              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                ),
              ),
            ],
          ),
        ),
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
