import SwiftUI

/// Displays OpenClaw connection status (LAN/Tailscale/Disconnected)
struct ConnectionStatusView: View {
  @ObservedObject var networkConfig = NetworkConfig.shared
  
  var body: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(statusColor)
        .frame(width: 8, height: 8)
      
      Text(statusText)
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(.white)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color.black.opacity(0.6))
    .cornerRadius(12)
  }
  
  private var statusColor: Color {
    switch networkConfig.currentMode {
    case .lan:
      return .green
    case .tailscale:
      return .blue
    case .disconnected:
      return .red
    }
  }
  
  private var statusText: String {
    switch networkConfig.currentMode {
    case .lan:
      return "LAN ✓"
    case .tailscale:
      return "Tailscale ✓"
    case .disconnected:
      return "Offline"
    }
  }
}

/// Memory status indicator
struct MemoryStatusView: View {
  @ObservedObject var memory = ConversationMemory.shared
  
  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: "brain.head.profile")
        .font(.system(size: 10))
        .foregroundColor(.white)
      
      Text("\(memory.messages.count) msgs")
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(.white)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color.black.opacity(0.6))
    .cornerRadius(12)
  }
}

#Preview {
  VStack(spacing: 10) {
    ConnectionStatusView()
    MemoryStatusView()
  }
  .padding()
  .background(Color.gray)
}
