// bin/jellyfin_list_sync.dart
import 'package:jellyfin_list_sync/trakttv.dart';
import 'package:jellyfin_list_sync/jellyfin.dart';
import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';

ArgResults parseArguments(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('jellyfinServerUrl', help: 'Jellyfin server address and port')
    ..addOption('jellyfinApiKey', help: 'Jellyfin API key')
    ..addOption('jellyfinUserId', help: 'Jellyfin user ID')
    ..addOption('traktApiKey', help: 'Trakt.tv API key')
    ..addOption('traktUsername', help: 'Trakt.tv username')
    ..addOption('jellyfinSearchMethod',
        help: 'Search method to use when searching for media in Jellyfin',
        allowed: ['tmdb', 'title'],
        defaultsTo: 'tmdb');
  return parser.parse(arguments);
}

void main(List<String> arguments) async {
  final argResults = parseArguments(arguments);
  final config = await readConfig(argResults);

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

// Read config.json file or use arguments
Future<Map<String, dynamic>> readConfig(ArgResults argResults) async {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final file = File('${scriptDir.path}/config.json');

  if (await file.exists()) {
    final contents = await file.readAsString();
    return json.decode(contents);
  } else {
    if (argResults.arguments.isEmpty) {
      print('No config.json file found and no arguments provided.');
      exit(1);
    }
    return {
      'jellyfinServerUrl': argResults['jellyfinServerUrl'],
      'jellyfinApiKey': argResults['jellyfinApiKey'],
      'jellyfinUserId': argResults['jellyfinUserId'],
      'traktApiKey': argResults['traktApiKey'],
      'traktUsername': argResults['traktUsername'],
      'jellyfinSearchMethod': argResults['jellyfinSearchMethod'],
    };
  }
}
