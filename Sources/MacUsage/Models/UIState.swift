import SwiftUI

public enum InspectorTab: String, CaseIterable, Identifiable {
    case processes = "Processes"
    case processor = "Processor"
    case memory = "Memory"
    case network = "Network"
    case disk = "Disk & Volumes"
    case battery = "Battery & Thermals"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .processes: return "list.bullet.rectangle"
        case .processor: return "cpu"
        case .memory: return "memorychip"
        case .network: return "globe"
        case .disk: return "internaldrive"
        case .battery: return "battery.100.bolt"
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
    @Published public var selectedInspectorTab: InspectorTab = .processes
    @Published public var processSearchText: String = ""
    @Published public var processSortField: ProcessSortField = .cpu
    @Published public var processSortAscending: Bool = false
    @Published public var selectedProcessPID: Int? = nil
    @Published public var hoveredCard: String? = nil
    
    public func setHoveredCard(_ name: String, isHovered: Bool) {
        if isHovered {
            self.hoveredCard = name
        } else if self.hoveredCard == name {
            self.hoveredCard = nil
        }
    }
}
