FROM python:3-slim

RUN apt-get update && apt-get install -y --no-install-recommends cron gosu && rm -rf /var/lib/apt/lists/*

# Create abc user/group
RUN groupadd -g 1000 abc && useradd -u 1000 -g abc -d /app -s /bin/sh -M abc

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY generate_vlc_playlist.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENV FOLDER_MEDIALIBRARY=/medialibrary
ENV PLAYLIST_OUTPUT_FOLDER=/output

ENTRYPOINT ["/app/entrypoint.sh"]
