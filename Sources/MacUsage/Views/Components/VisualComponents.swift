import SwiftUI

public struct DonutChartView: View {
    public var segments: [(percentage: Double, color: Color)]
    public var lineWidth: CGFloat = 16
    
    public init(segments: [(percentage: Double, color: Color)], lineWidth: CGFloat = 16) {
        self.segments = segments
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2 - lineWidth / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: lineWidth)
                    .frame(width: radius * 2, height: radius * 2)
                
                // Segments
                ForEach(0..<segments.count, id: \.self) { idx in
                    let startTrim = trimStart(for: idx)
                    let endTrim = startTrim + (segments[idx].percentage / 100.0)
                    
                    Circle()
                        .trim(from: startTrim, to: min(1.0, endTrim))
                        .stroke(
                            segments[idx].color,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: radius * 2, height: radius * 2)
                }
            }
            .position(center)
        }
    }
    
    private func trimStart(for index: Int) -> Double {
        var sum = 0.0
        for i in 0..<index {
            sum += segments[i].percentage / 100.0
        }
        return sum
    }
}

public struct RadialTickGauge: View {
    public var percentage: Double // 0 to 100
    public var tickCount: Int = 24
    public var activeColor: Color = Color(red: 0.38, green: 0.45, blue: 1.0) // Vibrant Indigo/Blue
    public var inactiveColor: Color = Color.primary.opacity(0.10)
    
    public init(percentage: Double, tickCount: Int = 24, activeColor: Color = Color(red: 0.38, green: 0.45, blue: 1.0)) {
        self.percentage = percentage
        self.tickCount = tickCount
        self.activeColor = activeColor
    }
    
    public var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2
            let activeTicks = Int(round((percentage / 100.0) * Double(tickCount)))
            
            ZStack {
                ForEach(0..<tickCount, id: \.self) { idx in
                    let angle = Double(idx) / Double(tickCount) * 360.0 - 90.0
                    let isActive = idx < activeTicks
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isActive ? activeColor : inactiveColor)
                        .frame(width: 4, height: 10)
                        .offset(y: -radius + 6)
                        .rotationEffect(.degrees(angle))
                }
            }
            .position(center)
        }
    }
}

public struct MirroredBarChart: View {
    public var downloadData: [Double] // Top bars
    public var uploadData: [Double]   // Bottom bars
    public var maxBars: Int = 24
    
    public init(downloadData: [Double], uploadData: [Double], maxBars: Int = 24) {
        self.downloadData = downloadData
        self.uploadData = uploadData
        self.maxBars = maxBars
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let midY = height / 2
            let barWidth: CGFloat = max(2.5, (width / CGFloat(maxBars)) - 2.5)
            
            let maxDown = max(1024.0, downloadData.max() ?? 1024.0)
            let maxUp = max(1024.0, uploadData.max() ?? 1024.0)
            
            HStack(alignment: .center, spacing: 2.5) {
                ForEach(0..<maxBars, id: \.self) { i in
                    let downVal = i < downloadData.count ? downloadData[i] : 0.0
                    let upVal = i < uploadData.count ? uploadData[i] : 0.0
                    
                    let downNorm = CGFloat(min(1.0, downVal / maxDown))
                    let upNorm = CGFloat(min(1.0, upVal / maxUp))
                    
                    VStack(spacing: 1.5) {
                        // Download Bar (Ascending Top - Pink/Fuchsia)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(red: 0.95, green: 0.25, blue: 0.55))
                            .frame(width: barWidth, height: max(3.0, (midY - 2.0) * downNorm))
                        
                        // Upload Bar (Descending Bottom - Violet/Purple)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(red: 0.55, green: 0.40, blue: 0.95))
                            .frame(width: barWidth, height: max(3.0, (midY - 2.0) * upNorm))
                    }
                }
            }
            .frame(width: width, height: height, alignment: .center)
        }
    }
}

public struct HistoryBarChart: View {
    public var totalData: [Double]
    public var userPart: [Double]?
    public var barCount: Int = 18
    
