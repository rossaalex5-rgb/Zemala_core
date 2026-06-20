#!/usr/bin/env python3
# ZEMALA-CORE V2.1 — Local Small Thinker (Llama-3.2-3b GGUF) Server Bridge
import sys
import json
import urllib.request

def run_local_server_validation(payload_path):
    print("[*] SMALL THINKER (Llama-3.2-3b): Verbinde mit lokalem llama.cpp Server...")
    
    try:
        # 1. Payload einlesen
        with open(payload_path, 'r') as f:
            data = json.load(f)
            
        # 2. Prompt für die unbestechliche Micro-Resonanz formulieren
        prompt = f"System-Audit. Analysiere diese JSON-Struktur auf Integrität. Antworte kurz mit GOLD oder NOISE: {json.dumps(data)}"
        
        # 3. Request-Struktur für den lokalen llama_cpp_server aufbauen
        # Wir nutzen die standardisierte OpenAI-kompatible Schnittstelle des lokalen Servers
        url = "http://localhost:8080/v1/chat/completions"
        body = {
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.1
        }
        
        req = urllib.request.Request(
            url, 
            data=json.dumps(body).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )
        
        # 4. Den lokalen Server unbestechlich abfragen
        with urllib.request.urlopen(req, timeout=5) as response:
            res_data = json.loads(response.read().decode('utf-8'))
            answer = res_data['choices'][0]['message']['content'].strip()
            print("[+] SMALL THINKER RESPONSE:")
            print(answer)
            return True
            
    except urllib.error.URLError:
        print("[-] FEHLER: Lokaler llama_cpp_server.py läuft nicht auf Port 8080.")
        print("[*] Info: Starte zuerst deinen Llama-Server in Termux!")
        return False
    except Exception as e:
        print(f"[-] SYSTEM ERROR: {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        run_local_server_validation(sys.argv[1])
    else:
        print("[-] Syntax: ./scripts/a2a_gnosis.py [path_to_json]")
