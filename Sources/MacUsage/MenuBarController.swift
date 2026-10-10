import AppKit
import SwiftUI

@MainActor
public class MenuBarController: NSObject, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var collector: MetricsCollector
    private var updateTimer: Timer?
    
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
        // Fixed length (92.0 pt) ensures the menu bar button NEVER resizes or shifts the popover anchor!
        statusItem = NSStatusBar.system.statusItem(withLength: 92.0)
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateStatusItemTitle()
        }
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
        // Coalesced timer to refresh status bar text smoothly
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
    
    @MainActor
    public func updateStatusItemTitle() {
        guard let button = statusItem.button else { return }
        
        let cpuPct = Int(round(collector.cpu.totalUsage))
        let netDown = collector.network.downloadBytesPerSec
        let netString: String
        if netDown >= 1_048_576 {
            netString = String(format: "%.1fM", netDown / 1_048_576.0)
        } else if netDown >= 1024 {
            netString = String(format: "%.0fK", netDown / 1024.0)
        } else {
            netString = String(format: "%.0fB", netDown)
        }
        
        // Crisp symbol and monospaced typography
        let imageConfig = NSImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let icon = NSImage(systemSymbolName: "gauge.with.needle", accessibilityDescription: "Mactivity")?.withSymbolConfiguration(imageConfig)
        
        button.image = icon
        button.imagePosition = .imageLeft
        button.title = " \(cpuPct)%  ↓\(netString)"
        button.font = NSFont.monospacedDigitSystemFont(ofSize: 11.5, weight: .medium)
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showContextMenu()
            return
        }
        
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            collector.setPopoverVisibility(true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    // MARK: - NSPopoverDelegate (Visibility awareness for extreme battery/CPU savings)
    public func popoverWillShow(_ notification: Notification) {
        collector.setPopoverVisibility(true)
    }
    
    public func popoverDidClose(_ notification: Notification) {
        collector.setPopoverVisibility(false)
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Mactivity · \(collector.cpu.chipName)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Open Dashboard Popover", action: #selector(openDashboardAction), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "Open Full Inspector Window...", action: #selector(openInspectorWindowAction), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Launch Activity Monitor", action: #selector(openActivityMonitorAction), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Force Refresh", action: #selector(refreshAction), keyEquivalent: "r"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Mactivity", action: #selector(quitAction), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Restore toggle behavior after click
    }
    
    @objc private func openInspectorWindowAction() {
        WindowManager.shared.openWindow(tab: .dashboard)
    }
    
    @objc private func openDashboardAction() {
        if let button = statusItem.button, !popover.isShown {
            collector.setPopoverVisibility(true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
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
