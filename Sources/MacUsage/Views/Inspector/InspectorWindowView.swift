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
            VStack(alignment: .leading, spacing: 14) {
                // Header Profile (Clickable to Dashboard)
                Button(action: {
                    uiState.selectedInspectorTab = .dashboard
                }) {
                    HStack(spacing: 10) {
                        if let icon = NSApp.applicationIconImage {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .cornerRadius(7)
                                .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1.5)
                        } else {
                            Image(systemName: "macbook.gen2")
                                .font(.system(size: 24))
                                .foregroundColor(MactivityTheme.sand)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(collector.cpu.chipName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.primary)
                            Text("\(collector.cpu.coreCount) Cores · \(String(format: "%.0f", Double(collector.memory.totalBytes) / 1_073_741_824.0)) GB Unified")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Divider().opacity(0.4)
                
                // Bespoke Themed Navigation Tabs (Full Bilah Clickable Surface)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(InspectorTab.allCases) { tab in
                            let isSelected = uiState.selectedInspectorTab == tab
                            let isHovered = uiState.hoveredSidebarTab == tab
                            Button(action: {
                                uiState.selectedInspectorTab = tab
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: tab.iconName)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(isSelected ? MactivityTheme.sand : (isHovered ? MactivityTheme.sand.opacity(0.85) : .secondary))
                                        .frame(width: 20)
                                    
                                    Text(tab.rawValue)
                                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                        .foregroundColor(isSelected ? .white : (isHovered ? Color.white.opacity(0.95) : .primary))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    if isSelected {
                                        Capsule()
                                            .fill(MactivityTheme.sand)
                                            .frame(width: 3, height: 16)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected
                                              ? MactivityTheme.petrol.opacity(0.85)
                                              : (isHovered ? MactivityTheme.petrol.opacity(0.40) : Color.primary.opacity(0.001)))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected
                                                ? MactivityTheme.slate.opacity(0.60)
                                                : (isHovered ? MactivityTheme.slate.opacity(0.35) : Color.clear), lineWidth: 0.8)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .onHover { hovering in
                                uiState.hoveredSidebarTab = hovering ? tab : nil
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                Spacer()
                
                // Bottom Status
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("Live Telemetry")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.0s")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(MactivityTheme.sand)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.60))
        } detail: {
            // Tab Content with Adaptive Responsive Layouts
            Group {
                switch uiState.selectedInspectorTab {
                case .dashboard:
                    DashboardInspectorView(collector: collector, uiState: uiState)
                case .processes:
                    ProcessesInspectorView(collector: collector, uiState: uiState)
                case .processor:
                    ProcessorInspectorView(collector: collector)
                case .graphics:
                    GraphicsInspectorView(collector: collector)
                case .memory:
                    MemoryInspectorView(collector: collector)
                case .network:
                    NetworkInspectorView(collector: collector)
                case .disk:
                    DiskInspectorView(collector: collector)
                case .battery:
                    BatteryInspectorView(collector: collector)
                case .thermals:
                    ThermalsInspectorView(collector: collector)
                case .bluetooth:
                    BluetoothInspectorView(collector: collector)
                }
            }
            .frame(minWidth: 620, minHeight: 520)
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
}

// MARK: - 0. Dashboard Inspector View (Premier Big Screen Overview)
@MainActor
struct DashboardInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    @ObservedObject var uiState: UIState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Profile & Live Telemetry Banner
                HStack(alignment: .center, spacing: 16) {
                    if let icon = NSApp.applicationIconImage {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 42, height: 42)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.30), radius: 4, x: 0, y: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(collector.cpu.machineName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("· \(collector.cpu.chipName)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(MactivityTheme.sand)
                        }
                        
                        Text("\(collector.cpu.topologyDescription) · \(collector.gpu.gpuName) \(collector.gpu.coreCountString) · \(String(format: "%.0f", Double(collector.memory.totalBytes) / 1_073_741_824.0)) GB Unified")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick KPI Badges
                    HStack(spacing: 8) {
                        DashboardMetricBadge(title: "CPU", value: String(format: "%.0f%%", collector.cpu.totalUsage), color: MactivityTheme.sand)
                        DashboardMetricBadge(title: "RAM", value: String(format: "%.0f%%", collector.memory.usedPercent), color: MactivityTheme.copper)
                        DashboardMetricBadge(title: "TEMP", value: "\(Int(round(collector.thermals.temperatureC)))°C", color: collector.thermals.temperatureC > 75 ? .red : MactivityTheme.sand)
                        DashboardMetricBadge(title: "NET", value: NetworkInfo.formatSpeed(collector.network.downloadBytesPerSec), color: MactivityTheme.sand)
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Symmetrical Bento Grid (Adapts to 2 or 3 columns based on window width)
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 260, maximum: 400), spacing: 12)
                ], spacing: 12) {
                    ProcessorCardView(cpu: collector.cpu)
                    MemoryCardView(memory: collector.memory)
                    GPUCardView(gpu: collector.gpu)
                    
                    DiskCardView(disk: collector.disk)
                    NetworkCardView(network: collector.network)
                    NetworkDataCardView(network: collector.network)
                    
                    TemperatureCardView(thermals: collector.thermals)
                    FansCardView(fans: collector.fans)
                    BatteryCardView(battery: collector.battery)
                    
                    BluetoothCardView(devices: collector.bluetoothDevices)
                    VolumesCardView(volumes: collector.volumes)
                    SystemArchCardView(cpu: collector.cpu)
                }
                
                // Grand Hero Top Processes Card (Full Width in Overview)
                ProcessesCardView(topCPU: collector.topProcessesCPU, topMem: collector.topProcessesMemory)
            }
            .padding(18)
        }
    }
}

