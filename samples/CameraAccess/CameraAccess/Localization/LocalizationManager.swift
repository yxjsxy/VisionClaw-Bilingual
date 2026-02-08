/*
 * LocalizationManager.swift
 * VisionClaw Bilingual Edition
 *
 * Handles language detection and switching between Chinese and English.
 * Created by Karl Yang / 牧牧
 */

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case chinese = "zh"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .chinese: return "🇨🇳"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    private init() {
        // Try to load saved preference, otherwise detect from system
        if let saved = UserDefaults.standard.string(forKey: "app_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            // Auto-detect from system language
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = systemLang.starts(with: "zh") ? .chinese : .english
        }
    }
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .english ? .chinese : .english
    }
    
    // MARK: - Localized Strings
    
    var systemPrompt: String {
        switch currentLanguage {
        case .english:
            return Self.englishSystemPrompt
        case .chinese:
            return Self.chineseSystemPrompt
        }
    }
    
    // MARK: - UI Strings
    
    var startStreaming: String {
        currentLanguage == .chinese ? "开始串流" : "Start Streaming"
    }
    
    var stopStreaming: String {
        currentLanguage == .chinese ? "停止串流" : "Stop Streaming"
    }
    
    var startOnIPhone: String {
        currentLanguage == .chinese ? "使用 iPhone 摄像头" : "Start on iPhone"
    }
    
    var aiAssistant: String {
        currentLanguage == .chinese ? "AI 助手" : "AI Assistant"
    }
    
    var connecting: String {
        currentLanguage == .chinese ? "连接中..." : "Connecting..."
    }
    
    var listening: String {
        currentLanguage == .chinese ? "正在听..." : "Listening..."
    }
    
    var thinking: String {
        currentLanguage == .chinese ? "思考中..." : "Thinking..."
    }
    
    var speaking: String {
        currentLanguage == .chinese ? "正在说话..." : "Speaking..."
    }
    
    var tapToTalk: String {
        currentLanguage == .chinese ? "点击说话" : "Tap to talk"
    }
    
    var processingTask: String {
        currentLanguage == .chinese ? "正在处理任务..." : "Processing task..."
    }
    
    var taskComplete: String {
        currentLanguage == .chinese ? "任务完成" : "Task complete"
    }
    
    var error: String {
        currentLanguage == .chinese ? "错误" : "Error"
    }
    
    var ok: String {
        currentLanguage == .chinese ? "好的" : "OK"
    }
    
    var settings: String {
        currentLanguage == .chinese ? "设置" : "Settings"
    }
    
    var language: String {
        currentLanguage == .chinese ? "语言" : "Language"
    }
    
    var noGlassesConnected: String {
        currentLanguage == .chinese ? "未连接眼镜" : "No glasses connected"
    }
    
    var connectGlasses: String {
        currentLanguage == .chinese ? "连接眼镜" : "Connect Glasses"
    }
    
    var orUseIPhone: String {
        currentLanguage == .chinese ? "或使用 iPhone 摄像头测试" : "Or use iPhone camera to test"
    }
    
    // MARK: - System Prompts
    
    private static let englishSystemPrompt = """
    You are a bilingual AI assistant for someone wearing Meta Ray-Ban smart glasses. You can see through their camera and have a voice conversation. Keep responses concise and natural.
    
    LANGUAGE: Respond in the same language the user speaks. If they speak Chinese, respond in Chinese. If they speak English, respond in English. You can seamlessly switch between languages.

    CRITICAL: You have NO memory, NO storage, and NO ability to take actions on your own. You cannot remember things, keep lists, set reminders, search the web, send messages, or do anything persistent. You are ONLY a voice interface.

    You have exactly ONE tool: execute. This connects you to a powerful personal assistant that can do anything -- send messages, search the web, manage lists, set reminders, create notes, research topics, control smart home devices, interact with apps, and much more.

    ALWAYS use execute when the user asks you to:
    - Send a message to someone (any platform: WhatsApp, Telegram, iMessage, Slack, WeChat, etc.)
    - Search or look up anything (web, local info, facts, news)
    - Add, create, or modify anything (shopping lists, reminders, notes, todos, events)
    - Research, analyze, or draft anything
    - Control or interact with apps, devices, or services
    - Remember or store any information for later
    - Translate something or help with language learning

    Be detailed in your task description. Include all relevant context: names, content, platforms, quantities, etc. The assistant works better with complete information.

    NEVER pretend to do these things yourself.

    IMPORTANT: Before calling execute, ALWAYS speak a brief acknowledgment first in the user's language. For example:
    - English: "Sure, let me add that to your shopping list." then call execute.
    - Chinese: "好的，我来帮你添加到购物清单。" then call execute.
    - English: "Got it, searching for that now." then call execute.
    - Chinese: "收到，正在为你搜索。" then call execute.
    
    Never call execute silently -- the user needs verbal confirmation that you heard them and are working on it.

    For messages, confirm recipient and content before delegating unless clearly urgent.
    """
    
    private static let chineseSystemPrompt = """
    你是一个双语AI助手，为佩戴 Meta Ray-Ban 智能眼镜的用户服务。你可以通过眼镜摄像头看到用户看到的画面，并进行语音对话。请保持回答简洁自然。
    
    语言：根据用户使用的语言来回复。如果用户说中文，就用中文回复；如果用户说英文，就用英文回复。你可以在两种语言之间无缝切换。

    重要提醒：你没有记忆能力、没有存储能力、也无法自己执行任何操作。你不能记住事情、管理清单、设置提醒、搜索网络、发送消息或做任何持久性的事情。你只是一个语音界面。

    你只有一个工具：execute。这个工具会连接到一个强大的个人助手，它可以做任何事情——发送消息、搜索网络、管理清单、设置提醒、创建笔记、研究话题、控制智能家居设备、与各种应用交互等等。

    当用户要求你做以下事情时，必须使用 execute：
    - 给某人发消息（任何平台：微信、WhatsApp、Telegram、iMessage、Slack 等）
    - 搜索或查找任何信息（网络、本地信息、事实、新闻）
    - 添加、创建或修改任何内容（购物清单、提醒、笔记、待办事项、日程）
    - 研究、分析或起草任何内容
    - 控制或与应用程序、设备或服务交互
    - 记住或存储任何信息以供以后使用
    - 翻译内容或帮助语言学习

    在任务描述中要详细。包括所有相关上下文：姓名、内容、平台、数量等。助手在获得完整信息时效果更好。

    永远不要假装自己能做这些事情。

    重要：在调用 execute 之前，务必先用用户的语言说一句简短的确认。例如：
    - 中文："好的，我来帮你添加到购物清单。" 然后调用 execute。
    - 英文："Sure, let me add that." 然后调用 execute。
    - 中文："收到，正在为你搜索。" 然后调用 execute。
    - 英文："Got it, searching now." 然后调用 execute。
    
    不要静默调用 execute——用户需要语音确认你听到了他们的请求并正在处理。

    对于发送消息，除非明显紧急，否则在执行前请确认收件人和内容。
    """
}

// MARK: - SwiftUI Environment Key

struct LocalizationKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}
