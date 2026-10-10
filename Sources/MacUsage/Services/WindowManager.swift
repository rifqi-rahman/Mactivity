import AppKit
import SwiftUI

@MainActor
public class WindowManager: NSObject, NSWindowDelegate {
    public static let shared = WindowManager()
    
    private var detailWindow: NSWindow?
    
    public override init() {
        super.init()
    }
    
    public func openWindow(tab: InspectorTab = .dashboard) {
        UIState.shared.selectedInspectorTab = tab
        
        if let win = detailWindow {
            NSApp.setActivationPolicy(.regular)
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            MetricsCollector.shared.setInspectorVisibility(true)
            return
        }
        
        let inspectorView = InspectorWindowView(collector: MetricsCollector.shared, uiState: UIState.shared)
        let hostingController = NSHostingController(rootView: inspectorView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.title = "Mactivity — System Activity Monitor"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.contentViewController = hostingController
        window.delegate = self
        window.minSize = NSSize(width: 860, height: 560)
        
        self.detailWindow = window
        
        // Show in Dock while window is active
        NSApp.setActivationPolicy(.regular)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        MetricsCollector.shared.setInspectorVisibility(true)
    }
    
    // MARK: - NSWindowDelegate
    public func windowWillClose(_ notification: Notification) {
        MetricsCollector.shared.setInspectorVisibility(false)
        
        // Revert to background menu-bar accessory mode seamlessly
        NSApp.setActivationPolicy(.accessory)
    }
}
