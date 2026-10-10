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
            // Top Navigation & Device Bar (Matching Image 2)
            HStack {
                HStack(spacing: 8) {
                    DevicePillButton(title: "MacBook Pro M4 Pro", isSelected: uiState.selectedDevice == "MacBook Pro") {
                        uiState.selectedDevice = "MacBook Pro"
                    }
                    
                    Button(action: {
                        WindowManager.shared.openWindow(tab: .processes)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "macwindow")
                            Text("Open App")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .help("Open Full Mac App Inspector Window")
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("Live")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            // Scrollable Bento 2-Column Grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    // Row 1: Core Performance
                    ProcessorCardView(cpu: collector.cpu)
                    MemoryCardView(memory: collector.memory)
                    
                    // Row 2: Connectivity & Network
                    NetworkCardView(network: collector.network)
                    NetworkDataCardView(network: collector.network)
                    
                    // Row 3: Storage & Thermals
                    DiskCardView(disk: collector.disk)
                    TemperatureCardView(thermals: collector.thermals)
                    
                    // Row 4: Cooling & Graphics
                    FansCardView(fans: collector.fans)
                    GPUCardView(gpu: collector.gpu)
                    
                    // Row 5: Power & Peripherals
                    BatteryCardView(battery: collector.battery)
                    BluetoothCardView(devices: collector.bluetoothDevices)
                    
                    // Row 6: Task Manager & Volumes
                    ProcessesCardView(topCPU: collector.topProcessesCPU, topMem: collector.topProcessesMemory)
                    VolumesCardView(volumes: collector.volumes)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
            
            Divider().opacity(0.5)
            
            // Bottom Action Bar
            HStack {
                Text("\(collector.cpu.chipName) · macOS")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
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
                    
                    Button("Open Full Mac App Window") {
                        WindowManager.shared.openWindow(tab: .processes)
                    }
                    
                    Button("Open Activity Monitor") {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                    }
                    
                    Button("Refresh Stats Now") {
                        collector.sampleAllMetrics()
                    }
                    
                    Divider()
                    
                    Button("Quit MacUsage") {
                        NSApplication.shared.terminate(nil)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 24)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 480, height: 680)
        .background(VisualEffectBlurView().ignoresSafeArea())
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
                .foregroundColor(isSelected ? .primary : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(isSelected ? Color.primary.opacity(0.10) : Color.clear)
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
