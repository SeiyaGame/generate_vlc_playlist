# VLC Playlist Generator

## Description

This script generates VLC-compatible XSPF playlists from a media library. 
It scans a specified folder for media files with allowed extensions, make download links, and generates playlists 
for all files or the latest ones (up to 100 files). The playlists are saved in the output directory.

## Usage

1. Edit the script configuration

- Set the media library folder: `folder_media`
- Set the playlist output folder: `playlist_output_folder`
- Set the base download URL: `url_dl`
- Specify allowed media extensions: `allowed_extensions`

2. Run the script

```
python playlist_generator.py
```

Playlists are saved in the `playlist_output_folder` with the format:

```bash
all-playlist-<subfolder>.xspf
latest-playlist-<subfolder>.xspf
```

# Credit
Inspired by https://github.com/sfonteneau/generate_xspf