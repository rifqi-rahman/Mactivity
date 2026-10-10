/**
 * Mactivity — Showcase Landing Page Scripts
 * Live Telemetry Simulator & Interactive Hardware Switcher
 */

document.addEventListener('DOMContentLoaded', () => {
  initClock();
  initMenuBarPillToggle();
  initMetricModes();
  initHardwareSwitcher();
  initLiveTelemetryCanvases();
  initCopyButton();
  initDownloadTabs();
});

/* ==========================================================================
   1. LIVE MENU BAR CLOCK
   ========================================================================== */
function initClock() {
  const clockEl = document.getElementById('liveClock');
  if (!clockEl) return;

  function update() {
    const now = new Date();
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const day = days[now.getDay()];
    const hours = String(now.getHours()).padStart(2, '0');
    const mins = String(now.getMinutes()).padStart(2, '0');
    clockEl.textContent = `${day} ${hours}:${mins}`;
  }

  update();
  setInterval(update, 30000);
}

/* ==========================================================================
   2. INTERACTIVE MENU BAR PILL & BENTO POPOVER SIMULATOR
   ========================================================================== */
function initMenuBarPillToggle() {
  const pillBtn = document.getElementById('menuBarPill');
  const popover = document.getElementById('bentoPopover');
  if (!pillBtn || !popover) return;

  // Always ensure Bento Popover is open and visible by default on the showcase webpage
  popover.classList.remove('closed');
  pillBtn.classList.add('active');

  // Toggle only when the user explicitly clicks the status pill directly
  pillBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    const isClosed = popover.classList.toggle('closed');
    pillBtn.classList.toggle('active', !isClosed);
  });
}

/* ==========================================================================
   3. METRIC DISPLAY MODES SWITCHER
   ========================================================================== */
function initMetricModes() {
  const chips = document.querySelectorAll('#modeChips .chip');
  const pillIcon = document.getElementById('pillIcon');
  const pillMetric = document.getElementById('pillMetric');
  if (!chips.length || !pillIcon || !pillMetric) return;

  const modeData = {
    cpuAndNet:   { icon: '⊚', text: '14%  ↓28.4K' },
    cpuOnly:     { icon: '􀧓', text: '14%' },
    cpuAndRam:   { icon: '􀫥', text: '14% · 42%' },
    memoryOnly:  { icon: '􀫥', text: '42% RAM' },
    battery:     { icon: '􀛩', text: '94%⚡' },
    networkOnly: { icon: '􀤆', text: '↓1.4M ↑184K' },
    temperature: { icon: '􀇬', text: '44°C' },
    compactAll:  { icon: '⊚', text: 'C:14% M:42% ↓28K' }
  };

  chips.forEach(chip => {
    chip.addEventListener('click', () => {
      chips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');

      const modeKey = chip.getAttribute('data-mode');
      const data = modeData[modeKey] || modeData.cpuAndNet;

      pillIcon.textContent = data.icon;
      pillMetric.textContent = data.text;
    });
  });
}

/* ==========================================================================
   4. DYNAMIC HARDWARE INTELLIGENCE SWITCHER
   ========================================================================== */
