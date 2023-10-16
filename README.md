# Jellyfin List Sync

Trying to learn Dart.

This project is aimed at creating playlists in Jellyfin based on my movie lists on trakt.tv and IMDB.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

-   Dart: Make sure you have Dart installed on your machine. If not, follow the instructions [here](https://dart.dev/get-dart) to install Dart.
-   trakt.tv Account: Create an account on trakt.tv and generate an API key for accessing trakt.tv API.

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

3. Copy `config.example.json` to `config.json` and edit the file to add your trakt.tv\jellyfin information:
    ```json
    {
        "jellyfinServerUrl": "http://your-jellyfin-server:port",
        "jellyfinApiKey": "your-jellyfin-api-key",
        "jellyfinUserId": "your-jellyfin-user-id",
        "traktApiKey": "your-trakt-api-key",
        "traktUsername": "your-trakt-username"
    }
    ```

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

### Creating trakt.tv API key

1. Create an account on trakt.tv
2. Go to Settings -> API
3. Click on "Your API Apps"
4. Click on "New API App"
5. Enter the details and click on "Create API App"
6. Copy the Api key and paste it in the config.json file

### Creating Jellyfin API key

1. Login to Jellyfin
2. Go to Dashboard
3. Click on your username
4. Click on "API Keys"
5. Click on "New API Key"
6. Enter the details and click on "Create API Key"
7. Copy the Api key and paste it in the config.json file

## Docker

I want this to just run "somewhere" in the background, so I make a simple Dockerfile to build a container.

I'll try to see if I can automate something and add it to githubs container registry, but you can also make it yourself.

1. Make sure your config.json is correct.
2. Run `docker build -t jellyfin_list_sync_container .`
3. I just use Portainer, but I am guessing something like `docker run -d -e JELLYFIN_SERVER_URL=http://server:port -e JELLYFIN_API_KEY=123abc (etc...) jellyfin_list_sync_container` works to run it?

### Docker container environment variables

These will all need to be set for the container to work since we don't have a config.json file in the container.
| Variable | Description | Example |
| -------- | ----------- | ------- |
| JELLYFIN_SERVER_URL | The server adress and port for your Jellyfin instance | http://your-jellyfin-server:port |
| JELLYFIN_API_KEY | The API key for your Jellyfin instance | |
| JELLYFIN_USER_ID | The user ID for your Jellyfin instance | 00000000-0000-0000-0000-000000000000 |
| TRAKT_API_KEY | The API key for your trakt.tv account | |
| TRAKT_USERNAME | The username for your trakt.tv account | |
| JELLYFIN_SEARCH_METHOD | The search method to use when searching for movies in Jellyfin, can be "tmdb" or "title" | tmdb |

## Releases

I have no idea how github releases works, but I want to try it out for this project.

[ ] docker container

[ ] windowsexecutable

[ ] linux

## Made with

[Dart](https://dart.dev/)

[http](https://pub.dev/packages/http) - A Dart library for sending HTTP requests.

## Contributing

If you wish to contribute to this project, feel free to fork the repository and submit a pull request. You can also contact me via email if you have any suggestions or feedback.

## Stuff I learned from while making this

[Trakt API](https://trakt.docs.apiary.io/#reference/users/list)

[Jellyfin API](https://api.jellyfin.org/) <---- Slammed my head against this one for a while. It's full of blatant misinformation.

[Isolates and Event Loops - Flutter in Focus](https://youtu.be/vl_AaCgudcY)

[Dart Futures - Flutter in Focus](https://www.youtube.com/watch?v=OTS-ap9_aXc)

https://pub.dev/packages/http

https://dart.dev/guides/libraries/private-files

Insomnia client is nice.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
