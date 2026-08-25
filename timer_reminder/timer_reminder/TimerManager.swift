//
//  TimerManager.swift
//  timer_reminder
//
//  Created by dev on 8/25/26.
//

import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var timers: [TimerItem] = []
    private var tickTimer: AnyCancellable?
    
    init() {
        loadTimers()
        tickTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.checkTimers() }
    }
    
    func checkTimers() {
        let now = Date()
        for index in timers.indices {
            // Skip timers that are turned off
            guard timers[index].isEnabled else { continue }
            
            if now >= timers[index].targetDate {
                triggerAlert(for: timers[index])
                
                if timers[index].isRecurring {
                    timers[index].targetDate = now.addingTimeInterval(timers[index].durationInSeconds)
                } else {
                    timers[index].isEnabled = false // Disable one-off timers
                }
                saveTimers()
            }
        }
        objectWillChange.send()
    }
    
    func saveTimers() {
        if let data = try? JSONEncoder().encode(timers) {
            UserDefaults.standard.set(data, forKey: "savedTimers")
        }
    }
    
    func loadTimers() {
        if let data = UserDefaults.standard.data(forKey: "savedTimers"),
           let decoded = try? JSONDecoder().decode([TimerItem].self, from: data) {
            self.timers = decoded
        }
    }
    
    func triggerAlert(for timer: TimerItem) {
        AlertWindowManager.shared.showPopup(for: timer)
    }
    
    // NEW: Helper to make times human-readable
    static func formatTime(_ seconds: TimeInterval) -> String {
        if seconds <= 0 { return "0s" }
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        
        var parts: [String] = []
        if h > 0 { parts.append("\(h)h") }
        if m > 0 { parts.append("\(m)m") }
        parts.append("\(s)s")
        
        return parts.joined(separator: " ")
    }
}
