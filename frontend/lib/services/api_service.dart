import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artist.dart';
import '../models/favorite.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/api';

  Future<List<Artist>> getArtists() async {
    final response = await http.get(Uri.parse('$_baseUrl/artists'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Artist.fromJson(json)).toList();
    }
    throw Exception('Failed to load artists (${response.statusCode})');
  }

  Future<List<Favorite>> getFavorites({int userId = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites?userId=$userId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Favorite.fromJson(json)).toList();
    }
    throw Exception('Failed to load favorites (${response.statusCode})');
  }
}
