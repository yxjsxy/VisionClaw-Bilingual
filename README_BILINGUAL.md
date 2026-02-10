# VisionClaw Chinese 🦞😎🇨🇳

> **VisionClaw 中文优化版** - 自动双语支持的 Meta Ray-Ban 智能眼镜 AI 助手

基于 [VisionClaw](https://github.com/sseanliu/VisionClaw) 优化，由 Karl Yang 制作。

## ✨ 特性

### 🌐 自动双语
- **自动语言识别**: 说中文就中文回复，说英文就英文回复
- **无需手动切换**: AI 自动检测语言并响应
- **混合使用**: 可以在对话中自由切换语言

### 🔗 OpenClaw 集成
- 通过 OpenClaw Gateway 执行任务
- 支持 56+ 技能：搜索、发消息、智能家居等
- 本地部署，隐私安全

### 🎙️ 优化的语音
- 使用 Sulafat 温暖声音
- 中英文发音清晰自然

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

### 3. 配置 OpenClaw（可选但推荐）
```swift
static let openClawHost = "http://你的Mac的IP"
static let openClawPort = 18789
static let openClawGatewayToken = "你的token"
```

### 4. 运行
- 选择你的 iPhone 作为目标设备
- 按 Cmd+R 运行
- 点击「使用 iPhone 摄像头」开始

## 🎯 使用示例

### 视觉问答
- "这是什么？"
- "What am I looking at?"
- "帮我看看这个价格"

### 搜索（需要 OpenClaw）
- "帮我搜索今天的新闻"
- "这个品牌怎么样"

### 发消息（需要 OpenClaw）
- "发 Telegram 消息给我"
- "帮我记个笔记"

### 实用工具（需要 OpenClaw）
- "今天天气怎么样"
- "帮我算一下小费"

## 📁 项目结构

```
samples/CameraAccess/CameraAccess/
├── Gemini/
│   ├── GeminiConfig.swift      # API Key + OpenClaw 配置
│   ├── GeminiLiveService.swift # Gemini Live WebSocket
│   ├── AudioManager.swift      # 音频处理
│   └── GeminiSessionViewModel.swift
├── OpenClaw/
│   ├── OpenClawBridge.swift    # OpenClaw HTTP 客户端
│   ├── ToolCallModels.swift    # 工具声明
│   └── ToolCallRouter.swift    # 工具调用路由
├── Views/
│   ├── NonStreamView.swift     # 主界面
│   └── StreamView.swift        # 串流界面
└── ...
```

## 🔧 依赖

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
- [OpenClaw](https://github.com/openclaw/openclaw)

---

Made with ❤️ by Karl Yang
