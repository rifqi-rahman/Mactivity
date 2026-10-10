import SwiftUI

public enum MenuBarMetricMode: String, CaseIterable, Identifiable {
    case cpuAndNetwork = "CPU & Network"
    case cpuOnly = "CPU Only"
    case cpuAndMemory = "CPU & Memory"
    case memoryOnly = "Memory (RAM)"
    case battery = "Battery & Power"
    case networkOnly = "Network Traffic"
    case temperature = "Thermals (Temp)"
    case compactAll = "Compact (CPU·RAM·Net)"
    case iconOnly = "Icon Only"
    
    public var id: String { rawValue }
    
    public var shortLabel: String {
        switch self {
        case .cpuAndNetwork: return "CPU & Net"
        case .cpuOnly: return "CPU"
        case .cpuAndMemory: return "CPU & RAM"
        case .memoryOnly: return "RAM"
        case .battery: return "Battery"
        case .networkOnly: return "Network"
        case .temperature: return "Temp"
        case .compactAll: return "All"
        case .iconOnly: return "Icon"
        }
    }
    
    public var iconName: String {
        switch self {
        case .cpuAndNetwork: return "gauge.with.needle"
        case .cpuOnly: return "cpu"
        case .cpuAndMemory: return "memorychip"
        case .memoryOnly: return "memorychip"
        case .battery: return "battery.100.bolt"
        case .networkOnly: return "network"
        case .temperature: return "thermometer.medium"
        case .compactAll: return "chart.bar.xaxis"
        case .iconOnly: return "gauge.with.needle.fill"
        }
    }
}

public enum BentoCardID: String, CaseIterable, Identifiable, Codable {
    case processor = "cpu"
    case memory = "memory"
    case disk = "disk"
    case bluetooth = "bluetooth"
    case thermals = "thermals"
    case fans = "fans"
    case network = "network"
    case networkData = "networkData"
    case gpu = "gpu"
    case battery = "battery"
    case volumes = "volumes"
    case arch = "arch"
    case processes = "processes"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .processor: return "Processor (CPU)"
        case .memory: return "Memory (RAM)"
        case .disk: return "Disk & Storage"
        case .bluetooth: return "Bluetooth Devices"
        case .thermals: return "Temperature"
        case .fans: return "Fans & Acoustics"
        case .network: return "Network Traffic"
        case .networkData: return "Data Ledger"
        case .gpu: return "Graphics (GPU)"
        case .battery: return "Battery & Power"
        case .volumes: return "Volumes"
        case .arch: return "SoC Architecture"
        case .processes: return "Top Processes"
        }
    }
    
    public var iconName: String {
        switch self {
        case .processor: return "cpu"
        case .memory: return "memorychip"
        case .disk: return "internaldrive"
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        case .thermals: return "thermometer.medium"
        case .fans: return "fanblades"
        case .network: return "network"
        case .networkData: return "arrow.up.arrow.down"
        case .gpu: return "display"
        case .battery: return "battery.100.bolt"
        case .volumes: return "opticaldiscdrive"
        case .arch: return "sparkles"
        case .processes: return "list.bullet.rectangle"
        }
    }
    
    public var isFullWidth: Bool {
        return self == .processes
    }
    
    public static let defaultOrder: [BentoCardID] = [
        .processor, .memory,
        .disk, .bluetooth,
        .thermals, .fans,
        .network, .networkData,
        .gpu, .battery,
        .volumes, .arch,
        .processes
    ]
}

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
    
    // Menu Bar & Bento Customization
    @Published public var menuBarMetricMode: MenuBarMetricMode = .cpuAndNetwork
    @Published public var bentoCardsOrder: [BentoCardID] = BentoCardID.defaultOrder
    @Published public var hiddenBentoCards: Set<String> = []
    @Published public var isEditBentoLayoutMode: Bool = false
    @Published public var draggedBentoCard: BentoCardID? = nil
    
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
    
    public init() {
        loadPreferences()
    }
    
    public func setMenuBarMetricMode(_ mode: MenuBarMetricMode) {
        self.menuBarMetricMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "Mactivity.menuBarMetricMode")
    }
    
    public func setHoveredCard(_ name: String, isHovered: Bool) {
        if isHovered {
            self.hoveredCard = name
        } else if self.hoveredCard == name {
            self.hoveredCard = nil
        }
    }
    
    public func moveBentoCard(from source: BentoCardID, to destination: BentoCardID) {
        guard let sourceIndex = bentoCardsOrder.firstIndex(of: source),
              let destIndex = bentoCardsOrder.firstIndex(of: destination),
              sourceIndex != destIndex else { return }
        
        bentoCardsOrder.remove(at: sourceIndex)
        bentoCardsOrder.insert(source, at: destIndex)
        saveBentoLayout()
    }
    
    public func moveBentoCardUp(_ card: BentoCardID) {
        guard let idx = bentoCardsOrder.firstIndex(of: card), idx > 0 else { return }
        bentoCardsOrder.swapAt(idx, idx - 1)
        saveBentoLayout()
    }
    
    public func moveBentoCardDown(_ card: BentoCardID) {
        guard let idx = bentoCardsOrder.firstIndex(of: card), idx < bentoCardsOrder.count - 1 else { return }
        bentoCardsOrder.swapAt(idx, idx + 1)
        saveBentoLayout()
    }
    
    public func toggleBentoCardVisibility(_ card: BentoCardID) {
        if hiddenBentoCards.contains(card.rawValue) {
            hiddenBentoCards.remove(card.rawValue)
        } else {
            hiddenBentoCards.insert(card.rawValue)
        }
        saveBentoLayout()
    }
    
    public func resetBentoLayout() {
        bentoCardsOrder = BentoCardID.defaultOrder
        hiddenBentoCards = []
        saveBentoLayout()
    }
    
    public func saveBentoLayout() {
        UserDefaults.standard.set(bentoCardsOrder.map { $0.rawValue }, forKey: "Mactivity.bentoCardsOrder")
        UserDefaults.standard.set(Array(hiddenBentoCards), forKey: "Mactivity.hiddenBentoCards")
    }
    
    public func loadPreferences() {
        if let modeRaw = UserDefaults.standard.string(forKey: "Mactivity.menuBarMetricMode"),
           let mode = MenuBarMetricMode(rawValue: modeRaw) {
            self.menuBarMetricMode = mode
        }
        
        if let savedCards = UserDefaults.standard.stringArray(forKey: "Mactivity.bentoCardsOrder") {
            let mapped = savedCards.compactMap { BentoCardID(rawValue: $0) }
            var complete = mapped
            for card in BentoCardID.defaultOrder {
                if !complete.contains(card) {
                    complete.append(card)
                }
            }
            if !complete.isEmpty {
                self.bentoCardsOrder = complete
            }
        }
        
        if let savedHidden = UserDefaults.standard.stringArray(forKey: "Mactivity.hiddenBentoCards") {
            self.hiddenBentoCards = Set(savedHidden)
        }
    }
}
