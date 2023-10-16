# Specify the Dart SDK base image
FROM dart:latest AS build

# Set the environment variables
ENV JELLYFIN_SERVER_URL=""
ENV JELLYFIN_API_KEY=""
ENV JELLYFIN_USER_ID=""
ENV TRAKT_API_KEY=""
ENV TRAKT_USERNAME=""
ENV JELLYFIN_SEARCH_METHOD=""

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Get all dependencies and build the project
RUN dart pub get
RUN dart compile exe bin/jellyfin_list_sync.dart -o /app/jellyfin_list_sync

# Use a minimal base image for the runtime
FROM debian:buster-slim

# Copy the compiled executable from the build image
COPY --from=build /app/jellyfin_list_sync /app/jellyfin_list_sync

# Create entry script
RUN { echo "#!/bin/sh"; echo "while :; do"; echo "    /app/jellyfin_list_sync --jellyfinServerUrl=\$JELLYFIN_SERVER_URL --jellyfinApiKey=\$JELLYFIN_API_KEY --jellyfinUserId=\$JELLYFIN_USER_ID --traktApiKey=\$TRAKT_API_KEY --traktUsername=\$TRAKT_USERNAME --jellyfinSearchMethod=\$JELLYFIN_SEARCH_METHOD"; echo "    sleep 1800"; echo "done"; } > /app/entry.sh && chmod +x /app/entry.sh

# Set the entry script as the entry point
ENTRYPOINT ["/app/entry.sh"]
