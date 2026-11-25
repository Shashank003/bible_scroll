import SwiftUI
import UserNotifications
import UIKit

struct GeneralSettingsView: View {
    @AppStorage("app.theme") private var theme = "system"
    @AppStorage("reader.fontSize") private var fontSize = 30.0

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $theme) {
                    Text("System").tag("system")
                    Text("Light mode").tag("light")
                    Text("Dark mode").tag("dark")
                }
            }
            Section {
                HStack {
                    Text("Font size")
                    Spacer()
                    Text("\(Int(fontSize)) pt").foregroundStyle(.secondary).monospacedDigit()
                }
                Slider(value: $fontSize, in: 22...42, step: 1)
                    .accessibilityLabel("Bible font size")
                    .accessibilityValue("\(Int(fontSize)) points")
                Text("Be still, and know that I am God.")
                    .font(.system(size: fontSize, design: .serif))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
            } header: { Text("Reading") } footer: {
                Text("Applies to Bible verses and daily reading. Other text follows your iPhone’s text-size settings.")
            }
            Section {
                NavigationLink("Notification settings") { NotificationSettingsView() }
            }
        }
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("General").navigationBarTitleDisplayMode(.inline)
        .tint(AppStyle.bronze)
    }
}

private struct WidgetInstructionsView: View {
    var body: some View {
        List {
            Section {
                Label("Bible verse widget", systemImage: "rectangle.on.rectangle")
                    .font(.headline).foregroundStyle(AppStyle.bronze)
                Text("Stillword’s widget is not available in this version. Once widget support is added, you can use these steps to put a verse on your Home Screen or Lock Screen.")
            }
            Section("Home Screen") {
                Text("1. Touch and hold an empty area of your Home Screen.")
                Text("2. Tap Edit, then Add Widget (or the + button on earlier iOS versions).")
                Text("3. Search for Stillword, choose a size, and tap Add Widget.")
                Text("4. Position the widget and tap Done.")
            }
            Section("Lock Screen") {
                Text("1. Touch and hold your Lock Screen, then tap Customize.")
                Text("2. Select Lock Screen and tap the widget area below the clock.")
                Text("3. Choose Stillword and a supported widget, then tap Done.")
            }
            Section {
                Link("Apple’s widget instructions", destination: URL(string: "https://support.apple.com/en-us/118610")!)
            }
        }
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("Bible verse widget").navigationBarTitleDisplayMode(.inline)
    }
}

private struct NotificationSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @AppStorage("notifications.daily.enabled") private var enabled = false
    @AppStorage("notifications.daily.hour") private var hour = 9
    @AppStorage("notifications.daily.minute") private var minute = 0
    @State private var status: UNAuthorizationStatus = .notDetermined
    @State private var updating = false
    @State private var errorMessage: String?
    private let identifier = "stillword.daily-reading"

    private var reminderTime: Binding<Date> {
        Binding(get: {
            Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        }, set: { date in
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            hour = components.hour ?? 9
            minute = components.minute ?? 0
            Task { await updateReminder(requestPermission: false) }
        })
    }

    var body: some View {
        Form {
            Section {
                Toggle("Daily reading reminder", isOn: Binding(get: { enabled }, set: { value in
                    enabled = value
                    Task { await updateReminder(requestPermission: value) }
                }))
                .disabled(updating)
                if enabled {
                    DatePicker("Remind me at", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .disabled(updating)
                }
            } header: { Text("Make time for the Word") } footer: {
                Text("One gentle reminder each day, at your selected local time. Delivery follows your iPhone’s Focus and notification settings.")
            }
            Section("iPhone permissions") {
                Text(status == .denied ? "Notifications are turned off in iPhone Settings." : "Control notification sounds, banners, and Lock Screen alerts in iPhone Settings.")
                    .foregroundStyle(.secondary)
                Button("Open notification settings") {
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
                }
            }
            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }
        }
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("Notifications").navigationBarTitleDisplayMode(.inline)
        .task { await updateReminder(requestPermission: false) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await updateReminder(requestPermission: false) } }
        }
    }

    @MainActor
    private func updateReminder(requestPermission: Bool) async {
        guard !updating else { return }
        updating = true
        defer { updating = false }
        errorMessage = nil
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        do {
            status = await center.notificationSettings().authorizationStatus
            if enabled && requestPermission && status == .notDetermined {
                _ = try await center.requestAuthorization(options: [.alert, .sound])
                status = await center.notificationSettings().authorizationStatus
            }
            guard enabled else { return }
            guard status == .authorized || status == .provisional || status == .ephemeral else {
                enabled = false
                if status == .denied { errorMessage = "Allow notifications in iPhone Settings to enable your reminder." }
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "A moment in the Word"
            content.body = "Take a quiet moment for Scripture. Your daily reading is waiting in Stillword."
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
            try await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
        } catch {
            enabled = false
            errorMessage = "Your reminder couldn’t be saved. Please try again."
        }
    }
}
