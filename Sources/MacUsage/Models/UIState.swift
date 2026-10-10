import SwiftUI

public enum InspectorTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case processes = "Processes"
    case processor = "Processor (CPU)"
    case graphics = "Graphics (GPU)"
    case memory = "Memory"
    case network = "Network & Data"
    case disk = "Disk & Storage"
    case battery = "Battery & Power"
    case thermals = "Thermals & Fans"
    case bluetooth = "Bluetooth Devices"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .processes: return "list.bullet.rectangle"
        case .processor: return "cpu"
        case .graphics: return "display"
        case .memory: return "memorychip"
        case .network: return "globe"
        case .disk: return "internaldrive"
        case .battery: return "battery.100.bolt"
        case .thermals: return "thermometer.medium"
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        }
    }
}

public enum ProcessSortField: String, CaseIterable, Identifiable {
    case cpu = "CPU %"
    case memory = "Memory"
    case name = "Name"
    case pid = "PID"
    
    public var id: String { rawValue }
}

@MainActor
public class UIState: ObservableObject {
    public static let shared = UIState()
    
    @Published public var selectedDevice: String = "MacBook Pro"
    @Published public var processMode: Int = 0 // 0 = CPU, 1 = Memory
    @Published public var refreshInterval: Double = 1.0
    
    // Full Mac App Inspector State
    @Published public var selectedInspectorTab: InspectorTab = .dashboard
    @Published public var hoveredSidebarTab: InspectorTab? = nil
    @Published public var processSearchText: String = ""
    @Published public var processSortField: ProcessSortField = .cpu
    @Published public var processSortAscending: Bool = false
    @Published public var selectedProcessPID: Int? = nil
    @Published public var processFilterMode: Int = 0 // 0 = All, 1 = User Apps, 2 = System
    @Published public var selectedBluetoothDeviceID: String? = nil
    @Published public var hoveredCard: String? = nil
    
    public func setHoveredCard(_ name: String, isHovered: Bool) {
        if isHovered {
            self.hoveredCard = name
        } else if self.hoveredCard == name {
            self.hoveredCard = nil
        }
    }
}
