import 'dart:convert';
import 'package:http/http.dart' as http;

class JellyfinSearcher {
  final String serverUrl;
  final String apiKey;
  final String userId;
  

  JellyfinSearcher(this.serverUrl, this.apiKey, this.userId);

  Future<List<dynamic>?> searchMovieByTitle(String movieTitle) async {
    final encodedTitle = Uri.encodeQueryComponent(movieTitle);
    final url = Uri.parse('$serverUrl/Items?searchTerm=$encodedTitle&IncludeItemTypes=Movie&userId=$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Emby-Token': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['Items'];
    } else {
      print('Failed to search movie. HTTP status code: ${response.statusCode}');
      return null;
    }
  }

  // Would be better to search by external id, like tmdbId, but it doesn't work
  // Future<List<dynamic>?> searchMovieByTmdbId(int tmdbId) async {
  //   final url =
  //       Uri.parse('$serverUrl/Items?ExternalId=$tmdbId&IncludeItemTypes=Movie');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'X-Emby-Token': apiKey,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body)['Items'];
  //   } else {
  //     print('Failed to search movie. HTTP status code: ${response.statusCode}');
  //     return null;
  //   }
  // }

  // Bad method, but should work...
  Future<List<dynamic>?> searchMovieByTmdbId(int tmdbId) async {
    final url =
        Uri.parse('$serverUrl/Items?hasTmdbId=true&IncludeItemTypes=Movie&userId=$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Emby-Token': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final items = json.decode(response.body)['Items'];

      for (var item in items) {
              print(item['Name']);
              break;
        if(item['movie']['ids']['tmdb'] == tmdbId) {
          return [item];
        }
      }
      // return json.decode(response.body)['Items'];
    } else {
      print('Failed to search movie. HTTP status code: ${response.statusCode}');
      return null;
    }
  }
}
