import SwiftUI
import AppKit

@main
struct timer_reminderApp: App {
    @StateObject var manager = TimerManager()
    @Environment(\.openWindow) var openWindow
    
    // This runs the moment your app launches
    init() {
        // Set the Mac's Dock icon to our custom emoji image
        NSApplication.shared.applicationIconImage = createEmojiIcon(emoji: "⏰")
    }
    
    var body: some Scene {
        // NEW: Using the 'label' format lets us use an exact emoji instead of an SF Symbol
        MenuBarExtra {
            VStack {
                let activeTimers = manager.timers.filter { $0.isEnabled }
                
                if activeTimers.isEmpty {
                    Text("No active timers")
                } else {
                    ForEach(activeTimers) { timer in
                        let remaining = max(0, timer.targetDate.timeIntervalSinceNow)
                        Text("\(timer.name): \(TimerManager.formatTime(remaining))")
                    }
                }
                
                Divider()
                
                Button("Manage Timers...") {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "manageTimers")
                }
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        } label: {
            Text("⏰") // Your custom Menu Bar Icon
        }
        
        Window("Manage Timers", id: "manageTimers") {
            ManageTimersView()
                .environmentObject(manager)
        }
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
        }
    }
}

// NEW: A slick helper function to turn any emoji string into an NSImage
func createEmojiIcon(emoji: String) -> NSImage {
    let size = NSSize(width: 256, height: 256)
    let image = NSImage(size: size)
    
    // Start drawing
    image.lockFocus()
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 220)
    ]
    let string = NSAttributedString(string: emoji, attributes: attributes)
    let stringSize = string.size()
    
    // Center the emoji perfectly inside the 256x256 square
    string.draw(in: NSRect(
        x: (size.width - stringSize.width) / 2,
        y: (size.height - stringSize.height) / 2,
        width: stringSize.width,
        height: stringSize.height
    ))
    
    // Finish drawing
    image.unlockFocus()
    
    return image
}
