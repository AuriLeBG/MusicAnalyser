import 'package:flutter/foundation.dart';
import '../models/favorite.dart';

/// Singleton partagé entre SongsScreen, ArtistDetailScreen et FavoritesScreen.
/// Toute modification (add/remove) est immédiatement visible sur les 3 écrans.
class FavoritesNotifier extends ChangeNotifier {
  static final FavoritesNotifier instance = FavoritesNotifier._();
  FavoritesNotifier._();

  final List<Favorite> _favorites = [];

  Set<int> get favoritedIds => _favorites.map((f) => f.songId).toSet();
  List<Favorite> get favorites => List.unmodifiable(_favorites);

  /// Remplace la liste complète (appelé au chargement initial depuis l'API).
  void setFavorites(List<Favorite> favs) {
    _favorites
      ..clear()
      ..addAll(favs);
    notifyListeners();
  }

  /// Ajout optimiste d'un favori.
  void add(Favorite fav) {
    if (!_favorites.any((f) => f.songId == fav.songId)) {
      _favorites.add(fav);
      notifyListeners();
    }
  }

  /// Suppression optimiste d'un favori. Retourne le favori retiré (pour rollback).
  Favorite? remove(int songId) {
    final idx = _favorites.indexWhere((f) => f.songId == songId);
    if (idx == -1) return null;
    final removed = _favorites.removeAt(idx);
    notifyListeners();
    return removed;
  }
}
