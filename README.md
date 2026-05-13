# SYSTEM_FLOW — Observable System Trace für zemala-core

## Zweck
Diese Datei visualisiert den aktiven Laufzeitfluss des Zemala-Systems. Es handelt sich um ein geschlossenes End-to-End System für deterministische State-Integrität.

## Der Flow
**Input (Web-UI)** → **Hashing** → **Ledger Append** → **Local Persist** → **Audit Export** → **Validation**

---

### 1. Phasen des Vollzugs
1. **Eingabe:** Events via [Zemala Web Interface](https://rossaalex5-rgb.github.io/Zemala_core/).
2. **Initialer Hash:** SHA-256 Generierung im Frontend.
3. **Orchestrierung:** `scripts/sync_drive.sh` transferiert zu `vault/inbox/`.
4. **Validierung:** `scripts/zemala_execute.sh` prüft Integrität gegen `core/checksums_precommit.txt`.
5. **Finalisierung:** Ledger-Eintrag und Git-Versiegelung.

---
**Status: Stufe 100 | Conductor: rossaalex5-rgb**
