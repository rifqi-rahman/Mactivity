# Product Requirements Document (PRD): Mactivity — Dedicated Activity Monitor for MacBook Pro M4 Pro

## 1. Executive Summary & Vision
**Mactivity** is a dedicated, ultra-lightweight, and visually stunning macOS menu bar and companion inspector activity monitor engineered specifically for Apple Silicon, with first-class optimization for the **MacBook Pro M4 Pro** (Apple M4 Pro chip architecture). 

Differentiated with an architectural Nordic Terracotta & Midnight Teal colorway (`#0F3040`, `#464858`, `#A56F63`, `#D99B7F`), Mactivity provides an at-a-glance menu bar presence coupled with an informative, glassmorphic Bento dashboard and a deep-dive macOS Inspector window. It bridges the gap between Apple's native Activity Monitor (utilitarian, clinical, separate window) and daily workflow needs: giving users instant insight into processor load, memory pressure, network throughput and accumulated data, disk and remote volume capacity, GPU utilization, real-time thermal status, fan RPMs, battery health, connected Bluetooth peripheral batteries, and top resource-consuming processes.

---

## 2. Competitive Deconstruction & Brand Identity

Through deep analysis of the utility space and user experience, Mactivity distinguishes itself:

| Dimension | Standard Utilities / Competitors | Implementation in Mactivity |
| :--- | :--- | :--- |
| **Color Identity** | Neon cyan, vibrant magenta, bright violet | Architectural Signature Palette: `#0F3040` (Midnight Petrol), `#464858` (Slate), `#A56F63` (Copper), `#D99B7F` (Warm Sand) |
| **Menu Bar First** | Shifts width erratically with dynamic numbers | Stabilized fixed-width (132pt) monospace numeric layout preventing menu bar jitter |
| **Two-Tier Architecture** | Either popup only or heavy window app | Seamless two-tier design: Menu Bar Bento popup + Clickable Inspector Window for deep drill-down |
| **Bento Grid Architecture** | Disjointed cards with empty spaces | Harmonious 2-column rounded cards with hover glowing borders and reactive cursor highlights |
| **Mirrored Network Traffic** | Generic line graph | Symmetrical mirrored dual-tone bars (Download top in Sand, Upload bottom in Copper) with historical traffic tracking |
| **Peripheral Battery Slots** | Disconnected battery listings | Clean vertical battery pillars with device glyphs for connected Bluetooth gear |
| **Apple Silicon Thermals & Fans** | Basic temperature number | Fluid mercury thermometer + dual blower fan tachometer tuned for M4 Pro acoustic curves |
| **Zero Bloat & Battery Friendly** | Electron memory hogs (>250MB) | Pure Swift 6 + AppKit/SwiftUI binary (~20MB RAM, <0.3% CPU idle) using Mach kernel and IOKit APIs |

---

## 3. Hardware Target: Universal macOS Architecture (Dynamic Hardware Detection)

Mactivity is engineered with dynamic kernel and IOKit hardware detection to support **all macOS devices** (MacBook Pro, MacBook Air, Mac mini, Mac Studio, iMac, Mac Pro, and Intel Macs) with verified first-class optimization for the **MacBook Pro M4 Pro** reference device:
- **CPU Architecture**: Dynamically probes Performance (P-Cores) and Efficiency (E-Cores) clusters or symmetric Intel cores without hardcoding core counts.
- **GPU Architecture**: Queries Metal subsystem and hardware registers for physical GPU cores (e.g. 10, 16, 20, 24..76 cores) and shared VRAM.
- **Unified Memory**: Real-time physical RAM probing with dynamic system page sizes (`getpagesize()` supporting 16KB ARM64 and 4KB Intel).
- **Thermal & Acoustic Profiles**: Dynamic awareness of **Fanless passive cooling** (MacBook Air, 0 dB), **Single blower** (Mac mini, iMac), **Dual blowers** (MacBook Pro, Mac Studio), and **Multi-fan** systems (Mac Pro).
- **Power Subsystem**: Seamless differentiation between internal laptop smart battery telemetry (cycles, health, wattage) and desktop Direct AC mains power architecture.
- **Storage & Peripherals**: NVMe APFS containers, removable external Thunderbolt/USB volumes, and genuine Bluetooth BLE peripheral battery levels.

---

## 4. Feature Specifications & Monitored Modules

Mactivity satisfies all requested monitoring capabilities across 11 dedicated functional modules:

