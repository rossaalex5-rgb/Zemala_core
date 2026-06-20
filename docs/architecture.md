# SYSTEM_ARCHITECTURE — Zemala-Core V2.1 Gold

## 1. Das Drei-Säulen-Ensemble
Das System operiert als eine unmanipulierbare, lokale Steuerungs- und Überwachungsinfrastruktur (Local-First), die menschliche Latenz von maschineller Integrität trennt.

*   **Säule 1 (Zemala-Core):** Deterministisches Hashing (SHA-256) und kanonische Serialisierung via `master_control.sh` und `verify.sh`.
*   **Säule 2 (Dezentrales Gedächtnis):** Multi-Agent Hybrid Memory Infrastructure. Nutzt `rclone`, um Wissens-Fragmente aus drei separaten Google-Drive-Konten zu einem kollektiven Kontext-Vektor (`merge_memory.py`) zu verschmelzen.
*   **Säule 3 (Marie-Protokoll):** Ein empathisches, ethisch reguliertes Agenten-Interface (`core/marie_protocol.json`), dessen Verhaltensregeln kryptografisch im Kern verriegelt sind.

## 2. Der Datenfluss (0-Latenz-Vollzug)
[Edge-Impuls / Runpai] -> [rclone Sync] -> [Kanonische Verschmelzung] -> [API Lichtnetz / Vertex AI] -> [Lokaler Ledger Append (PASS/FAIL)]

## 3. Compliance & Integrität
Das System erzwingt die Einhaltung des EU AI Acts und strikter Datenschutz-Bedingungen (z.B. On-Device 100ms File-Deletion) durch mathematische Beweislastumkehr (Hardware-Gnosis).