function initHardwareSwitcher() {
  const tabs = document.querySelectorAll('#macTabs .mac-tab');
  const hwModel = document.getElementById('hwModel');
  const hwCores = document.getElementById('hwCores');
  const hwCooling = document.getElementById('hwCooling');
  const hwPower = document.getElementById('hwPower');
  const hwGpu = document.getElementById('hwGpu');
  const hwMemory = document.getElementById('hwMemory');

  // Also update Bento header badges
  const chipTitle = document.getElementById('chipTitleBadge');
  const chipTopology = document.getElementById('chipTopologyBadge');
  const fanText = document.getElementById('fanText');
  const gpuCoresBadge = document.getElementById('gpuCoresBadge');

  if (!tabs.length) return;

  const presets = {
    mbp: {
      model: 'MacBook Pro (14-inch, M4 Pro)',
      cores: '14 Cores (10 Performance + 4 Efficiency)',
      cooling: 'Dual Centrifugal Blowers (Active Left/Right RPM)',
      power: 'Battery Health 100%, 18 Cycles, MagSafe 3 Rail',
      gpu: '20-Core Hardware Ray Tracing Engine',
      memory: '48 GB Unified Memory (273 GB/s Bandwidth)',
      bentoChip: 'Apple M4 Pro',
      bentoTopo: '14 Cores (10P + 4E)',
      fanDesc: 'Dual Blowers · 1,480 RPM',
      gpuDesc: '20 Cores · 9.4%'
    },
    mba: {
      model: 'MacBook Air (15-inch, M3)',
      cores: '8 Cores (4 Performance + 4 Efficiency)',
      cooling: '0 dB Fanless Passive Cooling (0 RPM, Silent Heatsink)',
      power: 'Battery Health 99%, 42 Cycles, MagSafe 3 Rail',
      gpu: '10-Core Integrated Metal 3 Engine',
      memory: '24 GB Unified Memory (100 GB/s Bandwidth)',
      bentoChip: 'Apple M3 (Air)',
      bentoTopo: '8 Cores (4P + 4E)',
      fanDesc: 'Fanless Passive · 0 dB (0 RPM)',
      gpuDesc: '10 Cores · 5.8%'
    },
    mini: {
      model: 'Mac mini (Apple M4)',
      cores: '10 Cores (4 Performance + 6 Efficiency)',
      cooling: 'Single Quiet Centrifugal Blower',
      power: 'Desktop AC Mode: Direct Internal Mains Power Rail',
      gpu: '10-Core Metal 3 Graphics Engine',
      memory: '32 GB Unified Memory (120 GB/s Bandwidth)',
      bentoChip: 'Apple M4 (mini)',
      bentoTopo: '10 Cores (4P + 6E)',
      fanDesc: 'Single Blower · 1,150 RPM',
      gpuDesc: '10 Cores · 7.2%'
    },
    studio: {
      model: 'Mac Studio (Apple M2 Ultra)',
      cores: '24 Cores (16 Performance + 8 Efficiency)',
      cooling: 'Dual Heavy-Duty Thermal Impellers (Rear Exhaust)',
      power: 'Desktop High-Current Workstation Rail (370W)',
      gpu: '76-Core Extreme Metal 3 Cluster',
      memory: '192 GB Unified Memory (800 GB/s Bandwidth)',
      bentoChip: 'Apple M2 Ultra',
      bentoTopo: '24 Cores (16P + 8E)',
      fanDesc: 'Dual Impellers · 1,320 RPM',
      gpuDesc: '76 Cores · 14.8%'
    }
  };

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const key = tab.getAttribute('data-mac');
      const p = presets[key] || presets.mbp;

      if (hwModel) hwModel.textContent = p.model;
      if (hwCores) hwCores.textContent = p.cores;
      if (hwCooling) hwCooling.textContent = p.cooling;
      if (hwPower) hwPower.textContent = p.power;
      if (hwGpu) hwGpu.textContent = p.gpu;
      if (hwMemory) hwMemory.textContent = p.memory;

      if (chipTitle) chipTitle.textContent = p.bentoChip;
      if (chipTopology) chipTopology.textContent = p.bentoTopo;
      if (fanText) fanText.textContent = p.fanDesc;
      if (gpuCoresBadge) gpuCoresBadge.textContent = p.gpuDesc;
    });
  });
}

/* ==========================================================================
   5. LIVE TELEMETRY CANVASES (CPU, GPU, SYMMETRICAL NETWORK WAVES)
   ========================================================================== */
