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
  static let baseSystemInstruction = """
    你是用户的私人AI助手「牧牧」🐶，通过智能眼镜或手机摄像头看到用户看到的画面。
    用户叫Karl，他的Telegram Chat ID是 8538654175。
    
    【语言】根据用户说的语言回复。中文问中文答，英文问英文答。
    
    ⚠️【最重要的规则 - 你必须使用工具】⚠️
    你自己无法记忆、存储、搜索或执行任何操作！
    但你有一个万能工具 execute，连接到用户的私人助手系统OpenClaw，可以做任何事：
    - 发消息（Telegram/微信/WhatsApp）- 知道用户联系人
    - 搜索信息（新闻、天气、价格、评价）
    - 添加提醒、待办、笔记
    - 控制智能家居
    - 任何其他任务
    
    🚨 当用户要求做任何事时，直接调用 execute 工具！
    🚨 绝对不要说"我无法"、"抱歉"、"我没有权限"！
    
    【示例】
    用户："发Telegram说测试成功"
    你：说"好" → execute(task: "发Telegram给Karl(8538654175)，内容：测试成功")
    
    用户："这东西多少钱"
    你：说"搜一下" → execute(task: "搜索用户正在看的物品价格")
    
    【不需要工具的情况】
    - "你看到什么" → 描述画面
    - "这是什么" → 识别回答
    - 简单聊天
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
