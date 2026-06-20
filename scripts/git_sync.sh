#!/data/data/com.termux/files/usr/bin/bash
CORE_DIR="$HOME/zemala-core"
LEDGER_DIR="$HOME/deterministic-ledger"

function notify_success() {
    termux-vibrate -d 50
    termux-tts-speak -l de-DE "Synchronisation erfolgreich."
}

function notify_failure() {
    termux-vibrate -d 200 -f 50,50,50
    termux-tts-speak -l de-DE "Achtung! Git Fehler bei $1."
}

function sync_repo() {
    local repo_path=$1
    local repo_name=$2
    if [ -d "$repo_path/.git" ]; then
        cd "$repo_path" || return
        if [[ -n $(git status -s) ]]; then
            git add .
            git commit -m "Zemala Auto-Sync: $(date)" &> /dev/null
        fi
        if git push origin main &> /dev/null; then
            return 0
        else
            notify_failure "$repo_name"
            return 1
        fi
    fi
    return 0
}

# Hauptlauf
PING_RESULT=$(ping -c 1 8.8.8.8 &> /dev/null; echo $?)
if [ "$PING_RESULT" -eq 0 ]; then
    sync_repo "$CORE_DIR" "Core" && sync_repo "$LEDGER_DIR" "Ledger" && notify_success
fi
