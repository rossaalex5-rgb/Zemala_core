#!/usr/bin/env bash
# zemala-setup.sh
# Zweck: Backup, Fusion, Pfad-Normalisierung, doctor, fix_sync, zz-runner
# Usage:
#   1) Kopieren: curl -sS ... > ~/zemala-core/scripts/zema_setup.sh
#   2) Machbar: chmod +x ~/zemala-core/scripts/zema_setup.sh
#   3) Dry run: DRY_RUN=true ~/zemala-core/scripts/zema_setup.sh
#   4) Wenn alles passt: DRY_RUN=false ~/zemala-core/scripts/zema_setup.sh

set -euo pipefail
Z="$HOME/zemala-core"

# -------------------------
# Konfiguration
# -------------------------
DRY_RUN="${DRY_RUN:-true}"        # true = nur anzeigen, false = ausführen
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
D_DASH="$HOME_DIR/zemala-core"
D_UNDERSCORE="$HOME_DIR/zemala_core"
B_DIR="$HOME_DIR/zemala_backup_$(date +%Y%m%d_%H%M%S)"
SCRIPTS_DIR="$D_DASH/scripts"
VAULT_DIR="$D_DASH/vault"
ARCHIVE_DIR="$VAULT_DIR/archive"
GNOSIS_PATH="$VAULT_DIR/gnosis_input.txt"
ZZ_ALIAS="${SCRIPTS_DIR}/zz.sh"

# Hilfsfunktionen
run() {
  if [ "$DRY_RUN" = "true" ]; then
    echo "[DRY] $*"
  else
    echo "[RUN] $*"
    eval "$@"
  fi
}

ensure_dir() {
  local d="$1"
  if [ ! -d "$d" ]; then
    run "mkdir -p \"$d\""
  fi
}

# -------------------------
# 1) Backups anlegen
# -------------------------
echo "==> 1) Erstelle Sicherheits-Backup in $B_DIR"
run "mkdir -p \"$B_DIR\""
if [ -d "$D_DASH" ]; then
  run "cp -a \"$D_DASH\" \"$B_DIR/dash_backup\""
fi
if [ -d "$D_UNDERSCORE" ]; then
  run "cp -a \"$D_UNDERSCORE\" \"$B_DIR/underscore_backup\""
fi

# -------------------------
# 2) Struktur anlegen und Fusion
# -------------------------
echo "==> 2) Erzeuge Standardstruktur und fusioniere (falls vorhanden)"
run "mkdir -p \"$SCRIPTS_DIR\" \"$D_DASH/logs\" \"$ARCHIVE_DIR\" \"$D_DASH/vault/inbox\" \"$D_DASH/docs\""

if [ -d "$D_UNDERSCORE" ]; then
  echo "   Fusioniere $D_UNDERSCORE -> $D_DASH (nur neue Dateien, keine Überschreibung)"
  run "cp -rn \"$D_UNDERSCORE\"/* \"$D_DASH\"/ 2>/dev/null || true"
fi

# -------------------------
# 3) Pfad-Normalisierung in Skripten
# -------------------------
echo "==> 3) Normalisiere Pfade in Skripten (zemala_core -> zemala-core)"
if [ -d "$SCRIPTS_DIR" ]; then
  # nur .sh, .py, .lua, .js
  run "find \"$SCRIPTS_DIR\" -type f \\( -name '*.sh' -o -name '*.py' -o -name '*.lua' -o -name '*.js' \\) -print0 | xargs -0 -r sed -i 's/zemala_core/zemala-core/g'"
fi

# -------------------------
# 4) .bashrc Absicherung
# -------------------------
echo "==> 4) Aktualisiere ~/.bashrc (ersetze zemala_core -> zemala-core), kein automatisches source"
if [ -f "$HOME_DIR/.bashrc" ]; then
  run "sed -i 's/zemala_core/zemala-core/g' \"$HOME_DIR/.bashrc\""
  echo "   Hinweis: .bashrc aktualisiert. Wenn du die Änderungen laden willst, führe 'source ~/.bashrc' manuell aus."
fi

# -------------------------
# 5) .gitignore vorbereiten
# -------------------------
echo "==> 5) Git-Vorbereitung (.gitignore ergänzen)"
if [ -d "$D_DASH" ]; then
  run "cd \"$D_DASH\" && touch .gitignore"
  for entry in "vault/" "logs/" "*.log" "backup/"; do
    run "cd \"$D_DASH\" && grep -qxF \"$entry\" .gitignore || echo \"$entry\" >> .gitignore"
  done
fi

