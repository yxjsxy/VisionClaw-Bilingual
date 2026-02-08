# VisionClaw 双语版 🦞😎🇨🇳🇺🇸

> **VisionClaw Bilingual Edition** - 中英双语支持的 Meta Ray-Ban 智能眼镜 AI 助手

基于 [VisionClaw](https://github.com/sseanliu/VisionClaw) 的双语增强版，由 Karl Yang 制作。

## ✨ 新增功能

### 🌐 双语支持
- **自动语言检测**: 根据系统语言自动设置中文或英文
- **一键切换**: UI 中随时切换语言，无需重启
- **智能响应**: AI 会根据你说话的语言自动用相应语言回复

### 📱 本地化 UI
- 完整中文界面
- 按钮、提示、错误信息全部汉化
- 保留英文选项供需要时使用

### 🤖 双语 AI 指令
- 中文语音指令: "帮我搜索附近的咖啡店"
- 英文语音指令: "Search for coffee shops nearby"
- 混合使用: 可以在对话中自由切换语言

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/yxjsxy/VisionClaw-Bilingual.git
cd VisionClaw-Bilingual/samples/CameraAccess
open CameraAccess.xcodeproj
```

### 2. 配置 API Key
编辑 `CameraAccess/Gemini/GeminiConfig.swift`:
```swift
static let apiKey = "你的_GEMINI_API_KEY"
```

### 3. 运行测试
- 选择你的 iPhone 作为目标设备
- 按 Cmd+R 运行
- 点击「使用 iPhone 摄像头」开始测试

## 🎯 使用场景

### 中文用户
- 🍳 "我在看什么食材？可以做什么菜？"
- 📝 "帮我把牛奶加到购物清单"
- 💬 "给老婆发微信说我晚点到家"
- 🔍 "搜索这个建筑的历史"

### English Users
- 🌍 "What am I looking at?"
- 📋 "Add eggs to my shopping list"
- 💌 "Send a message to John"
- 🔎 "Search for restaurants nearby"

## 📁 项目结构

```
samples/CameraAccess/CameraAccess/
├── Localization/
│   └── LocalizationManager.swift   # 新增：语言管理器
├── Gemini/
│   └── GeminiConfig.swift          # 修改：使用本地化系统提示
├── Views/
│   ├── Components/
│   │   └── LanguageToggle.swift    # 新增：语言切换按钮
│   ├── NonStreamView.swift         # 修改：中文 UI
│   └── StreamView.swift            # 修改：中文 UI
└── ...
```

## 🔧 技术实现

### LocalizationManager
- 单例模式管理全局语言状态
- 使用 `@Published` 实现 SwiftUI 响应式更新
- 语言偏好存储在 UserDefaults

### 双语系统提示
- 英文模式: 优化的英文 system prompt
- 中文模式: 针对中文用户习惯优化的提示词
- 两种模式都支持自动语言切换响应

## 🔗 依赖

- iOS 17.0+
- Xcode 15.0+
- Gemini API Key ([免费获取](https://aistudio.google.com/apikey))
- Meta Ray-Ban 智能眼镜 (可选 - 可用 iPhone 测试)
- OpenClaw (可选 - 用于执行任务)

## 📝 许可

基于原项目 MIT 许可证。

## 🙏 致谢

- [VisionClaw](https://github.com/sseanliu/VisionClaw) - 原始项目
- [Meta Wearables DAT SDK](https://github.com/facebook/meta-wearables-dat-ios)
- [OpenClaw](https://github.com/nichochar/openclaw)

---

Made with ❤️ by Karl Yang / 牧牧 🐶
