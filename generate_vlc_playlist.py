import os
import re
import urllib.parse
from jinja2 import Template
from typing import List, Dict

folder_media = r"S:\medialibrary" # Folder that contains all of you downloaded media
playlist_output_folder = r"." # Where to save vlc playlist (Default Current directory)
url_dl = r"https://dl.web.fr/api/public/dl/random_uuid" # Start of public download url

allowed_extensions = (".mkv", ".mp4", ".mp3", ".avi") # Media content you want to get in your playlist


def clean_title(title: str) -> str:
    return re.sub(r'[^a-zA-Z0-9\s()\[\]._-]', '', title)


def get_files(base_folder: str, latest: bool = False) -> List[str]:
    files_output = []
    for root, _, files in os.walk(base_folder):
        for file in files:
            if file.lower().endswith(allowed_extensions):
                full_path = os.path.join(root, file)
                if latest:
                    modification_time = os.path.getmtime(full_path)
                    files_output.append((full_path, modification_time))
                else:
                    files_output.append(full_path)
    if latest:
        files_output.sort(key=lambda x: x[1], reverse=True)
        return [file_info[0] for file_info in files_output]

    return files_output


def generate_file_dict(base_folder: str, base_url: str, max_size: int = -1, latest: bool = False) \
        -> Dict[int, Dict[str, int]]:

    files = get_files(base_folder, latest)
    if max_size > 0:
        files = files[:max_size]

    files_dict = {}
    for index, full_path in enumerate(files):
        relative_path = os.path.relpath(full_path, folder_media)
        url_path = urllib.parse.quote(relative_path.replace("\\", "/"))
        title = clean_title(os.path.splitext(os.path.basename(full_path))[0])

        files_dict[index] = {
            "title": title,
            "url": f"{base_url}/{url_path}",
            "index": index
        }
        index += 1
    return files_dict


# Template XSPF
template = Template(r"""<?xml version="1.0" encoding="UTF-8"?>
<playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">
    <title>Playlist</title>
    <trackList>
        {% for entry in files_dict.values() %}
        <track>
            <title>{{ entry.title }}</title>
            <location>{{ entry.url }}</location>
            <extension application="http://www.videolan.org/vlc/playlist/0">
                <vlc:id>{{ entry.index }}</vlc:id>
                <vlc:option>network-caching=2000</vlc:option>
            </extension>
        </track>
        {% endfor %}
    </trackList>
    <extension application="http://www.videolan.org/vlc/playlist/0">
        {% for entry in files_dict.values() %}
        <vlc:item tid="{{ entry.index }}"/>
        {% endfor %}
    </extension>
</playlist>
""")


def main():
    for folder in os.listdir(folder_media):
        base_folder = os.path.join(folder_media, folder)

        playlists = {
            "all": generate_file_dict(base_folder, url_dl),
            "latest": generate_file_dict(base_folder, url_dl, latest=True, max_size=100),
        }

        for prefix, files_dict in playlists.items():
            filename = f"{prefix}-playlist-{folder}.xspf"
            dest = os.path.join(playlist_output_folder, filename)
            playlist_content = template.render(files_dict=files_dict)

            if not os.path.isdir(playlist_output_folder):
                print(f"Cannot save to {playlist_output_folder}, folder does not exist")
                return False

            with open(dest, "w", encoding="utf-8") as f:
                f.write(playlist_content)

            print(f"Playlist {prefix} for {folder} generated : {filename}")


if __name__ == "__main__":
    main()
