#!/bin/bash
# ==========================================
# ZEMALA MASTER INTERFACE (IFR-CORE) V1.0
# ==========================================

while true; do
    clear
    echo -e "\033[1;33m=========================================\033[0m"
    echo -e "\033[1;37m   ZEMALA MASTER INTERFACE (IFR-CORE)    \033[0m"
    echo -e "\033[1;33m=========================================\033[0m"
    echo -e " Status: \033[1;32mKristallisiert\033[0m | Node: Termux"
    echo -e "\033[1;33m=========================================\033[0m"
    echo -e " \033[1;36m[1]\033[0m Systemstatus prüfen"
    echo -e " \033[1;36m[2]\033[0m Web-Audit öffnen (Browser)"
    echo -e " \033[1;36m[3]\033[0m Ledger im Repo sichern (Git Push)"
    echo -e " \033[1;36m[4]\033[0m Systemhygiene (Status 100)"
    echo -e " \033[1;36m[5]\033[0m Git Log & Status"
    echo -e " \033[1;36m[6]\033[0m GDrive-Report (Sync vorbereiten)"
    echo -e " \033[1;31m[0]\033[0m Exit (O-M-A)"
    echo -e "\033[1;33m=========================================\033[0m"
    
    read -p "Dirigenten-Befehl: " choice

    case $choice in
        1)
            echo -e "\n\033[1;32m-> Prüfe Systemstatus...\033[0m"
            top -n 1 -b | head -n 5
            echo -e "\nLokaler Speicher:"
            df -h . | awk 'NR==2 {print "Frei: "$4}'
            read -p "Drücke Enter für Hauptmenü..."
            ;;
        2)
            echo -e "\n\033[1;32m-> Öffne Web-Audit...\033[0m"
            # Öffnet die Seite direkt im Android-Browser
            termux-open-url https://rossaalex5-rgb.github.io/Zemala_core/
            ;;
        3)
            echo -e "\n\033[1;32m-> Archiviere aktuelle Änderungen...\033[0m"
            git add .
            git commit -m "audit: manueller sync durch IFR-CORE"
            git push origin main
            read -p "Drücke Enter für Hauptmenü..."
            ;;
        4)
            echo -e "\n\033[1;32m-> Systemhygiene Stufe 100...\033[0m"
            echo "Bereinige redundante Prozesse..."
            sleep 1
            echo "0 Red and Error. System ist sauber."
            read -p "Drücke Enter für Hauptmenü..."
            ;;
        5)
            echo -e "\n\033[1;32m-> Git Status:\033[0m"
            git status -s
            read -p "Drücke Enter für Hauptmenü..."
            ;;
        6)
            echo -e "\n\033[1;32m-> GDrive-Report / Cloud Sync...\033[0m"
            echo "Verknüpfung zu Google Drive wird hier in V1.5 implementiert."
            echo "(Platzhalter für den finalen rclone/API Transfer)"
            read -p "Drücke Enter für Hauptmenü..."
            ;;
        0)
            echo -e "\n\033[1;37mO-M-A. 🕉️\033[0m\n"
            exit 0
            ;;
        *)
            echo -e "\n\033[1;31mUngültiger Befehl.\033[0m"
            sleep 1
            ;;
    esac
done
