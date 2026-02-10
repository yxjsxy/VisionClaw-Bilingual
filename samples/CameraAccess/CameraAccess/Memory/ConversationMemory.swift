import Foundation

/// Manages conversation memory with persistence and summarization
@MainActor
class ConversationMemory: ObservableObject {
  
  static let shared = ConversationMemory()
  
  // MARK: - Types
  
  struct Message: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let role: Role
    let content: String
    let isToolCall: Bool
    let toolName: String?
    let toolResult: String?
    
    enum Role: String, Codable {
      case user
      case assistant
      case system
    }
    
    init(role: Role, content: String, isToolCall: Bool = false, toolName: String? = nil, toolResult: String? = nil) {
      self.id = UUID()
      self.timestamp = Date()
      self.role = role
      self.content = content
      self.isToolCall = isToolCall
      self.toolName = toolName
      self.toolResult = toolResult
    }
  }
  
  struct ConversationSummary: Codable {
    let date: Date
    let keyTopics: [String]
    let importantFacts: [String]
    let pendingTasks: [String]
    let userPreferences: [String: String]
  }
  
  // MARK: - State
  
  @Published private(set) var messages: [Message] = []
  @Published private(set) var currentSummary: ConversationSummary?
  
  private let maxMessagesInMemory = 50
  private let summarizeThreshold = 20
  
  // MARK: - Persistence
  
  private var messagesURL: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("conversation_messages.json")
  }
  
  private var summaryURL: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("conversation_summary.json")
  }
  
  // MARK: - Initialization
  
  private init() {
    loadFromDisk()
  }
  
  // MARK: - Public API
  
  /// Adds a user message
  func addUserMessage(_ content: String) {
    let message = Message(role: .user, content: content)
    messages.append(message)
    trimIfNeeded()
    saveToDisk()
    NSLog("[Memory] Added user message: \(content.prefix(50))...")
  }
  
  /// Adds an assistant message
  func addAssistantMessage(_ content: String) {
    let message = Message(role: .assistant, content: content)
    messages.append(message)
    trimIfNeeded()
    saveToDisk()
    NSLog("[Memory] Added assistant message: \(content.prefix(50))...")
  }
  
  /// Adds a tool call record
  func addToolCall(name: String, task: String, result: String) {
    let message = Message(
      role: .assistant,
      content: task,
      isToolCall: true,
      toolName: name,
      toolResult: result
    )
    messages.append(message)
    trimIfNeeded()
    saveToDisk()
    NSLog("[Memory] Added tool call: \(name)")
  }
  
  /// Gets context for Gemini system prompt (recent conversation summary)
  func getContextForPrompt() -> String {
    var context = ""
    
    // Add summary if available
    if let summary = currentSummary {
      context += "【对话记忆摘要】\n"
      if !summary.keyTopics.isEmpty {
        context += "最近话题: \(summary.keyTopics.joined(separator: ", "))\n"
      }
      if !summary.importantFacts.isEmpty {
        context += "重要信息: \(summary.importantFacts.joined(separator: "; "))\n"
      }
      if !summary.pendingTasks.isEmpty {
        context += "待办事项: \(summary.pendingTasks.joined(separator: "; "))\n"
      }
      context += "\n"
    }
    
    // Add recent messages (last 5)
    let recentMessages = messages.suffix(5)
    if !recentMessages.isEmpty {
      context += "【最近对话】\n"
      for msg in recentMessages {
        let roleLabel = msg.role == .user ? "用户" : "助手"
        if msg.isToolCall {
          context += "[\(roleLabel)调用\(msg.toolName ?? "工具"): \(msg.content.prefix(30))...]\n"
        } else {
          context += "\(roleLabel): \(msg.content.prefix(50))...\n"
        }
      }
    }
    
    return context
  }
  
  /// Clears all memory
  func clear() {
    messages.removeAll()
    currentSummary = nil
    saveToDisk()
    NSLog("[Memory] Cleared all memory")
  }
  
  /// Requests a summary update via OpenClaw
  func requestSummaryUpdate() async {
    guard messages.count >= summarizeThreshold else { return }
    
    // Build conversation text for summarization
    let conversationText = messages.suffix(summarizeThreshold).map { msg in
      let role = msg.role == .user ? "User" : "Assistant"
      return "\(role): \(msg.content)"
    }.joined(separator: "\n")
    
    // TODO: Call OpenClaw to generate summary
    // For now, extract simple keywords
    await extractSimpleSummary()
  }
  
  // MARK: - Private Methods
  
  private func trimIfNeeded() {
    if messages.count > maxMessagesInMemory {
      // Keep first message (might be important context) and recent ones
      let excess = messages.count - maxMessagesInMemory
      messages.removeSubrange(1..<(1 + excess))
    }
  }
  
  private func extractSimpleSummary() async {
    // Simple keyword extraction (will be replaced with LLM summarization)
    var topics: [String] = []
    var facts: [String] = []
    
    for msg in messages.suffix(20) where msg.role == .user {
      // Extract potential topics from user messages
      let words = msg.content.components(separatedBy: .whitespaces)
      for word in words where word.count > 3 {
        if word.contains("天气") || word.contains("weather") {
          topics.append("天气")
        }
        if word.contains("Telegram") || word.contains("消息") {
          topics.append("消息")
        }
        if word.contains("搜索") || word.contains("search") {
          topics.append("搜索")
        }
      }
    }
    
    currentSummary = ConversationSummary(
      date: Date(),
      keyTopics: Array(Set(topics)),
      importantFacts: facts,
      pendingTasks: [],
      userPreferences: [:]
    )
    saveToDisk()
  }
  
  private func saveToDisk() {
    // Save messages
    if let data = try? JSONEncoder().encode(messages) {
      try? data.write(to: messagesURL)
    }
    // Save summary
    if let summary = currentSummary, let data = try? JSONEncoder().encode(summary) {
      try? data.write(to: summaryURL)
    }
  }
  
  private func loadFromDisk() {
    // Load messages
    if let data = try? Data(contentsOf: messagesURL),
       let loaded = try? JSONDecoder().decode([Message].self, from: data) {
      messages = loaded
      NSLog("[Memory] Loaded \(loaded.count) messages from disk")
    }
    // Load summary
    if let data = try? Data(contentsOf: summaryURL),
       let loaded = try? JSONDecoder().decode(ConversationSummary.self, from: data) {
      currentSummary = loaded
      NSLog("[Memory] Loaded summary from disk")
    }
  }
}
