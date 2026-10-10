import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        menuBarController = MenuBarController(collector: MetricsCollector.shared)
        print("Mactivity started successfully on \(MetricsCollector.shared.cpu.machineName) (\(MetricsCollector.shared.cpu.chipName))")
    }
}

@main
struct MactivityApp {
    private static var appDelegate: AppDelegate?
    
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        appDelegate = delegate
        app.delegate = delegate
        app.run()
    }
}
