#!/usr/bin/env python3
import json
import os
import glob
from datetime import datetime

print("[+] ZEMALA MEMORY MERGE: Initialisiere Kollektiv-Gedächtnis...")

# Zielstruktur für das gebündelte Wissen
collective_knowledge = {
    "system": "ZEMALA-CORE",
    "compiled_at": datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
    "strands": {
        "zemala_core": [],
        "lofo_welt": [],
        "lofo_haupt": []
    }
}

# Pfade simulieren/einlesen (Hier landen deine rclone-Text-Abzüge)
# Das Skript scannt die lokalen Spiegelordner nach Text-Erkenntnissen
paths = {
    "zemala_core": "core/memory/zemala_*.txt",
    "lofo_welt": "core/memory/welt_*.txt",
    "lofo_haupt": "core/memory/haupt_*.txt"
}

for strand, pattern in paths.items():
    files = glob.glob(pattern)
    print(f"[*] Scanne {strand}: {len(files)} Fragmente gefunden.")
    for file_path in files:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read().strip()
            collective_knowledge["strands"][strand].append({
                "source": os.path.basename(file_path),
                "data": content
            })

# Kanonische Speicherung des Gesamtwissens in der SSoT
output_path = "core/memory/collective_context.json"
with open(output_path, "w", encoding="utf-8") as out:
    json.dump(collective_knowledge, out, indent=2, sort_keys=True)

print(f"[+] VOLLZUG: Kollektiver Kontext-Vektor erstellt unter {output_path}")
