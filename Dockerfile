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
COPY --from=build /bin/config.json /app/config.json

# Install cron
RUN apt-get update && apt-get install -y cron

# Add the cron job
RUN echo "0 * * * * /app/jellyfin_list_sync --jellyfinServerUrl=\$JELLYFIN_SERVER_URL --jellyfinApiKey=\$JELLYFIN_API_KEY --jellyfinUserId=\$JELLYFIN_USER_ID --traktApiKey=\$TRAKT_API_KEY --traktUsername=\$TRAKT_USERNAME --jellyfinSearchMethod=\$JELLYFIN_SEARCH_METHOD >> /var/log/cron.log 2>&1" | crontab -

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
