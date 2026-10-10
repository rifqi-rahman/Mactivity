import SwiftUI
import AppKit

@MainActor
public struct InspectorWindowView: View {
    @ObservedObject var collector: MetricsCollector
    @ObservedObject var uiState: UIState
    
    public init(collector: MetricsCollector, uiState: UIState) {
        self.collector = collector
        self.uiState = uiState
    }
    
    public init() {
        self.collector = MetricsCollector.shared
        self.uiState = UIState.shared
    }
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 12) {
                // Header Profile
                HStack(spacing: 10) {
                    Image(systemName: "macbook.gen2")
                        .font(.system(size: 24))
                        .foregroundColor(MactivityTheme.sand)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(collector.cpu.chipName)
                            .font(.system(size: 13, weight: .bold))
                        Text("\(collector.cpu.coreCount) Cores · \(String(format: "%.0f", Double(collector.memory.totalBytes) / 1_073_741_824.0)) GB Unified")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 16)
                
                Divider().opacity(0.5)
                
                // Navigation Tabs
                List(InspectorTab.allCases, selection: $uiState.selectedInspectorTab) { tab in
                    NavigationLink(value: tab) {
                        Label {
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        } icon: {
                            Image(systemName: tab.iconName)
                                .foregroundColor(uiState.selectedInspectorTab == tab ? MactivityTheme.sand : .secondary)
                        }
                    }
                    .tag(tab)
                }
                .listStyle(.sidebar)
                
                Spacer()
                
                // Bottom Status
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("Live Monitoring")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
            .frame(minWidth: 200, idealWidth: 220)
        } detail: {
            // Tab Content
            Group {
                switch uiState.selectedInspectorTab {
                case .processes:
                    ProcessesInspectorView(collector: collector, uiState: uiState)
                case .processor:
                    ProcessorInspectorView(collector: collector)
                case .memory:
                    MemoryInspectorView(collector: collector)
                case .network:
                    NetworkInspectorView(collector: collector)
                case .disk:
                    DiskInspectorView(collector: collector)
                case .battery:
                    BatteryInspectorView(collector: collector)
                }
            }
            .frame(minWidth: 640, minHeight: 520)
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
}

