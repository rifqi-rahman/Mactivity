# Product Requirements Document (PRD): MacUsage — Dedicated Activity Monitor for MacBook Pro M4 Pro

## 1. Executive Summary & Vision
**MacUsage** is a dedicated, ultra-lightweight, and visually stunning macOS menu bar activity monitor engineered specifically for Apple Silicon, with first-class optimization for the **MacBook Pro M4 Pro** (Apple M4 Pro chip architecture). 

Inspired by the acclaimed design and UX principles of [Usage](https://usage.pro/), MacUsage provides an at-a-glance menu bar presence coupled with an informative, glassmorphic popover dashboard. It bridges the gap between Apple's native Activity Monitor (utilitarian, clinical, separate window) and daily workflow needs: giving users instant insight into processor load, memory pressure, network throughput and accumulated data, disk and remote volume capacity, GPU utilization, real-time thermal status, fan RPMs, battery health, connected Bluetooth peripheral batteries, and top resource-consuming processes.

---

## 2. Competitive Deconstruction: What Makes Usage.pro Special?

Through deep analysis of **Usage.pro** and real-world usage patterns, the following core strengths set it apart:

| Dimension | Usage.pro Secret Sauce | Implementation in MacUsage |
| :--- | :--- | :--- |
| **Menu Bar First** | Unobtrusive, modular menu bar components. Users can pin just the stats they care about (e.g., CPU %, Net up/down, Disk radial gauge) without cluttering the native macOS menu bar. | Native `NSStatusItem` with customizable display modes: icon-only, compact dual-stat badges (e.g. CPU + Net), or radial gauges. |
| **Bento Grid Architecture** | 2-column rounded cards with unified spacing, high-contrast typography, and rich visual data representations (donuts, radial ticks, vertical liquid bars, mirrored bandwidth waves). | Modular SwiftUI card layout with native macOS `.ultraThinMaterial` / dark-light mode reactive styling and consistent typography. |
| **Mirrored Network Traffic** | Dual-direction sparkline / bar visualization: download on top (vibrant magenta/coral), upload on bottom (electric violet/indigo). | Interactive mirrored vertical bar graph with instant speed indicators and aggregate data accounting (Today, 7 Days, 30 Days). |
| **Peripheral Battery Slots** | Grid of battery pods for connected Bluetooth devices (AirPods, Magic Keyboard, Magic Trackpad) with empty hatched slots. | Direct `IOBluetooth` & `IOKit` power reporting displaying device glyph, percentage fill, and charging indicator. |
| **Apple Silicon Thermals & Fans** | Visual thermometer showing SoC temperature zone and dual fan speeds over time. | Direct thermal state monitoring and SMC/IOReport fan tachometer polling tailored to M4 Pro dual blower acoustics. |
| **Zero Bloat & Battery Friendly** | Native Swift binary consuming minimal memory (~20MB) and virtually 0% idle CPU. | Pure Swift 6 + AppKit/SwiftUI architecture utilizing Mach kernel APIs (`host_statistics64`, `vm_statistics64`, `libproc`) without Electron overhead. |

---

## 3. Hardware Target: MacBook Pro (M4 Pro Architecture)

MacUsage is tuned for the **MacBook Pro M4 Pro** specifications:
- **CPU Architecture**: 12-core or 14-core CPU (up to 10 Performance cores + 4 Efficiency cores).
- **GPU Architecture**: 16-core or 20-core GPU with hardware-accelerated ray tracing and dynamic caching.
- **Unified Memory**: 24 GB / 48 GB Unified LPDDR5X Memory (273 GB/s bandwidth).
- **Thermal Design**: Dual-fan active cooling system with multi-sensor thermal envelope.
- **Storage**: High-speed NVMe internal storage + Thunderbolt 5 external expansion ports.
- **Wireless & Connectivity**: Wi-Fi 6E/7, Bluetooth 5.3, high-speed Gigabit Ethernet support.

---

## 4. Feature Specifications & Monitored Modules

MacUsage satisfies all requested monitoring capabilities across 11 dedicated functional modules:

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

### 5.1. Visual Style & Tokens
- **Background**: Translucent frosted glass backing using macOS `.ultraThinMaterial` (`NSVisualEffectView`).
- **Color Palette**:
  - Primary Accent: Electric Blue (`#3B82F6` / `rgb(59, 130, 246)`).
  - Secondary Accent: Vivid Indigo (`#6366F1` / `rgb(99, 102, 241)`).
  - Network In / Down: Vivid Fuchsia / Rose (`#EC4899` / `#F43F5E`).
  - Network Out / Up: Deep Purple (`#8B5CF6`).
  - Success / Normal: Apple Emerald (`#10B981`).
  - Warning: Warm Amber (`#F59E0B`).
  - Danger / Critical: Coral Red (`#EF4444`).
- **Typography**: Apple San Francisco (`SF Pro Display` / `SF Pro Text`) with tabular figures (`.monospacedDigit()`) to prevent jittering during live stat updates.
- **Corner Radii**: Cards have 16pt corner radius with subtle 0.5pt border strokes (`rgba(255, 255, 255, 0.1)` in dark mode).

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
