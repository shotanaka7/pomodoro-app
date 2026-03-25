import UserNotifications
import AppKit

final class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
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
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