struct DashboardMetricBadge: View {
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(8)
    }
}

// MARK: - 1. Processes Inspector View (Fluid Responsive Design)
@MainActor
struct ProcessesInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    @ObservedObject var uiState: UIState
    
    var filteredProcesses: [ProcessItem] {
        let text = uiState.processSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var list = collector.allProcesses
        
        // Filter by Mode: 0 = All, 1 = User Apps, 2 = System Daemons
        if uiState.processFilterMode == 1 {
            list = list.filter { !$0.isSystem }
        } else if uiState.processFilterMode == 2 {
            list = list.filter { $0.isSystem }
        }
        
        // Filter by Search Query
        if !text.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(text) || String($0.pid).contains(text) || $0.user.lowercased().contains(text)
            }
        }
        
        // Sort
        switch uiState.processSortField {
        case .cpu:
            list.sort { uiState.processSortAscending ? $0.cpuPercent < $1.cpuPercent : $0.cpuPercent > $1.cpuPercent }
        case .memory:
            list.sort { uiState.processSortAscending ? $0.memoryBytes < $1.memoryBytes : $0.memoryBytes > $1.memoryBytes }
        case .name:
            list.sort { uiState.processSortAscending ? $0.name.localizedCompare($1.name) == .orderedAscending : $0.name.localizedCompare($1.name) == .orderedDescending }
        case .pid:
            list.sort { uiState.processSortAscending ? $0.pid < $1.pid : $0.pid > $1.pid }
        }
        
        return list
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search, Filters & Controls Bar
            HStack(spacing: 10) {
                // Search Input
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    TextField("Search processes by name, PID, user...", text: $uiState.processSearchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
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
                .frame(minWidth: 180, maxWidth: 300)
                
                // Filter Segmented Picker (All / Apps / System)
                Picker("Filter", selection: $uiState.processFilterMode) {
                    Text("All").tag(0)
                    Text("Apps").tag(1)
                    Text("System").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
                
                Spacer()
                
                // Launch Native Activity Monitor button
                Button(action: {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 11))
                        Text("Activity Monitor")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(12)
            
            Divider().opacity(0.5)
            
            // Responsive Table Header with Interactive Sort Headers
            HStack(spacing: 8) {
                // Process Name Header (Fluid Width)
                Button(action: { toggleSort(field: .name) }) {
                    HStack(spacing: 4) {
                        Text("Process Name")
                        sortIndicator(for: .name)
                    }
                    .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                
                // PID
                Button(action: { toggleSort(field: .pid) }) {
                    HStack(spacing: 2) {
                        Text("PID")
                        sortIndicator(for: .pid)
                    }
                    .frame(width: 55, alignment: .trailing)
                }
                .buttonStyle(.plain)
                
                // User
                Text("User")
                    .frame(width: 70, alignment: .leading)
                
                // Threads
                Text("Threads")
                    .frame(width: 55, alignment: .trailing)
                
                // CPU %
                Button(action: { toggleSort(field: .cpu) }) {
                    HStack(spacing: 2) {
                        Text("CPU %")
                        sortIndicator(for: .cpu)
                    }
                    .frame(width: 65, alignment: .trailing)
                }
                .buttonStyle(.plain)
                
                // Memory
                Button(action: { toggleSort(field: .memory) }) {
                    HStack(spacing: 2) {
                        Text("Memory")
                        sortIndicator(for: .memory)
                    }
                    .frame(width: 75, alignment: .trailing)
                }
                .buttonStyle(.plain)
                
                // Action
                Text("Action")
                    .frame(width: 55, alignment: .center)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.03))
            
            Divider().opacity(0.5)
            
            // Responsive Process Rows List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredProcesses) { proc in
                        let isSelected = uiState.selectedProcessPID == proc.pid
                        HStack(spacing: 8) {
                            // Process Name & Icon (Fluid Adaptive Column)
                            HStack(spacing: 8) {
                                Image(systemName: proc.isSystem ? "gearshape.2" : "app.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(proc.isSystem ? .secondary : MactivityTheme.sand)
                                    .frame(width: 14)
                                
                                Text(proc.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                            
                            // PID
                            Text("\(proc.pid)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 55, alignment: .trailing)
                            
                            // User
                            Text(proc.user)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .frame(width: 70, alignment: .leading)
                            
                            // Threads
                            Text("\(proc.threadsCount)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 55, alignment: .trailing)
                            
                            // CPU %
                            Text(String(format: "%.1f%%", proc.cpuPercent))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(proc.cpuPercent > 50.0 ? .red : (proc.cpuPercent > 15.0 ? MactivityTheme.copper : .primary))
                                .frame(width: 65, alignment: .trailing)
                            
                            // Memory
                            Text(proc.memoryString)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(MactivityTheme.sand)
                                .frame(width: 75, alignment: .trailing)
                            
                            // Force Quit Action
                            Button(action: {
                                let _ = collector.killProcess(pid: proc.pid)
                            }) {
                                Text("End")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.12))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 55, alignment: .center)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 5)
                        .background(
                            isSelected
                            ? MactivityTheme.petrol.opacity(0.40)
                            : (filteredProcesses.firstIndex(of: proc).map { $0 % 2 == 1 } ?? false ? Color.primary.opacity(0.015) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isSelected ? MactivityTheme.sand.opacity(0.50) : Color.clear, lineWidth: 0.8)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            uiState.selectedProcessPID = proc.pid
                        }
                    }
                }
            }
            
            Divider().opacity(0.5)
            
            // Bottom Status Summary
            HStack(spacing: 16) {
                Text("\(filteredProcesses.count) Processes Listed")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Text("Total CPU: \(String(format: "%.1f%%", collector.cpu.totalUsage))")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(MactivityTheme.sand)
                    Text("RAM Used: \(collector.memory.usedGBString)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(MactivityTheme.copper)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.02))
        }
    }
    
    private func toggleSort(field: ProcessSortField) {
        if uiState.processSortField == field {
            uiState.processSortAscending.toggle()
        } else {
            uiState.processSortField = field
            uiState.processSortAscending = (field == .name)
        }
    }
    
    @ViewBuilder
    private func sortIndicator(for field: ProcessSortField) -> some View {
        if uiState.processSortField == field {
            Image(systemName: uiState.processSortAscending ? "arrow.up" : "arrow.down")
                .font(.system(size: 9))
                .foregroundColor(MactivityTheme.sand)
        }
    }
}

// MARK: - 2. Processor Inspector View (CPU & Core Topology)
struct ProcessorInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Utilization Overview Card
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processor Utilization")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", collector.cpu.totalUsage))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
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
                    HistoryBarChart(totalData: collector.cpu.history, userPart: collector.cpu.userHistory, barCount: 28)
                        .frame(width: 240, height: 75)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Responsive Adaptive Core Topology Grid
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(collector.cpu.chipName) Core Topology (\(collector.cpu.coreCount) Active Cores)")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        if collector.cpu.performanceCoreCount > 0 && collector.cpu.efficiencyCoreCount > 0 {
                            HStack(spacing: 10) {
                                HStack(spacing: 4) {
                                    Circle().fill(MactivityTheme.sand).frame(width: 6, height: 6)
                                    Text("P-Cores (1-\(collector.cpu.performanceCoreCount))").font(.system(size: 10)).foregroundColor(.secondary)
                                }
                                HStack(spacing: 4) {
                                    Circle().fill(MactivityTheme.copper).frame(width: 6, height: 6)
                                    Text("E-Cores (1-\(collector.cpu.efficiencyCoreCount))").font(.system(size: 10)).foregroundColor(.secondary)
                                }
                            }
                        } else {
                            HStack(spacing: 4) {
                                Circle().fill(MactivityTheme.sand).frame(width: 6, height: 6)
                                Text("Cores (1-\(collector.cpu.coreCount))").font(.system(size: 10)).foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 68, maximum: 100), spacing: 8)], spacing: 8) {
                        ForEach(0..<collector.cpu.coreLoads.count, id: \.self) { idx in
                            let load = collector.cpu.coreLoads[idx]
                            let pCount = collector.cpu.performanceCoreCount > 0 ? collector.cpu.performanceCoreCount : collector.cpu.coreCount
                            let hasHybridTopology = collector.cpu.performanceCoreCount > 0 && collector.cpu.efficiencyCoreCount > 0
                            let isPCore = idx < pCount
                            let coreLabel: String = {
                                if hasHybridTopology {
                                    return isPCore ? "P\(idx + 1)" : "E\(idx - pCount + 1)"
                                } else {
                                    return "C\(idx + 1)"
                                }
                            }()
                            
                            VStack(spacing: 6) {
                                Text(coreLabel)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(isPCore ? MactivityTheme.sand : MactivityTheme.copper)
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .bottom) {
                                        Capsule().fill(Color.primary.opacity(0.08))
                                        Capsule()
                                            .fill(isPCore ? MactivityTheme.sand : MactivityTheme.copper)
                                            .frame(height: max(4, geo.size.height * CGFloat(load / 100.0)))
                                    }
                                }
                                .frame(height: 55)
                                
                                Text(String(format: "%.0f%%", load))
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                            }
                            .padding(8)
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Hardware Architectural Specs Card
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Architecture Details")
                            .font(.system(size: 12, weight: .bold))
                        Text("Unified memory architecture powered by \(collector.cpu.chipName) with \(collector.cpu.topologyDescription).")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Hardware Acceleration")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(MactivityTheme.sand)
                        Text("Hardware Accelerated Engine · \(collector.cpu.modelIdentifier)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(14)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(10)
            }
            .padding(18)
        }
    }
}

