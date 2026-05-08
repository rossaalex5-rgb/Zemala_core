async function sha256hex(str) {
  const enc = new TextEncoder();
  const data = enc.encode(str);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2,'0')).join('');
}

document.getElementById('hashBtn').addEventListener('click', async () => {
  const input = document.getElementById('input').value.trim();
  if (!input) {
    document.getElementById('output').textContent = 'ERROR: No input';
    return;
  }
  try {
    const parsed = JSON.parse(input);
    const canonical = JSON.stringify(parsed);
    const h = await sha256hex(canonical);
    document.getElementById('output').textContent = h;
    const blob = new Blob([JSON.stringify({event: parsed, event_hash: h})], {type:'application/json'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'zemala_event.json';
    a.textContent = 'Download event';
    const out = document.getElementById('output');
    const old = document.getElementById('downloadLink');
    if (old) old.remove();
    a.id = 'downloadLink';
    a.style.display = 'block';
    a.style.marginTop = '8px';
    out.parentNode.appendChild(a);
  } catch (e) {
    document.getElementById('output').textContent = 'ERROR: Invalid JSON';
  }
});
