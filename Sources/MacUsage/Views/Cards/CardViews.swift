import SwiftUI

// Common Bento Card Background Modifier
public struct BentoCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    public func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(white: 0.12).opacity(0.85) : Color.white.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 6, x: 0, y: 3)
    }
}

public extension View {
    func bentoCard() -> some View {
        self.modifier(BentoCardModifier())
    }
}

// 1. Processor Card
public struct ProcessorCardView: View {
    public var cpu: CPUInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Processor Load")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("14-Core")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
            }
            
            Text(String(format: "%.1f%%", cpu.totalUsage))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HistoryBarChart(totalData: cpu.history, userPart: cpu.userHistory, barCount: 16)
                .frame(height: 38)
            
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
        .bentoCard()
    }
}

// 2. Memory Card
public struct MemoryCardView: View {
    public var memory: MemoryInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "memorychip")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Memory")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
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
            
            HStack(spacing: 6) {
                // Pressure Badge
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 9, weight: .bold))
                    Text("\(memory.pressurePercent)%")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(6)
                
                // Swap Badge
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 9, weight: .bold))
                    Text(memory.swapUsedBytes == 0 ? "0 B" : "\(memory.swapUsedBytes / 1_048_576) MB")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(6)
            }
        }
        .bentoCard()
    }
}

// 3. Network Activity Card
public struct NetworkCardView: View {
    public var network: NetworkInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Network Activity")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(network.connectionType)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.25, blue: 0.55))
                    Text(NetworkInfo.formatSpeed(network.downloadBytesPerSec))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.95))
                    Text(NetworkInfo.formatSpeed(network.uploadBytesPerSec))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
            }
            
            MirroredBarChart(downloadData: network.downloadHistory, uploadData: network.uploadHistory, maxBars: 20)
                .frame(height: 38)
            
            HStack {
                Text("LAN: \(network.localIP)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("WAN: \(network.publicIP)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .bentoCard()
    }
}

// 4. Network Data Card
public struct NetworkDataCardView: View {
    public var network: NetworkInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Network Data")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text("Today")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(NetworkInfo.formatDataVolume(network.dataTodayBytes))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Divider().opacity(0.4)
            
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Last 7 days")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(NetworkInfo.formatDataVolume(network.data7DaysBytes))
                        .font(.system(size: 12, weight: .semibold))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Last 30 days")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(NetworkInfo.formatDataVolume(network.data30DaysBytes))
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .bentoCard()
    }
}

// 5. Disk Card
public struct DiskCardView: View {
    public var disk: DiskInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Disk")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(String(format: "%.1f%%", disk.usedPercent))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(disk.capacityString)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                RadialTickGauge(percentage: disk.usedPercent, tickCount: 22)
                    .frame(width: 48, height: 48)
            }
            
            HStack {
                Text(disk.name)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(6)
                Spacer()
            }
        }
        .bentoCard()
    }
}

// 6. Temperature Card
public struct TemperatureCardView: View {
    public var thermals: ThermalInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "thermometer.medium")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Processor Temperature")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.0f°C", thermals.temperatureC))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(String(format: "%.0f°F", thermals.temperatureF))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ThermometerView(temperatureC: thermals.temperatureC)
                    .frame(width: 42, height: 42)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "waveform.path")
                    .font(.system(size: 9))
                Text(thermals.status)
                    .font(.system(size: 10, weight: .medium))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.06))
            .cornerRadius(6)
        }
        .bentoCard()
    }
}

// 7. Fans Card
public struct FansCardView: View {
    public var fans: FanInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fanblades")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Cooling Fans")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(fans.status)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Left Fan")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(fans.leftRPM) RPM")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Right Fan")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(fans.rightRPM) RPM")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            
            // Progress bar toward max RPM
            let progress = CGFloat(Double(fans.leftRPM) / Double(fans.maxRPM))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08)).frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(6, geo.size.width * progress), height: 6)
                }
            }
            .frame(height: 6)
        }
        .bentoCard()
    }
}

// 8. GPU Card
public struct GPUCardView: View {
    public var gpu: GPUInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles.tv")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Graphics (M4 Pro)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("18-Core GPU")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.0f%%", gpu.utilizationPercent))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text(gpu.memoryUsedMBString)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                HistoryBarChart(totalData: gpu.history, barCount: 14)
                    .frame(width: 70, height: 32)
            }
        }
        .bentoCard()
    }
}

// 9. Battery Card
public struct BatteryCardView: View {
    public var battery: BatteryInfo
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: battery.isCharging ? "battery.100.bolt" : "battery.100")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Battery")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(battery.isACConnected ? "AC Power" : "On Battery")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(battery.percentage)%")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text(battery.isCharging ? "Charging" : (battery.percentage == 100 ? "Fully Charged" : "Normal"))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(battery.healthPercent)% Health")
                        .font(.system(size: 11, weight: .semibold))
                    Text("\(battery.cycleCount) Cycles")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .bentoCard()
    }
}

// 10. Bluetooth Devices Card
public struct BluetoothCardView: View {
    public var devices: [BluetoothPeripheral]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "headphones")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Bluetooth Devices")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(devices) { dev in
                    BatteryPillarView(peripheral: dev)
                }
            }
        }
        .bentoCard()
    }
}

// 11. Top Processes Card
public struct ProcessesCardView: View {
    public var topCPU: [ProcessItem]
    public var topMem: [ProcessItem]
    @ObservedObject var uiState = UIState.shared
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Processes")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                
                Picker("", selection: $uiState.processMode) {
                    Text("CPU").tag(0)
                    Text("Memory").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 110)
            }
            
            let list = uiState.processMode == 0 ? topCPU : topMem
            VStack(spacing: 5) {
                ForEach(list) { item in
                    HStack {
                        Image(systemName: "app.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        Text(item.name)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                        Spacer()
                        Text(uiState.processMode == 0 ? String(format: "%.1f%%", item.cpuPercent) : item.memoryString)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 1)
                }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
                }) {
                    Text("Open Activity Monitor")
                        .font(.system(size: 10, weight: .medium))
                }
                .buttonStyle(.borderless)
            }
        }
        .bentoCard()
    }
}

// 12. Remote Volumes Card
public struct VolumesCardView: View {
    public var volumes: [VolumeInfo]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "externaldrive.connected.to.line.below")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .medium))
                Text("Disks & Volumes")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(spacing: 6) {
                ForEach(volumes) { vol in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Image(systemName: vol.isRemote ? "network" : (vol.isRemovable ? "externaldrive.fill" : "internaldrive.fill"))
                                .font(.system(size: 11))
                                .foregroundColor(vol.isRemote ? .purple : .blue)
                            Text(vol.name)
                                .font(.system(size: 11, weight: .semibold))
                            Spacer()
                            Text("\(String(format: "%.1f", Double(vol.availableBytes) / 1_073_741_824.0)) GB free")
                                .font(.system(size: 10))
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
                    .padding(.vertical, 2)
                }
            }
        }
        .bentoCard()
    }
}
