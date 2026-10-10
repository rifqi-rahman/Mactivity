# Mactivity 🖥️⚡

> A dedicated, native menu bar and inspector activity monitor engineered for **Apple Silicon & all macOS devices** (MacBook Pro, MacBook Air, Mac mini, Mac Studio, iMac, and Mac Pro).

Mactivity sits directly in your macOS menu bar next to your battery and Wi-Fi icons. Clicking it opens a glassmorphic Bento dashboard showing live performance, thermal, and network metrics styled in our signature Nordic Terracotta & Midnight Teal colorway.

---

## 🧠 Universal Mac Hardware Intelligence (Zero Mock Data)

Unlike tools that rely on static presets or hardcoded assumptions, Mactivity dynamically probes the macOS kernel, IOKit registry, and Mach subsystems to detect and monitor **your exact Mac model**:

| Hardware Subsystem | MacBook Pro | MacBook Air | Desktop Macs (Mac mini, Mac Studio, iMac, Mac Pro) | Intel Macs |
| :--- | :--- | :--- | :--- | :--- |
| **Model & Chip** | Dynamic (`MacBook Pro · M-series`) | Dynamic (`MacBook Air · M-series`) | Dynamic (`Mac mini / Studio / Pro · Apple Silicon`) | Dynamic (`iMac / Mac Pro · Intel Core / Xeon`) |
| **CPU Topology** | Dynamic `P` + `E` Cores (e.g. 10P + 4E) | Dynamic `P` + `E` Cores (e.g. 4P + 4E) | Dynamic `P` + `E` Cores based on chip tier | Symmetrical `C1..Cn` Cores |
| **GPU Subsystem** | Direct Metal probe (`sppci_cores`) | Direct Metal probe (`sppci_cores`) | Direct Metal probe (`sppci_cores`) | Metal / Discrete GPU probe |
| **Cooling & Fans** | Dual Blowers (Left & Right RPM) | **Fanless Passive Cooling** (0 dB, 0 RPM) | Single Blower (mini/iMac) or Dual/Multi-Blowers | Desktop thermal management |
| **Power & Battery** | Health %, Cycles, Charging State | Health %, Cycles, Charging State | **Desktop AC Mode**: Direct Mains Power Rail | AC / Battery / UPS detection |
| **Bluetooth Telemetry** | Genuine peripheral battery (Mouse, Keyboard, Audio) | Genuine peripheral battery | Genuine peripheral battery | Genuine peripheral battery |

> [!NOTE]
> **Zero Mock Values**: All network counters, Bluetooth peripherals, core topologies, memory pages, and temperatures are 100% authentic live telemetry. Unpopulated peripheral slots show clean placeholder guides rather than fake devices.

---

## 🎨 Signature Palette & Identity

Mactivity is styled with a bespoke architectural palette:
- **`#0F3040` (Midnight Petrol Teal)**: Deep matte background canvas & subtle frosted card glass.
- **`#464858` (Muted Slate Gray)**: Structural card borders, dividers, track bases, and inactive state markers.
- **`#A56F63` (Muted Terracotta Rose / Copper)**: System workloads, upload bandwidth, remote volumes, secondary gauges.
- **`#D99B7F` (Warm Sand Peach / Golden Terracotta)**: User workloads, download bandwidth, active highlights, primary gauges.

---

## 🌟 Key Features

1. **At-a-Glance Fixed-Width Menu Bar**: Stabilized live status pill (`⊚ 12%  ↓24K`) with a constant 92pt footprint that never shifts adjacent status icons.
2. **Harmonious Bento Card Grid**: Perfectly proportioned 2-column bento layout with hover glow cards displaying unit telemetry.
3. **Dedicated macOS Inspector Window with Default Dashboard**:
   - **Full-Bilah Clickable Tabs**: Sidebar tabs can be clicked anywhere on the bar (not just on the text label) with tactile hover states.
   - **Contextual Navigation**: Clicking **"Open App"** opens the comprehensive **Dashboard** overview; clicking any specific card in the menu bar popover routes directly into that component's dedicated inspector panel.
4. **Mirrored Network Visualization**: Symmetrical wave chart showing download traffic in warm peach and upload traffic in terracotta copper.
5. **Peripheral Battery Gauge**: Clean vertical battery pillars with device glyphs for real connected Bluetooth gear (e.g. Logitech mice, Apple Magic accessories, wireless audio).
6. **Thermal & Fan Tachometer**: Real-time SoC temperature with fluid thermometer, automatically adapting between fanless passive designs (MacBook Air) and active centrifugal blowers.
7. **Zero Bloat Performance**: Native Swift 6 + AppKit/SwiftUI binary (~20MB RAM, <0.3% CPU usage) using direct Mach kernel (`host_statistics64`, `vm_statistics64`), `libproc`, and IOKit APIs.

---

## 📊 Monitored Hardware Modules