// MARK: - 3. Graphics Inspector View (Dedicated GPU Tab)
struct GraphicsInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header GPU Overview
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(collector.gpu.gpuName) Graphics Processor")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", collector.gpu.utilizationPercent))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(MactivityTheme.sand)
                        Text("\(collector.gpu.coreCountString) · Metal Hardware Engine")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Utilization Gauge Bar
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(collector.gpu.memoryUsedMBString)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(MactivityTheme.copper)
                        Text("Active Shared VRAM")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Adaptive Feature Tiles
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 350), spacing: 12)], spacing: 12) {
                    GpuFeatureCard(title: "Metal Acceleration", subtitle: "Low-overhead compute & graphics API", value: "Metal 3 Ready", icon: "cpu")
                    GpuFeatureCard(title: "Dynamic Caching", subtitle: "Unified Memory Allocation", value: "Hardware Enabled", icon: "memorychip")
                    GpuFeatureCard(title: "Hardware Shading", subtitle: "Complex Rendering Pipelines", value: "Supported", icon: "waveform.path.ecg")
                    GpuFeatureCard(title: "Unified Display Engine", subtitle: "\(collector.cpu.machineName) Output", value: "Direct Rendering", icon: "display")
                }
                
                // GPU Architecture Details
                VStack(alignment: .leading, spacing: 10) {
                    Text("Graphics & Display Subsystem")
                        .font(.system(size: 13, weight: .bold))
                    Text("The \(collector.gpu.gpuName) architecture integrates hardware-accelerated rasterization and compute pipelines directly across unified memory, maximizing rendering throughput and energy efficiency.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
            }
            .padding(18)
        }
    }
}

