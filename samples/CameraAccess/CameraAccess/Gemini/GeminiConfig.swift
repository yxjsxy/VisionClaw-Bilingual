import Foundation

enum GeminiConfig {
  static let websocketBaseURL = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent"
  static let model = "models/gemini-2.5-flash-native-audio-preview-12-2025"

  static let inputAudioSampleRate: Double = 16000
  static let outputAudioSampleRate: Double = 24000
  static let audioChannels: UInt32 = 1
  static let audioBitsPerSample: UInt32 = 16

  static let videoFrameInterval: TimeInterval = 1.0
  static let videoJPEGQuality: CGFloat = 0.5

  // Base system instruction (memory context added dynamically)
  // Optimized for natural voice conversation
  static let baseSystemInstruction = """
    你是「牧牧」，Karl的私人AI助手，通过智能眼镜看到他看到的画面。
    
    【说话风格】
    - 简短自然，像朋友聊天
    - 用口语，不用书面语
    - 中文回中文，英文回英文
    - 不要用"好的"、"明白了"开头，直接说重点
    
    【你的能力】
    你有工具 execute，可以帮Karl做任何事：发消息、搜索、设提醒、查天气等。
    Karl的Telegram是 8538654175。
    
    【关键规则】
    ✓ 用户要做事 → 直接调 execute，别废话
    ✓ 用户问"看到啥" → 描述画面
    ✓ 用户问价格/信息 → 调 execute 搜索
    ✗ 永远别说"我无法"、"我没有权限"
    
    【语音回复示例】
    用户："发Telegram说测试"
    你：说"发了" → execute(发Telegram给8538654175，内容：测试)
    
    用户："这多少钱"
    你：说"查查" → execute(搜索用户看到的物品价格)
    
    用户："今天天气咋样"
    你：说"看看" → execute(查Menlo Park今天天气)
    
    【回复长度】
    - 语音回复控制在2-3句话
    - 搜索结果只说关键数字
    - 列表最多说3项
    """

  // ---------------------------------------------------------------
  // Gemini API Key
  // ---------------------------------------------------------------
  static let apiKey = "AIzaSyAH086KFi7ggyU0mBckyHUNlwsWtxZXjxU"

  // ---------------------------------------------------------------
  // OpenClaw Config (now managed by NetworkConfig.swift)
  // These are kept for backward compatibility but NetworkConfig is preferred
  // ---------------------------------------------------------------
  static let openClawHost = "http://10.0.0.192"  // Fallback only
  static let openClawPort = 18789
  static let openClawHookToken = "5c0e3d45324d766a14f6a98cabe2d79b04cde61e4fcf64f3"
  static let openClawGatewayToken = "5c0e3d45324d766a14f6a98cabe2d79b04cde61e4fcf64f3"

  /// Returns system instruction with memory context
  @MainActor
  static func systemInstructionWithMemory() -> String {
    let memoryContext = ConversationMemory.shared.getContextForPrompt()
    if memoryContext.isEmpty {
      return baseSystemInstruction
    }
    return baseSystemInstruction + "\n\n" + memoryContext
  }
  
  /// Legacy static property for compatibility
  static var systemInstruction: String {
    return baseSystemInstruction
  }

  static func websocketURL() -> URL? {
    guard apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty else { return nil }
    return URL(string: "\(websocketBaseURL)?key=\(apiKey)")
  }

  static var isConfigured: Bool {
    return apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty
  }

  static var isOpenClawConfigured: Bool {
    return true  // Now managed by NetworkConfig
  }
}
