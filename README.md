# 🚀 DlerBot - 墙洞API Telegram Bot 部署系统

<div align="center">

![Version](https://img.shields.io/badge/version-v1.0.5-brightgreen) 
![Platform](https://img.shields.io/badge/platform-Linux-blue)
![Node](https://img.shields.io/badge/node-%3E%3D16-green)
![License](https://img.shields.io/badge/license-MIT-orange)

### ✨ 一键部署 · 全功能管理 · 安全可靠 ✨

</div>

---

## 🎯 项目概述

> 🎉 **欢迎使用墙洞API Telegram Bot完整部署系统！**  
> 这是一个功能完整的Telegram Bot自动化部署脚本项目，专为墙洞API服务设计。  
> 提供从安装、配置到管理的全流程自动化解决方案。

<div align="center">

```
   ╭─────────────────────────────────────────────╮
   │  🤖 智能部署  •  📱 Telegram集成  •  🔐 安全加密  │
   ╰─────────────────────────────────────────────╯
```

</div>

---

## ✨ 主要特性

<table>
<tr>
<td width="50%">

### 🔧 **部署管理**
- 🎯 **一键安装** - 自动检测系统并安装依赖
- 🔄 **多种启动方式** - PM2/SystemD/Screen支持
- 🔧 **完整管理** - 启动/停止/重启/卸载
- 📊 **状态监控** - 实时系统状态检查
- 🧪 **测试模式** - 完整功能验证

</td>
<td width="50%">

### 🤖 **Bot功能**
- 👤 **账户管理** - 登录/注销/多账号切换
- 🔐 **密码加密** - AES-256-CBC安全存储
- 📱 **订阅管理** - 多协议订阅链接获取
- 🌐 **节点查看** - 实时节点状态查询
- 🔄 **转发规则** - 灵活的规则配置

</td>
</tr>
</table>

### 🌈 核心功能亮点

| 功能模块 | 描述 | 状态 |
|---------|------|------|
| 🔄 **多种启动方式** | PM2、SystemD、Screen等 | ![Available](https://img.shields.io/badge/-Available-success) |
| 📱 **丰富Bot功能** | 登录管理、转发规则、状态查询 | ![Available](https://img.shields.io/badge/-Available-success) |
| 🔐 **密码加密** | AES-256-CBC加密存储 | ![Available](https://img.shields.io/badge/-Available-success) |
| 🎨 **彩色日志** | 美观的日志输出界面 | ![Available](https://img.shields.io/badge/-Available-success) |
| 🔧 **故障恢复** | 自动重启和故障处理 | ![Available](https://img.shields.io/badge/-Available-success) |
| 📊 **状态监控** | 系统健康检查和API监控 | ![Available](https://img.shields.io/badge/-Available-success) |

---

## 🚀 快速开始

### 📋 系统要求

<div align="center">

| 组件 | 要求 | 状态 |
|------|------|------|
| ![OS](https://img.shields.io/badge/🖥️-系统-blue) | Ubuntu/Debian/CentOS | ![Required](https://img.shields.io/badge/-必需-red) |
| ![Node](https://img.shields.io/badge/⚡-Node.js-green) | v16.0+ (自动安装) | ![Auto](https://img.shields.io/badge/-自动-brightgreen) |
| ![Space](https://img.shields.io/badge/💾-磁盘-orange) | 100MB+ 可用空间 | ![Required](https://img.shields.io/badge/-必需-red) |
| ![Network](https://img.shields.io/badge/🌐-网络-purple) | 互联网连接 | ![Required](https://img.shields.io/badge/-必需-red) |

</div>

### ⚡ 一键部署

```bash
# 下载并运行部署脚本
wget -O dler.sh https://your-domain.com/dler.sh
chmod +x dler.sh
./dler.sh
```

### 🎛️ 启动方式选择

<div align="center">

<table>
<tr>
<th width="20%">选项</th>
<th width="30%">方式</th>
<th width="25%">特点</th>
<th width="25%">推荐度</th>
</tr>
<tr>
<td>1️⃣</td>
<td><strong>PM2进程管理</strong></td>
<td>生产级管理，自动重启</td>
<td>![Excellent](https://img.shields.io/badge/-优秀-brightgreen)</td>
</tr>
<tr>
<td>2️⃣</td>
<td><strong>SystemD服务</strong></td>
<td>系统级服务，开机启动</td>
<td>![Excellent](https://img.shields.io/badge/-优秀-brightgreen)</td>
</tr>
<tr>
<td>3️⃣</td>
<td><strong>Screen后台运行</strong></td>
<td>后台运行，简单易用</td>
<td>![Good](https://img.shields.io/badge/-良好-green)</td>
</tr>
<tr>
<td>4️⃣</td>
<td><strong>Node.js直接运行</strong></td>
<td>直接运行，不推荐生产</td>
<td>![Basic](https://img.shields.io/badge/-基础-yellow)</td>
</tr>
<tr>
<td>5️⃣</td>
<td><strong>前台运行</strong></td>
<td>调试模式，用于测试</td>
<td>![Debug Only](https://img.shields.io/badge/-仅调试-orange)</td>
</tr>
<tr>
<td>6️⃣</td>
<td><strong>测试模式</strong></td>
<td>功能测试，验证配置</td>
<td>![Test Only](https://img.shields.io/badge/-仅测试-purple)</td>
</tr>
<tr>
<td>7️⃣</td>
<td><strong>快速启动</strong></td>
<td>一键启动，便捷操作</td>
<td>![Quick](https://img.shields.io/badge/-快速-lightblue)</td>
</tr>
</table>

</div>

---

## 🤖 Telegram Bot 功能指南

<div align="center">

### 📱 **功能全览图**

```
                    🤖 DlerBot 功能架构
                    ═══════════════════════
                           │
                    ┌──────┴──────┐
                    │   核心功能   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼───┐          ┌───▼───┐          ┌───▼───┐
    │账户管理│          │订阅服务│          │系统管理│
    └───┬───┘          └───┬───┘          └───┬───┘
        │                  │                  │
    ┌───▼───┐          ┌───▼───┐          ┌───▼───┐
    │转发规则│          │节点查看│          │状态监控│
    └───────┘          └───────┘          └───────┘
```

</div>

#### 🎯 基础命令
<div align="center">

| 命令 | 功能 | 示例 |
|------|------|------|
| ![start](https://img.shields.io/badge/🚀-/start-brightgreen) | 启动机器人并查看欢迎信息 | `/start` |
| ![help](https://img.shields.io/badge/❓-/help-blue) | 显示帮助信息和命令列表 | `/help` |
| ![status](https://img.shields.io/badge/📊-/status-purple) | 查看系统运行状态 | `/status` |
| ![ping](https://img.shields.io/badge/🏓-/ping-lightgreen) | 测试机器人响应速度 | `/ping` |

</div>

#### 👤 账户管理
<div align="center">

| 命令 | 功能 | 示例 |
|------|------|------|
| ![login](https://img.shields.io/badge/🔑-/login-success) | 登录墙洞账户 | `/login` |
| ![logout](https://img.shields.io/badge/🚪-/logout-red) | 登出并删除Token | `/logout` |
| ![accounts](https://img.shields.io/badge/👥-/accounts-blue) | 查看所有已保存账号 | `/accounts` |
| ![switch](https://img.shields.io/badge/🔄-/switch-orange) | 切换当前使用账号 | `/switch` |
| ![current](https://img.shields.io/badge/📍-/current-green) | 查看当前账号信息 | `/current` |
| ![info](https://img.shields.io/badge/ℹ️-/info-purple) | 查看账户详细信息 | `/info` |
| ![checkin](https://img.shields.io/badge/🎲-/checkin-yellow) | 执行每日签到 | `/checkin` |

</div>

#### 📱 订阅与节点
<div align="center">

| 命令 | 功能 | 示例 |
|------|------|------|
| ![sub](https://img.shields.io/badge/📱-/sub-brightgreen) | 获取订阅链接 | `/sub` |
| ![nodes](https://img.shields.io/badge/🌐-/nodes-blue) | 查看可用节点列表 | `/nodes` |

</div>

#### 🔄 转发规则管理
<div align="center">

| 命令 | 功能 | 示例 |
|------|------|------|
| ![getrules](https://img.shields.io/badge/📋-/getrules-blue) | 查看所有转发规则 | `/getrules` |
| ![addrule](https://img.shields.io/badge/➕-/addrule-green) | 添加新的转发规则 | `/addrule` |
| ![delrule](https://img.shields.io/badge/➖-/delrule-red) | 删除指定转发规则 | `/delrule` |

</div>

#### 🔧 系统管理
<div align="center">

| 命令 | 功能 | 示例 |
|------|------|------|
| ![ping](https://img.shields.io/badge/🏓-/ping-lightgreen) | 测试机器人响应 | `/ping` |
| ![info](https://img.shields.io/badge/ℹ️-/info-purple) | 查看机器人详细信息 | `/info` |
| ![creds](https://img.shields.io/badge/🔑-/creds-orange) | 密码管理和凭据状态 | `/creds` |
| ![tokenstats](https://img.shields.io/badge/📊-/tokenstats-cyan) | Token使用统计 | `/tokenstats` |

</div>

---

## 🧪 测试功能

### 🔍 健康检查

<details>
<summary>📊 <strong>系统状态监控</strong></summary>

```bash
# 实时系统状态
- CPU使用率监控
- 内存占用检查  
- 网络连接测试
- API响应时间
- 用户会话统计
- 功能模块状态
```

</details>

### 🎯 功能测试

<div align="center">

| 测试项目 | 描述 | 检查内容 |
|----------|------|----------|
| ![Network](https://img.shields.io/badge/🌐-网络测试-blue) | 网络连接检查 | 延迟、稳定性、DNS |
| ![API](https://img.shields.io/badge/🔗-API测试-green) | 墙洞API连通性 | 响应时间、状态码 |
| ![Bot](https://img.shields.io/badge/🤖-Bot测试-purple) | Telegram Bot功能 | 命令响应、消息发送 |
| ![Auth](https://img.shields.io/badge/🔐-认证测试-orange) | 登录认证机制 | Token有效性、刷新 |

</div>

---

## 🔒 安全特性

<div align="center">

| 安全特性 | 描述 | 状态 |
|----------|------|------|
| ![Encrypt](https://img.shields.io/badge/🔐-AES256加密-success) | 使用AES-256-CBC加密存储 | ![Active](https://img.shields.io/badge/-启用-brightgreen) |
| ![Refresh](https://img.shields.io/badge/🔄-自动刷新-blue) | Token自动刷新机制 | ![Active](https://img.shields.io/badge/-启用-brightgreen) |
| ![Validation](https://img.shields.io/badge/✅-输入验证-purple) | 严格的参数验证 | ![Active](https://img.shields.io/badge/-启用-brightgreen) |
| ![Isolation](https://img.shields.io/badge/🛡️-权限隔离-orange) | 管理员权限控制 | ![Active](https://img.shields.io/badge/-启用-brightgreen) |

</div>

### 🔐 密码管理说明

```
🔒 加密存储流程：
┌─────────┐    ┌─────────┐    ┌─────────┐
│ 用户密码 │ → │AES加密 │ → │本地存储 │
└─────────┘    └─────────┘    └─────────┘
      ↓              ↓              ↓
   明文输入      256位加密      安全保存
```

---

## 🎯 核心功能特性

<div align="center">

| 功能模块 | 状态 | 描述 |
|----------|------|------|
| ![Account](https://img.shields.io/badge/👤-账户管理-success) | ✅ | 完整的账户管理系统 |
| ![Rules](https://img.shields.io/badge/🔄-转发规则-blue) | ✅ | 转发规则管理 (添加/查看/删除) |
| ![Subscribe](https://img.shields.io/badge/📱-订阅获取-green) | ✅ | 多协议订阅链接获取 |
| ![Nodes](https://img.shields.io/badge/🌐-节点查看-purple) | ✅ | 实时节点状态查询 |
| ![Monitor](https://img.shields.io/badge/📊-状态监控-orange) | ✅ | 系统健康检查和监控 |
| ![Security](https://img.shields.io/badge/🔐-安全认证-red) | ✅ | AES加密和Token管理 |

</div>

---

## 📁 项目结构

```
dler-cloud-bot/
├── 📄 bot.js                 # 主程序文件
├── 📦 package.json           # 项目配置
├── 🔧 ecosystem.config.js    # PM2配置
├── 🛠️ quick-start.sh         # 快速启动脚本
├── 📊 status.sh              # 状态检查脚本
├── 🧪 test.sh                # 功能测试脚本
├── 🗑️ uninstall.sh           # 卸载脚本
├── 📂 config/                # 配置目录
│   └── 🔐 tokens.json        # 加密Token存储
└── 📂 logs/                  # 日志目录
    ├── 📄 bot.log            # 运行日志
    ├── 📄 error.log          # 错误日志
    └── 📄 pm2.log            # PM2日志
```

---

## 🔧 管理命令

<div align="center">

### 📋 **快速管理面板**

</div>

```bash
# 🚀 启动相关
./quick-start.sh              # 一键后台启动
pm2 start ecosystem.config.js # PM2启动
systemctl start dlerbot       # SystemD启动

# 📊 状态检查
./status.sh                   # 全面状态检查
pm2 status                    # PM2状态
pm2 logs dler-cloud-bot       # 查看日志

# 🔄 管理操作
pm2 restart dler-cloud-bot    # 重启服务
pm2 stop dler-cloud-bot       # 停止服务
pm2 delete dler-cloud-bot     # 删除服务

# 🧪 测试功能
./test.sh                     # 功能测试
node bot.js                   # 前台调试

# 🗑️ 卸载清理
./uninstall.sh                # 完整卸载
```

---

## 🆕 版本更新

<div align="center">

### 🚀 **v1.0.5 - 最终修复版**

</div>

| 更新类型 | 内容 | 状态 |
|----------|------|------|
| ![New](https://img.shields.io/badge/🆕-新功能-brightgreen) | 系统状态监控功能 | ✅ 已完成 |
| ![New](https://img.shields.io/badge/🆕-新功能-brightgreen) | 网络和API健康检查 | ✅ 已完成 |
| ![New](https://img.shields.io/badge/🆕-新功能-brightgreen) | 测试模式和状态检查脚本 | ✅ 已完成 |
| ![Fix](https://img.shields.io/badge/🔧-修复-blue) | API参数格式问题 | ✅ 已修复 |
| ![Improve](https://img.shields.io/badge/📱-改进-purple) | 用户界面和交互体验 | ✅ 已优化 |
| ![Enhance](https://img.shields.io/badge/🛠️-增强-orange) | 管理工具和错误处理 | ✅ 已完善 |

---

## 🤝 贡献与支持

<div align="center">

### 💡 **参与贡献**

![Issues](https://img.shields.io/badge/Issues-Welcome-brightgreen)
![PRs](https://img.shields.io/badge/PRs-Welcome-blue)
![Forks](https://img.shields.io/badge/Forks-Encouraged-purple)

</div>

```bash
# 🔍 问题反馈
# 在GitHub Issues中报告Bug或建议

# 🔀 代码贡献  
# Fork项目并提交Pull Request

# 📖 文档改进
# 帮助完善文档和使用指南
```

---

## 📞 联系方式

<div align="center">

![Author](https://img.shields.io/badge/👨‍💻-Dler%20Bot%20Team-blue)
![Version](https://img.shields.io/badge/📌-v1.0.5-brightgreen)
![Update](https://img.shields.io/badge/📅-2024--Latest-orange)

</div>

<div align="center">

### ⭐ **如果这个项目对你有帮助，请给个Star！** ⭐

```
      🎉 感谢使用 DlerBot 部署系统！ 🎉
   ═══════════════════════════════════════════
        让Telegram Bot管理变得简单高效！
```

</div>

---

<div align="center">

![Footer](https://img.shields.io/badge/Made%20with-❤️-red)
![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
![Telegram](https://img.shields.io/badge/Telegram-26A5E4?logo=telegram&logoColor=white)

**DlerBot © 2024 - 让API管理更简单**

</div>