### 4.1. Processor (CPU)
- **Real-time CPU Utilization (%)**: Combined overall processor load updated every 1.0s.
- **Core Breakdown**: Split between User (`%usr`), System (`%sys`), and Idle (`%idle`).
- **Cluster Awareness**: Insights into Efficiency (E-cores) vs Performance (P-cores) cluster load.
- **History Graph**: 16-to-24 bar timeline graph showing historical load trends with two-tone fill (user load in cyan/blue, system load in purple).

### 4.2. Memory (RAM)
- **Usage Overview**: Used RAM vs Total Unified Memory (e.g. `12.65 / 24.00 GB`) and overall percentage.
- **Memory Composition**: Multi-segment donut ring chart detailing:
  - App Memory (active process allocations).
  - Wired Memory (kernel and system-locked memory).
  - Compressed Memory (in-RAM compression before swapping).
  - Free / Cached Memory.
- **Memory Pressure Indicator**: Color-coded pill (`Normal`, `Warning`, `Critical`) reflecting macOS memory pressure.
- **Swap Tracking**: Current swap file space consumed (e.g. `0 B` or `128 MB`).

### 4.3. Network Activity & Data Usage
- **Real-time Throughput**: Live upload and download speeds (e.g. `▼ 24 KB/s`, `▲ 10 KB/s`).
- **Mirrored Wave Visualization**: Bidirectional stacked bar graph (Download ascending, Upload descending).
- **Connection Diagnostics**: Active interface detection (`Wi-Fi` SSID / `Ethernet`), Local IP (e.g. `192.168.1.x`), and Public IP resolver.
- **Data Usage Accounting**: Persistent historical counter tracking total transfer volumes:
  - Today (e.g. `1.54 GB`).
  - Last 7 Days (e.g. `26.84 GB`).
  - Last 30 Days (e.g. `139.6 GB`).

### 4.4. Disk & Storage
- **Internal Storage**: Percentage used, formatted capacity (e.g. `782.49 / 994.66 GB`), and volume name (`Macintosh HD`).
- **Visual Gauge**: Radial tick gauge / progress ring with segmented ticks.
- **I/O Activity**: Read and write throughput rates (MB/s).

### 4.5. Remote Volumes & External Drives
- **External Disks**: Thunderbolt 5 / USB-C SSDs, SD cards, and external backup drives.
- **Network Shares**: Mounted SMB, NFS, AFP, and WebDAV volumes.
- **Volume Metrics**: Free space, total size, mount point path, volume type badge, and one-click Eject button.

### 4.6. Battery & Power
- **Charge State**: Current percentage (0–100%), Charging status (On AC Power / Discharging / Fully Charged).
- **Power Draw**: Real-time wattage consumption (Watts in/out).
- **Health & Longevity**: Maximum capacity health percentage, cycle count, and battery condition status (`Normal`, `Service Recommended`).
- **Time Remaining**: Dynamic estimate of time until empty or time until full charge.

### 4.7. Fans (Active Cooling)
- **Fan Tachometer**: Real-time RPM readout for Left Fan and Right Fan on MacBook Pro.
- **Status Indicator**: Quiet / Normal / Elevated / Boost cooling curve mode.
- **Fan History Graph**: Trendline tracking fan acoustics over active workloads.

### 4.8. Temperature & Thermal State
- **SoC Temperature**: Real-time temperature in °C and °F.
- **Thermometer Gauge**: Custom skeuomorphic/modern fluid thermometer icon with dynamic mercury level and heat color (Blue <50°C, Amber 50–80°C, Red >80°C).
- **Thermal Throttling State**: Nominal, Fair, Serious, or Critical status indicator.

### 4.9. Graphics (GPU)
- **GPU Core Utilization**: Overall Apple Silicon M4 Pro GPU load percentage.
- **Dynamic Memory Allocation**: Shared unified memory reserved for graphics contexts / Metal shaders.
- **GPU History**: Mini sparkline for rendering and machine learning workloads.

### 4.10. Processes (Top Consumers)
- **Top CPU Consumers**: Top 5 active processes ranked by processor percentage.
- **Top Memory Consumers**: Top 5 active processes ranked by RAM footprint.
- **App Metadata**: Application icon, process name, PID, and instant shortcut to launch native Activity Monitor.

### 4.11. Bluetooth Devices
- **Peripheral Grid**: 4-slot modular cards with custom hardware glyphs (AirPods / Headphones, Magic Keyboard, Magic Mouse / Trackpad).
- **Battery Levels**: Vertical filled battery pillars with percentages (e.g., 50%, 91%, 47%).
- **Empty State**: Stylized diagonal-hatched placeholder slots for disconnected peripherals.

---

## 5. UI/UX & Design System Specifications

