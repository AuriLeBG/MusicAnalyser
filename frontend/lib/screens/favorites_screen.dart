import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Favorite>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = ApiService().getFavorites(userId: 1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Favorite>>(
      future: _favorites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        final favorites = snapshot.data!;
        if (favorites.isEmpty) {
          return const Center(child: Text('Aucun favori pour cet utilisateur.'));
        }
        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final fav = favorites[index];
            return ListTile(
              leading: const Icon(Icons.favorite),
              title: Text('Song #${fav.songId}'),
              subtitle: Text('User #${fav.userId}'),
            );
          },
        );
      },
    );
  }
}
