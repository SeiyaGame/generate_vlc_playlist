#!/bin/sh

PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo "
──────────────────────────────────
GID/UID
──────────────────────────────────
User uid:    $(id -u abc)
User gid:    $(id -g abc)
──────────────────────────────────"

# Adjust abc user/group to match requested PUID/PGID
if [ "$(id -u abc)" != "$PUID" ]; then
    usermod -o -u "$PUID" abc
fi
if [ "$(id -g abc)" != "$PGID" ]; then
    groupmod -o -g "$PGID" abc
fi

echo "
Setting PUID=$PUID and PGID=$PGID
"

# Create and fix ownership
mkdir -p "$FOLDER_MEDIALIBRARY" "$PLAYLIST_OUTPUT_FOLDER"
chown abc:abc /app "$PLAYLIST_OUTPUT_FOLDER"

# Build env file for cron context
printenv | grep -E '^(FOLDER_MEDIALIBRARY|PLAYLIST_OUTPUT_FOLDER|URL_DL|ALLOWED_EXTENSIONS)=' > /app/env.sh
sed -i 's/^/export /' /app/env.sh
chown abc:abc /app/env.sh

# Run once at startup
gosu abc python /app/generate_vlc_playlist.py

# Setup cron
echo "$CRON_SCHEDULE gosu abc /bin/sh -c '. /app/env.sh && python /app/generate_vlc_playlist.py' >> /proc/1/fd/1 2>&1" > /etc/cron.d/playlist-cron
chmod 0644 /etc/cron.d/playlist-cron
crontab /etc/cron.d/playlist-cron

echo "Cron scheduled: $CRON_SCHEDULE"

# Start cron in foreground
cron -f