| Module | What It Tracks | Visual Component |
| :--- | :--- | :--- |
| **Dashboard** | Unified helicopter overview of all hardware subsystems | Responsive Multi-Column Bento Grid + Live KPI Header |
| **Processor (CPU)** | Real-time CPU load, user vs. system breakdown, dynamic core cluster topology | Dual-tone history timeline + Adaptive per-core load capsules |
| **Memory (RAM)** | Total vs. used unified memory (dynamic page size), App, Wired, Compressed, Free, Swap | Multi-segment Donut Chart + Memory Pressure pill |
| **Graphics (GPU)** | Metal hardware engine utilization %, active shared VRAM allocation, dynamic core count | Live GPU utilization sparkline |
| **Network Activity** | Real-time download & upload speeds, LAN & WAN IP addresses | Mirrored wave bar chart (Download top / Upload bottom) |
| **Network Data** | Accumulated data traffic: Today, Last 7 Days, Last 30 Days | High-contrast data ledger with automatic date rollover |
| **Disk & Storage** | System container capacity, used/free gigabytes, read/write throughput | 22-segment Radial Tick circular gauge |
| **Temperature** | Real-time processor temperature in °C and °F, thermal throttling state | Glass fluid thermometer with color-coded thermal gradient |
| **Cooling Fans** | Fan tachometers adapted to model (Fanless 0 dB / Single Blower / Dual Blowers) | Dynamic RPM tachometer + speed curve progress bar |
| **Battery & Power** | Laptop charge %, power state, cycle count, health % — or Desktop AC Direct Mains mode | Dynamic battery capsule / Desktop power architecture card |
| **Bluetooth Devices** | Battery level of real connected Bluetooth mice, keyboards, trackpads, and headsets | Vertical battery pillars with device glyphs |
| **Top Processes** | Top resource-consuming applications ranked by CPU % or Memory with PID & thread count | Searchable & sortable process table with instant End Process action |
| **Mounted Volumes** | Mounted internal containers, external USB/Thunderbolt drives, network APFS/SMB shares | Volume capacity progress bars with free space readouts |

---

## 🚀 Getting Started

### 1. Build and Run
From the terminal, run the build script:
```bash
./build.sh
```
This produces `build/Mactivity.app`.

To launch the app:
```bash
open build/Mactivity.app
```
Or run the executable directly:
```bash
./build/Mactivity.app/Contents/MacOS/Mactivity
```

### 2. Menu Bar Controls
- **Left-Click** the menu bar icon: Toggles the floating Bento dashboard popover.
- **Right-Click** the menu bar icon: Opens the quick menu (Open Dashboard, Open Full Inspector Window, Launch Activity Monitor, Force Refresh, Quit).
- **Ellipsis (`...`) Menu**: In the bottom right of the dashboard, you can adjust the refresh rate (1s Live, 2s Normal, 5s Low Power) or quit.

### 3. Launch at Login (Optional)
To have Mactivity start automatically when your Mac boots:
1. Open **System Settings** > **General** > **Login Items**.
2. Click **+** under *Open at Login*.
3. Select `Mactivity.app` from this repository's `build/` folder.

---

## 📁 Repository Structure

```
mac-usage/
├── PRD.md                         # Product Requirements Document & architecture analysis
├── README.md                      # Documentation and universal hardware guide
├── build.sh                       # Native compilation and app bundling script
├── Resources/
│   └── Info.plist                 # App bundle metadata (LSUIElement = true)
├── Sources/
│   └── MacUsage/
│       ├── Main.swift             # App entry point (NSApplicationDelegate)
│       ├── MenuBarController.swift# NSStatusItem (fixed 92pt) and NSPopover lifecycle controller
│       ├── Models/
│       │   ├── SystemMetrics.swift# Data structures for all modules (dynamic hardware models)
│       │   └── UIState.swift      # Observable UI state, tab navigation, search & sorting
│       ├── Services/
│       │   ├── MetricsCollector.swift # Mach, IOKit, sysctl, libproc kernel sampler
│       │   └── WindowManager.swift    # Full Mac App window manager & activation policy controller
│       └── Views/
│           ├── DashboardView.swift    # 2-column Bento dashboard popover
│           ├── Cards/
│           │   └── CardViews.swift    # Modular Bento cards with hover details & click-to-app routing
│           ├── Components/
│           │   └── VisualComponents.swift # Donut charts, radial ticks, thermometer, battery pillars
│           └── Inspector/
│               └── InspectorWindowView.swift # Full Mac App detail inspector (Dashboard, Processes, Cores, etc.)
└── build/
    └── Mactivity.app              # Compiled native arm64 macOS application bundle
```

---

## 🪟 Dual-Mode Architecture (Menu Bar + Dedicated Mac App)

Mactivity operates in **two complementary modes**:
1. **Background Menu Bar Mode (Default)**:
   - Sits in the menu bar with zero Dock footprint (`NSApp.setActivationPolicy(.accessory)`).
   - Fixed 92pt status item width prevents the popup from shifting horizontally when metric numbers fluctuate.
   - Low-overhead background sampling (~20MB RAM, <0.3% CPU).
2. **Dedicated Full Mac App Window (Detail Inspector)**:
   - Clicking **"Open App"** opens the dedicated Mac App window directly to the **Dashboard** overview.
   - Clicking any specific card in the menu bar popup opens the Inspector directly focused on that card's deep-dive tab.
   - Automatically promotes to a standard application with Dock presence (`NSApp.setActivationPolicy(.regular)`).
   - Features full-width clickable sidebar tabs with responsive layouts.
   - Closing the window cleanly reverts the app back to background menu bar mode without quitting.

---

## 🔒 Privacy & Performance
- **100% Local**: No analytics, telemetry, or remote data transmission.
- **Low Power Architecture**: Uses native C/Mach kernel APIs (`host_statistics64`, `vm_statistics64`, `libproc`) and IOKit registry readers to sample hardware without spawning sub-processes or shell scripts.
