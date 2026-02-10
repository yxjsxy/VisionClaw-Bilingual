import Foundation

@MainActor
class OpenClawBridge: ObservableObject {
  @Published var lastToolCallStatus: ToolCallStatus = .idle
  @Published var connectionMode: NetworkConfig.ConnectionMode = .disconnected

  private let session: URLSession
  private var sessionKey: String
  private let networkConfig = NetworkConfig.shared
  private let memory = ConversationMemory.shared

  init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 120
    self.session = URLSession(configuration: config)
    self.sessionKey = OpenClawBridge.newSessionKey()
    
    // Initial connection check
    Task {
      await networkConfig.determineOptimalConnection()
      self.connectionMode = networkConfig.currentMode
    }
  }

  func resetSession() {
    sessionKey = OpenClawBridge.newSessionKey()
    NSLog("[OpenClaw] New session: %@", sessionKey)
  }

  private static func newSessionKey() -> String {
    let ts = ISO8601DateFormatter().string(from: Date())
    return "agent:main:glass:\(ts)"
  }
  
  /// Ensures we have a valid connection, trying LAN first then Tailscale
  func ensureConnection() async -> Bool {
    if networkConfig.isConnected {
      return true
    }
    await networkConfig.determineOptimalConnection()
    connectionMode = networkConfig.currentMode
    return networkConfig.isConnected
  }

  // MARK: - Agent Chat (session continuity via x-openclaw-session-key header)

  func delegateTask(
    task: String,
    toolName: String = "execute"
  ) async -> ToolResult {
    lastToolCallStatus = .executing(toolName)
    
    // Ensure we have a connection
    guard await ensureConnection() else {
      lastToolCallStatus = .failed(toolName, "No connection")
      return .failure("Cannot connect to OpenClaw. Check network.")
    }

    guard let url = networkConfig.chatCompletionsURL else {
      lastToolCallStatus = .failed(toolName, "Invalid URL")
      return .failure("Invalid gateway URL")
    }
    
    NSLog("[OpenClaw] Using \(networkConfig.currentMode.rawValue): \(url.absoluteString)")

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(NetworkConfig.token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(sessionKey, forHTTPHeaderField: "x-openclaw-session-key")

    let body: [String: Any] = [
      "model": "openclaw",
      "messages": [
        ["role": "user", "content": task]
      ],
      "stream": false
    ]

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      let (data, response) = try await session.data(for: request)
      let httpResponse = response as? HTTPURLResponse

      guard let statusCode = httpResponse?.statusCode, (200...299).contains(statusCode) else {
        let code = httpResponse?.statusCode ?? 0
        let bodyStr = String(data: data, encoding: .utf8) ?? "no body"
        NSLog("[OpenClaw] Chat failed: HTTP %d - %@", code, String(bodyStr.prefix(200)))
        
        // If current connection failed, try switching
        if code == 0 || code >= 500 {
          await networkConfig.reconnect()
          connectionMode = networkConfig.currentMode
        }
        
        lastToolCallStatus = .failed(toolName, "HTTP \(code)")
        return .failure("Agent returned HTTP \(code)")
      }

      if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
         let choices = json["choices"] as? [[String: Any]],
         let first = choices.first,
         let message = first["message"] as? [String: Any],
         let content = message["content"] as? String {
        NSLog("[OpenClaw] Agent result: %@", String(content.prefix(200)))
        
        // Record in memory
        memory.addToolCall(name: toolName, task: task, result: content)
        
        lastToolCallStatus = .completed(toolName)
        return .success(content)
      }

      let raw = String(data: data, encoding: .utf8) ?? "OK"
      NSLog("[OpenClaw] Agent raw: %@", String(raw.prefix(200)))
      lastToolCallStatus = .completed(toolName)
      return .success(raw)
    } catch {
      NSLog("[OpenClaw] Agent error: %@", error.localizedDescription)
      
      // Try reconnecting on network errors
      await networkConfig.reconnect()
      connectionMode = networkConfig.currentMode
      
      lastToolCallStatus = .failed(toolName, error.localizedDescription)
      return .failure("Agent error: \(error.localizedDescription)")
    }
  }
}
