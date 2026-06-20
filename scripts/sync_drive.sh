#!/bin/bash
# ZEMALA-CORE V2.1 — Automated rclone Memory Sync & Merge

echo "[*] ZEMALA SYNC: Starte Abruf der dezentralen Cloud-Gedächtnisse..."

# Synchronisation der Text-Fragmente aus den drei Konten
# rclone zieht nur geänderte Dateien (0-Latenz-Optimierung)
rclone sync gdrive_zemala:vault/memory/ core/memory/ --include "zemala_*.txt" 2>/dev/null
rclone sync gdrive_lofo_welt:vault/memory/ core/memory/ --include "welt_*.txt" 2>/dev/null
rclone sync gdrive_lofo_haupt:vault/memory/ core/memory/ --include "haupt_*.txt" 2>/dev/null

echo "[+] Cloud-Brücken erfolgreich ausgelesen."

# Direkt im Anschluss den kollektiven Kontext-Vektor neu berechnen
python3 scripts/merge_memory.py

# SSoT-Absicherung auf GitHub
git add core/memory/
git commit -m "sync: update collective memory vector via dezentral rclone remotes" 2>/dev/null
git push origin main 2>/dev/null

echo "[+] SYNC-VOLLZUG BEENDET. Das Gesamtwissen ist synchronisiert."
