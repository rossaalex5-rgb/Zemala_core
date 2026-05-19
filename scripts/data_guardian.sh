#!/data/data/com.termux/files/usr/bin/bash
NETWORK_TYPE=$(termux-telephony-deviceinfo | grep -o '"data_state": "[^"]*' | grep -o '[^"]*$')
if [ "$NETWORK_TYPE" == "connected" ]; then
    RX_BYTES=$(cat /proc/net/dev | grep -E "rmnet|wlan" | awk '{print $2}' | paste -sd+ - | bc)
    RX_MB=$(echo "$RX_BYTES / 1024 / 1024" | bc)
    if [ $RX_MB -gt 1500 ]; then
        termux-vibrate -d 500
        termux-tts-speak "Achtung Alex! Packgrenze fast erreicht. Sitzungsverbrauch bei $RX_MB Megabyte."
    fi
fi
