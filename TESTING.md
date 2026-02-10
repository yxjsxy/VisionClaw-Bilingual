# VisionClaw Max+ 测试指南

## 🔧 前置条件

### Mac 端
1. **OpenClaw 运行中**: `openclaw status`
2. **Tailscale 运行中**: 菜单栏检查或运行 `tailscale status`
3. **Gateway bind: auto**: 确保同时监听 LAN 和 Tailscale

### iPhone 端
1. **Tailscale 已连接**: 打开 Tailscale app 确认已连接
2. **VisionClaw 重新安装**: 如果 ATS 配置更新，需删除 app 重装

---

## 🧪 自动化测试

### 运行连接测试
```bash
cd ~/Documents/vibe_coding/VisionClaw-Bilingual
./scripts/test_connectivity.sh
```

**预期输出:**
```
✓ LAN: Health OK, API Working
✓ Tailscale: Health OK, API Working
✓ All connections working!
```

---

## 📱 iOS 手动测试

### 测试 1: LAN 连接 (同一 WiFi)
1. iPhone 连接到 Mac 同一 WiFi (10.0.0.x 网段)
2. 打开 VisionClaw app
3. 点击 AI 按钮启动 Gemini
4. 说: "发 Telegram 说测试成功"
5. **预期**: Xcode Console 显示 `[OpenClaw] Using LAN`

### 测试 2: Tailscale 连接 (外网)
1. iPhone 断开 WiFi，使用 4G/5G
2. 确保 iPhone Tailscale 已连接
3. 打开 VisionClaw app
4. 说: "发 Telegram 说外网测试"
5. **预期**: Xcode Console 显示 `[OpenClaw] Using Tailscale`

### 测试 3: 网络切换
1. 开始时使用 LAN
2. 断开 WiFi (保持 Tailscale 连接)
3. 继续对话
4. **预期**: 自动切换到 Tailscale，无中断

---

## 🎙️ 语音问答测试

### 基础测试
| 指令 | 预期响应 |
|------|----------|
| "你是谁" | 自我介绍，提到牧牧 |
| "你看到什么" | 描述摄像头画面 |
| "现在几点" | 调用 execute 查询时间 |

### 工具调用测试
| 指令 | 预期行为 |
|------|----------|
| "发 Telegram 说 hi" | execute → 发送消息成功 |
| "搜索今天天气" | execute → 返回天气信息 |
| "提醒我明天开会" | execute → 创建提醒 |

### 记忆测试
1. 说: "记住我喜欢咖啡"
2. 断开重连
3. 说: "我喜欢什么饮料"
4. **预期**: 能回忆起咖啡 (通过 ConversationMemory)

---

## 🐛 常见问题

### ATS 错误 (Error -1022)
```
The resource could not be loaded because the 
App Transport Security policy requires a secure connection.
```
**解决**: 删除 iPhone 上的 app，重新 Build & Run

### Tailscale 无法连接
1. 检查 Mac Tailscale: `tailscale status`
2. 检查 iPhone Tailscale app 是否显示 "Connected"
3. 确保 OpenClaw bind: auto

### Gemini 不调用 execute
检查 Xcode Console:
- `[Gemini] Tool call received` ✓ → 正常
- 无此日志 → Gemini 没有触发工具，检查系统提示

---

## 📊 Xcode Console 日志关键字

| 关键字 | 含义 |
|--------|------|
| `[NetworkConfig] Connected via LAN` | 使用 LAN 连接 |
| `[NetworkConfig] Connected via Tailscale` | 使用 Tailscale 连接 |
| `[Gemini] Tool call received` | Gemini 调用了工具 |
| `[OpenClaw] Agent result` | OpenClaw 返回结果 |
| `[Memory] Added user message` | 用户消息已保存 |
| `[Memory] Added tool call` | 工具调用已记录 |

---

## ✅ 发布前 Checklist

- [ ] LAN 连接测试通过
- [ ] Tailscale 连接测试通过
- [ ] 网络自动切换正常
- [ ] 语音问答流畅
- [ ] 工具调用成功
- [ ] 对话记忆恢复正常
- [ ] UI 状态显示正确
