import SwiftUI

@MainActor
public struct DashboardView: View {
    @ObservedObject var collector: MetricsCollector
    @ObservedObject var uiState: UIState = UIState.shared
    
    public init(collector: MetricsCollector, uiState: UIState) {
        self.collector = collector
        self.uiState = uiState
    }
    
    public init() {
        self.collector = MetricsCollector.shared
        self.uiState = UIState.shared
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation & Device Bar
            HStack {
                HStack(spacing: 8) {
                    DevicePillButton(title: "\(collector.cpu.machineName) · \(collector.cpu.chipName)", isSelected: true) {
                        WindowManager.shared.openWindow(tab: .processor)
                    }
                    
                    Button(action: {
                        WindowManager.shared.openWindow(tab: .processes)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "macwindow")
                            Text("Open App")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MactivityTheme.sand)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(MactivityTheme.petrol)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MactivityTheme.sand.opacity(0.35), lineWidth: 0.8)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .help("Open Full Mactivity Inspector Window")
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(MactivityTheme.sand)
                        .frame(width: 6, height: 6)
                    Text("Live")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MactivityTheme.sand)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MactivityTheme.petrol.opacity(0.70))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MactivityTheme.slate.opacity(0.40), lineWidth: 0.8)
                )
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            // Symmetrical, Perfectly-Aligned Bento Grid
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        // Row 1: Core Performance (150pt each)
                        ProcessorCardView(cpu: collector.cpu)
                        MemoryCardView(memory: collector.memory)
                        
                        // Row 2: Storage & Peripherals (150pt each)
                        DiskCardView(disk: collector.disk)
                        BluetoothCardView(devices: collector.bluetoothDevices)
                        
                        // Row 3: Thermals & Acoustics (150pt each)
                        TemperatureCardView(thermals: collector.thermals)
                        FansCardView(fans: collector.fans)
                        
                        // Row 4: Connectivity & Ledger (150pt each)
                        NetworkCardView(network: collector.network)
                        NetworkDataCardView(network: collector.network)
                        
                        // Row 5: Graphics & Power (150pt each)
                        GPUCardView(gpu: collector.gpu)
                        BatteryCardView(battery: collector.battery)
                        
                        // Row 6: Volumes & SoC Architecture (150pt each)
                        VolumesCardView(volumes: collector.volumes)
                        SystemArchCardView(cpu: collector.cpu)
                    }
                    
                    // Row 7: Grand Hero Top Processes Card (Spans Full Width 448pt)
                    ProcessesCardView(topCPU: collector.topProcessesCPU, topMem: collector.topProcessesMemory)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
            
            Divider().opacity(0.25)
            
            // Bottom Action Bar
            HStack {
                HStack(spacing: 5) {
                    Text("Mactivity")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(MactivityTheme.sand)
                    Text("· \(collector.cpu.chipName)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(white: 0.65))
                }
                
                Spacer()
                
                // Quick settings ellipsis menu
                Menu {
                    Section("Refresh Rate") {
                        Button("1 Second (Live)") {
                            uiState.refreshInterval = 1.0
                            collector.startTimer(interval: 1.0)
                        }
                        Button("2 Seconds") {
                            uiState.refreshInterval = 2.0
                            collector.startTimer(interval: 2.0)
                        }
                        Button("5 Seconds (Low Power)") {
                            uiState.refreshInterval = 5.0
                            collector.startTimer(interval: 5.0)
                        }
                    }
                    
                    Divider()
                    
                    Button("Open Full Mactivity Inspector Window") {
                        WindowManager.shared.openWindow(tab: .processes)
                    }
                    
                    Button("Open Activity Monitor") {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                    }
                    
                    Button("Refresh Stats Now") {
                        collector.sampleAllMetrics()
                    }
                    
                    Divider()
                    
                    Button("Quit Mactivity") {
                        NSApplication.shared.terminate(nil)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(MactivityTheme.sand)
                        .frame(width: 28, height: 24)
                        .background(MactivityTheme.petrol)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(MactivityTheme.slate.opacity(0.40), lineWidth: 0.8)
                        )
                        .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 480, height: 680)
        .background(
            ZStack {
                VisualEffectBlurView().ignoresSafeArea()
                MactivityTheme.petrol.opacity(0.40).ignoresSafeArea()
            }
        )
    }
}

// Device Pill Button
struct DevicePillButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? MactivityTheme.sand : Color(white: 0.70))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(isSelected ? MactivityTheme.petrol : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? MactivityTheme.sand.opacity(0.40) : Color.clear, lineWidth: 0.8)
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// Native macOS Frosted Glass Background
struct VisualEffectBlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .popover
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
