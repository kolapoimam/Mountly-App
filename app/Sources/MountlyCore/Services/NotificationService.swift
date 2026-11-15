import Foundation
import UserNotifications

/// Thin wrapper over `UserNotifications`.
/// Never posts anything unless the corresponding Settings toggle is on;
/// callers pass that decision in — this type has no opinion about policy.
public final class NotificationService: @unchecked Sendable {
    public static let shared = NotificationService()

    private init() {}

    public func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    public func notify(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
