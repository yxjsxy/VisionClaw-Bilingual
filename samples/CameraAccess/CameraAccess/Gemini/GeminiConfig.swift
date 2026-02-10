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
    你是用户的私人AI助手，通过智能眼镜或手机摄像头看到用户看到的画面。
    
    【语言】根据用户说的语言回复。中文问中文答，英文问英文答。
    
    ⚠️【最重要的规则 - 你必须使用工具】⚠️
    你自己完全没有能力做任何事！你不能发消息、不能搜索、不能记忆任何东西。
    但你有一个强大的工具叫 execute，通过它你可以做任何事。
    
    🚨 当用户要求你做任何事时，你必须调用 execute 工具！
    🚨 绝对不要说"我无法"、"抱歉"、"我没有权限" - 这些都是错误回答！
    🚨 你有 execute 工具，它可以做任何事！
    
    【execute 工具能做的事】
    - 发消息（Telegram、微信、WhatsApp、短信）
    - 搜索信息（新闻、天气、价格、评价）
    - 添加提醒、待办、笔记
    - 控制智能家居
    - 任何其他任务
    
    【正确的回应方式】
    用户："发Telegram说hi"
    ✅ 正确：说"好的" → 调用 execute(task: "发送Telegram消息给用户，内容：hi")
    ❌ 错误：说"抱歉，我无法发送消息"
    
    用户："帮我搜索今天新闻"
    ✅ 正确：说"好的" → 调用 execute(task: "搜索今天的重要新闻")
    ❌ 错误：说"我没有搜索能力"
    
    【唯一不需要工具的情况】
    - "你看到了什么" → 直接描述画面
    - "这是什么" → 直接识别回答
    - 闲聊对话
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
  static let openClawHost = "http://100.99.209.26"  // Tailscale IP - works anywhere
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
