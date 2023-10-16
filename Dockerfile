# I have no idea how to make Dockerfiles, I just asked ChatGPT to do it for me and edited this file a little bit

# Use the official Dart image as the base image
FROM google/dart:latest AS build

# Copy your Dart code into the image
COPY . /app

# Set the working directory
WORKDIR /app

# Get all dependencies
RUN pub get

# Compile your Dart code to native executable
RUN dart compile exe bin/jellyfin_list_sync.dart -o /app/jellyfin_list_sync

# Use a base image with cron installed
FROM debian:buster-slim

# Copy the compiled executable from the build image + config file
COPY --from=build /app/jellyfin_list_sync /app/jellyfin_list_sync
COPY --from=build /app/config.json /app/config.json

# Install cron
RUN apt-get update && apt-get install -y cron

# Add the cron job
RUN echo "0 * * * * /app/jellyfin_list_sync >> /var/log/cron.log 2>&1" | crontab -

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
