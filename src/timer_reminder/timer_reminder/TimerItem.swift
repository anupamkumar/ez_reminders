//
//  TimerItem.swift
//  timer_reminder
//
//  Created by dev on 8/25/26.
//

import Foundation

struct TimerItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var targetDate: Date
    var isRecurring: Bool
    var durationInSeconds: TimeInterval
    var isEnabled: Bool = true // NEW: Allows disabling instead of deleting
}
