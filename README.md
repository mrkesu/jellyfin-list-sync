# Jellyfin List Sync

Trying to learn Dart.

This project is aimed at creating playlists in Jellyfin based on my movie lists on trakt.tv and IMDB.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- Dart: Make sure you have Dart installed on your machine. If not, follow the instructions [here](https://dart.dev/get-dart) to install Dart.
- trakt.tv Account: Create an account on trakt.tv and generate an API key for accessing trakt.tv API.

### Installation

1. Clone the repository:
    ```
    git clone https://github.com/mrkesu/jellyfin-list-sync.git
    cd jellyfin-playlist-creator
    ```

2. Install the dependencies:
    ```
    pub get
    ```

3. Update the clientId and username variables in the main.dart file with your trakt.tv API client ID and username respectively.

## Usage
Run the script to fetch your trakt.tv lists and print the names of the lists to the console:

```
dart run
```

## Made with

[Dart](https://dart.dev/)

[http](https://pub.dev/packages/http) - A Dart library for sending HTTP requests.

## Contributing

If you wish to contribute to this project, feel free to fork the repository and submit a pull request. You can also contact me via email if you have any suggestions or feedback.

## License
This project is licensed under the MIT License - see the LICENSE.md file for details.