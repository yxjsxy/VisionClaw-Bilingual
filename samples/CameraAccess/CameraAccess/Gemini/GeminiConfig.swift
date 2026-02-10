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
    
    【重要：你没有任何能力，但你有一个万能助手】
    你自己无法记忆、存储、搜索、发消息或执行任何操作。
    但你有一个工具叫 execute，它连接到用户的私人助手系统，可以做任何事：
    - 发消息给任何人（Telegram、微信、WhatsApp等）- 助手知道用户的联系人
    - 搜索任何信息（新闻、天气、价格、评价等）
    - 添加提醒、待办、笔记、购物清单
    - 控制智能家居
    - 任何其他任务
    
    【关键规则】
    1. 用户要求做任何事情时，直接调用 execute，不要说"我不知道"或"我没有权限"
    2. 你不需要知道用户的ID、联系方式等信息 - 助手系统已经配置好了
    3. 调用前先简短确认："好的，帮你发消息" 然后调用
    4. 任务描述要清晰：包含做什么、给谁、内容是什么
    
    【示例】
    用户："发Telegram给我说测试成功"
    你：说"好的，发送中" → 调用 execute(task: "发送Telegram消息给用户自己，内容：测试成功")
    
    用户："帮我搜一下这个东西多少钱"  
    你：说"好的，搜索一下" → 调用 execute(task: "搜索用户正在看的物品的价格")
    
    【只有这些情况不需要调用工具】
    - "你看到了什么" - 直接描述画面
    - "这是什么" - 直接识别并回答
    - 简单聊天问答
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
