# Mactivity 🖥️⚡

> A dedicated, native menu bar and inspector activity monitor engineered specifically for **MacBook Pro M4 Pro**.

Mactivity sits directly in your macOS menu bar next to your battery and Wi-Fi icons. Clicking it opens a glassmorphic Bento dashboard showing live performance, thermal, and network metrics with our signature Nordic Terracotta & Midnight Teal colorway.

---

## 🎨 Signature Palette & Identity

Unlike generic utility tools, Mactivity is styled with a bespoke architectural palette:
- **`#0F3040` (Midnight Petrol Teal)**: Deep matte background canvas & subtle frosted card glass.
- **`#464858` (Muted Slate Gray)**: Structural card borders, dividers, track bases, and inactive state markers.
- **`#A56F63` (Muted Terracotta Rose / Copper)**: System workloads, upload bandwidth, remote volumes, secondary gauges.
- **`#D99B7F` (Warm Sand Peach / Golden Terracotta)**: User workloads, download bandwidth, active highlights, primary gauges.

---

## 🌟 Key Features

1. **At-a-Glance Fixed-Width Menu Bar**: Stabilized live status pill (`⊚ 12%  ↓24K`) that never shifts adjacent status icons.
2. **Harmonious Bento Card Grid**: Perfectly proportioned 2-column bento layout with hover glow cards.
3. **Dedicated macOS Inspector Window**: Full-fledged companion app accessible by clicking any card or pressing Open Inspector.
4. **Mirrored Network Visualization**: Symmetrical wave chart showing download traffic in warm peach and upload traffic in copper.
5. **Peripheral Battery Gauge**: Clean vertical battery pillars with device glyphs for connected Bluetooth gear.
6. **Thermal & Fan Tachometer**: Real-time SoC temperature with glass fluid thermometer and dual blower fan telemetry.
7. **Zero Bloat Performance**: Native Swift 6 + AppKit/SwiftUI binary (~20MB RAM, <0.3% CPU usage) using direct Mach kernel and IOKit APIs.

---

## 📊 Monitored Hardware Modules

| Module | What It Tracks | Visual Component |
| :--- | :--- | :--- |
| **Processor (CPU)** | Real-time CPU load, user vs. system breakdown, 14-core M4 Pro cluster | 16-bar dual-tone history timeline (Sand user / Copper system) |
| **Memory (RAM)** | Total vs used unified memory (e.g., 24 GB), App, Wired, Compressed, Free, Swap | Multi-segment circular Donut Chart + Memory Pressure pill |
| **Network Activity** | Real-time download & upload speeds, LAN & WAN IP addresses | Mirrored wave bar chart (Download top / Upload bottom) |
| **Network Data** | Accumulated data traffic: Today, Last 7 Days, Last 30 Days | High-contrast data ledger with automatic date rollover |
| **Disk Storage** | Macintosh HD capacity, used/free gigabytes, read/write throughput | 22-segment Radial Tick circular gauge |
| **Temperature** | Real-time processor temperature in °C and °F, thermal throttling state | Glass fluid thermometer with color-coded mercury fill |
| **Cooling Fans** | Left Fan & Right Fan RPM tachometer, acoustic mode (Silent / Active / Boost) | Dual blower RPM readouts + speed curve progress bar |
| **Graphics (GPU)** | Apple Silicon M4 Pro GPU load %, active shared VRAM allocation | Live GPU utilization sparkline |
| **Battery & Power** | Charge %, Power state (AC / Battery), Watts in/out, Cycle count, Health % | Live battery status + power metrics |
| **Bluetooth Devices** | Battery level of connected Bluetooth headphones, keyboard, and trackpad | Clean vertical battery pillars with device glyphs and percentages |
| **Top Processes** | Top resource-consuming applications ranked by CPU % or Memory | Interactive segmented list with one-click full Inspector window |
| **Remote Volumes** | Mounted internal containers, external USB/Thunderbolt drives, network shares | Volume capacity bars with free space readouts |

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
- **Right-Click** the menu bar icon: Opens the quick menu (Open Dashboard, Launch Activity Monitor, Force Refresh, Quit).
- **Ellipsis (`...`) Menu**: In the bottom right of the dashboard, you can adjust the refresh rate (1s Live, 2s Normal, 5s Low Power) or quit.

### 3. Launch at Login (Optional)
To have MacUsage start automatically when your Mac boots:
1. Open **System Settings** > **General** > **Login Items**.
2. Click **+** under *Open at Login*.
3. Select `MacUsage.app` from this repository's `build/` folder.

---

## 📁 Repository Structure

```
mac-usage/
├── PRD.md                         # Product Requirements Document & Usage.pro analysis
├── README.md                      # Documentation and quickstart guide
├── build.sh                       # Native compilation and app bundling script
├── Resources/
│   └── Info.plist                 # App bundle metadata (LSUIElement = true)
├── Sources/
│   └── MacUsage/
│       ├── Main.swift             # App entry point (NSApplicationDelegate)
│       ├── MenuBarController.swift# NSStatusItem (fixed 92pt) and NSPopover lifecycle controller
│       ├── Models/
│       │   ├── SystemMetrics.swift# Data structures for all modules
│       │   └── UIState.swift      # Observable UI & inspector state
│       ├── Services/
│       │   ├── MetricsCollector.swift # Mach, IOKit, sysctl, libproc kernel sampler
│       │   └── WindowManager.swift    # Full Mac App window manager & activation policy controller
│       └── Views/
│           ├── DashboardView.swift    # 2-column Bento dashboard popover
│           ├── Cards/
│           │   └── CardViews.swift    # Modular cards for all modules
│           ├── Components/
│           │   └── VisualComponents.swift # Donut charts, radial ticks, thermometer, etc.
│           └── Inspector/
│               └── InspectorWindowView.swift # Full Mac App detail inspector (Processes, Cores, Memory, etc.)
└── build/
    └── MacUsage.app               # Compiled native arm64 macOS application
```

---

## 🪟 Dual-Mode Architecture (Menu Bar + Dedicated Mac App)

MacUsage operates in **two complementary modes**:
1. **Background Menu Bar Mode (Default)**:
   - Sits in the menu bar with zero Dock footprint (`NSApp.setActivationPolicy(.accessory)`).
   - Fixed 92pt status item width prevents the popup from shifting horizontally when metric numbers fluctuate.
   - Low-overhead background sampling (~20MB RAM, <0.3% CPU).
2. **Dedicated Full Mac App Window (Detail Inspector)**:
   - Clicking **"Processes"** or any card's detail shortcut (`arrow.up.right`) opens the dedicated Mac App window.
   - Automatically promotes to a standard application with Dock presence (`NSApp.setActivationPolicy(.regular)`).
   - Features searchable, sortable process table with thread counts and one-click process termination.
   - Features dedicated deep-dive tabs for 14-core M4 Pro topology, memory distribution, network bandwidth, volumes, and battery/thermals.
   - Closing the window cleanly reverts the app back to background menu bar mode without quitting.

---

## 🔒 Privacy & Performance
- **100% Local**: No analytics, telemetry, or remote data transmission.
- **Low Power Architecture**: Uses native C/Mach kernel APIs (`host_statistics64`, `vm_statistics64`, `libproc`) and IOKit registry readers to sample hardware without spawning sub-processes or shell scripts.

