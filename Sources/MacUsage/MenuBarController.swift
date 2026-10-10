import AppKit
import SwiftUI
import Combine

@MainActor
public class MenuBarController: NSObject, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var collector: MetricsCollector
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    public init(collector: MetricsCollector) {
        self.collector = collector
        super.init()
        setupStatusItem()
        setupPopover()
        observeCollector()
    }
    
    public convenience override init() {
        self.init(collector: MetricsCollector.shared)
    }
    
    private func setupStatusItem() {
        // Fixed length per mode guarantees that the status item NEVER shifts on periodic timer updates!
        let initialLength = UIState.shared.menuBarMetricMode.statusItemLength
        statusItem = NSStatusBar.system.statusItem(withLength: initialLength)
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateStatusItemTitle()
        }
        
        // Update width ONLY when user explicitly changes metric mode
        UIState.shared.$menuBarMetricMode
            .receive(on: RunLoop.main)
            .sink { [weak self] newMode in
                guard let self = self else { return }
                self.statusItem.length = newMode.statusItemLength
                self.updateStatusItemTitle()
            }
            .store(in: &cancellables)
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 480, height: 680)
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: DashboardView(collector: collector, uiState: UIState.shared))
    }
    
    private func observeCollector() {
        updateTimer?.invalidate()
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateStatusItemTitle()
            }
        }
        t.tolerance = 0.2
        RunLoop.main.add(t, forMode: .common)
        self.updateTimer = t
    }
    
    private func formatSpeed(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_048_576 {
            return String(format: "%.1fM", bytesPerSec / 1_048_576.0)
        } else if bytesPerSec >= 1024 {
            return String(format: "%.0fK", bytesPerSec / 1024.0)
        } else {
            return String(format: "%.0fB", bytesPerSec)
        }
    }
    
    @MainActor
    public func updateStatusItemTitle() {
        guard let button = statusItem.button else { return }
        
        let mode = UIState.shared.menuBarMetricMode
        let imageConfig = NSImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        
        let cpuPct = Int(round(collector.cpu.totalUsage))
        let memPct = Int(round(collector.memory.usedPercent))
        let netDown = collector.network.downloadBytesPerSec
        let netUp = collector.network.uploadBytesPerSec
        let tempC = Int(round(collector.thermals.temperatureC))
        let battPct = collector.battery.percentage
        let hasBatt = collector.battery.hasBattery
        let isCharging = collector.battery.isCharging
        
        let icon: NSImage?
        let title: String
        
        switch mode {
        case .cpuAndNetwork:
            icon = NSImage(systemSymbolName: "gauge.with.needle", accessibilityDescription: "CPU & Net")?.withSymbolConfiguration(imageConfig)
            title = " \(cpuPct)%  ↓\(formatSpeed(netDown))"
            
        case .cpuOnly:
            icon = NSImage(systemSymbolName: "cpu", accessibilityDescription: "CPU")?.withSymbolConfiguration(imageConfig)
            title = " \(cpuPct)%"
            
        case .cpuAndMemory:
            icon = NSImage(systemSymbolName: "memorychip", accessibilityDescription: "CPU & RAM")?.withSymbolConfiguration(imageConfig)
            title = " \(cpuPct)% · \(memPct)%"
            
        case .memoryOnly:
            icon = NSImage(systemSymbolName: "memorychip", accessibilityDescription: "Memory")?.withSymbolConfiguration(imageConfig)
            title = " \(memPct)% RAM"
            
        case .battery:
            if hasBatt {
                let bolt = isCharging ? "⚡" : ""
                let battSymbol = isCharging ? "battery.100.bolt" : (battPct > 20 ? "battery.75" : "battery.25")
                icon = NSImage(systemSymbolName: battSymbol, accessibilityDescription: "Battery")?.withSymbolConfiguration(imageConfig)
                title = " \(battPct)%\(bolt)"
            } else {
                icon = NSImage(systemSymbolName: "powerplug", accessibilityDescription: "AC Power")?.withSymbolConfiguration(imageConfig)
                title = " AC"
            }
            
        case .networkOnly:
            icon = NSImage(systemSymbolName: "network", accessibilityDescription: "Network")?.withSymbolConfiguration(imageConfig)
            title = " ↓\(formatSpeed(netDown)) ↑\(formatSpeed(netUp))"
            
        case .temperature:
            icon = NSImage(systemSymbolName: "thermometer.medium", accessibilityDescription: "Thermals")?.withSymbolConfiguration(imageConfig)
            title = " \(tempC)°C"
            
        case .compactAll:
            icon = NSImage(systemSymbolName: "gauge.with.needle", accessibilityDescription: "All")?.withSymbolConfiguration(imageConfig)
            title = " C:\(cpuPct)% M:\(memPct)% ↓\(formatSpeed(netDown))"
            
        case .iconOnly:
            icon = NSImage(systemSymbolName: "gauge.with.needle.fill", accessibilityDescription: "Mactivity")?.withSymbolConfiguration(imageConfig)
            title = ""
        }
        
        button.image = icon
        button.imagePosition = title.isEmpty ? .imageOnly : .imageLeft
        button.title = title
        button.font = NSFont.monospacedDigitSystemFont(ofSize: 11.5, weight: .medium)
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showContextMenu()
            return
        }
        
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            collector.setPopoverVisibility(true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            configurePopoverWindow()
        }
    }
    
    // MARK: - NSPopoverDelegate
    public func popoverWillShow(_ notification: Notification) {
        collector.setPopoverVisibility(true)
        configurePopoverWindow()
    }
    
    public func popoverDidShow(_ notification: Notification) {
        configurePopoverWindow()
    }
    
    public func popoverDidClose(_ notification: Notification) {
        collector.setPopoverVisibility(false)
    }
    
    /// Ensures popover floats on top of other applications, including native macOS Fullscreen Spaces
    private func configurePopoverWindow() {
        let applyConfig = { [weak self] in
            guard let self = self, let window = self.popover.contentViewController?.view.window else { return }
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.level = .statusBar
            window.orderFrontRegardless()
        }
        
        applyConfig()
        DispatchQueue.main.async {
            applyConfig()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Mactivity · \(collector.cpu.chipName)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Menu Bar Display Submenu
        let displaySubmenu = NSMenu()
        for mode in MenuBarMetricMode.allCases {
            let item = NSMenuItem(title: mode.rawValue, action: #selector(setMetricModeAction(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode
            if UIState.shared.menuBarMetricMode == mode {
                item.state = .on
            }
            displaySubmenu.addItem(item)
        }
        
        let displayMenuItem = NSMenuItem(title: "Menu Bar Display", action: nil, keyEquivalent: "")
        displayMenuItem.submenu = displaySubmenu
        menu.addItem(displayMenuItem)
        
        // Customize Popover Layout
        let customizeItem = NSMenuItem(title: "Customize Bento Layout (Drag & Edit)...", action: #selector(customizeBentoAction), keyEquivalent: "e")
        customizeItem.target = self
        menu.addItem(customizeItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Dashboard Popover", action: #selector(openDashboardAction), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "Open Full Inspector Window...", action: #selector(openInspectorWindowAction), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Launch Activity Monitor", action: #selector(openActivityMonitorAction), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Force Refresh", action: #selector(refreshAction), keyEquivalent: "r"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Mactivity", action: #selector(quitAction), keyEquivalent: "q"))
        
        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
        }
    }
    
    @objc private func setMetricModeAction(_ sender: NSMenuItem) {
        if let mode = sender.representedObject as? MenuBarMetricMode {
            UIState.shared.setMenuBarMetricMode(mode)
            updateStatusItemTitle()
        }
    }
    
    @objc private func customizeBentoAction() {
        UIState.shared.isEditBentoLayoutMode = true
        if let button = statusItem.button, !popover.isShown {
            collector.setPopoverVisibility(true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            configurePopoverWindow()
        }
    }
    
    @objc private func openInspectorWindowAction() {
        WindowManager.shared.openWindow(tab: .dashboard)
    }
    
    @objc private func openDashboardAction() {
        if let button = statusItem.button, !popover.isShown {
            collector.setPopoverVisibility(true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            configurePopoverWindow()
        }
    }
    
    @objc private func openActivityMonitorAction() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
    }
    
    @objc private func refreshAction() {
        Task { @MainActor in
            collector.sampleAllMetrics()
            updateStatusItemTitle()
        }
    }
    
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
