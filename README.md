📋 项目简介

这是一个功能完整的Telegram机器人，专门用于管理墙洞云服务账户。通过简单的命令即可完成账户登录、流量查询、节点管理、转发规则配置等操作，支持多种部署方式和完善的监控功能。

✨ 功能特性

🔐 账户管理 

登录/注销 - 安全的账户认证

账户信息 - 查看套餐、流量、余额

每日签到 - 自动获取流量奖励


📱 订阅管理

多协议支持 - Smart/SS/VMess/Trojan/SS2022

一键获取 - 快速获取所有订阅链接

配置文件 - 自动生成配置名称


🌐 节点管理

节点列表 - 查看所有可用节点

状态显示 - 实时显示节点配置状态

详细信息 - 节点ID、名称、主机、端口


🔄 转发规则

添加规则 - 支持IP/域名转发配置

查看规则 - 列出所有转发规则详情

删除规则 - 灵活管理转发配置

协议一致 - 支持协议一致性设置


📊 系统监控

状态检查 - 网络、API、机器人健康监控

性能指标 - 内存使用、运行时间统计

延迟测试 - 网络和API响应时间

错误处理 - 完善的异常处理机制


🛠️ 部署管理

多种启动方式 - PM2/nohup/screen/systemd

状态监控 - 实时查看运行状态

日志管理 - 详细的日志记录

一键卸载 - 完整清理所有组件


🚀 快速开始

系统要求

操作系统: Ubuntu/Debian/CentOS/RHEL

Node.js: >= 16.0.0 (脚本自动安装)

内存: >= 200MB

磁盘: >= 100MB

一键部署

# 方式1: 直接运行
```bash
curl -fsSL https://raw.githubusercontent.com/laobanbiefangcu/DlerCloudBot/main/dlerbot.sh | bash
```


# 方式2: 下载后运行
```bash
wget https://raw.githubusercontent.com/laobanbiefangcu/DlerCloudBot/main/dlerbot.sh
chmod +x dlerbot.sh
./dlerbot.sh
```

配置机器人

1.创建Telegram机器人

在Telegram中搜索 @BotFather

发送 /newbot 创建新机器人

设置机器人名称和用户名

复制获得的Token

2.获取用户ID

在Telegram中搜索 @userinfobot

发送任意消息获取你的用户ID

3.配置环境变量

```bash
nano .env
```
```bash
# Telegram Bot Token
BOT_TOKEN=your_bot_token_here

# 管理员用户ID
ADMIN_USER_ID=your_user_id_here
```

启动机器人
```bash
# 推荐：PM2后台启动
./quick-start.sh

# 或选择其他启动方式
./start.sh
```

📊 监控和日志

```bash
# 检查系统状态
./status.sh

# PM2状态
pm2 status

# 系统服务状态
sudo systemctl status dler-bot
```

查看日志
```bash
# PM2日志
pm2 logs dler-bot

# 系统日志
sudo journalctl -u dler-bot -f

# 文件日志
tail -f logs/combined.log
```

重新部署
```bash
# 停止服务
./stop.sh

# 重新运行部署脚本
./dler.sh

# 或完全重新开始
./uninstall.sh
curl -fsSL https://raw.githubusercontent.com/laobanbiefangcu/DlerCloudBot/main/dlerbot.sh | bash
```
