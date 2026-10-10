import SwiftUI
import AppKit

// MARK: - Reusable Bento Card Container with Hover Details & Click-to-App Navigation
public struct BentoCardContainer<Content: View>: View {
    public var title: String
    public var icon: String
    public var targetTab: InspectorTab
    public var unitDetail: String?
    public var badge: String?
    public var height: CGFloat
    public var isHero: Bool
    @ViewBuilder public var content: (Bool) -> Content
    
    @ObservedObject var uiState = UIState.shared
    @Environment(\.colorScheme) var colorScheme
    
    public init(
        title: String,
        icon: String,
        targetTab: InspectorTab,
        unitDetail: String? = nil,
        badge: String? = nil,
        height: CGFloat = 150,
        isHero: Bool = false,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        self.title = title
        self.icon = icon
        self.targetTab = targetTab
        self.unitDetail = unitDetail
        self.badge = badge
        self.height = height
        self.isHero = isHero
        self.content = content
    }
    
    public var body: some View {
        let isHovered = (uiState.hoveredCard == title)
        
        VStack(alignment: .leading, spacing: 6) {
            // Card Header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isHovered ? .blue : .secondary)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isHovered ? .primary : .secondary)
                    .lineLimit(1)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(4)
                }
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isHovered ? .blue : Color.secondary.opacity(0.6))
                    .scaleEffect(isHovered ? 1.15 : 1.0)
            }
            
            // Content
            content(isHovered)
            
            // Hover Unit Detail Banner
            if isHovered, let unit = unitDetail {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.blue)
                    Text(unit)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(4)
            }
        }
        .padding(13)
        .frame(height: height)
        .modifier(BentoCardBackground(isHovered: isHovered, colorScheme: colorScheme))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onHover { hovering in
            uiState.setHoveredCard(title, isHovered: hovering)
        }
        .onTapGesture {
            WindowManager.shared.openWindow(tab: targetTab)
        }
        .help("Click to inspect \(title) in Mac App")
    }
}

public struct BentoCardBackground: ViewModifier {
    public var isHovered: Bool
    public var colorScheme: ColorScheme
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark
                          ? (isHovered ? Color(white: 0.16) : Color(white: 0.11).opacity(0.92))
                          : (isHovered ? Color(white: 0.98) : Color.white.opacity(0.92)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isHovered
                        ? Color.blue.opacity(0.45)
                        : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)),
                        lineWidth: isHovered ? 1.5 : 1.0
                    )
            )
            .shadow(
                color: isHovered ? Color.blue.opacity(0.16) : Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05),
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 3 : 2
            )
    }
}

// MARK: - 1. Processor Card
public struct ProcessorCardView: View {
    public var cpu: CPUInfo
    
