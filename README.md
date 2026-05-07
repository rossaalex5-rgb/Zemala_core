# ZEMALA Core 🧭
**Status: Marker 13 (Operational)**

ZEMALA Core ist ein lokales, deterministisches Event-System auf Termux-Basis. 

> "Wir speichern keine Zustände, sondern überprüfbare Ereignisverläufe."

### Kernfunktionen:
- **Emission:** `./scripts/lock_emit.sh` erzeugt fälschungssichere Events.
- **Integrität:** `./scripts/verify.sh` nutzt SHA-256 zur Validierung.
- **Rekonstruktion:** `./scripts/replay.sh` stellt die Zeitlinie wieder her.

### Sicherheit & Design:
- **Append-only:** Keine Datenlöschung, nur Ergänzung.
- **Kanonisch:** JSON-Normalisierung vor dem Hashing.
- **Autark:** Läuft zu 100% lokal auf Android/Termux.
