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

# Run once at startup
gosu abc python /app/generate_vlc_playlist.py

# Setup cron
cat > /etc/cron.d/playlist-cron <<EOF
PATH=/usr/local/bin:/usr/sbin:/usr/bin:/bin
FOLDER_MEDIALIBRARY=$FOLDER_MEDIALIBRARY
PLAYLIST_OUTPUT_FOLDER=$PLAYLIST_OUTPUT_FOLDER
URL_DL=$URL_DL
ALLOWED_EXTENSIONS=$ALLOWED_EXTENSIONS
$CRON_SCHEDULE root gosu abc python /app/generate_vlc_playlist.py > /dev/stdout 2>&1
EOF
chmod 0644 /etc/cron.d/playlist-cron

echo "Cron scheduled: $CRON_SCHEDULE"

# Start cron in foreground
cron -f