# -------------------------
# 6) doctor.sh anlegen
# -------------------------
echo "==> 6) Erzeuge Diagnose-Skript: $SCRIPTS_DIR/doctor.sh"
run "cat > \"$SCRIPTS_DIR/doctor.sh\" <<'EOF'
#!/usr/bin/env bash
Z=\"$HOME/zemala-core\"
echo \"--- ZEMALA DIAGNOSE ---\"
for d in scripts vault/archive vault/inbox logs docs; do
  if [ -d \"$Z/$d\" ]; then
    echo \"[OK]  Ordner: $d\"
  else
    echo \"[ERR] Ordner fehlt: $d\"
  fi
done
if grep -q \"zemala-core\" \"$HOME/.bashrc\" 2>/dev/null; then
  echo \"[OK]  Alias in .bashrc\"
else
  echo \"[ERR] Alias in .bashrc fehlt oder falsch\"
fi
if command -v jq >/dev/null 2>&1; then
  echo \"[OK]  jq installiert\"
else
  echo \"[ERR] jq fehlt (empfohlen für JSON-Checks)\"
fi
echo \"-----------------------\"
EOF"
run "chmod +x \"$SCRIPTS_DIR/doctor.sh\""

# -------------------------
# 7) fix_sync.sh anlegen (Marie Sync / Gnosis Fix)
# -------------------------
echo "==> 7) Erzeuge fix_sync.sh (schreibt Gnosis Input und optional generate_ledger)"
run "cat > \"$SCRIPTS_DIR/fix_sync.sh\" <<'EOF'
#!/usr/bin/env bash
set -e
GNOSIS_PATH=\"$GNOSIS_PATH\"
LEDGER_SCRIPT=\"$SCRIPTS_DIR/generate_ledger.sh\"

mkdir -p \"$(dirname \"$GNOSIS_PATH\")\"
cat > \"$GNOSIS_PATH\" <<GEOF
[BEFEHL: SYSTEM-SYNCHRONISATION STUFE 100]
- Status-Validierung: Kette (Download -> zz -> Archiv -> t2) verifiziert.
- Null-Punkt-Fixierung: \"Kein Befehl gefunden\" = Gitter rein.
- Bereitschaft: IFR-Zelle aktiv.
- Haftung: Bindung an Drive-Ledger-Historie.
GEOF

echo \"Status: Befehl in $GNOSIS_PATH fixiert.\"

if [ -x \"$LEDGER_SCRIPT\" ]; then
  echo \"Trigger: generate_ledger.sh wird ausgeführt...\"
  bash \"$LEDGER_SCRIPT\"
else
  echo \"Hinweis: generate_ledger.sh nicht gefunden oder nicht ausführbar.\"
fi
EOF"
run "chmod +x \"$SCRIPTS_DIR/fix_sync.sh\""

# -------------------------
# 8) zz Runner anlegen (Event-basiert)
# -------------------------
echo "==> 8) Erzeuge zz Runner: $ZZ_ALIAS"
run "cat > \"$ZZ_ALIAS\" <<'EOF'
#!/usr/bin/env bash
# zz.sh - Event-trigger: verschiebt zemala-ledger-*.json aus /sdcard/Download nach vault/archive und startet Verarbeitung
set -e
DOWNLOAD_DIR=\"/sdcard/Download\"
ARCHIVE_DIR=\"$ARCHIVE_DIR\"
PROCESSOR=\"$SCRIPTS_DIR/zemala_execute.sh\"

mkdir -p \"$ARCHIVE_DIR\"
shopt -s nullglob
for f in \"\$DOWNLOAD_DIR\"/zemala-ledger-*.json; do
  echo \"Found: \$f -> moving to archive\"
  mv \"\$f\" \"$ARCHIVE_DIR/\" || cp -a \"\$f\" \"$ARCHIVE_DIR/\" && rm -f \"\$f\"
done

# optional: starte processor wenn vorhanden
if [ -x \"$PROCESSOR\" ]; then
  echo \"Starte Processor: $PROCESSOR\"
  bash \"$PROCESSOR\"
else
  echo \"Kein Processor gefunden. Falls vorhanden, lege $PROCESSOR an.\"
fi
EOF"
run "chmod +x \"$ZZ_ALIAS\""

# -------------------------
# 9) Sicherheits-Hinweise und Abschluss
# -------------------------
echo "==> Fertig. Zusammenfassung:"
echo " - Backup: $B_DIR"
echo " - Scripts: $SCRIPTS_DIR"
echo " - Doctor: $SCRIPTS_DIR/doctor.sh"
echo " - Fix Sync: $SCRIPTS_DIR/fix_sync.sh"
echo " - ZZ Runner: $ZZ_ALIAS"
echo " - Archive: $ARCHIVE_DIR"
echo
if [ "$DRY_RUN" = "true" ]; then
  echo "DRY RUN aktiv. Um Änderungen anzuwenden, setze DRY_RUN=false und führe das Skript erneut."
else
  echo "Änderungen wurden ausgeführt."
fi

exit 0
