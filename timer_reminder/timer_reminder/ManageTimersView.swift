import SwiftUI
import AppKit // Needed to control the Dock icon

struct ManageTimersView: View {
    @EnvironmentObject var manager: TimerManager
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack {
            Table($manager.timers) {
                TableColumn("Message / Name") { $timer in
                    TextField("Name", text: $timer.name)
                        .textFieldStyle(.plain)
                        .onSubmit { manager.saveTimers() }
                }
                
                // NEW: Editable Duration Column (in Minutes)
                TableColumn("Duration (mins)") { $timer in
                    let minutesBinding = Binding<String>(
                        get: {
                            // Convert saved seconds into minutes for display
                            String(Int($timer.wrappedValue.durationInSeconds / 60))
                        },
                        set: { newValue in
                            // Convert typed minutes back into seconds
                            if let newMins = TimeInterval(newValue) {
                                let newSeconds = newMins * 60
                                $timer.wrappedValue.durationInSeconds = newSeconds
                                
                                // If the timer is currently running, restart it with the new duration
                                if $timer.wrappedValue.isEnabled {
                                    $timer.wrappedValue.targetDate = Date().addingTimeInterval(newSeconds)
                                }
                                manager.saveTimers()
                            }
                        }
                    )
                    
                    TextField("Mins", text: minutesBinding)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { manager.saveTimers() }
                }
                .width(90)
                
                TableColumn("Remaining") { $timer in
                    let item = $timer.wrappedValue
                    let remaining = max(0, item.targetDate.timeIntervalSinceNow)
                    
                    Text(item.isEnabled ? TimerManager.formatTime(remaining) : "Disabled")
                        .monospacedDigit()
                        .foregroundColor(item.isEnabled ? .primary : .secondary)
                }
                
                TableColumn("Repeating") { $timer in
                    Toggle("", isOn: $timer.isRecurring)
                }
                .width(70)
                
                TableColumn("Active") { $timer in
                    Toggle("", isOn: Binding(
                        get: { $timer.wrappedValue.isEnabled },
                        set: { newValue in
                            $timer.wrappedValue.isEnabled = newValue
                            if newValue {
                                $timer.wrappedValue.targetDate = Date().addingTimeInterval($timer.wrappedValue.durationInSeconds)
                            }
                            manager.saveTimers()
                        }
                    ))
                }
                .width(60)
                
                TableColumn("") { $timer in
                    Button("Delete") {
                        manager.timers.removeAll { $0.id == $timer.wrappedValue.id }
                        manager.saveTimers()
                    }
                }
                .width(60)
            }
            
            HStack {
                Button("Add New Timer") {
                    showingAddSheet = true
                }
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 700, minHeight: 400) // Made slightly wider for the new column
        .sheet(isPresented: $showingAddSheet) {
            AddTimerSheet(manager: manager)
        }
        // NEW: Dynamic Dock Icon Logic
        .onAppear {
            // Show the app in the Dock and App Switcher (Cmd+Tab)
            NSApp.setActivationPolicy(.regular)
            NSApplication.shared.applicationIconImage = createEmojiIcon(emoji: "⏰")
        }
        .onDisappear {
            // Hide the app from the Dock and go back to Menu Bar only
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

// The sub-view for creating a new timer
struct AddTimerSheet: View {
    @ObservedObject var manager: TimerManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var amount: String = "20"
    @State private var unit: TimeUnit = .minutes
    @State private var isRecurring = false
    
    enum TimeUnit: String, CaseIterable, Identifiable {
        case minutes = "Minutes"
        case hours = "Hours"
        var id: Self { self }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Configure Timer").font(.headline)
            
            Form {
                TextField("Message to display", text: $name)
                    .textFieldStyle(.roundedBorder)
                
                LabeledContent("Duration") {
                    HStack {
                        TextField("", text: $amount)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        
                        Picker("", selection: $unit) {
                            ForEach(TimeUnit.allCases) { u in
                                Text(u.rawValue).tag(u)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }
                }
                
                Toggle("Repeat automatically", isOn: $isRecurring)
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save Timer") {
                    guard let val = Double(amount), val > 0, !name.isEmpty else { return }
                    let totalSeconds = unit == .hours ? (val * 3600) : (val * 60)
                    
                    let newTimer = TimerItem(
                        name: name,
                        targetDate: Date().addingTimeInterval(totalSeconds),
                        isRecurring: isRecurring,
                        durationInSeconds: totalSeconds,
                        isEnabled: true
                    )
                    manager.timers.append(newTimer)
                    manager.saveTimers()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || Double(amount) == nil)
            }
        }
        .padding()
        .frame(width: 350)
    }
}
