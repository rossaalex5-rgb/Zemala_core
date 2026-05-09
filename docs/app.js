async function generateHash() {
    const input = document.getElementById('inputArea').value;
    if (!input) return;

    // 1. Hash berechnen
    const encoder = new TextEncoder();
    const data = encoder.encode(input);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

    // 2. Hash anzeigen
    document.getElementById('hashOutput').innerText = hashHex;

    // 3. JSON Export Objekt
    const exportData = {
        timestamp: new Date().toISOString(),
        input: input,
        hash: hashHex,
        system: "Zemala Core v1.0"
    };

    // 4. Download-Trigger (Optimiert für Mobile)
    const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `zemala-event-${Math.floor(Date.now() / 1000)}.json`;
    
    // Wichtig für Mobile: Das Element muss kurz im DOM sein
    document.body.appendChild(a);
    a.click();
    
    // Aufräumen
    setTimeout(() => {
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    }, 100);
}
