# Jellyfin List Sync

Trying to learn Dart.

This project is aimed at creating playlists in Jellyfin based on my lists on trakt.tv and IMDB.

And yes, this project is overly complicated. I'm using it not only to learn Dart, but also trying some more Github Actions, Releases and Docker stuff.

## Releases (executables)

Not done yet.

## Docker container

I want this to just run "somewhere" in the background, so I just build it as a simple container.

### Pulling my auto-created container from Github Packages container registry
`docker pull ghcr.io/mrkesu/jellyfin-list-sync:main`

### Building the container yourself
Run `docker build -t jellyfin_list_sync_container .`

### Running the container
I just use Portainer, but I am guessing something like `docker run -d -e JELLYFIN_SERVER_URL=http://server:port -e JELLYFIN_API_KEY=123abc (etc...) jellyfin_list_sync_container` works to run it?

### Docker container environment variables

These will all need to be set for the container to work since we don't have a config.json file in the container.
| Variable | Description | Example |
| -------- | ----------- | ------- |
| JELLYFIN_SERVER_URL | The server adress and port for your Jellyfin instance | http://your-jellyfin-server:port |
| JELLYFIN_API_KEY | The API key for your Jellyfin instance | |
| JELLYFIN_USER_ID | The user ID for your Jellyfin instance | |
| TRAKT_API_KEY | The API key for your trakt.tv account | |
| TRAKT_USERNAME | The username for your trakt.tv account | |
| JELLYFIN_SEARCH_METHOD | The search method to use when searching for movies in Jellyfin, can be "tmdb" or "title" | tmdb |
| INTERVAL_SECONDS | The interval in seconds between each sync | 1800 |

# Build-it-yourself instructions

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes, or if you have a healthy scepticism towards running random containers from the internet and prefer to check the code and build it yourself.

## Prerequisites

-   Dart: Make sure you have Dart installed on your machine. If not, follow the instructions [here](https://dart.dev/get-dart) to install Dart.
-   trakt.tv Account: Create an account on trakt.tv and [generate an API key](#creating-api-keys) for accessing trakt.tv API.

### Installation and configuration

1. Clone the repository:

    ```
    git clone https://github.com/mrkesu/jellyfin-list-sync.git
    cd jellyfin-playlist-creator
    ```

2. Install the dependencies:

    ```
    pub get
    ```

3. Copy `config.example.json` to `bin/config.json` and edit the file to add your trakt.tv\jellyfin information:
    ```json
    {
        "jellyfinServerUrl": "http://your-jellyfin-server:port",
        "jellyfinApiKey": "your-jellyfin-api-key",
        "jellyfinUserId": "your-jellyfin-user-id",
        "traktApiKey": "your-trakt-api-key",
        "traktUsername": "your-trakt-username",
        "jellyfinSearchMethod": "tmdb"
    }
    ```
PS: You can also use command line arguments to set the config values, but I find this a bit easier.

## Usage

Run the script to fetch your trakt.tv lists and print the names of the lists to the console:

```
dart run
```

## Compile your own binary

```
dart compile exe bin/jellyfin_list_sync.dart -o jellyfin_list_sync.exe
```

## Creating API keys

### Trakt.tv API key

1. Create an account on trakt.tv
2. Go to Settings -> API
3. Click on "Your API Apps"
4. Click on "New API App"
5. Enter the details and click on "Create API App"
6. Copy the Api key and paste it in the config.json file

### Jellyfin API key

1. Login to Jellyfin
2. Go to Dashboard
3. Click on your username
4. Click on "API Keys"
5. Click on "New API Key"
6. Enter the details and click on "Create API Key"
7. Copy the Api key and paste it in the config.json file

## Releases

I have no idea how github releases works, but I want to try it out for this project.

- [x] docker container
- [ ] windows executable
- [ ] linux executable
- [ ] mac executable


## Made with

- [Dart](https://dart.dev/)
- [Dart package: http](https://pub.dev/packages/http) - *"A composable, Future-based library for making HTTP requests"*
- [Dart package: args](https://pub.dev/packages/args) - *"Parses raw command-line arguments into a set of options and values"*
- [docker](https://www.docker.com/)

## Contributing

If you wish to contribute to this project, feel free to fork the repository and submit a pull request. You can also contact me via email if you have any suggestions or feedback.

## Stuff I learned from while making this

- [Trakt API](https://trakt.docs.apiary.io/#reference/users/list)
- [Jellyfin API](https://api.jellyfin.org/)
    - Slammed my head against this one for a while. Most of this doesn't work exactly as described 🙃
- [Isolates and Event Loops - Flutter in Focus](https://youtu.be/vl_AaCgudcY)
- [Dart Futures - Flutter in Focus](https://www.youtube.com/watch?v=OTS-ap9_aXc)
- [Dart - What not to commit](https://dart.dev/guides/libraries/private-files)
- [Dart - Effective Dart](https://dart.dev/effective-dart)
    - Trying to re-read every now and then as I get more comfortable with the language
- [Insomnia - The Collaborative API Client and Design Tool](https://insomnia.rest/)
    - I've typically used Postman, but found this refreshingly simple for my use cases.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
