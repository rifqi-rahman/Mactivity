import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns") ?? Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
           let iconImg = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = iconImg
        }
        
        menuBarController = MenuBarController(collector: MetricsCollector.shared)
        print("Mactivity started successfully on \(MetricsCollector.shared.cpu.machineName) (\(MetricsCollector.shared.cpu.chipName))")
        
        let isBackground = CommandLine.arguments.contains("--background") || CommandLine.arguments.contains("--daemon")
        if isBackground {
            NSApp.setActivationPolicy(.accessory)
        } else {
            WindowManager.shared.openWindow(tab: .dashboard)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WindowManager.shared.openWindow(tab: .dashboard)
        return true
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
