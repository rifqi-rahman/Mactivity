import SwiftUI
import UniformTypeIdentifiers

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
            topNavigationBar
            
            // Edit Mode Notification & Control Banner
            if uiState.isEditBentoLayoutMode {
                editModeBanner
            }
            
            // Bento Grid (Interactive Reordering & Drag-and-Drop)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    let visibleCards = uiState.bentoCardsOrder.filter { !uiState.hiddenBentoCards.contains($0.rawValue) }
                    let rows = buildRows(from: visibleCards)
                    
                    ForEach(rows) { row in
                        if row.isFullWidth {
                            // Full-Width Card (e.g., Top Processes)
                            cardWrapper(for: row.cards[0], isFullWidth: true)
                        } else {
                            // Two-Column Grid Row
                            HStack(spacing: 12) {
                                ForEach(row.cards) { card in
                                    cardWrapper(for: card, isFullWidth: false)
                                }
                                if row.cards.count == 1 {
                                    Spacer()
                                        .frame(width: 218)
                                }
                            }
                        }
                    }
                    
                    // Hidden Cards Recovery Section in Edit Mode
                    if uiState.isEditBentoLayoutMode && !uiState.hiddenBentoCards.isEmpty {
                        hiddenCardsTray
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, uiState.isEditBentoLayoutMode ? 6 : 0)
                .padding(.bottom, 16)
            }
            
            Divider().opacity(0.25)
            
            // Bottom Action Bar
            bottomActionBar
        }
        .frame(width: 480, height: 680)
        .background(
            ZStack {
                VisualEffectBlurView().ignoresSafeArea()
                MactivityTheme.petrol.opacity(0.40).ignoresSafeArea()
            }
        )
    }
    
    // MARK: - Row Chunking Helper
    private func buildRows(from cards: [BentoCardID]) -> [BentoRow] {
        var rows: [BentoRow] = []
        var currentRow: [BentoCardID] = []
        
        for card in cards {
            if card.isFullWidth {
                if !currentRow.isEmpty {
                    rows.append(BentoRow(id: currentRow.map(\.rawValue).joined(separator: "_"), cards: currentRow))
                    currentRow = []
                }
                rows.append(BentoRow(id: card.rawValue, cards: [card]))
            } else {
                currentRow.append(card)
                if currentRow.count == 2 {
                    rows.append(BentoRow(id: currentRow.map(\.rawValue).joined(separator: "_"), cards: currentRow))
                    currentRow = []
                }
            }
        }
        if !currentRow.isEmpty {
            rows.append(BentoRow(id: currentRow.map(\.rawValue).joined(separator: "_"), cards: currentRow))
        }
        return rows
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            HStack(spacing: 8) {
                DevicePillButton(title: "\(collector.cpu.machineName) · \(collector.cpu.chipName)", isSelected: true) {
                    WindowManager.shared.openWindow(tab: .processor)
                }
                
                Button(action: {
                    WindowManager.shared.openWindow(tab: .dashboard)
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
            
            HStack(spacing: 8) {
                // Layout Edit Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        uiState.isEditBentoLayoutMode.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: uiState.isEditBentoLayoutMode ? "checkmark" : "slider.horizontal.3")
                        Text(uiState.isEditBentoLayoutMode ? "Done" : "Customize")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(uiState.isEditBentoLayoutMode ? Color.white : MactivityTheme.sand)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(uiState.isEditBentoLayoutMode ? MactivityTheme.copper : MactivityTheme.petrol.opacity(0.70))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MactivityTheme.sand.opacity(0.40), lineWidth: 0.8)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .help(uiState.isEditBentoLayoutMode ? "Finish customizing layout" : "Customize and reorder popup cards")
                
                // Live indicator
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
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 12)
    }
    
    // MARK: - Edit Mode Control Banner
    private var editModeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(MactivityTheme.sand)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit Popup Bento Layout")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text("Drag cards or use arrows to reorder · Click eye to hide/show")
                    .font(.system(size: 10))
                    .foregroundColor(Color(white: 0.85))
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    uiState.resetBentoLayout()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(MactivityTheme.sand)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.35))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .help("Reset to default bento card layout")
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    uiState.isEditBentoLayoutMode = false
                }
            }) {
                Text("Done")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(MactivityTheme.copper)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(MactivityTheme.petrol.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(MactivityTheme.copper.opacity(0.80), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Card Wrapper with Edit Overlay & Drag-Drop Support
    @ViewBuilder
    private func cardWrapper(for card: BentoCardID, isFullWidth: Bool) -> some View {
        let cardContent = ZStack(alignment: .topTrailing) {
            // Actual Interactive Metric Card
            cardView(for: card)
                .opacity(uiState.draggedBentoCard == card ? 0.40 : 1.0)
            
            // Reordering Toolbar Overlay in Edit Mode
            if uiState.isEditBentoLayoutMode {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        // Drag Handle Pill
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 11, weight: .bold))
                            Text(card.title)
                                .font(.system(size: 10, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(MactivityTheme.sand)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3.5)
                        .background(Color.black.opacity(0.80))
                        .cornerRadius(6)
                        
                        Spacer()
                        
                        // Move Up/Left Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                uiState.moveBentoCardUp(card)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Color.black.opacity(0.70))
                                .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                        .help("Move card earlier")
                        
                        // Move Down/Right Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                uiState.moveBentoCardDown(card)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Color.black.opacity(0.70))
                                .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                        .help("Move card later")
                        
                        // Hide Card Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                uiState.toggleBentoCardVisibility(card)
                            }
                        }) {
                            Image(systemName: "eye.slash")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(white: 0.85))
                                .frame(width: 22, height: 22)
                                .background(Color.red.opacity(0.60))
                                .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                        .help("Hide card from popup")
                    }
                    .padding(6)
                    
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(MactivityTheme.sand.opacity(0.80), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                )
            }
        }
        .frame(width: isFullWidth ? 448 : 218)
        
        if uiState.isEditBentoLayoutMode {
            cardContent
                .onDrag {
                    uiState.draggedBentoCard = card
                    return NSItemProvider(object: card.rawValue as NSString)
                }
                .onDrop(of: [.plainText, .text], delegate: BentoCardDropDelegate(targetCard: card, uiState: uiState))
        } else {
            cardContent
        }
    }
    
    // MARK: - Dynamic Card View Switcher
    @ViewBuilder
    private func cardView(for cardID: BentoCardID) -> some View {
        switch cardID {
        case .processor:
            ProcessorCardView(cpu: collector.cpu)
        case .memory:
            MemoryCardView(memory: collector.memory)
        case .disk:
            DiskCardView(disk: collector.disk)
        case .bluetooth:
            BluetoothCardView(devices: collector.bluetoothDevices)
        case .thermals:
            TemperatureCardView(thermals: collector.thermals)
        case .fans:
            FansCardView(fans: collector.fans)
        case .network:
            NetworkCardView(network: collector.network)
        case .networkData:
            NetworkDataCardView(network: collector.network)
        case .gpu:
            GPUCardView(gpu: collector.gpu)
        case .battery:
            BatteryCardView(battery: collector.battery)
        case .volumes:
            VolumesCardView(volumes: collector.volumes)
        case .arch:
            SystemArchCardView(cpu: collector.cpu)
        case .processes:
            ProcessesCardView(topCPU: collector.topProcessesCPU, topMem: collector.topProcessesMemory)
        }
    }
    
    // MARK: - Hidden Cards Recovery Tray
    private var hiddenCardsTray: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hidden Cards (\(uiState.hiddenBentoCards.count)) — Click + to restore:")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(MactivityTheme.sand)
            
            FlowLayout(spacing: 8) {
                ForEach(BentoCardID.allCases.filter { uiState.hiddenBentoCards.contains($0.rawValue) }) { card in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            uiState.toggleBentoCardVisibility(card)
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: card.iconName)
                                .font(.system(size: 10))
                            Text(card.title)
                                .font(.system(size: 11, weight: .medium))
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(MactivityTheme.sand)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(MactivityTheme.petrol)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(MactivityTheme.slate.opacity(0.50), lineWidth: 0.8)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.35))
        .cornerRadius(10)
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
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
            
            // Menu Bar Metric Mode Quick Selector
            Menu {
                Section("Select Menu Bar Status Metric") {
                    ForEach(MenuBarMetricMode.allCases) { mode in
                        Button(action: {
                            uiState.setMenuBarMetricMode(mode)
                        }) {
                            HStack {
                                Text(mode.rawValue)
                                if uiState.menuBarMetricMode == mode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: uiState.menuBarMetricMode.iconName)
                        .font(.system(size: 10))
                    Text(uiState.menuBarMetricMode.shortLabel)
                        .font(.system(size: 10.5, weight: .semibold))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundColor(MactivityTheme.sand)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MactivityTheme.petrol)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(MactivityTheme.slate.opacity(0.40), lineWidth: 0.8)
                )
                .cornerRadius(6)
            }
            .menuStyle(.borderlessButton)
            .help("Choose which metric appears in the macOS menu bar")
            
            // Quick settings ellipsis menu
            Menu {
                Section("Layout & Customization") {
                    Button(uiState.isEditBentoLayoutMode ? "Finish Customizing" : "Customize Bento Layout (Drag & Drop)...") {
                        uiState.isEditBentoLayoutMode.toggle()
                    }
                    Button("Reset Layout to Default") {
                        uiState.resetBentoLayout()
                    }
                }
                
                Divider()
                
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
                    WindowManager.shared.openWindow(tab: .dashboard)
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
}

// MARK: - Drop Delegate for Bento Drag & Drop Reordering
struct BentoCardDropDelegate: DropDelegate {
    let targetCard: BentoCardID
    let uiState: UIState
    
    func dropEntered(info: DropInfo) {
        guard let source = uiState.draggedBentoCard, source != targetCard else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            uiState.moveBentoCard(from: source, to: targetCard)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        uiState.draggedBentoCard = nil
        uiState.saveBentoLayout()
        return true
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

// MARK: - Row Model for Dynamic Bento Grid
struct BentoRow: Identifiable {
    let id: String
    let cards: [BentoCardID]
    
    var isFullWidth: Bool {
        cards.count == 1 && cards[0].isFullWidth
    }
}

// Simple Flow Layout for Hidden Cards Badges
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 448
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
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
