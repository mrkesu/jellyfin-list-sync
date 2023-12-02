import 'dart:convert';
import 'package:http/http.dart' as http;

class Jellyfin {
  final String serverUrl;
  final String apiKey;
  final String userId;
  List<dynamic>? allMedia;

  Jellyfin(this.serverUrl, this.apiKey, this.userId);

  // So I guess /Items initially just returns a list of the "My Media" folders no matter what we ask for.
  Future<List<String>> getInitialIds() async {
    final url = Uri.parse('$serverUrl/Items?userId=$userId');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return (json.decode(response.body)['Items'] as List)
          .map((item) => item['Id'].toString())
          .toList();
    } else {
      print(
          'Failed to get initial IDs. HTTP status code: ${response.statusCode}');
      return [];
    }
  }

  // searchTerm= doesn't work, the API documentation lies.
  // So we just have to get everything and filter it ourselves ¯\_(ツ)_/¯
  Future<List<dynamic>> getItemsByParentId(String parentId) async {
    final url = Uri.parse('$serverUrl/Items?userId=$userId&parentId=$parentId');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body)['Items'];
    } else {
      print('Failed to get movies. HTTP status code: ${response.statusCode}');
      return [];
    }
  }

  // Supposedly we can get IMDB or TMDB ids via /Items/{itemId}/ExternalIdInfos
  // This, again, is a lie. The API documentation is wrong. It returns {0} as id for all external providers.

  dynamic searchMediaByTitle(String mediaTitle) {
    return allMedia?.firstWhere(
      (media) => media['Name'].toLowerCase() == mediaTitle.toLowerCase(),
      orElse: () => null,
    );
  }

  // I don't know why, but it looks like "UserData.Key" is the TMDB id.
  // No idea if this is univeral, or if that's just my server.
  // Anyway it's great because we can search by ID instead of title.
  dynamic searchMediaByTMDBId(String tmdbId) {
    return allMedia?.firstWhere(
      (media) => media['UserData']['Key'].toString() == tmdbId,
      orElse: () => null,
    );
  }

  Future<void> fetchAllMedia() async {
    final initialIds = await getInitialIds();
    var media = <dynamic>[];
    for (String parentId in initialIds) {
      final mediaInParent = await getItemsByParentId(parentId);
      media.addAll(mediaInParent);
    }
    allMedia = media;
  }

  Future<void> createPlaylist(
      String playlistName, List<String> movieIds) async {
    var url = Uri.parse('$serverUrl/Playlists');

    final playlistId = await findPlaylist(playlistName);

    if (playlistId != "") {
      print('Playlist already exists. Updating playlist id $playlistId.');
      url = Uri.parse('$serverUrl/Playlists/$playlistId/Items?userId=$userId');
    }

    final playlistData = {
      'Name': playlistName,
      'Ids': movieIds,
      'UserId': userId,
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(playlistData),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      print(
          'Failed to create playlist. HTTP status code: ${response.statusCode}');
    }
  }

  Future<String> findPlaylist(String playlistName) async {
    final url = Uri.parse('$serverUrl/Users/$userId/Items/');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final playlists = json.decode(response.body)['Items'];
      final playlistIds = playlists
          .where((playlist) => playlist['CollectionType'] == 'playlists')
          .map((playlist) => playlist['Id'].toString())
          .toList();

      for (String playlistId in playlistIds) {
        final playlistItems = await getItemsByParentId(playlistId);
        for (var playlistItem in playlistItems) {
          if (playlistItem['Name'] == playlistName) {
            return playlistItem['Id'].toString();
          }
        }
      }
    } else {
      print(
          'Failed to get playlists. HTTP status code: ${response.statusCode}');
    }
    return "";
  }

  Future<void> deletePlaylist(String playlistId) async {
    final url = Uri.parse('$serverUrl/Playlists/$playlistId');

    final response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      print(
          'Failed to delete playlist. HTTP status code: ${response.statusCode}');
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Emby-Token': apiKey,
      };
}