struct GpuFeatureCard: View {
    var title: String
    var subtitle: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(MactivityTheme.sand)
                Spacer()
                Text(value)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(MactivityTheme.copper)
            }
            Text(title)
                .font(.system(size: 12, weight: .bold))
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(10)
    }
}

// MARK: - 4. Memory Inspector View
struct MemoryInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unified Memory Status")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", collector.memory.usedPercent))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
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
                
                // Detailed Memory Breakdown Table
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
            .padding(18)
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

// MARK: - 5. Network Inspector View
struct NetworkInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
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
                
                // Historical Volume Ledger Cards (Adaptive Grid)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 300), spacing: 12)], spacing: 12) {
                    DataVolumeCard(title: "Today", volume: collector.network.dataTodayBytes)
                    DataVolumeCard(title: "Last 7 Days", volume: collector.network.data7DaysBytes)
                    DataVolumeCard(title: "Last 30 Days", volume: collector.network.data30DaysBytes)
                }
            }
            .padding(18)
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
                .foregroundColor(MactivityTheme.sand)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(10)
    }
}

// MARK: - 6. Disk & Volumes Inspector View
struct DiskInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Mounted Storage & Volumes")
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
            .padding(18)
        }
    }
}

// MARK: - 7. Battery & Power Inspector View
struct BatteryInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if collector.battery.hasBattery {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(collector.cpu.machineName) Power & Battery")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("\(collector.battery.percentage)%")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(collector.battery.percentage > 20 ? MactivityTheme.sand : .red)
                            Text(collector.battery.isACConnected ? "Connected to Power Adapter (AC)" : "Running on Battery Power")
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
                    
