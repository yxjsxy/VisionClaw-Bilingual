import Foundation
import UserNotifications

/// Handles proactive notifications from OpenClaw
/// Polls for pending notifications and delivers them via voice or system notification
@MainActor
class NotificationBridge: ObservableObject {
  
  static let shared = NotificationBridge()
  
  // MARK: - Types
  
  struct PendingNotification: Codable {
    let id: String
    let timestamp: Date
    let title: String
    let body: String
    let priority: Priority
    let source: String  // e.g., "cron", "alert", "reminder"
    
    enum Priority: String, Codable {
      case low
      case normal
      case high
      case urgent
    }
  }
  
  // MARK: - State
  
  @Published var pendingNotifications: [PendingNotification] = []
  @Published var lastCheckTime: Date?
  @Published var isPolling: Bool = false
  
  /// Callback when a notification should be spoken
  var onSpeakNotification: ((String) -> Void)?
  
  private var pollingTask: Task<Void, Never>?
  private let pollingInterval: TimeInterval = 30  // Check every 30 seconds
  
  // MARK: - Initialization
  
  private init() {
    requestNotificationPermission()
  }
  
  // MARK: - Permission
  
  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
      if granted {
        NSLog("[NotificationBridge] Notification permission granted")
      } else if let error = error {
        NSLog("[NotificationBridge] Permission error: \(error.localizedDescription)")
      }
    }
  }
  
  // MARK: - Polling
  
  func startPolling() {
    guard pollingTask == nil else { return }
    isPolling = true
    
    pollingTask = Task {
      NSLog("[NotificationBridge] Started polling")
      while !Task.isCancelled {
        await checkForNotifications()
        try? await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
      }
    }
  }
  
  func stopPolling() {
    pollingTask?.cancel()
    pollingTask = nil
    isPolling = false
    NSLog("[NotificationBridge] Stopped polling")
  }
  
  // MARK: - Check Notifications
  
  private func checkForNotifications() async {
    let networkConfig = NetworkConfig.shared
    
    guard networkConfig.isConnected else {
      // Try to reconnect
      await networkConfig.determineOptimalConnection()
      guard networkConfig.isConnected else { return }
    }
    
    // Query OpenClaw for pending VisionClaw notifications
    // This uses a special query that asks for any proactive messages
    guard let url = URL(string: "\(networkConfig.currentHost):\(NetworkConfig.port)/v1/chat/completions") else {
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(NetworkConfig.token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("agent:main:glass:notifications", forHTTPHeaderField: "x-openclaw-session-key")
    request.timeoutInterval = 10
    
    let body: [String: Any] = [
      "model": "openclaw",
      "messages": [
        ["role": "user", "content": "[SYSTEM] Check for any pending notifications or alerts for VisionClaw. If none, reply with just 'NO_NOTIFICATIONS'. If there are any, provide them in a speakable format."]
      ],
      "stream": false
    ]
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
        return
      }
      
      if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
         let choices = json["choices"] as? [[String: Any]],
         let first = choices.first,
         let message = first["message"] as? [String: Any],
         let content = message["content"] as? String {
        
        lastCheckTime = Date()
        
        // Check if there are actual notifications
        if !content.contains("NO_NOTIFICATIONS") && !content.isEmpty {
          NSLog("[NotificationBridge] Received notification: \(content.prefix(100))...")
          
          // Deliver via voice if callback is set
          onSpeakNotification?(content)
          
          // Also show system notification
          await showSystemNotification(title: "牧牧提醒", body: content)
        }
      }
    } catch {
      NSLog("[NotificationBridge] Check failed: \(error.localizedDescription)")
    }
  }
  
  // MARK: - System Notification
  
  private func showSystemNotification(title: String, body: String) async {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil  // Deliver immediately
    )
    
    do {
      try await UNUserNotificationCenter.current().add(request)
    } catch {
      NSLog("[NotificationBridge] Failed to show notification: \(error.localizedDescription)")
    }
  }
  
  // MARK: - Manual Check
  
  func checkNow() async {
    await checkForNotifications()
  }
}
