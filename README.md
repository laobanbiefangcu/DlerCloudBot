# 🌟 墙洞API Telegram Bot 部署脚本

<div align="center">

![Version](https://img.shields.io/badge/版本-v1.0.5-blue.svg?style=for-the-badge)
![License](https://img.shields.io/badge/许可证-MIT-green.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/状态-稳定版-success.svg?style=for-the-badge)

**🚀 一键部署 | 🛡️ 安全可靠 | 💎 功能完整 | 🔧 易于管理**

---

### ✨ 世界上最优雅的墙洞管理机器人部署解决方案 ✨

</div>

## 🎯 项目概览

这是一个**功能强大、设计精美**的墙洞API Telegram机器人一键部署脚本，让您能够：

- 🎪 **零配置部署** - 一条命令，搞定一切
- 🎭 **多账号管理** - 支持无限账号切换
- 🎨 **智能维护** - 自动Token刷新，永不掉线
- 🎪 **可视化管理** - 美观的交互界面
- 🎯 **专业级监控** - PM2进程管理，稳如磐石

---

## 🌈 核心特性

### 🔥 **自动化部署**
```bash
# 一键部署，从零到完成
bash dler.sh
```

<details>
<summary>🎪 <strong>点击展开 - 完整功能列表</strong></summary>

### 💎 **账号管理**
- 🔐 **多账号支持** - 无限账号，一键切换
- 🛡️ **密码加密** - AES-256-CBC军用级加密
- 🔄 **自动登录** - Token过期自动重新登录
- 📱 **会话持久化** - 重启后数据不丢失

### ⚡ **智能维护** 
- 🕐 **定时刷新** - 每45分钟自动刷新Token
- 🔍 **健康检查** - 实时监控Token状态
- 🚨 **故障恢复** - 自动处理网络异常
- 📊 **数据统计** - 详细使用记录

### 🎨 **用户体验**
- 🌟 **美观界面** - 精心设计的交互体验
- 📋 **快捷命令** - 丰富的管理指令
- 🔔 **智能提醒** - 重要事件及时通知
- 🎯 **精准操作** - 防误操作保护机制

### 🛠️ **技术亮点**
- 🚀 **PM2管理** - 专业级进程管理
- 🐳 **容器支持** - Docker友好设计
- 🔧 **SystemD集成** - 系统级服务支持
- 📦 **依赖自动** - 智能安装所需组件

</details>

---

## 🎪 快速开始

### 🚀 **超级简单的一键部署**

```bash
# 下载并运行部署脚本
wget -O dler.sh https://your-domain.com/dler.sh
chmod +x dler.sh
bash dler.sh
```

### 🎭 **或者使用在线部署**

```bash
# 直接在线运行（推荐）
curl -fsSL https://your-domain.com/dler.sh | bash
```

---

## 🎨 使用指南

### 📱 **机器人命令大全**

<table>
<tr>
<td width="50%">

#### 🔐 **账号管理**
```
/login          📝 登录新账号
/logout         🚪 注销当前账号
/accounts       📋 查看所有账号
/switch <ID>    🔄 切换账号
/remove <ID>    🗑️删除指定账号
```

</td>
<td width="50%">

#### 🛠️ **系统管理**
```
/status         📊 系统状态检查
/info           ℹ️ 账户详细信息
/creds          🔑 凭据管理
/ping           🏓 网络延迟测试
/help           📚 帮助文档
```

</td>
</tr>
</table>

### 🎯 **服务器管理命令**

<table>
<tr>
<td width="33%">

#### 🚀 **启动服务**
```bash
# PM2启动（推荐）
pm2 start ecosystem.config.js

# 直接启动
./start.sh

# 快速启动
./quick-start.sh
```

</td>
<td width="33%">

#### 📊 **监控管理**
```bash
# 查看状态
pm2 status

# 查看日志
pm2 logs dler-bot

# 重启服务
pm2 restart dler-bot
```

</td>
<td width="33%">

#### 🛑 **停止服务**
```bash
# 停止服务
./stop.sh

# PM2停止
pm2 stop dler-bot

# 完全卸载
./uninstall.sh
```

</td>
</tr>
</table>

---

## 🏗️ 架构设计

### 📁 **项目结构**

```
dler-cloud-bot/
├── 🤖 bot.js                  # 主程序文件
├── 📦 package.json            # 依赖配置
├── ⚙️ ecosystem.config.js     # PM2配置
├── 🔐 .env                    # 环境变量
├── 📋 logs/                   # 日志目录
│   ├── 📄 out.log            # 输出日志
│   ├── ❌ err.log            # 错误日志
│   └── 📊 combined.log       # 合并日志
├── 🚀 start.sh               # 启动脚本
├── ⚡ quick-start.sh         # 快速启动
├── 🛑 stop.sh                # 停止脚本
├── 📊 status.sh              # 状态查看
└── 🗑️ uninstall.sh           # 卸载脚本
```

### 🔧 **技术栈**

<div align="center">

| 组件 | 技术 | 描述 |
|------|------|------|
| 🚀 **运行时** | Node.js 18+ | 高性能JavaScript运行环境 |
| 📱 **机器人框架** | node-telegram-bot-api | 专业Telegram Bot SDK |
| 🔒 **加密算法** | AES-256-CBC | 军用级数据加密 |
| 🛠️ **进程管理** | PM2 | 企业级进程管理器 |
| 🌐 **网络请求** | node-fetch | 现代化HTTP客户端 |
| 📊 **日志系统** | Winston | 专业日志管理 |

</div>

---

## ⚙️ 配置指南

### 🔐 **环境变量配置**

创建 `.env` 文件：

```bash
# 机器人基础配置
BOT_TOKEN=your_telegram_bot_token_here
ADMIN_ID=your_telegram_user_id_here

# API配置
API_BASE_URL=https://dler.cloud/api/v1
DEBUG=false

# 安全配置
ENCRYPTION_KEY=your_32_character_encryption_key_here

# 高级配置
TOKEN_REFRESH_INTERVAL=45  # Token刷新间隔（分钟）
MAX_RETRY_ATTEMPTS=3       # 最大重试次数
REQUEST_TIMEOUT=30000      # 请求超时时间（毫秒）
```

### 🎨 **自定义配置**

<details>
<summary>🔧 <strong>高级配置选项</strong></summary>

```javascript
// ecosystem.config.js - PM2配置
module.exports = {
  apps: [{
    name: 'dler-bot',
    script: 'bot.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '200M',
    env: {
      NODE_ENV: 'production'
    },
    // 🎯 日志配置
    log_file: './logs/combined.log',
    out_file: './logs/out.log',
    error_file: './logs/err.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    
    // 🚀 性能优化
    node_args: '--max-old-space-size=256',
    
    // 🔄 重启策略
    min_uptime: '10s',
    max_restarts: 10
  }]
}
```

</details>

---

## 🛡️ 安全特性

### 🔐 **数据保护**

<table>
<tr>
<td width="50%">

#### 💎 **加密存储**
- 🛡️ AES-256-CBC加密算法
- 🔑 随机生成的加密密钥  
- 🔒 密码永不明文存储
- 🚫 防止数据泄露风险

</td>
<td width="50%">

#### 🛠️ **安全机制**
- 🚨 管理员权限验证
- 🔍 输入数据合规检查
- ⏰ Token过期自动处理
- 🚦 请求频率限制保护

</td>
</tr>
</table>

### 🔧 **权限控制**

```javascript
// 管理员验证机制
const isAdmin = (userId) => {
    return userId === parseInt(process.env.ADMIN_ID);
};

// 用户权限检查
const hasPermission = (chatId, operation) => {
    return isAdmin(chatId) || userHasAccess(chatId, operation);
};
```

---

## 📊 监控运维

### 🎯 **实时监控**

```bash
# 🔍 查看实时日志
pm2 logs dler-bot --lines 100

# 📊 性能监控
pm2 monit

# 📈 进程状态
pm2 status

# 🔄 重启服务
pm2 restart dler-bot

# 🛑 停止服务
pm2 stop dler-bot
```

### 📈 **性能优化**

<details>
<summary>🚀 <strong>性能调优建议</strong></summary>

#### 🎪 **内存优化**
```bash
# 设置内存限制
pm2 start bot.js --max-memory-restart 200M

# 优化Node.js内存
node --max-old-space-size=256 bot.js
```

#### ⚡ **并发优化**
```bash
# 集群模式运行
pm2 start ecosystem.config.js -i max

# 负载均衡配置
pm2 start bot.js -i 4
```

#### 🔧 **系统调优**
```bash
# 增加文件描述符限制
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# 优化TCP参数
echo "net.core.somaxconn = 65536" >> /etc/sysctl.conf
sysctl -p
```

</details>

---

## 🆘 故障排除

### 🚨 **常见问题**

<details>
<summary>❓ <strong>机器人无法启动</strong></summary>

```bash
# 1. 检查Token配置
echo $BOT_TOKEN

# 2. 验证网络连接
curl -s https://api.telegram.org/bot$BOT_TOKEN/getMe

# 3. 查看错误日志
tail -f logs/err.log

# 4. 重新安装依赖
npm install --production
```

</details>

<details>
<summary>🔧 <strong>Token自动刷新失败</strong></summary>

```bash
# 1. 检查凭据文件
ls -la credentials.json

# 2. 验证加密密钥
echo $ENCRYPTION_KEY | wc -c  # 应该是32字符

# 3. 测试API连接
curl -X POST https://dler.cloud/api/v1/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test","passwd":"test"}'

# 4. 重置用户数据
rm -f tokens.json sessions.json credentials.json
```

</details>

<details>
<summary>📊 <strong>PM2服务异常</strong></summary>

```bash
# 1. 重置PM2进程
pm2 kill
pm2 start ecosystem.config.js

# 2. 清理日志文件
pm2 flush

# 3. 更新PM2版本
npm install -g pm2@latest

# 4. 检查系统资源
free -h
df -h
```

</details>

---

## 🎯 部署模式

### 🚀 **生产环境部署**

```bash
# 🏭 生产环境一键部署
bash dler.sh --production

# 🐳 Docker容器部署
docker run -d --name dler-bot \
  -e BOT_TOKEN=your_token \
  -e ADMIN_ID=your_id \
  -v $(pwd)/data:/app/data \
  dler-bot:latest

# ☁️ 云服务器部署
curl -fsSL https://install.dler-bot.com | bash
```

### 🧪 **开发环境部署**

```bash
# 🔧 开发模式启动
npm run dev

# 🐛 调试模式
DEBUG=true npm start

# 🧪 测试环境
NODE_ENV=test npm test
```

---

## 🤝 贡献指南

### 💡 **如何贡献**

1. 🍴 **Fork** 项目到您的账户
2. 🌿 **创建** 您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 💾 **提交** 您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 📤 **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. 🎯 **开启** Pull Request

### 🐛 **Bug 报告**

发现问题？请在 [Issues](https://github.com/your-repo/issues) 页面提交：

- 📝 详细描述问题
- 🔄 提供复现步骤
- 🖥️ 说明运行环境
- 📸 附上错误截图

---

## 📜 许可证

本项目采用 **MIT 许可证** - 查看 [LICENSE](LICENSE) 文件了解详情

---

## 🌟 致谢

感谢所有为这个项目做出贡献的开发者们！

<div align="center">

### 🎉 **如果这个项目对您有帮助，请给我们一个 ⭐ Star！** 🎉

---

**🚀 Made with ❤️ by Dler Bot Team**

**📧 联系我们：support@dler-bot.com**

**🌐 官方网站：https://dler-bot.com**

</div>