                    // Power Efficiency Telemetry
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 300), spacing: 12)], spacing: 12) {
                        PowerMetricCard(title: "Charging State", value: collector.battery.isCharging ? "Charging" : (collector.battery.isACConnected ? "Fully Charged" : "Discharging"), icon: "bolt.fill")
                        PowerMetricCard(title: "Battery Health", value: collector.battery.healthPercent >= 80 ? "Normal" : "Service Recommended", icon: "heart.fill")
                        PowerMetricCard(title: "Battery Cycles", value: "\(collector.battery.cycleCount) / 1000", icon: "arrow.triangle.2.circlepath")
                    }
                } else {
                    // Desktop Mac Mode (AC Power Direct, No Battery Cell)
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(collector.cpu.machineName) Power Architecture")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("AC Power Direct")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(MactivityTheme.sand)
                            Text("Continuous Mains Power · Desktop Architecture")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("Desktop Hardware")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(MactivityTheme.copper)
                            Text("No Battery Degradation")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(12)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 300), spacing: 12)], spacing: 12) {
                        PowerMetricCard(title: "Power Source", value: "AC Wall Outlet", icon: "powerplug.fill")
                        PowerMetricCard(title: "Battery Cell", value: "None (Desktop)", icon: "battery.0")
                        PowerMetricCard(title: "Thermal Governor", value: "Direct AC Rails", icon: "bolt.shield.fill")
                    }
                }
            }
            .padding(18)
        }
    }
}

struct PowerMetricCard: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(MactivityTheme.sand)
                Spacer()
            }
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(10)
    }
}