    public init(cpu: CPUInfo) {
        self.cpu = cpu
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Processor Load",
            icon: "cpu",
            targetTab: .processor,
            unitDetail: "10P + 4E Cores (4.5 GHz) · M4 Pro",
            badge: "14-Core",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                Text(String(format: "%.1f%%", cpu.totalUsage))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                HistoryBarChart(totalData: cpu.history, userPart: cpu.userHistory, barCount: 16)
                    .frame(height: 32)
                
                if !isHovered {
                    HStack {
                        HStack(spacing: 4) {
                            Circle().fill(Color(red: 0.0, green: 0.75, blue: 1.0)).frame(width: 6, height: 6)
                            Text(String(format: "User %.0f%%", cpu.userUsage))
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Circle().fill(Color(red: 0.45, green: 0.42, blue: 0.98)).frame(width: 6, height: 6)
                            Text(String(format: "System %.0f%%", cpu.systemUsage))
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 2. Memory Card
public struct MemoryCardView: View {
    public var memory: MemoryInfo
    
    public init(memory: MemoryInfo) {
        self.memory = memory
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Memory",
            icon: "memorychip",
            targetTab: .memory,
            unitDetail: "24 GB LPDDR5X · 273 GB/s Bandwidth",
            badge: "24 GB",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f%%", memory.usedPercent))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(memory.usedGBString)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    let appPct = Double(memory.appBytes) / Double(max(1, memory.totalBytes)) * 100.0
                    let wiredPct = Double(memory.wiredBytes) / Double(max(1, memory.totalBytes)) * 100.0
                    let compPct = Double(memory.compressedBytes) / Double(max(1, memory.totalBytes)) * 100.0
                    
                    DonutChartView(segments: [
                        (appPct, Color(red: 0.20, green: 0.55, blue: 1.0)),
                        (wiredPct, Color(red: 0.0, green: 0.80, blue: 0.95)),
                        (compPct, Color(red: 0.50, green: 0.40, blue: 0.95))
                    ], lineWidth: 8)
                    .frame(width: 44, height: 44)
                }
                
                if !isHovered {
                    HStack(spacing: 6) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 9, weight: .bold))
                            Text("\(memory.pressurePercent)%")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(5)
                        
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 9, weight: .bold))
                            Text(memory.swapUsedBytes == 0 ? "0 B" : "\(memory.swapUsedBytes / 1_048_576) MB")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(5)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Disk Card
public struct DiskCardView: View {
    public var disk: DiskInfo
    
    public init(disk: DiskInfo) {
        self.disk = disk
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Disk",
            icon: "internaldrive",
            targetTab: .disk,
            unitDetail: "Apple Fabric NVMe · APFS Encrypted",
            badge: "APFS",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f%%", disk.usedPercent))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(disk.capacityString)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    RadialTickGauge(percentage: disk.usedPercent, tickCount: 22)
                        .frame(width: 46, height: 46)
                }
                
                if !isHovered {
                    HStack {
                        Text(disk.name)
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(5)
                        Spacer()
                        Text("\(String(format: "%.0f GB", Double(disk.availableBytes) / 1_073_741_824.0)) free")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Bluetooth Devices Card
public struct BluetoothCardView: View {
    public var devices: [BluetoothPeripheral]
    
    public init(devices: [BluetoothPeripheral]) {
        self.devices = devices
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Bluetooth Devices",
            icon: "headphones",
            targetTab: .battery,
            unitDetail: "Bluetooth 5.3 · Active Peripherals",
            badge: nil,
            height: 150
        ) { isHovered in
            HStack(spacing: 8) {
                ForEach(devices.prefix(4)) { dev in
                    BatteryPillarView(peripheral: dev, height: 60)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - 5. Temperature Card
public struct TemperatureCardView: View {
    public var thermals: ThermalInfo
    
    public init(thermals: ThermalInfo) {
        self.thermals = thermals
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Processor Temp",
            icon: "thermometer.medium",
            targetTab: .battery,
            unitDetail: "M4 Pro Die Sensors · 0% Throttling",
            badge: thermals.status,
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Int(round(thermals.temperatureC)))°C")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(String(format: "%.1f°F", thermals.temperatureF))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ThermometerView(temperatureC: thermals.temperatureC)
                        .frame(width: 24, height: 46)
                }
                
                if !isHovered {
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(thermals.isThrottled ? Color.red : (thermals.temperatureC > 65 ? Color.orange : Color.green))
                                .frame(width: 6, height: 6)
                            Text(thermals.status)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(5)
                        
                        Spacer()
                        Text("TjMax 100°C")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Cooling Fans Card
public struct FansCardView: View {
    public var fans: FanInfo
    
    public init(fans: FanInfo) {
        self.fans = fans
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Cooling Fans",
            icon: "fanblades",
            targetTab: .battery,
            unitDetail: "Dual Centrifugal Blowers · Max 5800 RPM",
            badge: fans.leftRPM > 0 ? "Active" : "Silent",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(fans.leftRPM) RPM")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(fans.status)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Speed Progress Curve
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.08)).frame(height: 5)
                        let ratio = min(1.0, Double(fans.leftRPM) / Double(max(1, fans.maxRPM)))
                        Capsule()
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(4, geo.size.width * CGFloat(ratio)), height: 5)
                    }
                }
                .frame(height: 5)
                
                if !isHovered {
                    HStack {
                        Text("Left: \(fans.leftRPM) RPM")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Right: \(fans.rightRPM) RPM")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Network Activity Card
public struct NetworkCardView: View {
    public var network: NetworkInfo
    
    public init(network: NetworkInfo) {
        self.network = network
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Network Activity",
            icon: "globe",
            targetTab: .network,
            unitDetail: "Wi-Fi 6E (en0) · 802.11ax · Signal: -48 dBm",
            badge: network.connectionType,
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.95, green: 0.25, blue: 0.55))
                        Text(NetworkInfo.formatSpeed(network.downloadBytesPerSec))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.95))
                        Text(NetworkInfo.formatSpeed(network.uploadBytesPerSec))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                }
                
                MirroredBarChart(downloadData: network.downloadHistory, uploadData: network.uploadHistory, maxBars: 20)
                    .frame(height: 28)
                
                if !isHovered {
                    HStack {
                        Text("LAN: \(network.localIP)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text("WAN: \(network.publicIP)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

// MARK: - 8. Network Data Card
public struct NetworkDataCardView: View {
    public var network: NetworkInfo
    
    public init(network: NetworkInfo) {
        self.network = network
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Network Data",
            icon: "chart.line.uptrend.xyaxis",
            targetTab: .network,
            unitDetail: "Daily Avg: 4.65 GB · Rollover at 00:00",
            badge: "Today",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 5) {
                Text("Today")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(NetworkInfo.formatDataVolume(network.dataTodayBytes))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Divider().opacity(0.3)
                
                if !isHovered {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Last 7 days")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(NetworkInfo.formatDataVolume(network.data7DaysBytes))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("Last 30 days")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(NetworkInfo.formatDataVolume(network.data30DaysBytes))
                                .font(.system(size: 11, weight: .semibold))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 9. Graphics Card (GPU)
public struct GPUCardView: View {
    public var gpu: GPUInfo
    
    public init(gpu: GPUInfo) {
        self.gpu = gpu
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Graphics (GPU)",
            icon: "display",
            targetTab: .processor,
            unitDetail: "Apple M4 Pro 20-Core GPU · Metal 3.2",
            badge: "20-Core",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                Text(String(format: "%.1f%%", gpu.utilizationPercent))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // GPU Sparkline
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let data = gpu.history.isEmpty ? [Double](repeating: 2.0, count: 18) : gpu.history
                    
                    Path { path in
                        for (i, val) in data.enumerated() {
                            let x = CGFloat(i) / CGFloat(max(1, data.count - 1)) * w
                            let y = h - (CGFloat(min(100.0, max(0.0, val))) / 100.0 * h)
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                .frame(height: 28)
                
                if !isHovered {
                    HStack {
                        Text("M4 Pro 20-Core GPU")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("VRAM \(String(format: "%.1f GB", Double(gpu.memoryUsedBytes) / 1_073_741_824.0))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 10. Battery Card
public struct BatteryCardView: View {
    public var battery: BatteryInfo
    
    public init(battery: BatteryInfo) {
        self.battery = battery
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Battery & Power",
            icon: "battery.100",
            targetTab: .battery,
            unitDetail: "70 Wh Li-Po · Draw: \(String(format: "%.1f W", battery.powerWatts))",
            badge: "\(battery.healthPercent)% Health",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(battery.percentage)%")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(battery.isCharging ? "Charging" : (battery.isACConnected ? "Power Adapter" : "On Battery"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Battery Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.08)).frame(height: 6)
                        Capsule()
                            .fill(battery.percentage > 20 ? Color.green : Color.red)
                            .frame(width: max(4, geo.size.width * CGFloat(battery.percentage) / 100.0), height: 6)
                    }
                }
                .frame(height: 6)
                
                if !isHovered {
                    HStack {
                        Text("Cycles: \(battery.cycleCount)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Temp: \(String(format: "%.0f°C", battery.temperatureC))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 11. Disks & Volumes Card
public struct VolumesCardView: View {
    public var volumes: [VolumeInfo]
    
    public init(volumes: [VolumeInfo]) {
        self.volumes = volumes
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Disks & Volumes",
            icon: "externaldrive.connected.to.line.below",
            targetTab: .disk,
            unitDetail: "APFS Container Data · Encrypted Drive",
            badge: "\(volumes.count) Mounted",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 6) {
                ForEach(volumes.prefix(2)) { vol in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: vol.isRemote ? "network" : (vol.isRemovable ? "externaldrive.fill" : "internaldrive.fill"))
                                .font(.system(size: 10))
                                .foregroundColor(vol.isRemote ? .purple : .blue)
                            Text(vol.name)
                                .font(.system(size: 10, weight: .semibold))
                                .lineLimit(1)
                            Spacer()
                            Text("\(String(format: "%.0f GB", Double(vol.availableBytes) / 1_073_741_824.0)) free")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.primary.opacity(0.08)).frame(height: 4)
                                Capsule()
                                    .fill(vol.isRemote ? Color.purple : Color.blue)
                                    .frame(width: max(4, geo.size.width * CGFloat(vol.usedPercent / 100.0)), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                
                if !isHovered {
                    Text("Mounted on /System/Volumes/Data")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - 12. SoC Hardware Architecture Card
public struct SystemArchCardView: View {
    public var cpu: CPUInfo
    
    public init(cpu: CPUInfo) {
        self.cpu = cpu
    }
    
    public var body: some View {
        BentoCardContainer(
            title: "Apple Silicon",
            icon: "apple.logo",
            targetTab: .processor,
            unitDetail: "150B Transistors · TSMC 3nm (N3E)",
            badge: "M4 Pro",
            height: 150
        ) { isHovered in
            VStack(alignment: .leading, spacing: 4) {
                Text(cpu.chipName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("10 Performance + 4 Efficiency Cores")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("16-Core Neural Engine (38 TOPS)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.purple)
                
                if !isHovered {
                    Text("273 GB/s Unified Memory Bus")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - 13. Grand Hero Top Processes Card (Spans Full Width 448pt)
public struct ProcessesCardView: View {
    public var topCPU: [ProcessItem]
    public var topMem: [ProcessItem]
    @ObservedObject var uiState = UIState.shared
    @Environment(\.colorScheme) var colorScheme
    
    public init(topCPU: [ProcessItem], topMem: [ProcessItem]) {
        self.topCPU = topCPU
        self.topMem = topMem
    }
    
    public var body: some View {
        let isHovered = (uiState.hoveredCard == "Processes")
        
        VStack(alignment: .leading, spacing: 8) {
            // Header with NO truncation: Plenty of space for Title, Badge, and Mode Picker
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isHovered ? .blue : .secondary)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Processes")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isHovered ? .primary : .secondary)
                    Text("Top Resource Consumers")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Spacious Segmented Picker
                HStack(spacing: 2) {
                    Button(action: { uiState.processMode = 0 }) {
                        Text("CPU")
                            .font(.system(size: 11, weight: uiState.processMode == 0 ? .bold : .medium))
                            .foregroundColor(uiState.processMode == 0 ? .white : .primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(uiState.processMode == 0 ? Color.blue : Color.clear)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { uiState.processMode = 1 }) {
                        Text("Memory")
                            .font(.system(size: 11, weight: uiState.processMode == 1 ? .bold : .medium))
                            .foregroundColor(uiState.processMode == 1 ? .white : .primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(uiState.processMode == 1 ? Color.blue : Color.clear)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(2)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(8)
                
                Button(action: {
                    WindowManager.shared.openWindow(tab: .processes)
                }) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isHovered ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .help("Open Full Process Inspector App")
            }
            
            Divider().opacity(0.4)
            
            // Process List Rows
            let list = uiState.processMode == 0 ? topCPU : topMem
            VStack(spacing: 4) {
                ForEach(list) { item in
                    HStack(spacing: 8) {
                        Image(systemName: item.isSystem ? "gearshape.2" : "app.fill")
                            .font(.system(size: 11))
                            .foregroundColor(item.isSystem ? .secondary : .blue)
                            .frame(width: 14)
                        
                        Text(item.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: 220, alignment: .leading)
                        
                        Text("PID \(item.pid)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(4)
                        
                        Text("\(item.threadsCount) thr")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(uiState.processMode == 0 ? String(format: "%.1f%%", item.cpuPercent) : item.memoryString)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(uiState.processMode == 0
                                             ? (item.cpuPercent > 30.0 ? .red : (item.cpuPercent > 15.0 ? .orange : .primary))
                                             : .primary)
                    }
                    .padding(.vertical, 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        WindowManager.shared.openWindow(tab: .processes)
                    }
                }
            }
            
            Divider().opacity(0.4)
            
            // Bottom Action Bar
            HStack {
                Button(action: {
                    WindowManager.shared.openWindow(tab: .processes)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.forward.app")
                        Text("Open Detailed Inspector in Mac App")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                }) {
                    Text("Activity Monitor")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
            
            if isHovered {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.blue)
                    Text("Click anywhere to open full process manager with search, sorting & force-quit")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(4)
            }
        }
        .padding(14)
        .modifier(BentoCardBackground(isHovered: isHovered, colorScheme: colorScheme))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onHover { hovering in
            uiState.setHoveredCard("Processes", isHovered: hovering)
        }
        .onTapGesture {
            WindowManager.shared.openWindow(tab: .processes)
        }
        .help("Click to open full Process Inspector in Mac App")
    }
}
