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

# Install cron
RUN apt-get update && apt-get install -y cron

# Create run script
RUN echo -e "#!/bin/sh\n\
    export JELLYFIN_SERVER_URL=\$JELLYFIN_SERVER_URL\n\
    export JELLYFIN_API_KEY=\$JELLYFIN_API_KEY\n\
    export JELLYFIN_USER_ID=\$JELLYFIN_USER_ID\n\
    export TRAKT_API_KEY=\$TRAKT_API_KEY\n\
    export TRAKT_USERNAME=\$TRAKT_USERNAME\n\
    export JELLYFIN_SEARCH_METHOD=\$JELLYFIN_SEARCH_METHOD\n\
    /app/jellyfin_list_sync" >> /app/run_script.sh \
    && chmod +x /app/run_script.sh

# Add the cron job
RUN echo "0 * * * * /app/run_script.sh >> /var/log/cron.log 2>&1" | crontab -

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
