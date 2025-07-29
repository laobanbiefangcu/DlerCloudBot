# 🚀 墙洞API Telegram Bot 完整部署系统

<div align="center">

![Version](https://img.shields.io/badge/版本-v1.0.5-blue.svg?style=for-the-badge)
![License](https://img.shields.io/badge/许可证-MIT-green.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/平台-Linux-orange.svg?style=for-the-badge)
![Node](https://img.shields.io/badge/Node.js-18+-brightgreen.svg?style=for-the-badge)

**🤖 一键部署完整的墙洞API管理机器人**

*功能强大 • 安装简单 • 管理便捷*

</div>

---

## 📋 目录

- [✨ 特性亮点](#-特性亮点)
- [🎯 功能模块](#-功能模块)
- [⚡ 快速开始](#-快速开始)
- [🔧 配置说明](#-配置说明)
- [📱 使用指南](#-使用指南)
- [🛠️ 管理工具](#️-管理工具)
- [🧪 测试模式](#-测试模式)
- [❓ 故障排除](#-故障排除)
- [📞 技术支持](#-技术支持)

---

## ✨ 特性亮点

<div align="center">

| 🌟 **核心特性** | 🔧 **技术特点** | 🛡️ **安全特性** |
|:---:|:---:|:---:|
| 🤖 智能化管理 | 🔄 自动重连机制 | 🔐 AES-256加密 |
| 📊 实时状态监控 | 🚀 多种启动方式 | 👑 管理员权限控制 |
| 🌐 多节点支持 | 📋 完整日志记录 | 🔑 密码安全存储 |
| 🎯 一键部署 | ⚡ 高性能运行 | 🛡️ 输入验证保护 |

</div>

### 🆕 最新功能

- 🔍 **系统状态监控** - 实时监控机器人运行状态
- 📊 **网络连接测试** - 自动检测API连接质量
- 🔗 **API健康检查** - 监控API服务可用性
- 📈 **性能指标显示** - 内存、CPU使用率实时展示
- 🧪 **测试模式运行** - 安全的调试和测试环境
- 📋 **详细错误处理** - 智能错误诊断和修复建议
- 🔄 **自动重连机制** - 网络中断自动恢复
- 💾 **多账号管理** - 支持管理多个Dler账户

---

## 🎯 功能模块

<table>
<tr>
<td width="50%" valign="top">

### 🔐 账户管理
- ✅ 用户登录/注销
- 📊 账户信息查看
- 🎁 每日签到奖励
- 🔄 Token自动刷新
- 👥 多账号切换

### 📱 订阅管理
- 🔗 Smart订阅链接
- 🛡️ Shadowsocks订阅
- 🚀 VMess/Trojan支持
- 🔒 SS2022协议支持
- 📋 订阅信息管理

</td>
<td width="50%" valign="top">

### 🌐 节点管理
- 🌍 真实节点列表
- 📊 节点状态监控
- ⚡ 延迟测试
- 📈 流量统计
- 🔄 节点切换

### 🛠️ 系统管理
- 📊 系统状态监控
- 🔧 服务控制
- 📋 日志查看
- 🧪 测试模式
- 🗑️ 一键卸载

</td>
</tr>
</table>

---

## ⚡ 快速开始

### 🚀 **超级简单的一键部署**

```bash
# 下载并运行部署脚本
wget -O dler.sh https://raw.githubusercontent.com/laobanbiefangcu/DlerCloudBot/main/dler.sh
chmod +x dler.sh
bash dler.sh
```

### 🎭 **或者使用在线部署**

```bash
# 直接在线运行（推荐）
curl -fsSL https://raw.githubusercontent.com/laobanbiefangcu/DlerCloudBot/main/dler.sh | bash
```

### 🚀 启动选项

安装完成后，您有多种启动方式：

<table>
<tr>
<th width="25%">启动方式</th>
<th width="35%">命令</th>
<th width="40%">特点</th>
</tr>
<tr>
<td>🏃 <strong>快速启动</strong></td>
<td><code>./quick-start.sh</code></td>
<td>🌟 推荐方式，PM2后台运行</td>
</tr>
<tr>
<td>⚙️ <strong>详细模式</strong></td>
<td><code>./start.sh</code></td>
<td>选择启动方式，支持前台/后台</td>
</tr>
<tr>
<td>📊 <strong>状态检查</strong></td>
<td><code>./status.sh</code></td>
<td>查看运行状态和日志</td>
</tr>
<tr>
<td>🛑 <strong>停止服务</strong></td>
<td><code>./stop.sh</code></td>
<td>安全停止所有进程</td>
</tr>
</table>

---

## 🔧 配置说明

### 📝 环境变量配置

安装过程中会自动创建 `.env` 配置文件：

```bash
# Telegram Bot配置
BOT_TOKEN=your_bot_token_here          # 从 @BotFather 获取
ADMIN_USER_ID=your_admin_user_id       # 从 @userinfobot 获取

# 可选配置
DLER_BASE_URL=https://dler.cloud/api/v1  # Dler API地址
DEBUG=false                              # 调试模式
```

### 🤖 创建Telegram Bot

1. **联系 @BotFather**
   ```
   /newbot
   输入机器人名称
   输入机器人用户名（必须以bot结尾）
   ```

2. **获取Token**
   - 复制 `BOT_TOKEN`
   - 粘贴到 `.env` 文件

3. **获取管理员ID**
   ```
   联系 @userinfobot
   发送任意消息获取您的用户ID
   将ID填入 ADMIN_USER_ID
   ```

---

## 📱 使用指南

### 🎮 基础命令

<div align="center">

| 命令 | 功能 | 示例 |
|:---:|:---:|:---:|
| `/start` | 🚀 开始使用 | 显示欢迎信息和菜单 |
| `/help` | ❓ 帮助信息 | 查看所有可用命令 |
| `/status` | 📊 系统状态 | 查看机器人运行状态 |
| `/login` | 🔐 账户登录 | `/login user@example.com password` |
| `/info` | 📋 账户信息 | 查看当前账户详情 |

</div>

### 🔐 账户操作

```
🔑 登录账户
/login user@example.com your_password

📊 查看信息  
/info

🎁 每日签到
/checkin

🚪 注销登录
/logout
```

### 📱 订阅获取

```
🔗 获取Smart订阅
/smart

🛡️ 获取SS订阅  
/ss

🚀 获取VMess订阅
/vmess

🔒 获取Trojan订阅
/trojan
```

### 🌐 节点管理

```
📋 查看节点列表
/nodes

📊 节点状态检查
/nodestatus

⚡ 节点延迟测试  
/nodetest
```

### 👑 管理员功能

```
🔍 系统监控
/monitor

📊 性能统计
/performance

🔧 服务控制
/service [start|stop|restart]

📋 日志查看
/logs [lines]
```

---

## 🛠️ 管理工具

### 📊 状态监控

```bash
# 查看详细状态
./status.sh

# 实时日志监控
pm2 logs dler-bot

# 系统资源监控
pm2 monit
```

### 🔄 服务控制

<table>
<tr>
<th width="30%">操作</th>
<th width="35%">PM2命令</th>
<th width="35%">Systemd命令</th>
</tr>
<tr>
<td>🚀 <strong>启动服务</strong></td>
<td><code>pm2 start dler-bot</code></td>
<td><code>sudo systemctl start dler-bot</code></td>
</tr>
<tr>
<td>🛑 <strong>停止服务</strong></td>
<td><code>pm2 stop dler-bot</code></td>
<td><code>sudo systemctl stop dler-bot</code></td>
</tr>
<tr>
<td>🔄 <strong>重启服务</strong></td>
<td><code>pm2 restart dler-bot</code></td>
<td><code>sudo systemctl restart dler-bot</code></td>
</tr>
<tr>
<td>📊 <strong>查看状态</strong></td>
<td><code>pm2 status</code></td>
<td><code>sudo systemctl status dler-bot</code></td>
</tr>
</table>

### 📋 日志管理

```bash
# 实时查看日志
pm2 logs dler-bot --lines 50

# 查看错误日志
pm2 logs dler-bot --err

# 清空日志
pm2 flush dler-bot

# 日志文件位置
tail -f logs/combined.log
tail -f logs/error.log
```

---

## 🧪 测试模式

### 🔍 功能测试

```bash
# 启动测试模式
./start.sh
# 选择选项 7 (测试模式)

# 或直接运行
node -e "
require('dotenv').config();
console.log('🧪 配置测试:');
console.log('Bot Token:', process.env.BOT_TOKEN ? '✅ 已配置' : '❌ 未配置');
console.log('Admin ID:', process.env.ADMIN_USER_ID ? '✅ 已配置' : '❌ 未配置');
"
```

### 📊 连接测试

在Telegram中发送以下命令测试：

- `/status` - 测试机器人响应
- `/info` - 测试API连接
- `/nodes` - 测试节点获取
- `/smart` - 测试订阅生成

---

## ❓ 故障排除

<details>
<summary>🔧 <strong>常见问题解决方案</strong></summary>

### ❌ 机器人无响应

```bash
# 检查进程状态
./status.sh

# 查看错误日志
pm2 logs dler-bot --err

# 重启服务
pm2 restart dler-bot
```

### 🌐 网络连接问题

```bash
# 测试网络连接
ping 8.8.8.8

# 检查防火墙
sudo ufw status

# 测试HTTPS连接
curl -I https://api.telegram.org
```

### 🔑 登录失败

1. **检查账户信息**
   - 确认用户名和密码正确
   - 检查账户是否被锁定

2. **检查API连接**
   ```bash
   curl -X POST https://dler.cloud/api/v1/login \
     -H "Content-Type: application/json" \
     -d '{"email":"your_email","passwd":"your_password"}'
   ```

### 📱 订阅获取失败

1. **检查登录状态**
   - 发送 `/info` 确认已登录
   - 必要时重新登录

2. **检查账户套餐**
   - 确认账户有效期内
   - 检查剩余流量

</details>

---

## 🗑️ 卸载说明

如需完全卸载系统：

```bash
# 运行卸载脚本
./uninstall.sh

# 手动清理（如果需要）
pm2 delete dler-bot
sudo systemctl stop dler-bot
sudo systemctl disable dler-bot
sudo rm /etc/systemd/system/dler-bot.service
rm -rf ~/dler-bot
```

---

## 📞 技术支持

<div align="center">

### 🛟 获得帮助

| 类型 | 联系方式 | 说明 |
|:---:|:---:|:---:|
| 🐛 **Bug报告** | [Issues](https://github.com/your-repo/issues) | 提交bug和功能请求 |
| 💬 **讨论交流** | [Discussions](https://github.com/your-repo/discussions) | 技术讨论和经验分享 |
| 📖 **文档更新** | [Wiki](https://github.com/your-repo/wiki) | 查看详细文档 |
| ⭐ **项目支持** | [Star项目](https://github.com/your-repo) | 给项目点个星支持我们 |

</div>

---

<div align="center">

### 🎉 感谢使用

**墙洞API Telegram Bot部署系统**

*让API管理变得简单而强大*

[![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red.svg?style=for-the-badge)](https://github.com/your-repo)
[![Powered by Node.js](https://img.shields.io/badge/Powered%20by-Node.js-green.svg?style=for-the-badge)](https://nodejs.org)

---

**⚡ 快速、🛡️ 安全、🎯 可靠**

</div>