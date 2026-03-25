import UserNotifications
import AppKit
import os

private let logger = Logger(subsystem: "com.uxcentra.PomodoroTimer", category: "Notification")

final class NotificationManager: NSObject, @unchecked Sendable, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        logger.info("Requesting notification permission, bundleID=\(Bundle.main.bundleIdentifier ?? "nil")")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            logger.info("requestAuthorization result: granted=\(granted), error=\(String(describing: error))")
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            logger.info("Notification settings: auth=\(settings.authorizationStatus.rawValue), alert=\(settings.alertSetting.rawValue), sound=\(settings.soundSetting.rawValue)")
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

        content.sound = .default

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
        logger.info("willPresent called - showing banner+sound")
        completionHandler([.banner, .sound])
    }
}
