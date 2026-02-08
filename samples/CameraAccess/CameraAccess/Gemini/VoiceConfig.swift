/*
 * VoiceConfig.swift
 * VisionClaw Bilingual Edition
 *
 * Voice options for Gemini Live API
 * Created by Karl Yang / 牧牧
 */

import Foundation

enum GeminiVoice: String, CaseIterable {
    // Warm & Friendly
    case sulafat = "Sulafat"           // Warm - 推荐！温暖亲切
    case vindemiatrix = "Vindemiatrix" // Gentle - 温柔
    case achernar = "Achernar"         // Soft - 轻柔
    case achird = "Achird"             // Friendly - 友好
    
    // Upbeat & Energetic
    case puck = "Puck"                 // Upbeat - 活泼
    case leda = "Leda"                 // Youthful - 年轻
    case fenrir = "Fenrir"             // Excitable - 兴奋
    case laomedeia = "Laomedeia"       // Upbeat - 开朗
    case sadachbia = "Sadachbia"       // Lively - 活泼
    
    // Professional & Clear
    case charon = "Charon"             // Informative - 专业
    case algieba = "Algieba"           // Smooth - 流畅
    case despina = "Despina"           // Smooth - 顺滑
    case iapetus = "Iapetus"           // Clear - 清晰
    case erinome = "Erinome"           // Clear - 清澈
    
    // Casual & Easy-going
    case aoede = "Aoede"               // Breezy - 轻松
    case umbriel = "Umbriel"           // Easy-going - 随和
    case callirrhoe = "Callirrhoe"     // Easy-going - 悠闲
    case zubenelgenubi = "Zubenelgenubi" // Casual - 随性
    
    // Other
    case zephyr = "Zephyr"             // Bright - 明亮
    case kore = "Kore"                 // Firm - 坚定
    case orus = "Orus"                 // Firm - 稳重
    case autonoe = "Autonoe"           // Bright - 明快
    case schedar = "Schedar"           // Even - 平稳
    case enceladus = "Enceladus"       // Breathy - 气息感
    case algenib = "Algenib"           // Gravelly - 沙哑
    case gacrux = "Gacrux"             // Mature - 成熟
    case sadaltager = "Sadaltager"     // Knowledgeable - 博学
    case rasalgethi = "Rasalgethi"     // Informative - 知性
    case alnilam = "Alnilam"           // Firm - 坚毅
    case pulcherrima = "Pulcherrima"   // Forward - 自信
    
    var displayName: String {
        switch self {
        case .sulafat: return "🌟 Sulafat (温暖)"
        case .vindemiatrix: return "🌸 Vindemiatrix (温柔)"
        case .achernar: return "🌙 Achernar (轻柔)"
        case .achird: return "😊 Achird (友好)"
        case .puck: return "⚡ Puck (活泼)"
        case .leda: return "🌈 Leda (年轻)"
        case .fenrir: return "🔥 Fenrir (兴奋)"
        case .charon: return "📚 Charon (专业)"
        case .algieba: return "✨ Algieba (流畅)"
        case .aoede: return "🍃 Aoede (轻松)"
        default: return self.rawValue
        }
    }
    
    var description: String {
        switch self {
        case .sulafat: return "Warm, 亲切温暖，适合日常对话"
        case .vindemiatrix: return "Gentle, 柔和温柔，女声"
        case .achernar: return "Soft, 轻声细语"
        case .puck: return "Upbeat, 充满活力"
        case .leda: return "Youthful, 青春气息"
        case .charon: return "Informative, 专业播报"
        case .algieba: return "Smooth, 顺滑流畅"
        case .aoede: return "Breezy, 轻松自在"
        default: return ""
        }
    }
}

class VoiceManager: ObservableObject {
    static let shared = VoiceManager()
    
    @Published var currentVoice: GeminiVoice {
        didSet {
            UserDefaults.standard.set(currentVoice.rawValue, forKey: "gemini_voice")
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "gemini_voice"),
           let voice = GeminiVoice(rawValue: saved) {
            self.currentVoice = voice
        } else {
            // 默认使用温暖的声音
            self.currentVoice = .sulafat
        }
    }
    
    // 推荐的声音列表（最好听的几个）
    static let recommended: [GeminiVoice] = [
        .sulafat,      // 温暖
        .vindemiatrix, // 温柔
        .puck,         // 活泼
        .leda,         // 年轻
        .aoede,        // 轻松
        .charon,       // 专业
        .algieba       // 流畅
    ]
}
