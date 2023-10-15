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

final jellyfinSearcher = JellyfinSearcher(
    config['jellyfinServerUrl'],
    config['jellyfinApiKey'],
    config['jellyfinUserId'],
  );

  final lists = await traktTVFetcher.fetchTraktTVLists();

  if (lists != null) {
    for (var list in lists) {
      final listId = list['ids']['trakt'].toString();

      if (list['name'] != 'mdblist-horrors') {
        continue;
      }

      print('List Name: ${list['name']}');

      final movies = await traktTVFetcher.fetchMoviesInList(listId);
      if (movies != null) {
        for (var movie in movies) {
          // print(
          //     'Movie Title: ${movie['movie']['title']}\t\t tmdbId: ${movie['movie']['ids']['tmdb']}');

          // final tmdbId = movie['movie']['ids']['tmdb'];
          // final jellyfinMovies =
          //     await jellyfinSearcher.searchMovieByTmdbId(tmdbId);
          final movieTitle = movie['movie']['title'];
          final jellyfinMovies = await jellyfinSearcher.searchMovieByTitle(movieTitle);

          if (jellyfinMovies != null && jellyfinMovies.isNotEmpty) {
            print('Movie found on Jellyfin: ${movie['movie']['title']}');
            // print(movie['movie']['ids']['tmdb']);
          }
        }
      }
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