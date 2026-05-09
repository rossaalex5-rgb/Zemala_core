async function generateHash() {
    const input = document.getElementById('inputArea').value;
    if (!input) return;

    const encoder = new TextEncoder();
    const data = encoder.encode(input);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

    document.getElementById('hashOutput').innerText = hashHex;

    const exportData = {
        timestamp: new Date().toISOString(),
        input: input,
        hash: hashHex,
        system: "Zemala Core v1.0"
    };

    // Robuster Download-Trigger für Android
    const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    
    a.style.display = 'none';
    a.href = url;
    a.download = `zemala-event-${Math.floor(Date.now() / 1000)}.json`;
    
    // WICHTIG: Das Element MUSS im Body sein, damit Chrome den Klick akzeptiert
    document.body.appendChild(a);
    a.click();
    
    setTimeout(() => {
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
    }, 100);
}