// MARK: - 1. Processes Inspector View
@MainActor
struct ProcessesInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    @ObservedObject var uiState: UIState
    
    var filteredProcesses: [ProcessItem] {
        let text = uiState.processSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var list = collector.allProcesses
        
        if !text.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(text) || String($0.pid).contains(text)
            }
        }
        
        switch uiState.processSortField {
        case .cpu:
            list.sort { uiState.processSortAscending ? $0.cpuPercent < $1.cpuPercent : $0.cpuPercent > $1.cpuPercent }
        case .memory:
            list.sort { uiState.processSortAscending ? $0.memoryBytes < $1.memoryBytes : $0.memoryBytes > $1.memoryBytes }
        case .name:
            list.sort { uiState.processSortAscending ? $0.name < $1.name : $0.name > $1.name }
        case .pid:
            list.sort { uiState.processSortAscending ? $0.pid < $1.pid : $0.pid > $1.pid }
        }
        
        return list
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search & Controls Header
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search processes by name or PID...", text: $uiState.processSearchText)
                        .textFieldStyle(.plain)
                    if !uiState.processSearchText.isEmpty {
                        Button(action: { uiState.processSearchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(8)
                
                Picker("Sort by", selection: $uiState.processSortField) {
                    ForEach(ProcessSortField.allCases) { field in
                        Text(field.rawValue).tag(field)
                    }
                }
                .frame(width: 130)
                
                Button(action: { uiState.processSortAscending.toggle() }) {
                    Image(systemName: uiState.processSortAscending ? "arrow.up" : "arrow.down")
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Launch Activity Monitor") {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                }
                .buttonStyle(.bordered)
            }
            .padding(14)
            
            Divider()
            
            // Table Header
            HStack {
                Text("Process Name")
                    .frame(width: 220, alignment: .leading)
                Text("PID")
                    .frame(width: 60, alignment: .trailing)
                Text("User")
                    .frame(width: 80, alignment: .leading)
                Text("Threads")
                    .frame(width: 70, alignment: .trailing)
                Text("CPU %")
                    .frame(width: 90, alignment: .trailing)
                Text("Memory")
                    .frame(width: 90, alignment: .trailing)
                Spacer()
                Text("Action")
                    .frame(width: 80, alignment: .center)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.03))
            
            Divider()
            
            // Process List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredProcesses) { proc in
                        HStack {
                            // Process Name & Icon
                            HStack(spacing: 8) {
                                Image(systemName: proc.isSystem ? "gearshape.2" : "app.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(proc.isSystem ? .secondary : MactivityTheme.sand)
                                Text(proc.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                            }
                            .frame(width: 220, alignment: .leading)
                            
                            // PID
                            Text("\(proc.pid)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .trailing)
                            
                            // User
                            Text(proc.user)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            // Threads
                            Text("\(proc.threadsCount)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 70, alignment: .trailing)
                            
                            // CPU %
                            Text(String(format: "%.1f%%", proc.cpuPercent))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(proc.cpuPercent > 50.0 ? .red : (proc.cpuPercent > 15.0 ? .orange : .primary))
                                .frame(width: 90, alignment: .trailing)
                            
                            // Memory
                            Text(proc.memoryString)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .frame(width: 90, alignment: .trailing)
                            
                            Spacer()
                            
                            // Force Quit Action
                            Button(action: {
                                let _ = collector.killProcess(pid: proc.pid)
                            }) {
                                Text("End")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.red.opacity(0.10))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 80, alignment: .center)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(uiState.selectedProcessPID == proc.pid ? Color.blue.opacity(0.12) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            uiState.selectedProcessPID = proc.pid
                        }
                        
                        Divider().opacity(0.3)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Processor Inspector View
struct ProcessorInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header overview
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processor Utilization")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", collector.cpu.totalUsage))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Circle().fill(MactivityTheme.sand).frame(width: 7, height: 7)
                                Text(String(format: "User: %.1f%%", collector.cpu.userUsage))
                                    .font(.system(size: 11))
                            }
                            HStack(spacing: 4) {
                                Circle().fill(MactivityTheme.copper).frame(width: 7, height: 7)
                                Text(String(format: "System: %.1f%%", collector.cpu.systemUsage))
                                    .font(.system(size: 11))
                            }
                            HStack(spacing: 4) {
                                Circle().fill(Color.gray).frame(width: 7, height: 7)
                                Text(String(format: "Idle: %.1f%%", collector.cpu.idleUsage))
                                    .font(.system(size: 11))
                            }
                        }
                    }
                    Spacer()
                    HistoryBarChart(totalData: collector.cpu.history, userPart: collector.cpu.userHistory, barCount: 24)
                        .frame(width: 220, height: 75)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // All 14 M4 Pro Cores Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Apple M4 Pro Core Topology (\(collector.cpu.coreCount) Active Cores)")
                        .font(.system(size: 13, weight: .bold))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                        ForEach(0..<collector.cpu.coreLoads.count, id: \.self) { idx in
                            let load = collector.cpu.coreLoads[idx]
                            let isPCore = idx < 10 // First 10 are Performance cores on M4 Pro
                            
                            VStack(spacing: 6) {
                                Text(isPCore ? "P-Core \(idx + 1)" : "E-Core \(idx - 9)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(isPCore ? MactivityTheme.sand : MactivityTheme.copper)
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .bottom) {
                                        Capsule().fill(Color.primary.opacity(0.08))
                                        Capsule()
                                            .fill(isPCore ? MactivityTheme.sand : MactivityTheme.copper)
                                            .frame(height: max(4, geo.size.height * CGFloat(load / 100.0)))
                                    }
                                }
                                .frame(height: 60)
                                
                                Text(String(format: "%.0f%%", load))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .padding(8)
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
            }
            .padding(20)
        }
    }
}

// MARK: - 3. Memory Inspector View
struct MemoryInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unified Memory Status")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", collector.memory.usedPercent))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        Text(collector.memory.usedGBString)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    let appPct = Double(collector.memory.appBytes) / Double(max(1, collector.memory.totalBytes)) * 100.0
                    let wiredPct = Double(collector.memory.wiredBytes) / Double(max(1, collector.memory.totalBytes)) * 100.0
                    let compPct = Double(collector.memory.compressedBytes) / Double(max(1, collector.memory.totalBytes)) * 100.0
                    
                    DonutChartView(segments: [
                        (appPct, MactivityTheme.sand),
                        (wiredPct, MactivityTheme.copper),
                        (compPct, MactivityTheme.slate)
                    ], lineWidth: 16)
                    .frame(width: 85, height: 85)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Detailed memory breakdown table
                VStack(spacing: 10) {
                    MemoryStatRow(title: "App Memory (Active user applications)", bytes: collector.memory.appBytes, color: MactivityTheme.sand)
                    Divider().opacity(0.4)
                    MemoryStatRow(title: "Wired Memory (Operating system & drivers)", bytes: collector.memory.wiredBytes, color: MactivityTheme.copper)
                    Divider().opacity(0.4)
                    MemoryStatRow(title: "Compressed Memory (Compressed in RAM)", bytes: collector.memory.compressedBytes, color: MactivityTheme.slate)
                    Divider().opacity(0.4)
                    MemoryStatRow(title: "Cached / Free Memory", bytes: collector.memory.freeBytes, color: .gray)
                    Divider().opacity(0.4)
                    MemoryStatRow(title: "Swap Memory Used", bytes: collector.memory.swapUsedBytes, color: .orange)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
            }
            .padding(20)
        }
    }
}