// MARK: - 8. Thermals & Fans Inspector View (Dedicated Telemetry Tab)
struct ThermalsInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Thermals Status
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(collector.cpu.chipName) Thermal Envelope")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f°C", collector.thermals.temperatureC))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(collector.thermals.temperatureC > 85 ? .red : (collector.thermals.temperatureC > 70 ? MactivityTheme.copper : MactivityTheme.sand))
                        Text("SoC Temperature: \(String(format: "%.0f°F", collector.thermals.temperatureF)) · \(collector.thermals.status)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    ThermometerView(temperatureC: collector.thermals.temperatureC)
                        .frame(width: 30, height: 75)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Fan Telemetry (Dynamically handling Fanless, Single Fan, Dual Fans)
                VStack(alignment: .leading, spacing: 12) {
                    if collector.fans.isFanless {
                        Text("Fanless Acoustic Architecture")
                            .font(.system(size: 13, weight: .bold))
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "wind.snow")
                                        .font(.system(size: 18))
                                        .foregroundColor(MactivityTheme.sand)
                                    Spacer()
                                    Text("0 dB Completely Silent")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.green)
                                }
                                Text("100% Passive Cooling")
                                    .font(.system(size: 16, weight: .bold))
                                Text("This \(collector.cpu.machineName) features a silent fanless thermal system with passive aluminum conduction.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(10)
                        }
                    } else if collector.fans.fanCount == 1 {
                        Text("Cooling Blower Telemetry")
                            .font(.system(size: 13, weight: .bold))
                        
                        FanCard(title: "System Cooling Blower", rpm: collector.fans.leftRPM, status: collector.fans.status)
                    } else {
                        Text("Dual Centrifugal Blowers Telemetry")
                            .font(.system(size: 13, weight: .bold))
                        
                        HStack(spacing: 12) {
                            FanCard(title: "Left Cooling Blower", rpm: collector.fans.leftRPM, status: collector.fans.status)
                            FanCard(title: "Right Cooling Blower", rpm: collector.fans.rightRPM, status: collector.fans.status)
                        }
                    }
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Acoustic Profile Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(collector.cpu.machineName) Acoustic Profile")
                        .font(.system(size: 12, weight: .bold))
                    Text(collector.fans.isFanless
                         ? "Fanless design delivers zero audible noise, relying on thermal throttling governor and natural convective heat transfer."
                         : "\(collector.cpu.machineName) utilizes dynamic thermal curves: fans remain quiet or completely silent during general productivity, smoothly ramping RPM when compiling or rendering complex workloads.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(10)
            }
            .padding(18)
        }
    }
}

struct FanCard: View {
    var title: String
    var rpm: Int
    var status: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fanblades")
                    .font(.system(size: 16))
                    .foregroundColor(rpm > 0 ? MactivityTheme.sand : .secondary)
                Spacer()
                Text(rpm > 0 ? "Active" : "Silent (0 RPM)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(rpm > 0 ? MactivityTheme.sand : .green)
            }
            
            Text("\(rpm) RPM")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08)).frame(height: 5)
                    Capsule()
                        .fill(MactivityTheme.sand)
                        .frame(width: max(4, geo.size.width * CGFloat(min(1.0, Double(rpm) / 5800.0))), height: 5)
                }
            }
            .frame(height: 5)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(10)
    }
}

// MARK: - 9. Bluetooth Devices Inspector View (Dedicated Peripherals Section)
struct BluetoothInspectorView: View {
    @ObservedObject var collector: MetricsCollector
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Bluetooth Manager Overview
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bluetooth Peripherals & Connected Devices")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("\(collector.cpu.chipName) Wireless Subsystem")
                            .font(.system(size: 24, weight: .bold))
                        Text("IOBluetooth & Apple HID Event Service Telemetry")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Quick Action: Open macOS Bluetooth Settings
                    Button(action: {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings") {
                            NSWorkspace.shared.open(url)
                        } else {
                            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Bluetooth.prefPane"))
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "gearshape")
                            Text("Bluetooth Settings")
                        }
                        .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
                .background(Color.primary.opacity(0.04))
                .cornerRadius(12)
                
