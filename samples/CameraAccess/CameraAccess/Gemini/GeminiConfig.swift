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

  // System instruction (bilingual support with OpenClaw tools)
  static let systemInstruction = """
    你是一个双语AI助手，为佩戴智能眼镜的用户服务。你可以通过摄像头看到用户看到的画面，并进行语音对话。
    
    语言：根据用户使用的语言来回复。如果用户说中文，就用中文回复；如果用户说英文，就用英文回复。
    
    重要：你有一个工具叫 execute，可以执行各种任务：
    - 搜索网络信息
    - 发送消息（微信、Telegram、WhatsApp等）
    - 添加提醒、待办事项
    - 控制智能家居
    - 其他任何需要执行的操作
    
    当用户要求搜索、发消息、添加事项等操作时，使用 execute 工具。
    在调用工具前，先口头确认你收到了请求。
    
    对于简单问题（看到什么、这是什么），直接回答即可。
    """

  // ---------------------------------------------------------------
  // REQUIRED: Add your own Gemini API key here.
  // Get one at https://aistudio.google.com/apikey
  // ---------------------------------------------------------------
  static let apiKey = "AIzaSyAH086KFi7ggyU0mBckyHUNlwsWtxZXjxU"

  // ---------------------------------------------------------------
  // OPTIONAL: OpenClaw gateway config (for agentic tool-calling).
  // Only needed if you want Gemini to perform actions (web search,
  // send messages, delegate tasks) via an OpenClaw gateway on your Mac.
  // See README.md for setup instructions.
  // ---------------------------------------------------------------
  static let openClawHost = "http://10.0.0.192"
  static let openClawPort = 18789
  static let openClawHookToken = "5c0e3d45324d766a14f6a98cabe2d79b04cde61e4fcf64f3"
  static let openClawGatewayToken = "5c0e3d45324d766a14f6a98cabe2d79b04cde61e4fcf64f3"

  static func websocketURL() -> URL? {
    guard apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty else { return nil }
    return URL(string: "\(websocketBaseURL)?key=\(apiKey)")
  }

  static var isConfigured: Bool {
    return apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty
  }

  static var isOpenClawConfigured: Bool {
    return openClawGatewayToken != "YOUR_OPENCLAW_GATEWAY_TOKEN"
      && !openClawGatewayToken.isEmpty
      && openClawHost != "http://YOUR_MAC_HOSTNAME.local"
  }
}