function initLiveTelemetryCanvases() {
  const cpuCanvas = document.getElementById('cpuCanvas');
  const gpuCanvas = document.getElementById('gpuCanvas');
  const netCanvas = document.getElementById('netCanvas');

  // History buffers
  const cpuHistory = Array.from({ length: 40 }, () => 10 + Math.random() * 15);
  const gpuHistory = Array.from({ length: 40 }, () => 6 + Math.random() * 10);
  const netDownHistory = Array.from({ length: 40 }, () => 20 + Math.random() * 50);
  const netUpHistory = Array.from({ length: 40 }, () => 5 + Math.random() * 20);

  function drawSparkline(canvas, data, strokeColor, fillColor, maxVal = 100) {
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const w = canvas.width;
    const h = canvas.height;

    ctx.clearRect(0, 0, w, h);

    if (data.length < 2) return;

    const step = w / (data.length - 1);

    ctx.beginPath();
    ctx.moveTo(0, h - (data[0] / maxVal) * (h - 6));

    for (let i = 1; i < data.length; i++) {
      const x = i * step;
      const y = h - (data[i] / maxVal) * (h - 6);
      ctx.lineTo(x, y);
    }

    ctx.strokeStyle = strokeColor;
    ctx.lineWidth = 1.8;
    ctx.stroke();

    // Area fill
    ctx.lineTo(w, h);
    ctx.lineTo(0, h);
    ctx.closePath();
    ctx.fillStyle = fillColor;
    ctx.fill();
  }

  function drawMirroredNetworkWave(canvas, downData, upData, maxVal = 100) {
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const w = canvas.width;
    const h = canvas.height;
    const midY = h / 2;

    ctx.clearRect(0, 0, w, h);

    // Center divider
    ctx.beginPath();
    ctx.moveTo(0, midY);
    ctx.lineTo(w, midY);
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.12)';
    ctx.lineWidth = 1;
    ctx.stroke();

    const step = w / (downData.length - 1);

    // 1. Download wave (Top half)
    ctx.beginPath();
    ctx.moveTo(0, midY - (downData[0] / maxVal) * (midY - 4));
    for (let i = 1; i < downData.length; i++) {
      const x = i * step;
      const y = midY - (downData[i] / maxVal) * (midY - 4);
      ctx.lineTo(x, y);
    }
    ctx.strokeStyle = '#D99B7F';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.lineTo(w, midY);
    ctx.lineTo(0, midY);
    ctx.closePath();
    ctx.fillStyle = 'rgba(217, 155, 127, 0.22)';
    ctx.fill();

    // 2. Upload wave (Bottom half, inverted)
    ctx.beginPath();
    ctx.moveTo(0, midY + (upData[0] / maxVal) * (midY - 4));
    for (let i = 1; i < upData.length; i++) {
      const x = i * step;
      const y = midY + (upData[i] / maxVal) * (midY - 4);
      ctx.lineTo(x, y);
    }
    ctx.strokeStyle = '#A56F63';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.lineTo(w, midY);
    ctx.lineTo(0, midY);
    ctx.closePath();
    ctx.fillStyle = 'rgba(165, 111, 99, 0.22)';
    ctx.fill();
  }

  // Animation Loop
  let lastUpdate = Date.now();
  function render() {
    const now = Date.now();
    if (now - lastUpdate > 1200) {
      lastUpdate = now;

      // Push simulated genuine metrics
      const newCpu = 10 + Math.random() * 12 + (Math.random() > 0.8 ? 20 : 0);
      cpuHistory.shift();
      cpuHistory.push(newCpu);

      const newGpu = 5 + Math.random() * 8 + (Math.random() > 0.85 ? 15 : 0);
      gpuHistory.shift();
      gpuHistory.push(newGpu);

      const newDown = 20 + Math.random() * 60;
      netDownHistory.shift();
      netDownHistory.push(newDown);

      const newUp = 5 + Math.random() * 25;
      netUpHistory.shift();
      netUpHistory.push(newUp);

      // Update text badges
      const cpuBadge = document.getElementById('cpuPctBadge');
      if (cpuBadge) cpuBadge.textContent = `${newCpu.toFixed(1)}%`;

      const netBadge = document.getElementById('netSpeedBadge');
      if (netBadge) netBadge.textContent = `↓ ${(newDown / 50).toFixed(2)} MB/s`;
    }

    drawSparkline(cpuCanvas, cpuHistory, '#D99B7F', 'rgba(217, 155, 127, 0.2)', 100);
    drawSparkline(gpuCanvas, gpuHistory, '#A56F63', 'rgba(165, 111, 99, 0.2)', 100);
    drawMirroredNetworkWave(netCanvas, netDownHistory, netUpHistory, 100);

    requestAnimationFrame(render);
  }

  render();
}

/* ==========================================================================
   6. ONE-CLICK COMMAND COPY
   ========================================================================== */
function initCopyButton() {
  const btn = document.getElementById('copyCmdBtn');
  const text = document.getElementById('copyBtnText');
  if (!btn || !text) return;

  const cmd = `git clone https://github.com/rifqi-rahman/Mactivity.git && cd Mactivity && ./build.sh && open build/Mactivity.app`;

  btn.addEventListener('click', async () => {
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(cmd);
      } else {
        const textarea = document.createElement('textarea');
        textarea.value = cmd;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
      }

      text.textContent = 'Copied! ✓';
      btn.style.borderColor = '#34d399';
      btn.style.color = '#34d399';

      setTimeout(() => {
        text.textContent = 'Copy';
        btn.style.borderColor = '';
        btn.style.color = '';
      }, 2500);
    } catch (err) {
      console.warn('Clipboard write failed:', err);
    }
  });
}

/* ==========================================================================
   7. INSTALLATION MODE TAB SWITCHER (USERS VS DEVELOPERS)
   ========================================================================== */
function initDownloadTabs() {
  const tabBtns = document.querySelectorAll('.install-tab-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');
  if (!tabBtns.length) return;

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.getAttribute('data-tab');
      tabBtns.forEach(b => {
        b.classList.remove('active');
        b.setAttribute('aria-selected', 'false');
      });
      tabPanes.forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      btn.setAttribute('aria-selected', 'true');
      const targetPane = document.getElementById(targetId);
      if (targetPane) targetPane.classList.add('active');
    });
  });
}
