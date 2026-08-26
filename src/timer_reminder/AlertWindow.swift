//
//  AlertWindow.swift
//  timer_reminder
//
//  Created by dev on 8/25/26.
//


import SwiftUI
import AppKit
import Combine



// 1. The SwiftUI View (The design of the pop-up)
struct AlertView: View {
    let timerName: String
    let closeAction: () -> Void
    
    // Grab values directly from Settings!
    @AppStorage("primaryColorHex") private var primaryColorHex = "#FF0000"
    @AppStorage("secondaryColorHex") private var secondaryColorHex = "#FFFF00"
    @AppStorage("flashFrequency") private var flashFrequency = 500
    @AppStorage("buttonDelay") private var buttonDelay = 10
    
    @State private var countdown = 0
    @State private var isFlashing = false
    
    let tickTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(timerName)
                .font(.largeTitle)
                .bold()
            
            Button(countdown > 0 ? "Wait... \(countdown) seconds" : "Okay") {
                closeAction()
            }
            .disabled(countdown > 0)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(width: 400, height: 250)
        .background(isFlashing ? Color(hex: primaryColorHex) : Color(hex: secondaryColorHex))
        .onAppear {
            // Set the countdown dynamically based on Settings
            countdown = buttonDelay
            
            // Set the flash speed dynamically
            let duration = Double(flashFrequency) / 1000.0
            withAnimation(Animation.easeInOut(duration: duration).repeatForever()) {
                isFlashing.toggle()
            }
        }
        .onReceive(tickTimer) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
    }
}

// 2. The AppKit Manager (Forces the window above everything else)
class AlertWindowManager {
    static let shared = AlertWindowManager()
    
    func showPopup(for timer: TimerItem) {
        DispatchQueue.main.async {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
                styleMask: [.titled, .fullSizeContentView],
                backing: .buffered, 
                defer: false
            )
            
            // .screenSaver forces it above almost all other windows, even full-screen apps
            window.level = .screenSaver 
            window.center()
            window.title = "REMINDER!"
            window.isReleasedWhenClosed = false
            
            let hostingView = NSHostingView(
                rootView: AlertView(timerName: timer.name, closeAction: {
                    window.close()
                })
            )
            window.contentView = hostingView
            window.makeKeyAndOrderFront(nil)
            
            // Steal focus so the user doesn't miss it
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
