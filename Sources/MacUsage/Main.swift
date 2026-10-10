import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as menu-bar accessory app (no dock icon, sits in menu bar)
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize Menu Bar controller and metrics collection
        menuBarController = MenuBarController(collector: MetricsCollector.shared)
        print("MacUsage started successfully on MacBook Pro M4 Pro")
    }
}

@main
struct MacUsageApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
