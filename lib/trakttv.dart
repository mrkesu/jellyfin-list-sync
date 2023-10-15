// lib/jellyfin_list_sync.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TraktTVFetcher {
  final String clientId;
  final String username;

  TraktTVFetcher(this.clientId, this.username);

  Future<List<dynamic>?> fetchTraktTVLists() async {
    final url = Uri.parse('https://api.trakt.tv/users/$username/lists');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': clientId,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load lists. HTTP status code: ${response.statusCode}');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMoviesInList(String listId) async {
    final url = Uri.parse('https://api.trakt.tv/users/$username/lists/$listId/items');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': clientId,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load movies. HTTP status code: ${response.statusCode}');
      return null;
    }
  }
}
