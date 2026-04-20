import xml.etree.ElementTree as ET
import json
import os
import urllib.parse

# 1. Configuration & Rules
XML_PATH = 'rekordbox.xml'
OUTPUT_HTML = os.path.expanduser('~/Documents/rekordbox_library_browser.html')

# Keywords for routing
IGNORE_PATHS = ['PioneerDJ', 'Demo Tracks', 'Sampler']
PEAK_ARTISTS = ['Excision', 'SVDDEN DEATH', 'MARAUDA', 'Playboi Carti', 'Ken Carson', 'Lil Uzi Vert', 'Hardwell', 'Dimitri Vegas', 'Pitbull', 'Lil Jon']
WARMUP_ARTISTS = ['Drake', 'Juice WRLD', 'Post Malone', 'The Weeknd', 'Ne-Yo', 'Akon']
BASS_KEYWORDS = ['Subtronics', 'Zeds Dead', 'Sullivan King']

data_map = {
    "Peak Time": {"Heavy Bass": [], "Big Room": [], "Modern Rap": [], "Old Rap": [], "Pop & Throwbacks": []},
    "Build-up": {"Heavy Bass": [], "Big Room": [], "Modern Rap": [], "Old Rap": [], "Pop & Throwbacks": []},
    "Warmup": {"Heavy Bass": [], "Big Room": [], "Modern Rap": [], "Old Rap": [], "Pop & Throwbacks": []},
    "Slowdown": {"Heavy Bass": [], "Big Room": [], "Modern Rap": [], "Old Rap": [], "Pop & Throwbacks": []}
}

def classify_track(track):
    path = urllib.parse.unquote(track.get('Location', '')).lower()
    artist = track.get('Artist', '')
    name = track.get('Name', '')
    bpm = float(track.get('AverageBpm', '0'))
    
    # Ignore samplers and demo tracks
    if any(ignore.lower() in path for ignore in IGNORE_PATHS):
        return

    # Determine Genre based on folder paths
    genre = "Pop & Throwbacks"
    if 'edm' in path or 'best-edm' in path:
        genre = "Big Room" if bpm == 128 else "Heavy Bass"
    elif 'rap' in path:
        genre = "Old Rap" if 'old rap' in path else "Modern Rap"
    elif 'throwbacks' in path:
        genre = "Pop & Throwbacks"

    track_data = {
        "Name": name,
        "Artist": artist,
        "BPM": bpm,
        "Key": track.get('Tonality', '')
    }

    # Determine Energy (Multi-fit logic)
    # Peak Time Check
    if any(a.lower() in artist.lower() for a in PEAK_ARTISTS) or (genre == 'Heavy Bass' and bpm >= 140) or (genre == 'Big Room'):
        data_map['Peak Time'][genre].append(track_data)
        if bpm < 140 and genre != 'Big Room': # Versatile track
            data_map['Build-up'][genre].append(track_data)
            
    # Warmup / Slowdown Check
    elif any(a.lower() in artist.lower() for a in WARMUP_ARTISTS) or (bpm > 0 and bpm < 95):
        data_map['Warmup'][genre].append(track_data)
        data_map['Slowdown'][genre].append(track_data) # Chill tracks go to both
        
    # Build-up (Default/Catch-all for mid-energy)
    else:
        data_map['Build-up'][genre].append(track_data)
        if bpm > 125: # Fast enough to potentially bleed into Peak Time
            data_map['Peak Time'][genre].append(track_data)

# 2. Parse XML
print("Parsing rekordbox.xml...")
tree = ET.parse(XML_PATH)
root = tree.getroot()

for track in root.findall('.//TRACK'):
    classify_track(track)

# 3. Generate HTML
print("Generating HTML Browser...")
html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Rekordbox Organization Review</title>
    <style>
        body {{ font-family: -apple-system, sans-serif; background-color: #1e1e1e; color: #fff; margin: 0; padding: 20px; }}
        h1 {{ border-bottom: 1px solid #333; padding-bottom: 10px; }}
        input {{ padding: 10px; width: 300px; margin-bottom: 20px; background: #333; border: 1px solid #555; color: #fff; border-radius: 5px;}}
        .folder {{ margin-bottom: 20px; background: #2a2a2a; border-radius: 8px; padding: 15px; border: 1px solid #444; }}
        .playlist {{ margin-left: 20px; margin-top: 10px; }}
        .playlist h3 {{ color: #00ffcc; cursor: pointer; }}
        .track-list {{ display: none; background: #1a1a1a; padding: 10px; border-radius: 5px; }}
        .track {{ padding: 5px 0; border-bottom: 1px solid #333; font-size: 14px; display: flex; justify-content: space-between;}}
        .bpm-key {{ color: #aaa; font-size: 12px; }}
    </style>
</head>
<body>
    <h1>Library Map Review</h1>
    <input type="text" id="search" placeholder="Search tracks or artists..." onkeyup="filterTracks()">
    <div id="content"></div>

    <script>
        const data = {json.dumps(data_map)};
        const contentDiv = document.getElementById('content');

        for (const [folder, playlists] of Object.entries(data)) {{
            let folderHtml = `<div class="folder"><h2>⚡ ${{folder}}</h2>`;
            for (const [playlist, tracks] of Object.entries(playlists)) {{
                if (tracks.length === 0) continue;
                folderHtml += `<div class="playlist">
                    <h3 onclick="this.nextElementSibling.style.display = this.nextElementSibling.style.display === 'block' ? 'none' : 'block'">
                        📁 ${{playlist}} (${{tracks.length}} tracks)
                    </h3>
                    <div class="track-list">`;
                tracks.forEach(t => {{
                    folderHtml += `<div class="track" data-search="${{t.Name.toLowerCase()}} ${{t.Artist.toLowerCase()}}">
                        <span><strong>${{t.Artist}}</strong> - ${{t.Name}}</span>
                        <span class="bpm-key">${{t.BPM}} BPM | ${{t.Key}}</span>
                    </div>`;
                }});
                folderHtml += `</div></div>`;
            }}
            folderHtml += `</div>`;
            contentDiv.innerHTML += folderHtml;
        }}

        function filterTracks() {{
            const query = document.getElementById('search').value.toLowerCase();
            document.querySelectorAll('.track').forEach(track => {{
                track.style.display = track.getAttribute('data-search').includes(query) ? 'flex' : 'none';
            }});
        }}
    </script>
</body>
</html>
"""

with open(OUTPUT_HTML, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"Done! Open this file in your browser: {OUTPUT_HTML}")