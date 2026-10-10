import SwiftUI

// MARK: - Mactivity Signature Color Palette & Design System
// Palette: #0F3040 (Midnight Petrol), #464858 (Muted Slate), #A56F63 (Terracotta Copper), #D99B7F (Warm Sand Peach)
public struct MactivityTheme {
    /// #0F3040 — Deep Midnight Petrol Teal
    public static let petrol = Color(red: 15/255, green: 48/255, blue: 64/255)
    
    /// #464858 — Muted Indigo-Slate Gray
    public static let slate = Color(red: 70/255, green: 72/255, blue: 88/255)
    
    /// #A56F63 — Muted Terracotta Rose / Copper
    public static let copper = Color(red: 165/255, green: 111/255, blue: 99/255)
    
    /// #D99B7F — Warm Sand Peach / Golden Terracotta
    public static let sand = Color(red: 217/255, green: 155/255, blue: 127/255)
    
    // Semantic tokens
    public static let primaryAccent = sand
    public static let secondaryAccent = copper
    public static let trackColor = slate.opacity(0.35)
    public static let cardBg = Color(red: 15/255, green: 46/255, blue: 62/255).opacity(0.90)
    public static let cardHoverBg = Color(red: 22/255, green: 58/255, blue: 76/255).opacity(0.96)
    public static let cardBorder = slate.opacity(0.45)
    public static let cardBorderHover = sand.opacity(0.75)
    
    // Gradients
    public static let warmGradient = LinearGradient(colors: [sand, copper], startPoint: .top, endPoint: .bottom)
    public static let horizontalWarm = LinearGradient(colors: [sand, copper], startPoint: .leading, endPoint: .trailing)
    public static let petrolSlate = LinearGradient(colors: [petrol, slate], startPoint: .top, endPoint: .bottom)
}

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
                    .stroke(MactivityTheme.slate.opacity(0.25), lineWidth: lineWidth)
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
    public var activeColor: Color = MactivityTheme.sand
    public var inactiveColor: Color = MactivityTheme.slate.opacity(0.35)
    
    public init(
        percentage: Double,
        tickCount: Int = 24,
        activeColor: Color = MactivityTheme.sand,
        inactiveColor: Color = MactivityTheme.slate.opacity(0.35)
    ) {
        self.percentage = percentage
        self.tickCount = tickCount
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
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
                        // Download Bar (Ascending Top - Warm Sand Peach #D99B7F)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(MactivityTheme.sand)
                            .frame(width: barWidth, height: max(3.0, (midY - 2.0) * downNorm))
                        
                        // Upload Bar (Descending Bottom - Terracotta Copper #A56F63)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(MactivityTheme.copper)
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
                        // Slot background track
                        RoundedRectangle(cornerRadius: 2)
                            .fill(MactivityTheme.slate.opacity(0.20))
                            .frame(width: barWidth, height: height)
                        
                        // Stacked Bars: User (#D99B7F) + System (#A56F63)
                        VStack(spacing: 0) {
                            // User (Warm Sand Peach #D99B7F)
                            Rectangle()
                                .fill(MactivityTheme.sand)
                                .frame(width: barWidth, height: userHeight)
                            
                            // System (Muted Terracotta Copper #A56F63)
                            Rectangle()
                                .fill(MactivityTheme.copper)
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
            
            HStack(spacing: 6) {
                // Thermometer Outline & Fluid
                ZStack(alignment: .bottom) {
                    // Glass Background
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(MactivityTheme.slate.opacity(0.30))
                            .frame(width: stemWidth, height: stemHeight)
                        Circle()
                            .fill(MactivityTheme.slate.opacity(0.30))
                            .frame(width: bulbSize, height: bulbSize)
                            .offset(y: -4)
                    }
                    
                    // Liquid Fill (#D99B7F -> #A56F63)
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(MactivityTheme.warmGradient)
                            .frame(width: stemWidth - 2, height: fillHeight)
                        Circle()
                            .fill(MactivityTheme.copper)
                            .frame(width: bulbSize - 2, height: bulbSize - 2)
                            .offset(y: -4)
                    }
                }
                .frame(width: bulbSize)
                
                // Calibration Ticks
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(MactivityTheme.sand.opacity(0.40))
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
    public var height: CGFloat
    
    public init(peripheral: BluetoothPeripheral, height: CGFloat = 60) {
        self.peripheral = peripheral
        self.height = height
    }
    
    public var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .bottom) {
                // Background Track (Petrol Tinted Track)
                RoundedRectangle(cornerRadius: 10)
                    .fill(MactivityTheme.petrol.opacity(0.40))
                    .frame(height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MactivityTheme.slate.opacity(0.35), lineWidth: 1)
                    )
                
                if peripheral.isConnected, let battery = peripheral.batteryLevel {
                    // Liquid Fill Level
                    let fillRatio = max(0.20, min(1.0, Double(battery) / 100.0))
                    let fillHeight = CGFloat(Double(height) * fillRatio)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(MactivityTheme.warmGradient)
                        .frame(height: fillHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Peripheral Icon
                    VStack {
                        Spacer()
                        peripheralGlyph(for: peripheral.type)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(MactivityTheme.petrol)
                            .padding(.bottom, 6)
                    }
                } else {
                    // Diagonal hatched placeholder for empty slot
                    HatchedPlaceholderShape()
                        .stroke(MactivityTheme.slate.opacity(0.30), lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: height)
                }
            }
            .frame(height: height)
            
            // Single, Clean Text Label
            if peripheral.isConnected, let battery = peripheral.batteryLevel {
                Text("\(battery)%")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(MactivityTheme.sand)
            } else {
                Text("—")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(MactivityTheme.slate.opacity(0.5))
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