    public init(totalData: [Double], userPart: [Double]? = nil, barCount: Int = 18) {
        self.totalData = totalData
        self.userPart = userPart
        self.barCount = barCount
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let barWidth: CGFloat = max(3.5, (width / CGFloat(barCount)) - 3.0)
            
            HStack(alignment: .bottom, spacing: 3.0) {
                ForEach(0..<barCount, id: \.self) { idx in
                    let totalVal = idx < totalData.count ? totalData[idx] : 0.0
                    let userVal = (userPart != nil && idx < userPart!.count) ? userPart![idx] : totalVal * 0.7
                    
                    let totalHeight = max(4.0, height * CGFloat(min(100.0, totalVal) / 100.0))
                    let userHeight = totalHeight * CGFloat(min(1.0, max(0.1, userVal / max(1.0, totalVal))))
                    let sysHeight = max(0.0, totalHeight - userHeight)
                    
                    ZStack(alignment: .bottom) {
                        // Full slot background track
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primary.opacity(0.06))
                            .frame(width: barWidth, height: height)
                        
                        // Filled Stack
                        VStack(spacing: 0) {
                            // User (Bright Cyan/Blue)
                            Rectangle()
                                .fill(Color(red: 0.0, green: 0.75, blue: 1.0))
                                .frame(width: barWidth, height: userHeight)
                            
                            // System (Purple/Indigo)
                            Rectangle()
                                .fill(Color(red: 0.45, green: 0.42, blue: 0.98))
                                .frame(width: barWidth, height: sysHeight)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                }
            }
            .frame(width: width, height: height, alignment: .bottom)
        }
    }
}

public struct ThermometerView: View {
    public var temperatureC: Double // e.g. 48.0
    
    public init(temperatureC: Double) {
        self.temperatureC = temperatureC
    }
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let bulbSize: CGFloat = min(22, width * 0.65)
            let stemWidth: CGFloat = bulbSize * 0.45
            
            // Normalize temp from 30°C to 100°C
            let norm = CGFloat(min(1.0, max(0.05, (temperatureC - 30.0) / 70.0)))
            let stemHeight = height - bulbSize + 4
            let fillHeight = stemHeight * norm
            
            let fluidColor: Color = {
                if temperatureC < 55.0 {
                    return Color(red: 0.0, green: 0.65, blue: 1.0) // Calm Cyan/Blue
                } else if temperatureC < 75.0 {
                    return Color(red: 0.95, green: 0.65, blue: 0.15) // Warm Amber
                } else {
                    return Color(red: 0.95, green: 0.25, blue: 0.25) // High Coral Red
                }
            }()
            
            HStack(spacing: 6) {
                // Thermometer Outline & Fluid
                ZStack(alignment: .bottom) {
                    // Glass Background
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: stemWidth, height: stemHeight)
                        Circle()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: bulbSize, height: bulbSize)
                            .offset(y: -4)
                    }
                    
                    // Liquid Fill
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(fluidColor)
                            .frame(width: stemWidth - 2, height: fillHeight)
                        Circle()
                            .fill(fluidColor)
                            .frame(width: bulbSize - 2, height: bulbSize - 2)
                            .offset(y: -4)
                    }
                }
                .frame(width: bulbSize)
                
                // Calibration Ticks
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.primary.opacity(0.20))
                            .frame(width: 8, height: 1.5)
                    }
                }
            }
            .frame(width: width, height: height, alignment: .center)
        }
    }
}

public struct BatteryPillarView: View {
    public var peripheral: BluetoothPeripheral
    
    public init(peripheral: BluetoothPeripheral) {
        self.peripheral = peripheral
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                // Container Box
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.05))
                    .frame(height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                
                if peripheral.isConnected, let battery = peripheral.batteryLevel {
                    // Liquid Fill Level
                    let fillHeight = CGFloat(72 * (Double(battery) / 100.0))
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.42, green: 0.45, blue: 0.95))
                        .frame(height: fillHeight)
                        .animation(.easeInOut, value: battery)
                    
                    // Peripheral Icon
                    VStack {
                        Spacer()
                        peripheralGlyph(for: peripheral.type)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                    }
                } else {
                    // Diagonal hatched placeholder for empty slot
                    HatchedPlaceholderShape()
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(height: 72)
                }
            }
            .frame(height: 72)
            
            // Text Label
            if peripheral.isConnected, let battery = peripheral.batteryLevel {
                Text("\(battery)%")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                Text("—")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func peripheralGlyph(for type: PeripheralType) -> some View {
        switch type {
        case .headphones:
            Image(systemName: "headphones")
        case .keyboard:
            Image(systemName: "keyboard.fill")
        case .trackpad:
            Image(systemName: "hand.point.up.left.fill")
        case .mouse:
            Image(systemName: "magicmouse.fill")
        case .phone:
            Image(systemName: "iphone")
        case .placeholder:
            EmptyView()
        }
    }
}

// Hatched diagonal stripe pattern for empty slots
struct HatchedPlaceholderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 10.0
        let total = rect.width + rect.height
        for x in stride(from: -total, through: total, by: step) {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.maxY))
        }
        return path
    }
}
