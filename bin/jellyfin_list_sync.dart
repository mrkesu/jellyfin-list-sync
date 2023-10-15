// bin/jellyfin_list_sync.dart
import 'package:jellyfin_list_sync/trakttv.dart';
import 'package:jellyfin_list_sync/jellyfin.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  final config = await readConfig();

  final traktTVFetcher = TraktTVFetcher(
    config['traktApiKey'],
    config['traktUsername'],
  );

  final jellyfin = Jellyfin(
    config['jellyfinServerUrl'],
    config['jellyfinApiKey'],
    config['jellyfinUserId'],
  );

  final traktLists = await traktTVFetcher.fetchTraktTVLists();
  await jellyfin.fetchAllMedia();

  if (traktLists != null) {

    for (var list in traktLists) {

      List<String> jellyfinMediaIds = [];
      
      final listId = list['ids']['trakt'].toString();

      print('List Name: ${list['name']}');

      final traktMedias = await traktTVFetcher.fetchMoviesInList(listId);
      if (traktMedias != null) {
        for (var traktMedia in traktMedias) {
          // I'll only handle movies for now.
          if (traktMedia['type'] != 'movie') {
            continue;
          }

          final Map<String, dynamic>? jellyfinMedia;
          final tmdbId = traktMedia['movie']['ids']['tmdb'].toString();
          final movieTitle = traktMedia['movie']['title'];

          if (config['jellyfinSearchMethod'] == 'tmdb') {
            jellyfinMedia = await jellyfin.searchMediaByTMDBId(tmdbId);
          } else {
            jellyfinMedia = await jellyfin.searchMediaByTitle(movieTitle);
          }

          if (jellyfinMedia != null && jellyfinMedia.isNotEmpty) {
            jellyfinMediaIds.add(jellyfinMedia['Id'].toString());
            print(
                'Media found in Jellyfin. Trakt: ${traktMedia['movie']['title']} - Jellyfin: ${jellyfinMedia['Name']}');
          }
        }
      }

      await jellyfin.createCollection(list['name'], jellyfinMediaIds);
    }
  } else {
    print('Failed to fetch lists.');
  }
}

// Read config.json file
Future<Map<String, dynamic>> readConfig() async {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final file = File('${scriptDir.path}/config.json');
  final contents = await file.readAsString();
  return json.decode(contents);
}
