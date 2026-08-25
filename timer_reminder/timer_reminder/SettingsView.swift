import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("primaryColorHex") private var primaryColorHex = "#FF0000"
    @AppStorage("secondaryColorHex") private var secondaryColorHex = "#FFFF00"
    @AppStorage("flashFrequency") private var flashFrequency = 500
    @AppStorage("buttonDelay") private var buttonDelay = 10
    
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    
    var primaryColor: Binding<Color> {
        Binding(get: { Color(hex: primaryColorHex) }, set: { primaryColorHex = $0.hex })
    }
    var secondaryColor: Binding<Color> {
        Binding(get: { Color(hex: secondaryColorHex) }, set: { secondaryColorHex = $0.hex })
    }
    
    var body: some View {
        Form {
            Section("Alert Colors") {
                ColorPicker("Primary Flash Color:", selection: primaryColor)
                ColorPicker("Secondary Flash Color:", selection: secondaryColor)
                
                // LabeledContent forces the text into the left column, controls into the right
                LabeledContent("Flash Frequency:") {
                    HStack {
                        Slider(value: Binding(
                            get: { Double(flashFrequency) },
                            set: { flashFrequency = Int($0) }
                        ), in: 100...2000, step: 100)
                        
                        Text("\(flashFrequency) ms")
                            .monospacedDigit()
                            .frame(width: 60, alignment: .trailing)
                    }
                }
            }
            
            Section("Behavior") {
                // Separating the label from the stepper prevents the left-side truncation
                LabeledContent("Okay Button Delay:") {
                    Stepper("\(buttonDelay) seconds", value: $buttonDelay, in: 0...60)
                }
                
                // Separating the label from the toggle prevents the right-side truncation
                LabeledContent("Startup:") {
                    Toggle("Start EZ-Reminders automatically at login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                print("Failed to update auto-start: \(error)")
                            }
                        }
                }
            }
        }
        // This gives it the modern, clean macOS settings look with rounded sections
        .formStyle(.grouped)
        // Using minWidth/maxWidth makes the window responsive instead of locking it
        .frame(minWidth: 500, maxWidth: 800, minHeight: 300, maxHeight: 600)
    }
}

// Helper extension remains unchanged
extension Color {
    init(hex: String) {
        let hexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexCode).scanHexInt64(&rgb)
        self.init(red: Double((rgb >> 16) & 0xFF) / 255.0, green: Double((rgb >> 8) & 0xFF) / 255.0, blue: Double(rgb & 0xFF) / 255.0)
    }

    var hex: String {
        guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else { return "#FFFFFF" }
        return String(format: "#%02X%02X%02X", Int(nsColor.redComponent * 255), Int(nsColor.greenComponent * 255), Int(nsColor.blueComponent * 255))
    }
}
