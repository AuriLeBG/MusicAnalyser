import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artist.dart';
import '../models/favorite.dart';
import '../models/song.dart';
import '../models/analytics.dart';
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/api';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Artist>> getArtists({String? search}) async {
    final uri = search != null && search.isNotEmpty
        ? Uri.parse('$_baseUrl/artists?search=${Uri.encodeQueryComponent(search)}')
        : Uri.parse('$_baseUrl/artists');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Artist.fromJson(json)).toList();
    }
    throw Exception('Failed to load artists (${response.statusCode})');
  }

  Future<List<Song>> getSongsByArtist(int artistId,
      {int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artists/$artistId/songs?page=$page&size=$size'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] as List<dynamic>;
      return content.map((json) => Song.fromJson(json)).toList();
    }
    throw Exception('Failed to load songs for artist (${response.statusCode})');
  }

  Future<List<Favorite>> getFavorites({required int userId}) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites?userId=$userId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Favorite.fromJson(json)).toList();
    }
    throw Exception('Failed to load favorites (${response.statusCode})');
  }

  Future<Favorite?> addFavorite({required int userId, required int songId}) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/favorites'),
      headers: headers,
      body: jsonEncode({'userId': userId, 'songId': songId}),
    );
    if (response.statusCode == 201) {
      return Favorite.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> removeFavorite({required int userId, required int songId}) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/favorites?userId=$userId&songId=$songId'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  Future<List<Song>> getSongs({int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/songs?page=$page&size=$size'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] as List<dynamic>;
      return content.map((json) => Song.fromJson(json)).toList();
    }
    throw Exception('Failed to load songs (${response.statusCode})');
  }

  Future<List<ViewsByYear>> getViewsByYear() async {
    final response = await http.get(Uri.parse('$_baseUrl/analytics/views-by-year'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ViewsByYear.fromJson(json)).toList();
    }
    throw Exception('Failed to load views by year (${response.statusCode})');
  }

  Future<List<TopArtist>> getTopArtists({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/analytics/top-artists?limit=$limit'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TopArtist.fromJson(json)).toList();
    }
    throw Exception('Failed to load top artists (${response.statusCode})');
  }

  Future<List<TopGenre>> getTopGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/analytics/top-genres'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TopGenre.fromJson(json)).toList();
    }
    throw Exception('Failed to load top genres (${response.statusCode})');
  }
}