struct MemoryStatRow: View {
    var title: String
    var bytes: UInt64
    var color: Color
    
    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 12, weight: .medium))
            Spacer()
            let gb = Double(bytes) / 1_073_741_824.0
            Text(gb >= 1.0 ? String(format: "%.2f GB", gb) : String(format: "%.0f MB", Double(bytes) / 1_048_576.0))
                .font(.system(size: 12, weight: .bold, design: .monospaced))
        }
    }
}

// MARK: - 4. Network Inspector View
struct NetworkInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Interface (\(collector.network.interfaceName))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(collector.network.connectionType)
                            .font(.system(size: 26, weight: .bold))
                        HStack(spacing: 12) {
                            Text("LAN: \(collector.network.localIP)")
                                .font(.system(size: 11, design: .monospaced))
                            Text("WAN: \(collector.network.publicIP)")
                                .font(.system(size: 11, design: .monospaced))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("↓ \(NetworkInfo.formatSpeed(collector.network.downloadBytesPerSec))")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(MactivityTheme.sand)
                        Text("↑ \(NetworkInfo.formatSpeed(collector.network.uploadBytesPerSec))")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(MactivityTheme.copper)
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                MirroredBarChart(downloadData: collector.network.downloadHistory, uploadData: collector.network.uploadHistory, maxBars: 36)
                    .frame(height: 70)
                    .padding(16)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(12)
                
                // Historical volume
                HStack(spacing: 12) {
                    DataVolumeCard(title: "Today", volume: collector.network.dataTodayBytes)
                    DataVolumeCard(title: "Last 7 Days", volume: collector.network.data7DaysBytes)
                    DataVolumeCard(title: "Last 30 Days", volume: collector.network.data30DaysBytes)
                }
            }
            .padding(20)
        }
    }
}

struct DataVolumeCard: View {
    var title: String
    var volume: UInt64
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            Text(NetworkInfo.formatDataVolume(volume))
                .font(.system(size: 20, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(10)
    }
}

// MARK: - 5. Disk Inspector View
struct DiskInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Mounted Storage & Remote Volumes")
                    .font(.system(size: 14, weight: .bold))
                
                ForEach(collector.volumes) { vol in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: vol.isRemote ? "network" : (vol.isRemovable ? "externaldrive.fill" : "internaldrive.fill"))
                                .font(.system(size: 18))
                                .foregroundColor(vol.isRemote ? MactivityTheme.copper : MactivityTheme.sand)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vol.name)
                                    .font(.system(size: 13, weight: .bold))
                                Text("\(vol.fileSystem) · \(vol.path)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(format: "%.1f%% Used", vol.usedPercent))
                                    .font(.system(size: 12, weight: .bold))
                                Text("\(String(format: "%.1f", Double(vol.availableBytes) / 1_073_741_824.0)) GB Free")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.primary.opacity(0.08)).frame(height: 6)
                                Capsule()
                                    .fill(vol.isRemote ? MactivityTheme.copper : MactivityTheme.sand)
                                    .frame(width: max(6, geo.size.width * CGFloat(vol.usedPercent / 100.0)), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(14)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(10)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - 6. Battery Inspector View
struct BatteryInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apple Silicon Power & Battery")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("\(collector.battery.percentage)%")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        Text(collector.battery.isACConnected ? "Connected to Power Adapter" : "Running on Battery")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("\(collector.battery.healthPercent)% Health")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                        Text("\(collector.battery.cycleCount) Cycle Count")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processor Temperature")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f°C  (%.0f°F)", collector.thermals.temperatureC, collector.thermals.temperatureF))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(collector.thermals.status)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dual Cooling Fans")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("L: \(collector.fans.leftRPM) · R: \(collector.fans.rightRPM) RPM")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(collector.fans.status)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(MactivityTheme.sand)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(10)
                }
            }
            .padding(20)
        }
    }
}
