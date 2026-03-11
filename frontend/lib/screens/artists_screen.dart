import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../services/api_service.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  late Future<List<Artist>> _artists;

  @override
  void initState() {
    super.initState();
    _artists = ApiService().getArtists();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Artist>>(
      future: _artists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        final artists = snapshot.data!;
        if (artists.isEmpty) {
          return const Center(child: Text('Aucun artiste trouvé.'));
        }
        return ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ListTile(
              leading: const Icon(Icons.mic),
              title: Text(artist.name),
              subtitle: artist.genre != null ? Text(artist.genre!) : null,
            );
          },
        );
      },
    );
  }
}
