import SwiftUI

@MainActor
public class UIState: ObservableObject {
    public static let shared = UIState()
    
    @Published public var selectedDevice: String = "MacBook Pro"
    @Published public var processMode: Int = 0 // 0 = CPU, 1 = Memory
    @Published public var refreshInterval: Double = 1.0
    
    public init() {}
}
