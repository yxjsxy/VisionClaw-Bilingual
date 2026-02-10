import Foundation
import Network

/// Manages OpenClaw connectivity with automatic LAN/Tailscale switching
@MainActor
class NetworkConfig: ObservableObject {
  
  static let shared = NetworkConfig()
  
  // MARK: - Configuration
  
  /// LAN configuration (same WiFi network)
  static let lanHost = "http://10.0.0.192"
  
  /// Tailscale configuration (works anywhere)
  static let tailscaleHost = "http://karls-mac-mini.tail765ae2.ts.net"
  
  /// OpenClaw port
  static let port = 18789
  
  /// Gateway token
  static let token = "5c0e3d45324d766a14f6a98cabe2d79b04cde61e4fcf64f3"
  
  // MARK: - State
  
  enum ConnectionMode: String {
    case lan = "LAN"
    case tailscale = "Tailscale"
    case disconnected = "Disconnected"
  }
  
  @Published private(set) var currentMode: ConnectionMode = .disconnected
  @Published private(set) var currentHost: String = lanHost
  @Published private(set) var isConnected: Bool = false
  @Published private(set) var lastError: String?
  
  private let monitor = NWPathMonitor()
  private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
  
  // MARK: - Initialization
  
  private init() {
    startMonitoring()
  }
  
  // MARK: - Network Monitoring
  
  private func startMonitoring() {
    monitor.pathUpdateHandler = { [weak self] path in
      Task { @MainActor in
        if path.status == .satisfied {
          await self?.determineOptimalConnection()
        } else {
          self?.currentMode = .disconnected
          self?.isConnected = false
        }
      }
    }
    monitor.start(queue: monitorQueue)
  }
  
  // MARK: - Connection Logic
  
  /// Determines the best connection method (LAN preferred, Tailscale fallback)
  func determineOptimalConnection() async {
    // Try LAN first (faster, lower latency)
    if await testConnection(host: Self.lanHost) {
      currentHost = Self.lanHost
      currentMode = .lan
      isConnected = true
      lastError = nil
      NSLog("[NetworkConfig] Connected via LAN")
      return
    }
    
    // Fall back to Tailscale
    if await testConnection(host: Self.tailscaleHost) {
      currentHost = Self.tailscaleHost
      currentMode = .tailscale
      isConnected = true
      lastError = nil
      NSLog("[NetworkConfig] Connected via Tailscale")
      return
    }
    
    // No connection available
    currentMode = .disconnected
    isConnected = false
    lastError = "Cannot reach OpenClaw via LAN or Tailscale"
    NSLog("[NetworkConfig] No connection available")
  }
  
  /// Tests if a host is reachable
  private func testConnection(host: String) async -> Bool {
    guard let url = URL(string: "\(host):\(Self.port)/health") else {
      return false
    }
    
    var request = URLRequest(url: url)
    request.timeoutInterval = 3.0
    request.httpMethod = "HEAD"
    
    do {
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        return (200...299).contains(httpResponse.statusCode)
      }
      return false
    } catch {
      NSLog("[NetworkConfig] Test failed for \(host): \(error.localizedDescription)")
      return false
    }
  }
  
  /// Returns the full API URL for chat completions
  var chatCompletionsURL: URL? {
    URL(string: "\(currentHost):\(Self.port)/v1/chat/completions")
  }
  
  /// Forces a reconnection attempt
  func reconnect() async {
    await determineOptimalConnection()
  }
}