### 5.1. Signature Architectural Color Palette & Design System
Mactivity utilizes a bespoke architectural Nordic Terracotta & Midnight Teal palette designed to stand distinct from generic neon utility monitors:

| Token Name | Hex Code | RGB | Purpose & Semantic Role |
| :--- | :--- | :--- | :--- |
| **Midnight Petrol** | `#0F3040` | `rgb(15, 48, 64)` | Deep canvas background, card backing, container fill, active tab pill background |
| **Muted Slate** | `#464858` | `rgb(70, 72, 88)` | Structural card borders, dividers, track bases, inactive glyphs, subtle outlines |
| **Terracotta Copper** | `#A56F63` | `rgb(165, 111, 99)` | System CPU utilization, upload throughput (↑), wired memory segment, warning thermals |
| **Warm Sand Peach** | `#D99B7F` | `rgb(217, 155, 127)` | User CPU utilization, download throughput (↓), app memory segment, active accents, primary badges |

- **Background Styling**: Frosted glass backing using native macOS `NSVisualEffectView` (`.behindWindow` blending, `.popover` material) layered with `MactivityTheme.petrol.opacity(0.40)`.
- **Card Styling**: 16pt corner radius, `MactivityTheme.cardBg` (`#0F3040` @ 90% opacity), `0.8pt` border stroke with `MactivityTheme.slate`, and warm sand hover glow effects (`#D99B7F` @ 20% shadow opacity).
- **Typography**: Apple San Francisco (`SF Pro Display` / `SF Pro Text`) with tabular figures (`.monospacedDigit()`) to prevent jittering during live stat updates.
- **Micro-Visuals**: Mirrored dual-tone bandwidth waves, radial tick gauges, multi-segment donut rings, fluid thermometers, and vertical peripheral battery pillars.

### 5.2. Menu Bar Presence
- **Placement**: Native `NSStatusItem` in the macOS system status bar (adjacent to Battery, Control Center, and Clock).
- **Display Configurations**:
  - *Option A (Default Minimal)*: Monogram icon + Dual stacked stats (`CPU 12%`, `NET 24K`).
  - *Option B (Graph View)*: Live mini sparkline.
  - *Option C (Icon Only)*: Clean Activity gauge icon.
- **Click Behavior**: Left-click immediately anchors the floating popover below the status item with zero delay.

---

## 6. Technical Architecture & Engineering Decisions

### 6.1. Technology Selection: Native Swift App
- **Language**: Swift 6.4.
- **UI Framework**: SwiftUI + AppKit integration (`NSStatusItem`, `NSPopover`).
- **Underlying System APIs**:
  - Mach Kernel: `host_statistics64`, `processor_info`, `vm_statistics64` for CPU and Memory metrics without invoking slow shell commands.
  - IOKit: `IOPowerSources`, `IOPSCopyPowerSourcesInfo` for battery and power profiling.
  - IOReport / SMC: Sensor interfaces for M4 Pro thermal and fan monitoring.
  - SystemConfiguration / Network: `getifaddrs` and `sysctl` (`NET_RT_IFLIST2`) for microsecond-level network interface delta calculations.
  - DiskArbitration & `statfs`: Fast local and remote volume inspection.
  - `libproc`: Direct kernel process table sampling for low-overhead top process ranking.

### 6.2. Resource Budget & Efficiency
- **Idle CPU Target**: < 0.5% CPU core usage during continuous 1.0s background polling.
- **Memory Footprint**: < 30 MB Resident Memory (clean native footprint).
- **Battery Impact**: Minimized timer coalescing and pause on popover close (background monitoring drops to low-frequency 5.0s rate when popover is closed).

---

## 7. Delivery Plan & Verification Strategy

1. **Phase 1: Architecture & Data Providers**:
   - Implement kernel metric collector (`SystemMetricsCollector.swift`): CPU, RAM, Disk, Network, Battery, Thermals, Bluetooth, Processes.
2. **Phase 2: Menu Bar Integration**:
   - Implement `AppDelegate.swift` and `MenuBarController.swift` managing the `NSStatusItem` with custom AppKit status view and live rendering.
3. **Phase 3: Popover Dashboard & Design System**:
   - Build SwiftUI card widgets mirroring Usage.pro aesthetic: Memory donut, Processor load bar timeline, Mirrored Network chart, Bluetooth battery pillars, Thermometer gauge, Remote Volumes table, Top Processes view.
4. **Phase 4: Compilation & Native Bundle Packaging**:
   - Build native macOS universal arm64 binary and `.app` bundle, test run directly on this MacBook Pro M4 Pro.
5. **Phase 5: User Verification & Polish**:
   - Verify all 11 modules report live real hardware statistics accurately and render flawlessly.
