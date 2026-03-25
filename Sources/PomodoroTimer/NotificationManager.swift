import UserNotifications
import AppKit
import os

private let logger = Logger(subsystem: "com.uxcentra.PomodoroTimer", category: "Notification")

struct NotificationSound: Identifiable, Hashable {
    let id: String
    let displayName: String

    static let available: [NotificationSound] = [
        NotificationSound(id: "default", displayName: "デフォルト"),
        NotificationSound(id: "Basso", displayName: "Basso"),
        NotificationSound(id: "Blow", displayName: "Blow"),
        NotificationSound(id: "Bottle", displayName: "Bottle"),
        NotificationSound(id: "Frog", displayName: "Frog"),
        NotificationSound(id: "Funk", displayName: "Funk"),
        NotificationSound(id: "Glass", displayName: "Glass"),
        NotificationSound(id: "Hero", displayName: "Hero"),
        NotificationSound(id: "Morse", displayName: "Morse"),
        NotificationSound(id: "Ping", displayName: "Ping"),
        NotificationSound(id: "Pop", displayName: "Pop"),
        NotificationSound(id: "Purr", displayName: "Purr"),
        NotificationSound(id: "Sosumi", displayName: "Sosumi"),
        NotificationSound(id: "Submarine", displayName: "Submarine"),
        NotificationSound(id: "Tink", displayName: "Tink"),
    ]
}

final class NotificationManager: NSObject, @unchecked Sendable, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    var selectedSoundId: String {
        get { UserDefaults.standard.string(forKey: "notificationSound") ?? "default" }
        set { UserDefaults.standard.set(newValue, forKey: "notificationSound") }
    }

    private override init() {
        super.init()
    }

    func requestPermission() {
        logger.info("Requesting notification permission, bundleID=\(Bundle.main.bundleIdentifier ?? "nil")")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            logger.info("requestAuthorization result: granted=\(granted), error=\(String(describing: error))")
        }
    }

    func previewSound(_ soundId: String) {
        if soundId == "default" {
            NSSound.beep()
        } else if let sound = NSSound(named: NSSound.Name(soundId)) {
            sound.play()
        }
    }

    func sendNotification(for completedPhase: TimerPhase) {
        let content = UNMutableNotificationContent()

        switch completedPhase {
        case .work:
            content.title = "🍅 作業完了！"
            content.body = "お疲れさまです！休憩しましょう。"
        case .shortBreak:
            content.title = "☕ 休憩終了"
            content.body = "次の作業を始めましょう！"
        case .longBreak:
            content.title = "🎉 長休憩終了"
            content.body = "リフレッシュできましたか？次のセットを始めましょう！"
        case .lunchBreak:
            content.title = "🍱 お昼休憩終了"
            content.body = "午後も頑張りましょう！"
        }

        if selectedSoundId == "default" {
            content.sound = .default
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "/System/Library/Sounds/\(selectedSoundId).aiff"))
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        logger.info("Sending notification for phase: \(completedPhase.rawValue)")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                logger.error("Notification add error: \(error.localizedDescription)")
            } else {
                logger.info("Notification scheduled successfully")
            }
        }
    }

    // フォアグラウンドでも通知を表示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
