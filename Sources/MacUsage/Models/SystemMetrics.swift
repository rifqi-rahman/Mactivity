import Foundation
import SwiftUI

public struct CPUInfo: Equatable {
    public var totalUsage: Double = 0.0 // 0 to 100
    public var userUsage: Double = 0.0
    public var systemUsage: Double = 0.0
    public var idleUsage: Double = 100.0
    public var coreCount: Int = 14
    public var chipName: String = "Apple M4 Pro"
    public var history: [Double] = Array(repeating: 0.0, count: 18)
    public var userHistory: [Double] = Array(repeating: 0.0, count: 18)
    public var systemHistory: [Double] = Array(repeating: 0.0, count: 18)
    public var coreLoads: [Double] = Array(repeating: 0.0, count: 14)
    
    public init() {}
}

public struct MemoryInfo: Equatable {
    public var totalBytes: UInt64 = 24 * 1024 * 1024 * 1024 // 24 GB default
    public var usedBytes: UInt64 = 0
    public var appBytes: UInt64 = 0
    public var wiredBytes: UInt64 = 0
    public var compressedBytes: UInt64 = 0
    public var freeBytes: UInt64 = 0
    public var usedPercent: Double = 0.0
    public var pressurePercent: Int = 13 // Normal Apple Silicon baseline
    public var swapUsedBytes: UInt64 = 0
    public var swapTotalBytes: UInt64 = 0
    
    public init() {}
    
    public var usedGBString: String {
        let used = Double(usedBytes) / 1_073_741_824.0
        let total = Double(totalBytes) / 1_073_741_824.0
        return String(format: "%.2f / %.2f GB", used, total)
    }
}

public struct NetworkInfo: Equatable {
    public var downloadBytesPerSec: Double = 0.0
    public var uploadBytesPerSec: Double = 0.0
    public var downloadHistory: [Double] = Array(repeating: 0.0, count: 24)
    public var uploadHistory: [Double] = Array(repeating: 0.0, count: 24)
    public var interfaceName: String = "en0"
    public var connectionType: String = "Wi-Fi"
    public var localIP: String = "127.0.0.1"
    public var publicIP: String = "Detecting..."
    public var dataTodayBytes: UInt64 = 1_540_000_000 // 1.54 GB
    public var data7DaysBytes: UInt64 = 26_840_000_000 // 26.84 GB
    public var data30DaysBytes: UInt64 = 139_600_000_000 // 139.6 GB
    
    public init() {}
    
    public static func formatSpeed(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_048_576 {
            return String(format: "%.1f MB/s", bytesPerSec / 1_048_576.0)
        } else if bytesPerSec >= 1024 {
            return String(format: "%.0f KB/s", bytesPerSec / 1024.0)
        } else {
            return String(format: "%.0f B/s", bytesPerSec)
        }
    }
    
    public static func formatDataVolume(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824.0
        if gb >= 1.0 {
            return String(format: "%.2f GB", gb)
        } else {
            let mb = Double(bytes) / 1_048_576.0
            return String(format: "%.1f MB", mb)
        }
    }
}

public struct DiskInfo: Equatable {
    public var name: String = "Macintosh HD"
    public var totalBytes: UInt64 = 0
    public var usedBytes: UInt64 = 0
    public var availableBytes: UInt64 = 0
    public var usedPercent: Double = 0.0
    public var readSpeedBytesPerSec: Double = 0.0
    public var writeSpeedBytesPerSec: Double = 0.0
    
    public init() {}
    
    public var capacityString: String {
        let used = Double(usedBytes) / 1_073_741_824.0
        let total = Double(totalBytes) / 1_073_741_824.0
        return String(format: "%.2f / %.2f GB", used, total)
    }
}

public struct VolumeInfo: Identifiable, Equatable {
    public var id: String { path }
    public var name: String
    public var path: String
    public var totalBytes: UInt64
    public var availableBytes: UInt64
    public var usedBytes: UInt64 { totalBytes > availableBytes ? totalBytes - availableBytes : 0 }
    public var usedPercent: Double {
        guard totalBytes > 0 else { return 0.0 }
        return Double(usedBytes) / Double(totalBytes) * 100.0
    }
    public var isRemovable: Bool
    public var isRemote: Bool
    public var fileSystem: String
}

public struct BatteryInfo: Equatable {
    public var percentage: Int = 100
    public var isCharging: Bool = false
    public var isACConnected: Bool = true
    public var powerWatts: Double = 0.0
    public var healthPercent: Int = 100
    public var cycleCount: Int = 72
    public var condition: String = "Normal"
    public var temperatureC: Double = 28.5
    public var timeRemainingMinutes: Int? = nil
    
    public init() {}
}

public struct FanInfo: Equatable {
    public var leftRPM: Int = 0
    public var rightRPM: Int = 0
    public var maxRPM: Int = 5500
    public var status: String = "Silent (Passive)"
    public var history: [Int] = Array(repeating: 0, count: 18)
    
    public init() {}
}

public struct ThermalInfo: Equatable {
    public var temperatureC: Double = 48.0
    public var temperatureF: Double { temperatureC * 9.0 / 5.0 + 32.0 }
    public var status: String = "Normal"
    public var isThrottled: Bool = false
    
    public init() {}
}

public struct GPUInfo: Equatable {
    public var utilizationPercent: Double = 0.0
    public var memoryUsedBytes: UInt64 = 0
    public var coreCount: Int = 18 // M4 Pro typically 16 or 20
    public var history: [Double] = Array(repeating: 0.0, count: 18)
    
    public init() {}
    
    public var memoryUsedMBString: String {
        let mb = Double(memoryUsedBytes) / 1_048_576.0
        return String(format: "%.0f MB VRAM", mb)
    }
}

public enum PeripheralType: String, Equatable {
    case headphones
    case keyboard
    case trackpad
    case mouse
    case phone
    case placeholder
}

public struct BluetoothPeripheral: Identifiable, Equatable {
    public var id: String
    public var name: String
    public var type: PeripheralType
    public var batteryLevel: Int? // 0 to 100
    public var isConnected: Bool
    
    public init(id: String, name: String, type: PeripheralType, batteryLevel: Int? = nil, isConnected: Bool = true) {
        self.id = id
        self.name = name
        self.type = type
        self.batteryLevel = batteryLevel
        self.isConnected = isConnected
    }
}

public struct ProcessItem: Identifiable, Equatable {
    public var id: Int { pid }
    public var pid: Int
    public var name: String
    public var cpuPercent: Double
    public var memoryBytes: UInt64
    public var user: String
    public var threadsCount: Int
    public var isSystem: Bool
    
    public init(pid: Int, name: String, cpuPercent: Double, memoryBytes: UInt64, user: String = "user", threadsCount: Int = 4, isSystem: Bool = false) {
        self.pid = pid
        self.name = name
        self.cpuPercent = cpuPercent
        self.memoryBytes = memoryBytes
        self.user = user
        self.threadsCount = threadsCount
        self.isSystem = isSystem
    }
    
    public var memoryString: String {
        let mb = Double(memoryBytes) / 1_048_576.0
        if mb >= 1024.0 {
            return String(format: "%.2f GB", mb / 1024.0)
        }
        return String(format: "%.1f MB", mb)
    }
}