                // Active Connected Peripheral Cards Grid
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Active Connected Devices (\(collector.connectedBluetoothDevices.count) Connected)")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        HStack(spacing: 6) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("Bluetooth 5.3 Ready")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if collector.connectedBluetoothDevices.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("No Active Bluetooth Peripherals")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Connect a Bluetooth mouse, keyboard, or headset via System Settings.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.primary.opacity(0.03))
                        .cornerRadius(10)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260, maximum: 400), spacing: 12)], spacing: 12) {
                            ForEach(collector.connectedBluetoothDevices) { dev in
                                BluetoothDeviceCard(device: dev)
                            }
                        }
                    }
                }
                
                // Saved / Paired Inactive Devices (if any)
                if !collector.pairedBluetoothDevices.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Paired & Saved Devices (\(collector.pairedBluetoothDevices.count) Offline)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260, maximum: 400), spacing: 12)], spacing: 12) {
                            ForEach(collector.pairedBluetoothDevices) { dev in
                                BluetoothDeviceCard(device: dev)
                            }
                        }
                    }
                }
                
                // Bluetooth Diagnostic & Power Advice Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(MactivityTheme.sand)
                        Text("Apple Silicon Peripheral Management")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Text("Battery telemetry for wireless mice, keyboards, audio devices, and BLE peripherals is retrieved directly from macOS core Bluetooth subsystems without unnecessary background polling drain.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(10)
            }
            .padding(18)
        }
    }
}

struct BluetoothDeviceCard: View {
    var device: BluetoothPeripheral
    
    var iconName: String {
        switch device.type {
        case .headphones: return "headphones"
        case .keyboard: return "keyboard"
        case .trackpad: return "trackpad"
        case .mouse: return "computermouse"
        case .phone: return "iphone"
        case .placeholder: return "plus.circle.dashed"
        }
    }
    
    var typeTitle: String {
        switch device.type {
        case .headphones: return "Wireless Audio"
        case .keyboard: return "Wireless Keyboard"
        case .trackpad: return "Wireless Trackpad"
        case .mouse: return "Bluetooth Mouse"
        case .phone: return "Apple Device"
        case .placeholder: return "Ready for Pairing"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Device Icon & Name
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(device.isConnected ? MactivityTheme.petrol : Color.primary.opacity(0.05))
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 16))
                        .foregroundColor(device.isConnected ? MactivityTheme.sand : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text(typeTitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if device.isConnected {
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Text("Connected")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                } else if device.type == .placeholder {
                    Text("Slot Available")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 4) {
                        Circle().fill(Color.gray).frame(width: 6, height: 6)
                        Text("Offline / Paired")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider().opacity(0.3)
            
            // Battery Status Bar & Number
            if let battery = device.batteryLevel, device.isConnected {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Battery Power")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(battery)%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(battery > 40 ? MactivityTheme.sand : (battery > 20 ? MactivityTheme.copper : .red))
                    }
                    
                    // Battery Progress Capsule
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.primary.opacity(0.08)).frame(height: 6)
                            Capsule()
                                .fill(battery > 40 ? MactivityTheme.sand : (battery > 20 ? MactivityTheme.copper : .red))
                                .frame(width: max(6, geo.size.width * CGFloat(Double(battery) / 100.0)), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text(battery > 20 ? "Optimal Battery Health" : "Low Battery — Charge Peripheral")
                        .font(.system(size: 9))
                        .foregroundColor(battery > 20 ? .secondary : .red)
                }
            } else if device.isConnected {
                HStack {
                    Text("Power Source")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Active / AC Powered")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MactivityTheme.sand)
                }
            } else {
                HStack {
                    Text(device.type == .placeholder ? "Connect via Bluetooth Settings" : "Offline / Out of Range")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color.primary.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(device.isConnected ? MactivityTheme.slate.opacity(0.50) : Color.primary.opacity(0.06), lineWidth: 0.8)
        )
        .cornerRadius(12)
    }
}
