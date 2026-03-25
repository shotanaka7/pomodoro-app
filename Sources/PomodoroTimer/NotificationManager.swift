import UserNotifications
import AppKit

final class NotificationManager: NSObject, @unchecked Sendable, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            if !granted {
                print("Notification permission not granted")
            }
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

        UNUserNotificationCenter.current().add(request)
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
