# VisionClaw Max+ 🚀

**AI眼镜助手 - 外出场景优化版**

基于 VisionClaw Bilingual Edition，增加以下 Max+ 功能：

## ✨ 新功能

### 🧠 对话记忆系统
- **持久化存储**: 对话历史保存到本地，重启不丢失
- **上下文恢复**: 重连后自动加载最近对话摘要
- **智能摘要**: 提取关键话题、重要信息、待办事项
- **记忆容量**: 保留最近50条消息

```
对话中提到的关键信息 → 自动记录
重连时 → 自动恢复上下文
"刚才说的是什么" → 可以回忆
```

### 🌐 智能网络切换
- **自动检测**: 优先LAN，自动切回Tailscale
- **无缝切换**: 网络变化时自动重连
- **状态显示**: UI实时显示当前连接模式
- **外出支持**: Tailscale确保随时可用

```
家里WiFi → LAN模式 (低延迟)
外出4G/5G → Tailscale模式 (全球可达)
网络切换 → 自动检测重连
```

### 📢 主动通知推送
- **定时任务**: OpenClaw cron输出可推送到眼镜
- **语音播报**: 重要提醒通过AI语音传达
- **系统通知**: 同时发送iOS通知
- **智能过滤**: 只推送重要信息

```
Morning Brief → 语音播报今日概览
提醒事项 → 眼镜里语音提醒
重要邮件 → 即时推送
```

### 🎨 UI改进
- **连接状态**: 显示 LAN ✓ / Tailscale ✓ / Offline
- **记忆指示**: 显示当前记忆消息数量
- **状态栏**: 不遮挡主要视野

## 🔧 配置

### OpenClaw 设置
```json
{
  "gateway": {
    "bind": "auto",  // 同时监听LAN和Tailscale
    "port": 18789
  }
}
```

### VisionClaw 网络配置
自动管理，无需手动配置：
- LAN: `http://10.0.0.192:18789`
- Tailscale: `http://karls-mac-mini.tail765ae2.ts.net:18789`

## 📁 新增文件

```
CameraAccess/
├── Memory/
│   └── ConversationMemory.swift    # 对话记忆系统
├── OpenClaw/
│   ├── NetworkConfig.swift         # 智能网络管理
│   ├── NotificationBridge.swift    # 主动通知推送
│   └── OpenClawBridge.swift        # (更新) 集成记忆和网络
└── Views/Components/
    └── ConnectionStatusView.swift  # 状态显示组件
```

## 🎯 使用场景

### 外出购物
1. 戴上眼镜，自动通过Tailscale连接
2. 看到商品说"这个多少钱"
3. AI搜索价格并语音回复
4. 说"加到购物清单" → 记录到OpenClaw

### 日常通勤
1. 早晨收到Morning Brief语音播报
2. 边走边问"今天有什么会议"
3. 收到Telegram消息 → 眼镜语音提醒
4. 说"回复他说好的" → 自动发送

### 会议记录
1. 会议中AI自动记录关键点
2. 会后说"总结刚才的会议"
3. AI基于对话记忆生成摘要
4. 说"发给团队" → Telegram发送

## 🐛 已知问题

1. **iOS ATS限制**: 需要删除app重装才能生效新的ATS配置
2. **Tailscale冷启动**: 首次连接可能需要几秒
3. **记忆摘要**: 目前使用简单关键词提取，未来可接入LLM

## 📈 下一步

- [ ] ClawRouter项目 - 智能路由
- [ ] LLM驱动的对话摘要
- [ ] 更智能的通知过滤
- [ ] 多设备同步记忆

---

**Made with 💖 by Karl & 牧牧 🐶**
