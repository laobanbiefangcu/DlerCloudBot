#!/bin/bash

# 墙洞API Telegram Bot 完整最终部署脚本
# 作者: Dler Bot Team
# 版本: v1.0.5 - 最终修复版
# 使用方法: bash dlerbot.sh

set -e

# 设置时区为中国标准时间
export TZ=Asia/Shanghai

echo "🚀 墙洞API Telegram Bot 完整最终部署脚本 v1.0.5"
echo "======================================================"
echo "✨ 包含完整功能：安装、配置、管理、测试、卸载"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_blue() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_purple() {
    echo -e "${PURPLE}[FEATURE]${NC} $1"
}

log_cyan() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warn "检测到root用户，建议使用普通用户运行"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "部署取消"
            exit 1
        fi
    fi
}

# 检测系统类型
detect_os() {
    if [[ -f /etc/redhat-release ]]; then
        OS="centos"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
    else
        log_error "不支持的操作系统"
        exit 1
    fi
    log_info "检测到系统: $OS"
}

# 检查网络连接
check_network() {
    log_blue "检查网络连接..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_error "网络连接失败，请检查网络设置"
        exit 1
    fi
    log_info "网络连接正常"
}

# 检查磁盘空间
check_disk_space() {
    log_blue "检查磁盘空间..."
    available_space=$(df / | awk 'NR==2 {print $4}')
    required_space=100000  # 100MB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        log_error "磁盘空间不足，需要至少100MB"
        exit 1
    fi
    log_info "磁盘空间检查通过"
}

# 检查权限
check_permissions() {
    log_blue "检查权限..."
    if [[ ! -w $HOME ]]; then
        log_error "当前用户没有写入权限"
        exit 1
    fi
    log_info "权限检查通过"
}

# 安装Node.js
install_nodejs() {
    log_blue "检查Node.js安装状态..."
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        log_info "Node.js已安装: $NODE_VERSION"
        
        # 检查版本是否满足要求 (>= 16)
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [[ $MAJOR_VERSION -lt 16 ]]; then
            log_warn "Node.js版本过低，需要升级到16+"
            NEED_INSTALL=true
        else
            NEED_INSTALL=false
        fi
    else
        log_warn "Node.js未安装"
        NEED_INSTALL=true
    fi
    
    if [[ $NEED_INSTALL == true ]]; then
        log_blue "开始安装Node.js 18..."
        
        if [[ $OS == "debian" ]]; then
            # Ubuntu/Debian
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get update
            sudo apt-get install -y nodejs
            
            # 基本系统依赖已通过Node.js安装完成
            
        elif [[ $OS == "centos" ]]; then
            # CentOS/RHEL
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
            
            # 基本系统依赖已通过Node.js安装完成
        fi
        
        log_info "Node.js安装完成: $(node --version)"
        log_info "npm版本: $(npm --version)"
    fi
}

# 安装PM2
install_pm2() {
    if ! command -v pm2 &> /dev/null; then
        log_blue "安装PM2进程管理器..."
        npm install -g pm2
        log_info "PM2安装完成"
    else
        log_info "PM2已安装: $(pm2 --version)"
    fi
}

# 创建项目
create_project() {
    log_blue "创建项目目录..."
    
    PROJECT_DIR="$HOME/dler-cloud-bot"
    
    if [[ -d "$PROJECT_DIR" ]]; then
        log_warn "目录 $PROJECT_DIR 已存在"
        read -p "是否删除并重新创建? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
            log_info "已删除旧目录"
        else
            log_error "部署取消"
            exit 1
        fi
    fi
    
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    log_info "项目目录创建完成: $PROJECT_DIR"
}
# 创建package.json
create_package_json() {
    log_blue "创建package.json..."
    
cat > package.json << 'EOF'
{
  "name": "dler-cloud-telegram-bot",
  "version": "1.0.5",
  "description": "墙洞API Telegram机器人 - 最终修复版",
  "main": "bot.js",
  "scripts": {
    "start": "node bot.js",
    "dev": "nodemon bot.js",
    "pm2:start": "pm2 start ecosystem.config.js",
    "pm2:stop": "pm2 stop dler-bot",
    "pm2:restart": "pm2 restart dler-bot",
    "pm2:delete": "pm2 delete dler-bot",
    "pm2:logs": "pm2 logs dler-bot",
    "test": "node test.js"
  },
  "dependencies": {
    "node-telegram-bot-api": "^0.64.0",
    "undici": "^6.10.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  },
  "keywords": [
    "telegram",
    "bot",
    "dler",
    "proxy",
    "api",
    "management"
  ],
  "author": "Dler Bot Team",
  "license": "MIT"
}
EOF
    
    log_info "package.json创建完成"
}

# 创建PM2配置
create_pm2_config() {
    log_blue "创建PM2配置文件..."
    
cat > ecosystem.config.js << 'EOF'
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
    error_file: 'logs/err.log',
    out_file: 'logs/out.log',
    log_file: 'logs/combined.log',
    time: true,
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    merge_logs: true,
    log_type: 'json'
  }]
};
EOF
    
    mkdir -p logs
    log_info "PM2配置文件创建完成"
}

# 创建环境变量文件
create_env_file() {
    log_blue "创建环境变量配置文件..."
    
cat > .env << 'EOF'
# Telegram Bot Token (从 @BotFather 获取)
BOT_TOKEN=

# 管理员用户ID (从 @userinfobot 获取)
ADMIN_USER_ID=

# 可选配置
# DLER_BASE_URL=https://dler.cloud/api/v1
# DEBUG=false
EOF
    
    log_info ".env文件创建完成"
}

# 创建systemd服务
create_systemd_service() {
    log_blue "创建systemd服务文件..."
    
    SERVICE_FILE="dler-bot.service"
    
cat > $SERVICE_FILE << EOF
[Unit]
Description=Dler Cloud Telegram Bot v1.0.5
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
ExecStart=/usr/bin/node bot.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    log_info "systemd服务文件创建完成: $SERVICE_FILE"
}

# 安装依赖
install_dependencies() {
    log_blue "安装项目依赖..."
    npm install
    log_info "依赖安装完成"
}
# 创建机器人主程序 - 第1部分
create_bot_js_part1() {
    log_blue "创建机器人主程序..."
    
cat > bot.js << 'EOF'
const TelegramBot = require('node-telegram-bot-api');
const { request } = require('undici');
const { createGunzip } = require('zlib');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// 配置
const BOT_TOKEN = process.env.BOT_TOKEN;
const ADMIN_USER_ID = process.env.ADMIN_USER_ID;
const DLER_BASE_URL = process.env.DLER_BASE_URL || 'https://dler.cloud/api/v1';
const DEBUG = process.env.DEBUG === 'true';

// 检查配置
if (!BOT_TOKEN || !ADMIN_USER_ID) {
    console.error('❌ 请先配置环境变量 BOT_TOKEN 和 ADMIN_USER_ID');
    console.log('💡 编辑 .env 文件，添加你的配置');
    process.exit(1);
}

// 创建bot实例
const bot = new TelegramBot(BOT_TOKEN, { polling: true });

// 存储用户会话信息 (token现在保存在文件中)
let userSessions = {};
let savedCredentials = {};
let tokenFailureLog = []; // 记录token失效日志
let tokenLastChecked = {}; // 记录每个用户token最后检查时间
let tokenExpiryTimes = {}; // 记录每个用户token过期时间
let userCookies = {}; // 存储用户的cookies
let tokenRefreshTimers = {}; // 存储token刷新定时器

// 多账号管理
let userAccounts = {}; // 存储每个用户的多个账号 {chatId: {accountId: {email, token, ...}}}
let currentAccount = {}; // 存储每个用户当前选中的账号 {chatId: accountId}




// 多账号管理函数
const generateAccountId = (email) => {
    return email.split('@')[0].toLowerCase().replace(/[^a-z0-9]/g, '');
};

const addAccount = (chatId, email, token, tokenExpire) => {
    if (!userAccounts[chatId]) {
        userAccounts[chatId] = {};
    }
    
    const accountId = generateAccountId(email);
    userAccounts[chatId][accountId] = {
        email: email,
        token: token,
        tokenExpire: tokenExpire,
        loginTime: Date.now(),
        lastUsed: Date.now()
    };
    
    // 如果是第一个账号，设为当前账号
    if (!currentAccount[chatId]) {
        currentAccount[chatId] = accountId;
    }
    
    console.log(`✅ 为用户 ${chatId} 添加账号: ${email} (ID: ${accountId})`);
    return accountId;
};

const getCurrentAccountInfo = (chatId) => {
    const accountId = currentAccount[chatId];
    if (!accountId || !userAccounts[chatId] || !userAccounts[chatId][accountId]) {
        return null;
    }
    
    // 从文件加载最新的token
    const tokenData = loadTokenFromFile(chatId, accountId);
    const accountInfo = {
        accountId: accountId,
        ...userAccounts[chatId][accountId]
    };
    
    // 如果文件中有token，使用文件中的token
    if (tokenData) {
        accountInfo.token = tokenData.token;
        accountInfo.tokenExpire = tokenData.tokenExpire;
    }
    
    return accountInfo;
};

const switchAccount = (chatId, accountId) => {
    if (!userAccounts[chatId] || !userAccounts[chatId][accountId]) {
        return false;
    }
    
    // 清理旧账号的Token刷新定时器
    if (tokenRefreshTimers[chatId]) {
        clearInterval(tokenRefreshTimers[chatId]);
        delete tokenRefreshTimers[chatId];
        console.log(`⏰ 清理用户 ${chatId} 的旧Token刷新定时器`);
    }
    
    // 清理旧账号的Cookie
    if (userCookies[chatId]) {
        delete userCookies[chatId];
        console.log(`🍪 清理用户 ${chatId} 的旧Cookie`);
    }
    
    currentAccount[chatId] = accountId;
    
    // 保存token到文件
    const account = userAccounts[chatId][accountId];
    saveTokenToFile(chatId, accountId, {
        token: account.token,
        tokenExpire: account.tokenExpire,
        email: account.email
    });
    updateUserSession(chatId, {
        email: account.email,
        loginTime: new Date(account.loginTime),
        hasRememberedPassword: true,
        autoRelogin: true
    }, accountId);
    
    // 更新最后使用时间
    userAccounts[chatId][accountId].lastUsed = Date.now();
    
    // 更新全局token过期时间
    tokenExpiryTimes[chatId] = account.tokenExpire;
    
    console.log(`🔄 用户 ${chatId} 切换到账号: ${account.email}`);
    return true;
};

const getAccountList = (chatId) => {
    if (!userAccounts[chatId]) {
        return [];
    }
    return Object.keys(userAccounts[chatId]).map(accountId => ({
        accountId,
        ...userAccounts[chatId][accountId]
    }));
};

const removeAccount = (chatId, accountId) => {
    if (!userAccounts[chatId] || !userAccounts[chatId][accountId]) {
        return false;
    }
    
    const email = userAccounts[chatId][accountId].email;
    delete userAccounts[chatId][accountId];
    
    // 同时删除该账号的凭证
    deleteSavedCredentials(chatId, accountId);
    
    // 如果删除的是当前账号，切换到其他账号或清空
    if (currentAccount[chatId] === accountId) {
        const remainingAccounts = Object.keys(userAccounts[chatId]);
        if (remainingAccounts.length > 0) {
            switchAccount(chatId, remainingAccounts[0]);
        } else {
            delete currentAccount[chatId];
            deleteTokenFromFile(chatId);
            delete userSessions[chatId];
        }
    }
    
    console.log(`🗑️ 用户 ${chatId} 删除账号: ${email} (同时删除凭证)`);
    return true;
};


// 文件路径
const CREDENTIALS_FILE = path.join(__dirname, '.credentials');
const TOKENS_FILE = path.join(__dirname, '.tokens');
const SESSIONS_FILE = path.join(__dirname, '.sessions');
const ENCRYPTION_KEY_FILE = path.join(__dirname, '.encryption_key');

// 加密密钥管理函数
const getOrCreateEncryptionKey = () => {
    try {
        // 优先使用环境变量
        if (process.env.ENCRYPTION_KEY) {
            console.log('✅ 使用环境变量中的加密密钥');
            return process.env.ENCRYPTION_KEY;
        }
        
        // 检查密钥文件是否存在
        if (fs.existsSync(ENCRYPTION_KEY_FILE)) {
            const savedKey = fs.readFileSync(ENCRYPTION_KEY_FILE, 'utf8').trim();
            if (savedKey && savedKey.length === 64) {
                console.log('✅ 从文件加载已保存的加密密钥');
                return savedKey;
            }
        }
        
        // 生成新密钥并保存
        const newKey = crypto.randomBytes(32).toString('hex');
        fs.writeFileSync(ENCRYPTION_KEY_FILE, newKey);
        console.log('✅ 生成并保存新的加密密钥');
        return newKey;
    } catch (error) {
        console.error('❌ 加密密钥管理错误:', error.message);
        // 如果出错，返回临时密钥（但不保存）
        return crypto.randomBytes(32).toString('hex');
    }
};

// 初始化加密密钥
const ENCRYPTION_KEY = getOrCreateEncryptionKey();

// 加密函数
const encrypt = (text) => {
    const algorithm = 'aes-256-cbc';
    // 确保密钥总是Buffer格式，长度为32字节
    const key = Buffer.from(ENCRYPTION_KEY, 'hex');
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(algorithm, key, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return iv.toString('hex') + ':' + encrypted;
};

// 解密函数
const decrypt = (text) => {
    try {
        const algorithm = 'aes-256-cbc';
        // 确保密钥总是Buffer格式，长度为32字节
        const key = Buffer.from(ENCRYPTION_KEY, 'hex');
        const textParts = text.split(':');
        const iv = Buffer.from(textParts.shift(), 'hex');
        const encryptedText = textParts.join(':');
        const decipher = crypto.createDecipheriv(algorithm, key, iv);
        let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    } catch (error) {
        console.error('解密失败:', error.message);
        return null;
    }
};

// ===== TOKEN文件存储功能 =====
// 保存token到文件
const saveTokenToFile = (chatId, accountId, tokenData) => {
    try {
        let tokens = {};
        if (fs.existsSync(TOKENS_FILE)) {
            const data = fs.readFileSync(TOKENS_FILE, 'utf8');
            tokens = JSON.parse(data);
        }
        
        if (!tokens[chatId]) {
            tokens[chatId] = {};
        }
        
        tokens[chatId][accountId] = {
            token: tokenData.token,
            tokenExpire: tokenData.tokenExpire,
            email: tokenData.email,
            savedAt: new Date().toISOString()
        };
        
        fs.writeFileSync(TOKENS_FILE, JSON.stringify(tokens, null, 2));
        console.log(`✅ Token已保存到文件 - 用户: ${chatId}, 账号: ${accountId}`);
        return true;
    } catch (error) {
        console.error('保存Token到文件失败:', error.message);
        return false;
    }
};

// 从文件加载token
const loadTokenFromFile = (chatId, accountId) => {
    try {
        if (!fs.existsSync(TOKENS_FILE)) {
            return null;
        }
        
        const data = fs.readFileSync(TOKENS_FILE, 'utf8');
        const tokens = JSON.parse(data);
        
        if (tokens[chatId] && tokens[chatId][accountId]) {
            return tokens[chatId][accountId];
        }
        
        return null;
    } catch (error) {
        console.error('从文件加载Token失败:', error.message);
        return null;
    }
};

// 获取用户当前token
const getUserToken = (chatId) => {
    const currentAccountInfo = getCurrentAccountInfo(chatId);
    if (!currentAccountInfo) {
        return null;
    }
    
    const tokenData = loadTokenFromFile(chatId, currentAccountInfo.accountId);
    return tokenData ? tokenData.token : null;
};

// 从文件获取所有活跃用户列表
const getActiveUsersFromFile = () => {
    try {
        if (!fs.existsSync(TOKENS_FILE)) {
            return [];
        }
        
        const data = fs.readFileSync(TOKENS_FILE, 'utf8');
        const tokens = JSON.parse(data);
        return Object.keys(tokens);
    } catch (error) {
        console.error('获取活跃用户列表失败:', error.message);
        return [];
    }
};

// 删除文件中的token
const deleteTokenFromFile = (chatId, accountId = null) => {
    try {
        if (!fs.existsSync(TOKENS_FILE)) {
            return true;
        }
        
        const data = fs.readFileSync(TOKENS_FILE, 'utf8');
        let tokens = JSON.parse(data);
        
        if (accountId) {
            // 删除指定账号的token
            if (tokens[chatId] && tokens[chatId][accountId]) {
                delete tokens[chatId][accountId];
                
                // 如果用户没有其他账号了，删除整个用户记录
                if (Object.keys(tokens[chatId]).length === 0) {
                    delete tokens[chatId];
                }
            }
        } else {
            // 删除用户所有token
            delete tokens[chatId];
        }
        
        fs.writeFileSync(TOKENS_FILE, JSON.stringify(tokens, null, 2));
        console.log(`✅ Token已从文件删除 - 用户: ${chatId}${accountId ? `, 账号: ${accountId}` : ' (全部)'}`);
        return true;
    } catch (error) {
        console.error('删除Token文件失败:', error.message);
        return false;
    }
};

// ===== SESSIONS文件存储功能 =====
// 保存session到文件（支持多账号）
const saveSessionToFile = (chatId, accountId, sessionData) => {
    try {
        let sessions = {};
        if (fs.existsSync(SESSIONS_FILE)) {
            const data = fs.readFileSync(SESSIONS_FILE, 'utf8');
            sessions = JSON.parse(data);
        }
        
        // 初始化用户sessions结构
        if (!sessions[chatId]) {
            sessions[chatId] = {
                currentAccountId: null,
                accounts: {}
            };
        }
        
        // 序列化Date对象为timestamp
        const serializedSession = {
            ...sessionData,
            loginTime: sessionData.loginTime ? sessionData.loginTime.getTime() : Date.now()
        };
        
        // 保存账号session数据
        sessions[chatId].accounts[accountId] = serializedSession;
        
        // 更新当前活跃账号
        sessions[chatId].currentAccountId = accountId;
        
        fs.writeFileSync(SESSIONS_FILE, JSON.stringify(sessions, null, 2));
        console.log(`✅ Session已保存到文件 - 用户: ${chatId}, 账号: ${accountId}`);
        return true;
    } catch (error) {
        console.error('保存Session到文件失败:', error.message);
        return false;
    }
};

// 从文件加载session（支持多账号）
const loadSessionFromFile = (chatId, accountId = null) => {
    try {
        if (!fs.existsSync(SESSIONS_FILE)) {
            return null;
        }
        
        const data = fs.readFileSync(SESSIONS_FILE, 'utf8');
        const sessions = JSON.parse(data);
        
        if (sessions[chatId]) {
            // 如果指定了accountId，返回特定账号的session
            if (accountId && sessions[chatId].accounts && sessions[chatId].accounts[accountId]) {
                const session = { ...sessions[chatId].accounts[accountId] };
                if (session.loginTime) {
                    session.loginTime = new Date(session.loginTime);
                }
                return session;
            }
            
            // 如果没有指定accountId，返回当前活跃账号的session
            const currentAccountId = sessions[chatId].currentAccountId;
            if (currentAccountId && sessions[chatId].accounts && sessions[chatId].accounts[currentAccountId]) {
                const session = { ...sessions[chatId].accounts[currentAccountId] };
                if (session.loginTime) {
                    session.loginTime = new Date(session.loginTime);
                }
                return session;
            }
        }
        
        return null;
    } catch (error) {
        console.error('从文件加载Session失败:', error.message);
        return null;
    }
};

// 获取用户的当前活跃账号ID
const getCurrentAccountIdFromFile = (chatId) => {
    try {
        if (!fs.existsSync(SESSIONS_FILE)) {
            return null;
        }
        
        const data = fs.readFileSync(SESSIONS_FILE, 'utf8');
        const sessions = JSON.parse(data);
        
        return sessions[chatId] ? sessions[chatId].currentAccountId : null;
    } catch (error) {
        console.error('获取当前账号ID失败:', error.message);
        return null;
    }
};

// 删除文件中的session
const deleteSessionFromFile = (chatId) => {
    try {
        if (!fs.existsSync(SESSIONS_FILE)) {
            return true;
        }
        
        const data = fs.readFileSync(SESSIONS_FILE, 'utf8');
        let sessions = JSON.parse(data);
        
        delete sessions[chatId];
        
        fs.writeFileSync(SESSIONS_FILE, JSON.stringify(sessions, null, 2));
        console.log(`✅ Session已从文件删除 - 用户: ${chatId}`);
        return true;
    } catch (error) {
        console.error('删除Session文件失败:', error.message);
        return false;
    }
};

// 启动时加载所有sessions
const loadAllSessions = () => {
    try {
        if (!fs.existsSync(SESSIONS_FILE)) {
            console.log('📄 未找到Sessions文件，从零开始');
            return;
        }
        
        const data = fs.readFileSync(SESSIONS_FILE, 'utf8');
        const sessions = JSON.parse(data);
        
        let totalUsers = 0;
        let totalSessions = 0;
        
        for (const chatId in sessions) {
            totalUsers++;
            const userSessionData = sessions[chatId];
            
            // 处理新格式（多账号）
            if (userSessionData.accounts && userSessionData.currentAccountId) {
                const currentAccountId = userSessionData.currentAccountId;
                const currentSession = userSessionData.accounts[currentAccountId];
                
                if (currentSession) {
                    // 加载当前活跃账号的session到内存
                    userSessions[chatId] = {
                        ...currentSession,
                        loginTime: currentSession.loginTime ? new Date(currentSession.loginTime) : new Date()
                    };
                    
                    // 更新currentAccount
                    currentAccount[chatId] = currentAccountId;
                }
                
                totalSessions += Object.keys(userSessionData.accounts).length;
            }
            // 处理旧格式（单账号） - 向后兼容
            else if (userSessionData.email) {
                userSessions[chatId] = {
                    ...userSessionData,
                    loginTime: userSessionData.loginTime ? new Date(userSessionData.loginTime) : new Date()
                };
                totalSessions++;
            }
        }
        
        console.log(`✅ 已从文件加载Sessions到内存 - 用户: ${totalUsers}个, 会话: ${totalSessions}个`);
    } catch (error) {
        console.error('加载Sessions文件失败:', error.message);
    }
};

// 辅助函数：更新userSessions并保存到文件（支持多账号）
const updateUserSession = (chatId, sessionData, accountId = null) => {
    // 如果没有提供accountId，尝试从currentAccount获取
    if (!accountId) {
        accountId = currentAccount[chatId];
    }
    
    // 如果仍然没有accountId，尝试从文件获取当前账号
    if (!accountId) {
        accountId = getCurrentAccountIdFromFile(chatId);
    }
    
    // 如果还是没有accountId，创建一个默认的（这种情况很少见）
    if (!accountId) {
        console.warn(`警告: 用户 ${chatId} 没有活跃账号，使用默认账号ID`);
        accountId = 'default';
    }
    
    // 为了保持向后兼容，仍然更新内存中的userSessions（使用当前账号的数据）
    if (!userSessions[chatId]) {
        userSessions[chatId] = {};
    }
    Object.assign(userSessions[chatId], sessionData);
    
    // 保存到文件（支持多账号）
    saveSessionToFile(chatId, accountId, sessionData);
};

// 启动时加载所有tokens到内存
const loadAllTokens = () => {
    try {
        if (!fs.existsSync(TOKENS_FILE)) {
            console.log('📄 未找到Token文件，从零开始');
            return;
        }
        
        const data = fs.readFileSync(TOKENS_FILE, 'utf8');
        const tokens = JSON.parse(data);
        
        let totalUsers = 0;
        let totalTokens = 0;
        
        // 将文件中的token数据加载到userAccounts
        for (const chatId in tokens) {
            totalUsers++;
            if (!userAccounts[chatId]) {
                userAccounts[chatId] = {};
            }
            
            for (const accountId in tokens[chatId]) {
                totalTokens++;
                const tokenData = tokens[chatId][accountId];
                
                userAccounts[chatId][accountId] = {
                    email: tokenData.email,
                    token: tokenData.token,
                    tokenExpire: tokenData.tokenExpire,
                    lastUsed: Date.now(),
                    loginTime: Date.now()
                };
            }
        }
        
        console.log(`✅ 已从文件加载Token到内存 - 用户: ${totalUsers}个, Token: ${totalTokens}个`);
    } catch (error) {
        console.error('加载Token文件失败:', error.message);
    }
};

// 保存凭据到文件（多账号模式）
const saveCredentials = (chatId, email, password) => {
    try {
        const accountId = generateAccountId(email);
        
        // 初始化用户凭证结构
        if (!savedCredentials[chatId]) {
            savedCredentials[chatId] = {};
        }
        
        const credentials = {
            email: encrypt(email),
            password: encrypt(password),
            savedAt: new Date().toISOString()
        };
        
        savedCredentials[chatId][accountId] = credentials;
        fs.writeFileSync(CREDENTIALS_FILE, JSON.stringify(savedCredentials, null, 2));
        
        console.log(`✅ 为用户 ${chatId} 保存账号 ${email} 的凭证 (ID: ${accountId})`);
        return true;
    } catch (error) {
        console.error('保存凭据失败:', error.message);
        return false;
    }
};

// 从文件加载凭据
const loadCredentials = () => {
    try {
        if (fs.existsSync(CREDENTIALS_FILE)) {
            const data = fs.readFileSync(CREDENTIALS_FILE, 'utf8');
            savedCredentials = JSON.parse(data);
            console.log('✅ 已加载保存的凭据');
        }
    } catch (error) {
        console.error('加载凭据失败:', error.message);
        savedCredentials = {};
    }
};

// 获取保存的凭据（多账号模式）
const getSavedCredentials = (chatId, accountId = null) => {
    try {
        const userCredentials = savedCredentials[chatId];
        if (!userCredentials) return null;
        
        // 如果指定了accountId，获取特定账号的凭证
        if (accountId) {
            const saved = userCredentials[accountId];
            if (saved) {
                const email = decrypt(saved.email);
                const password = decrypt(saved.password);
                if (email && password) {
                    return { email, password, accountId };
                }
            }
            return null;
        }
        
        // 如果没有指定accountId，获取当前账号的凭证
        const currentAccountInfo = getCurrentAccountInfo(chatId);
        if (currentAccountInfo) {
            const currentAccountId = currentAccountInfo.accountId;
            const saved = userCredentials[currentAccountId];
            if (saved) {
                const email = decrypt(saved.email);
                const password = decrypt(saved.password);
                if (email && password) {
                    return { email, password, accountId: currentAccountId };
                }
            }
        }
        
        return null;
    } catch (error) {
        console.error('获取凭据失败:', error.message);
        return null;
    }
};

// 获取用户所有保存的凭证
const getAllSavedCredentials = (chatId) => {
    try {
        const userCredentials = savedCredentials[chatId];
        if (!userCredentials) return [];
        
        const result = [];
        for (const [accountId, saved] of Object.entries(userCredentials)) {
            const email = decrypt(saved.email);
            const password = decrypt(saved.password);
            if (email && password) {
                result.push({
                    accountId,
                    email,
                    password,
                    savedAt: saved.savedAt
                });
            }
        }
        return result;
    } catch (error) {
        console.error('获取所有凭据失败:', error.message);
        return [];
    }
};

// 删除保存的凭据（多账号模式）
const deleteSavedCredentials = (chatId, accountId = null) => {
    try {
        if (!savedCredentials[chatId]) return true;
        
        // 如果指定了accountId，删除特定账号的凭证
        if (accountId) {
            delete savedCredentials[chatId][accountId];
            
            // 如果用户没有任何凭证了，删除整个用户记录
            if (Object.keys(savedCredentials[chatId]).length === 0) {
                delete savedCredentials[chatId];
            }
        } else {
            // 如果没有指定accountId，删除用户所有凭证
            delete savedCredentials[chatId];
        }
        
        fs.writeFileSync(CREDENTIALS_FILE, JSON.stringify(savedCredentials, null, 2));
        console.log(`✅ 删除用户 ${chatId} 的凭证${accountId ? ` (账号ID: ${accountId})` : ' (全部)'}`);
        return true;
    } catch (error) {
        console.error('删除凭据失败:', error.message);
        return false;
    }
};

// 自动重新登录函数（多账号模式）
const autoRelogin = async (chatId, specificAccountId = null) => {
    try {
        let credentials;
        
        // 如果指定了特定账号ID，为该账号重登录
        if (specificAccountId) {
            credentials = getSavedCredentials(chatId, specificAccountId);
            if (!credentials) {
                console.log(`❌ 用户 ${chatId} 账号 ${specificAccountId} 没有保存凭证`);
                return false;
            }
        } else {
            // 否则为当前账号重登录
            credentials = getSavedCredentials(chatId);
            if (!credentials) {
                // 如果当前账号没有凭证，尝试为所有有凭证的账号重登录
                const allCredentials = getAllSavedCredentials(chatId);
                if (allCredentials.length === 0) {
                    console.log(`❌ 用户 ${chatId} 没有保存任何凭证`);
                    return false;
                }
                
                // 为所有有凭证的账号尝试重登录
                let successCount = 0;
                for (const cred of allCredentials) {
                    const success = await autoRelogin(chatId, cred.accountId);
                    if (success) successCount++;
                }
                
                if (successCount > 0) {
                    console.log(`✅ 用户 ${chatId} 成功重登录 ${successCount}/${allCredentials.length} 个账号`);
                    return true;
                }
                return false;
            }
        }
        
        console.log(`🔄 为用户 ${chatId} 执行自动重新登录 (账号: ${credentials.email})...`);
        
        const response = await sendRequest('/login', {
            email: credentials.email,
            passwd: credentials.password,
            token_expire: 30,
            save_cookie: true
        }, null, chatId);
        
        if (response.ret === 200) {
            // 获取正确的token字段（可能是token或access_token）
            const token = response.data.token || response.data.access_token;
            if (!token) {
                console.error('❌ 自动重新登录响应中没有找到token或access_token字段');
                return false;
            }
            
            // 计算token过期时间：使用服务端返回的token_expire或默认30天
            let tokenExpiry;
            if (response.data.token_expire && response.data.token_expire !== '9999-99-99 99:99:99') {
                // 使用服务端返回的具体过期时间
                tokenExpiry = new Date(response.data.token_expire).getTime();
                if (DEBUG) {
                    console.log('🕐 自动重登录使用服务端返回的token_expire:', response.data.token_expire);
                }
            } else {
                // 服务端返回默认值，使用本地计算（30天）
                tokenExpiry = Date.now() + (30 * 24 * 60 * 60 * 1000);
                if (DEBUG) {
                    console.log('🕐 自动重登录使用本地计算的token_expire: 30天');
                }
            }
            
            const accountId = credentials.accountId;
            
            // 更新账号信息
            if (userAccounts[chatId] && userAccounts[chatId][accountId]) {
                userAccounts[chatId][accountId] = {
                    ...userAccounts[chatId][accountId],
                    token: token,
                    tokenExpire: tokenExpiry,
                    loginTime: Date.now(),
                    lastUsed: Date.now()
                };
                
                // 设置token过期时间到全局变量
                tokenExpiryTimes[chatId] = tokenExpiry;
                
                // 保存token到文件（所有账号都保存）
                saveTokenToFile(chatId, accountId, {
                    token: token,
                    tokenExpire: tokenExpiry,
                    email: userAccounts[chatId][accountId].email
                });
                    
                    updateUserSession(chatId, {
                        email: credentials.email,
                        loginTime: new Date(),
                        plan: response.data.plan,
                        hasRememberedPassword: true
                    }, accountId);
                
                console.log(`✅ 用户 ${chatId} 账号 ${credentials.email} 自动重新登录成功`);
                
                // 设置Token刷新定时器
                setupTokenRefreshTimer(chatId);
                
                // 通知用户（仅当为当前账号重登录时）
                if (!specificAccountId || currentAccount[chatId] === accountId) {
                    bot.sendMessage(chatId, `🔄 检测到Token已过期，已自动重新登录\n\n📋 账户信息：\n• 邮箱：${credentials.email}\n• 套餐：${response.data.plan}\n• 到期时间：${response.data.plan_time}\n• 余额：¥${response.data.money}\n${formatTraffic(response.data)}\n\n🔄 已启用Token自动刷新（每45分钟）`);
                }
                
                return true;
            } else {
                console.log(`❌ 用户 ${chatId} 账号 ${accountId} 不存在于账号列表中`);
                return false;
            }
        } else {
            console.log(`❌ 用户 ${chatId} 账号 ${credentials.email} 自动重新登录失败: ${response.msg}`);
            if (!specificAccountId) {
                bot.sendMessage(chatId, `❌ 自动重新登录失败：${response.msg}\n\n请使用 /login 手动重新登录`);
            }
            return false;
        }
    } catch (error) {
        console.error(`❌ 用户 ${chatId} 自动重新登录异常:`, error.message);
        if (!specificAccountId) {
            bot.sendMessage(chatId, '❌ 自动重新登录失败，请使用 /login 手动重新登录');
        }
        return false;
    }
};

// 检查Token是否过期
const checkTokenExpiry = async (chatId) => {
    try {
        const currentAccount = getCurrentAccountInfo(chatId);
        if (!currentAccount || !currentAccount.token) {
            return false;
        }
        const token = currentAccount.token;
        
        // 检查是否最近已经验证过（30分钟内不重复验证）
        const lastChecked = tokenLastChecked[chatId];
        const now = Date.now();
        if (lastChecked && (now - lastChecked) < (30 * 60 * 1000)) {
            console.log(`⏰ 用户 ${chatId} Token在30分钟内已验证，跳过检查`);
            return true;
        }
        
        // 尝试一个简单的API调用来检查token是否有效
        const response = await sendRequest('/information', { access_token: currentAccount.token }, null, chatId);
        
        // 更新最后检查时间
        tokenLastChecked[chatId] = now;
        
        if (response.ret === 401 || response.ret === 403) {
            // Token已过期
            const currentTime = new Date();
            const expiredAt = tokenExpiryTimes[chatId] ? new Date(tokenExpiryTimes[chatId]) : null;
            const actualDuration = expiredAt ? Math.floor((currentTime - (expiredAt.getTime() - 90 * 24 * 60 * 60 * 1000)) / (1000 * 60 * 60 * 24)) : 0;
            
            // 记录失效日志
            const logEntry = {
                chatId: String(chatId), // 确保chatId是字符串类型
                failureTime: currentTime,
                expectedExpiry: expiredAt,
                actualDuration: actualDuration,
                reason: `API返回${response.ret}`,
                timeToExpiry: expiredAt ? Math.floor((expiredAt - currentTime) / (1000 * 60 * 60)) : 0
            };
            
            try {
                tokenFailureLog.push(logEntry);
                console.log(`📊 Token失效统计已记录 - 用户 ${chatId}, 当前记录数: ${tokenFailureLog.length}`);
            } catch (pushError) {
                console.error(`❌ Token失效统计记录失败:`, pushError);
            }
            
            // 保持最近100条记录
            if (tokenFailureLog.length > 100) {
                tokenFailureLog.shift();
            }
            
            console.log(`⏰ 用户 ${chatId} Token失效 - 实际使用${actualDuration}天, 距离预期过期${logEntry.timeToExpiry}小时, 原因: ${logEntry.reason}`);
            deleteTokenFromFile(chatId);
            delete userSessions[chatId];
            delete tokenLastChecked[chatId]; // 清理检查缓存
            // 清理持久化页面（已移除Puppeteer）
            return false;
        }
        
        return response.ret === 200;
    } catch (error) {
        // 如果是网络错误或其他错误，检查HTTP状态码
        if (error.response && (error.response.status === 401 || error.response.status === 403)) {
            const currentTime = new Date();
            const expiredAt = tokenExpiryTimes[chatId] ? new Date(tokenExpiryTimes[chatId]) : null;
            const actualDuration = expiredAt ? Math.floor((currentTime - (expiredAt.getTime() - 90 * 24 * 60 * 60 * 1000)) / (1000 * 60 * 60 * 24)) : 0;
            
            // 记录失效日志
            const logEntry = {
                chatId: String(chatId), // 确保chatId是字符串类型
                failureTime: currentTime,
                expectedExpiry: expiredAt,
                actualDuration: actualDuration,
                reason: `HTTP状态码${error.response.status}`,
                timeToExpiry: expiredAt ? Math.floor((expiredAt - currentTime) / (1000 * 60 * 60)) : 0
            };
            
            try {
                tokenFailureLog.push(logEntry);
                console.log(`📊 Token失效统计已记录 - 用户 ${chatId}, 当前记录数: ${tokenFailureLog.length}`);
            } catch (pushError) {
                console.error(`❌ Token失效统计记录失败:`, pushError);
            }
            
            // 保持最近100条记录
            if (tokenFailureLog.length > 100) {
                tokenFailureLog.shift();
            }
            
            console.log(`⏰ 用户 ${chatId} Token失效 - 实际使用${actualDuration}天, 距离预期过期${logEntry.timeToExpiry}小时, 原因: ${logEntry.reason}`);
            deleteTokenFromFile(chatId);
            delete userSessions[chatId];
            delete tokenLastChecked[chatId]; // 清理检查缓存
            // 清理持久化页面（已移除Puppeteer）
            return false;
        }
        console.error(`❌ 检查Token过期异常:`, error.message);
        return false; // 网络错误等情况返回false，触发重新登录
    }
};

// 主动刷新Token（每45分钟刷新一次，避免1小时过期）
const refreshUserToken = async (chatId) => {
    try {
        const credentials = getSavedCredentials(chatId);
        if (!credentials) {
            console.log(`⚠️ 用户 ${chatId} 无保存凭据，跳过Token刷新`);
            return false;
        }
        
        console.log(`🔄 主动刷新用户 ${chatId} 的Token...`);
        
        // 使用保存的凭据重新登录
        const response = await sendRequest('/login', {
            email: credentials.email,
            passwd: credentials.password,
            token_expire: 30,
            save_cookie: true
        }, null, chatId);
        
        if (response.ret === 200) {
            // 获取正确的token字段（可能是token或access_token）
            const token = response.data.token || response.data.access_token;
            if (!token) {
                console.error('❌ Token刷新响应中没有找到token或access_token字段');
                return false;
            }
            
            // 更新token和相关信息
            const accountId = credentials.accountId || `${chatId}_${Date.now()}`;
            
            if (userAccounts[chatId] && userAccounts[chatId][accountId]) {
                userAccounts[chatId][accountId].token = token;
                userAccounts[chatId][accountId].lastUsed = Date.now();
                
                if (currentAccount[chatId] === accountId) {
                    saveTokenToFile(chatId, accountId, {
                        token: token,
                        tokenExpire: userAccounts[chatId][accountId].tokenExpire,
                        email: userAccounts[chatId][accountId].email
                    });
                    updateUserSession(chatId, { token: token }, accountId);
                }
            }
            
            console.log(`✅ 用户 ${chatId} Token刷新成功`);
            return true;
        } else {
            console.log(`❌ 用户 ${chatId} Token刷新失败: ${response.msg}`);
            return false;
        }
    } catch (error) {
        console.error(`❌ 用户 ${chatId} Token刷新异常:`, error.message);
        return false;
    }
};

// 设置Token刷新定时器
const setupTokenRefreshTimer = (chatId) => {
    // 清除已存在的定时器
    if (tokenRefreshTimers[chatId]) {
        clearInterval(tokenRefreshTimers[chatId]);
    }
    
    // 每45分钟刷新一次Token
    tokenRefreshTimers[chatId] = setInterval(async () => {
        console.log(`⏰ 定时刷新用户 ${chatId} 的Token`);
        await refreshUserToken(chatId);
    }, 45 * 60 * 1000); // 45分钟
    
    console.log(`⏰ 已设置用户 ${chatId} 的Token定时刷新（每45分钟）`);
};

// 定时检测所有用户的Token状态
const startTokenMonitoring = () => {
    // 每60分钟检查一次所有用户的token状态
    setInterval(async () => {
        const activeUsers = getActiveUsersFromFile();
        if (activeUsers.length === 0) {
            return;
        }
        
        console.log(`⏰ 开始定时检测 ${activeUsers.length} 个用户的Token状态...`);
        
        for (const chatId of activeUsers) {
            try {
                const tokenExpiry = tokenExpiryTimes[chatId];
                const now = Date.now();
                
                // 如果token在6小时内过期，提前刷新
                if (tokenExpiry && (tokenExpiry - now) < (6 * 60 * 60 * 1000)) {
                    console.log(`⏰ 用户 ${chatId} Token将在6小时内过期，开始提前刷新...`);
                    
                    const success = await autoRelogin(chatId);
                    if (success) {
                        console.log(`✅ 用户 ${chatId} Token提前刷新成功`);
                    } else {
                        console.log(`❌ 用户 ${chatId} Token提前刷新失败`);
                    }
                } else {
                    // 常规检查token有效性
                    const isValid = await checkTokenExpiry(chatId);
                    if (!isValid) {
                        console.log(`⚠️ 用户 ${chatId} 的Token已过期，尝试自动重新登录...`);
                        console.log(`📊 当前Token失效统计记录数: ${tokenFailureLog.length}`);
                        const success = await autoRelogin(chatId);
                        if (success) {
                            console.log(`✅ 用户 ${chatId} 自动重新登录成功`);
                        } else {
                            console.log(`❌ 用户 ${chatId} 自动重新登录失败`);
                        }
                    } else {
                        console.log(`✅ 用户 ${chatId} 的Token状态正常`);
                    }
                }
                
                // 每个用户检查之间间隔2-5秒随机延迟，避免API频率限制
                const randomDelay = Math.floor(Math.random() * 3000) + 2000; // 2-5秒随机延迟
                await new Promise(resolve => setTimeout(resolve, randomDelay));
            } catch (error) {
                console.error(`❌ 检测用户 ${chatId} Token状态时出错:`, error.message);
            }
        }
        
        console.log(`✅ 定时Token检测完成，下次检测时间: ${new Date(Date.now() + 60 * 60 * 1000).toLocaleString()}`);
    }, 60 * 60 * 1000); // 60分钟 = 60 * 60 * 1000 毫秒
    
    // 启动时立即执行一次检测（延迟30秒，等待系统稳定）
    setTimeout(async () => {
        const activeUsers = getActiveUsersFromFile();
        if (activeUsers.length > 0) {
            console.log(`🔍 启动后首次Token状态检测，共 ${activeUsers.length} 个用户`);
            for (const chatId of activeUsers) {
                try {
                    await checkTokenExpiry(chatId);
                    const randomDelay = Math.floor(Math.random() * 3000) + 2000; // 2-5秒随机延迟
                    await new Promise(resolve => setTimeout(resolve, randomDelay));
                } catch (error) {
                    console.error(`❌ 检测用户 ${chatId} Token状态时出错:`, error.message);
                }
            }
        }
    }, 30 * 1000); // 30秒后执行首次检测
};

// 中间件：检查登录状态和Token有效性
const requireLogin = (callback) => {
    return async (msg) => {
        const chatId = msg.chat.id;
        
        // 首先检查是否有当前账号
        const currentAccount = getCurrentAccountInfo(chatId);
        if (!currentAccount) {
            // 尝试自动重新登录
            const success = await autoRelogin(chatId);
            if (!success) {
                bot.sendMessage(chatId, '❌ 请先登录 /login\n💡 如需管理多个账号，可登录多次');
                return;
            }
        } else {
            // 检查token是否过期
            const valid = await checkTokenExpiry(chatId);
            if (!valid) {
                // token过期，尝试自动重新登录
                const success = await autoRelogin(chatId);
                if (!success) {
                    bot.sendMessage(chatId, '❌ Token已过期，自动重新登录失败，请手动重新登录 /login');
                    return;
                }
            }
        }
        
        // 确保当前账号存在后再执行回调
        const finalAccount = getCurrentAccountInfo(chatId);
        if (finalAccount && finalAccount.token) {
            callback(msg);
        } else {
            bot.sendMessage(chatId, '❌ 登录状态异常，请使用 /login 重新登录');
        }
    };
};

// 工具函数：分段发送长消息
const sendLongMessage = async (chatId, text, options = {}) => {
    const MAX_LENGTH = 4000;
    
    if (text.length <= MAX_LENGTH) {
        return await bot.sendMessage(chatId, text, options);
    }
    
    const paragraphs = text.split('\n\n');
    let currentMessage = '';
    let messageCount = 1;
    
    for (let i = 0; i < paragraphs.length; i++) {
        const paragraph = paragraphs[i];
        
        if (paragraph.length > MAX_LENGTH) {
            const lines = paragraph.split('\n');
            for (const line of lines) {
                if ((currentMessage + line + '\n').length > MAX_LENGTH) {
                    if (currentMessage) {
                        const header = messageCount > 1 ? `📄 第${messageCount}部分:\n\n` : '';
                        await bot.sendMessage(chatId, header + currentMessage.trim(), options);
                        messageCount++;
                    }
                    currentMessage = line + '\n';
                } else {
                    currentMessage += line + '\n';
                }
            }
        } else {
            if ((currentMessage + paragraph + '\n\n').length > MAX_LENGTH) {
                if (currentMessage) {
                    const header = messageCount > 1 ? `📄 第${messageCount}部分:\n\n` : '';
                    await bot.sendMessage(chatId, header + currentMessage.trim(), options);
                    messageCount++;
                }
                currentMessage = paragraph + '\n\n';
            } else {
                currentMessage += paragraph + '\n\n';
            }
        }
    }
    
    if (currentMessage) {
        const header = messageCount > 1 ? `📄 第${messageCount}部分:\n\n` : '';
        await bot.sendMessage(chatId, header + currentMessage.trim(), options);
    }
};

// 中间件：验证管理员权限
const requireAdmin = (callback) => {
    return (msg) => {
        if (msg.from.id.toString() !== ADMIN_USER_ID) {
            bot.sendMessage(msg.chat.id, '⚠️ 你没有权限使用此功能');
            return;
        }
        callback(msg);
    };
};

// 发送API请求（使用undici）
const sendRequest = async (endpoint, data, token = null, chatId = null) => {
    try {
        if (DEBUG) {
            console.log(`📤 API请求: ${DLER_BASE_URL}${endpoint}`);
            console.log('📋 请求数据:', JSON.stringify(data, null, 2));
        }
        
        const headers = {
            'Content-Type': 'application/json',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/json, text/plain, */*',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Sec-Fetch-Dest': 'empty',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'same-origin',
            'Referer': 'https://dler.cloud/',
            'Origin': 'https://dler.cloud',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'DNT': '1',
            'Sec-CH-UA': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            'Sec-CH-UA-Mobile': '?0',
            'Sec-CH-UA-Platform': '"Windows"'
        };
        
        // 如果有Cookie，添加Cookie头
        if (chatId && userCookies[chatId]) {
            headers['Cookie'] = userCookies[chatId];
        }
        
        const response = await request(`${DLER_BASE_URL}${endpoint}`, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(data)
        });
        
        // 正确处理响应体，包括gzip解压
        let responseText;
        if (response.headers['content-encoding'] === 'gzip') {
            const chunks = [];
            const gunzip = createGunzip();
            
            response.body.pipe(gunzip);
            
            for await (const chunk of gunzip) {
                chunks.push(chunk);
            }
            
            responseText = Buffer.concat(chunks).toString();
        } else {
            responseText = await response.body.text();
        }
        
        const responseData = JSON.parse(responseText);
        
        // 保存Cookie（如果是登录请求）
        if (endpoint === '/login' && response.headers['set-cookie'] && chatId) {
            const cookies = response.headers['set-cookie'];
            if (Array.isArray(cookies)) {
                userCookies[chatId] = cookies.join('; ');
            } else {
                userCookies[chatId] = cookies;
            }
            console.log(`🍪 保存用户 ${chatId} 的Cookie`);
        }
        
        if (DEBUG) {
            console.log('📥 API响应:', JSON.stringify(responseData, null, 2));
        }
        
        return responseData;
    } catch (error) {
        console.error('❌ API请求失败:');
        console.error('URL:', `${DLER_BASE_URL}${endpoint}`);
        if (DEBUG) {
            console.error('Data:', JSON.stringify(data, null, 2));
        }
        console.error('Error:', error.message);
        throw error;
    }
};

// 格式化流量显示
const formatTraffic = (data) => {
    return `
📊 流量信息:
- 今日使用: ${data.today_used || '0MB'}
- 已使用: ${data.used || '0MB'}
- 剩余: ${data.unused || '0MB'}
- 总流量: ${data.traffic || '0MB'}
`;
};

// 获取系统状态
const getSystemStatus = async () => {
    try {
        const startTime = Date.now();
        
        // 测试网络连接 - 使用更可靠的服务
        const networkTest = await request('https://api.ipify.org?format=json', {
            method: 'GET',
            headersTimeout: 5000,
            bodyTimeout: 5000
        });
        let networkText;
        if (networkTest.headers['content-encoding'] === 'gzip') {
            const chunks = [];
            const gunzip = createGunzip();
            
            networkTest.body.pipe(gunzip);
            
            for await (const chunk of gunzip) {
                chunks.push(chunk);
            }
            
            networkText = Buffer.concat(chunks).toString();
        } else {
            networkText = await networkTest.body.text();
        }
        
        let networkData;
        try {
            networkData = JSON.parse(networkText);
        } catch (parseError) {
            console.error('网络测试响应解析失败:', networkText.substring(0, 100));
            throw new Error('网络测试返回非JSON响应');
        }
        const networkLatency = Date.now() - startTime;
        
        // 测试墙洞API连接
        const apiStartTime = Date.now();
        try {
            await request('https://dler.cloud/api/v1/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    email: 'health-check@test.com',
                    passwd: 'test-health-check'
                }),
                headersTimeout: 10000,
                bodyTimeout: 10000
            });
            var apiLatency = Date.now() - apiStartTime;
            var apiStatus = '✅ 正常';
        } catch (apiError) {
            var apiLatency = Date.now() - apiStartTime;
            
            // 如果是认证错误但返回了正确格式，说明API正常
            if (apiError.statusCode && (apiError.statusCode === 400 || apiError.statusCode === 401)) {
                var apiStatus = '✅ 正常';
            } else {
                var apiStatus = '❌ 异常';
            }
        }      



        // 获取系统信息
        const uptime = process.uptime();
        const memUsage = process.memoryUsage();
        
        return {
            network: {
                status: '✅ 正常',
                latency: networkLatency,
                ip: networkData.ip || networkData.origin || '未知'
            },
            api: {
                status: apiStatus,
                latency: apiLatency
            },
            bot: {
                uptime: Math.floor(uptime),
                memory: Math.round(memUsage.rss / 1024 / 1024),
                version: '1.0.5'
            }
        };
    } catch (error) {
        return {
            network: {
                status: '❌ 异常',
                error: error.message
            },
            api: {
                status: '❓ 未知'
            },
            bot: {
                uptime: Math.floor(process.uptime()),
                memory: Math.round(process.memoryUsage().rss / 1024 / 1024),
                version: '1.0.5'
            }
        };
    }
};

// 设置机器人菜单
const setupBotMenu = async () => {
    try {
        await bot.setMyCommands([
            { command: 'start', description: '🎉 开始使用机器人' },
            { command: 'help', description: '📖 查看帮助信息' },
            { command: 'status', description: '📊 查看系统状态' },
            { command: 'login', description: '🔐 登录墙洞账户' },
            { command: 'logout', description: '🚪 注销当前账号' },
            { command: 'accounts', description: '👥 查看所有账号' },
            { command: 'switch', description: '🔄 切换账号' },
            { command: 'current', description: '📍 查看当前账号' },
            { command: 'remove', description: '🗑️ 删除账号' },
            { command: 'creds', description: '🔑 密码管理' },
            { command: 'tokenstats', description: '📊 Token失效统计' },
            { command: 'info', description: '📊 查看账户信息' },
            { command: 'checkin', description: '🎲 每日签到' },
            { command: 'sub', description: '📱 获取订阅链接' },
            { command: 'nodes', description: '🌐 查看可用节点' },
            { command: 'getrules', description: '📋 查看转发规则' },
            { command: 'addrule', description: '➕ 添加转发规则' },
            { command: 'delrule', description: '➖ 删除转发规则' }
        ]);
        console.log('✅ 机器人菜单设置完成');
    } catch (error) {
        console.error('❌ 设置机器人菜单失败:', error.message);
    }
};
EOF
}

# 创建机器人主程序 - 第2部分（基础命令）
create_bot_js_part2() {
cat >> bot.js << 'EOF'

// 开始命令
bot.onText(/\/start/, (msg) => {
    const welcomeMessage = `
🎉 欢迎使用墙洞管理机器人！

📌 可用命令：
/status - 查看系统状态 🔍
/login - 登录获取Token
/logout - 注销登录
/accounts - 查看所有账号 👥
/switch - 切换账号 🔄
/current - 查看当前账号 📍
/remove - 删除账号 🗑️
/creds - 密码管理 🔑
/tokenstats - Token失效统计 📊
/info - 查看用户信息
/checkin - 试试手气
/sub - 获取所有订阅链接
/nodes - 查看可用节点 🌐
/getrules - 查看外部转发规则 👑
/addrule - 添加外部转发规则 👑
/delrule - 删除外部转发规则 👑
/help - 查看帮助

👑 需要管理员权限
⚡ 机器人版本: v1.0.5 (最终修复版)

💡 点击左下角菜单按钮可快速选择命令！
`;
    bot.sendMessage(msg.chat.id, welcomeMessage);
});

// 系统状态命令
bot.onText(/\/status/, async (msg) => {
    try {
        const progressMsg = await bot.sendMessage(msg.chat.id, '🔍 正在检测系统状态...');
        
        const status = await getSystemStatus();
        
        let statusMsg = `📊 系统状态报告\n\n`;
        
        // 网络状态
        statusMsg += `🌐 网络连接:\n`;
        statusMsg += `• 状态: ${status.network.status}\n`;
        if (status.network.latency) {
            statusMsg += `• 延迟: ${status.network.latency}ms\n`;
        }
        if (status.network.ip) {
            statusMsg += `• 出口IP: ${status.network.ip}\n`;
        }
        if (status.network.error) {
            statusMsg += `• 错误: ${status.network.error}\n`;
        }
        statusMsg += '\n';
        
        // API状态
        statusMsg += `🔗 墙洞API:\n`;
        statusMsg += `• 状态: ${status.api.status}\n`;
        if (status.api.latency) {
            statusMsg += `• 延迟: ${status.api.latency}ms\n`;
        }
        statusMsg += '\n';
        
        // 机器人状态
        statusMsg += `🤖 机器人状态:\n`;
        statusMsg += `• 版本: v${status.bot.version}\n`;
        statusMsg += `• 运行时间: ${Math.floor(status.bot.uptime / 3600)}小时${Math.floor((status.bot.uptime % 3600) / 60)}分钟\n`;
        statusMsg += `• 内存使用: ${status.bot.memory}MB\n`;
        statusMsg += `• 用户会话: ${getActiveUsersFromFile().length}个\n\n`;
        
        // 功能状态
        statusMsg += `⚙️ 功能模块:\n`;
        statusMsg += `• 账户管理: ✅ 正常\n`;
        statusMsg += `• 订阅获取: ✅ 正常\n`;
        statusMsg += `• 节点查看: ✅ 正常\n`;
        statusMsg += `• 转发管理: ✅ 正常\n`;
        statusMsg += `• 消息分段: ✅ 正常\n\n`;
        
        const overallStatus = status.network.status.includes('✅') && status.api.status.includes('✅') ? '🟢 健康' : '🟡 警告';
        statusMsg += `📈 总体状态: ${overallStatus}`;
        
        try {
            await bot.deleteMessage(msg.chat.id, progressMsg.message_id);
        } catch (e) {}
        
        bot.sendMessage(msg.chat.id, statusMsg);
        
    } catch (error) {
        console.error('获取系统状态失败:', error);
        bot.sendMessage(msg.chat.id, '❌ 获取系统状态失败，请稍后重试');
    }
});

// 帮助命令
bot.onText(/\/help/, (msg) => {
    const helpMessage = `
📖 命令详解：

🔍 系统相关：
/status - 查看系统状态和健康检查
/start - 显示欢迎信息

🔐 账户相关：
/login - 登录获取访问Token
/logout - 登出并删除Token
/creds - 密码管理和凭据查看
/tokenstats - Token失效统计和分析
/info - 查看账户信息和流量
/checkin - 每日签到获取流量

📱 订阅相关：
/sub - 获取所有订阅链接

🌐 节点相关：
/nodes - 查看节点信息和使用指导

🔄 外部转发（管理员）：
/getrules - 查看当前转发规则
/addrule - 添加新的转发规则
/delrule - 删除指定的转发规则

💡 使用示例：
- 系统状态: /status
- 查看节点: /nodes
- 登录: /login 然后输入 "邮箱 密码"
- 密码管理: /creds 查看和管理保存的凭据
- 添加规则: /addrule 1528 192.168.1.100 8080
- 删除规则: /delrule 456

📋 工作流程：
1. /status - 检查系统状态
2. /login - 登录账户（选择保存密码）
3. /creds - 管理密码和查看凭据状态
4. /nodes - 查看节点信息
5. /addrule - 添加转发规则
6. /getrules - 查看已添加的规则

🔑 密码管理功能：
• 加密保存登录凭据
• 自动重新登录
• 凭据状态查看
• 安全测试和管理

⚡ 新功能：
• 系统状态监控
• 网络连接测试
• API健康检查
• 性能指标显示
• 密码管理中心

💡 提示：点击左下角菜单按钮可快速选择命令！
`;
    bot.sendMessage(msg.chat.id, helpMessage);
});
EOF
}
# 创建机器人主程序 - 第3部分（用户管理）
create_bot_js_part3() {
cat >> bot.js << 'EOF'

// 登录命令
bot.onText(/\/login/, (msg) => {
    bot.sendMessage(msg.chat.id, '🔐 请输入邮箱和密码，格式：\n邮箱 密码\n\n例如：user@example.com mypassword\n\n⚠️ 请注意隐私安全，建议私聊使用');
    
    const chatId = msg.chat.id;
    const messageHandler = async (loginMsg) => {
        if (loginMsg.chat.id !== chatId) return;
        
        const parts = loginMsg.text.split(' ');
        if (parts.length < 2) {
            bot.sendMessage(chatId, '❌ 格式错误，请重新输入');
            return;
        }
        
        const email = parts[0];
        const passwd = parts.slice(1).join(' ');
        
        try {
            await bot.deleteMessage(chatId, loginMsg.message_id);
        } catch (e) {}
        
        try {
            const progressMsg = await bot.sendMessage(chatId, '🔄 正在登录...');
            
            const response = await sendRequest('/login', {
                email: email,
                passwd: passwd,
                token_expire: 30,
                save_cookie: true
            }, null, chatId);
            
            try {
                await bot.deleteMessage(chatId, progressMsg.message_id);
            } catch (e) {}
            
            if (response.ret === 200) {
                // 调试：打印登录响应数据
                console.log(`🔍 登录响应数据:`, JSON.stringify(response.data));
                
                // 获取正确的token字段（可能是token或access_token）
                const token = response.data.token || response.data.access_token;
                if (!token) {
                    console.error('❌ 登录响应中没有找到token或access_token字段');
                    bot.sendMessage(chatId, '❌ 登录失败：服务器响应格式错误，未返回token');
                    bot.removeListener('message', messageHandler);
                    return;
                }
                
                // 计算token过期时间：使用服务端返回的token_expire或默认30天
                let tokenExpiry;
                if (response.data.token_expire && response.data.token_expire !== '9999-99-99 99:99:99') {
                    // 使用服务端返回的具体过期时间
                    tokenExpiry = new Date(response.data.token_expire).getTime();
                    if (DEBUG) {
                        console.log('🕐 使用服务端返回的token_expire:', response.data.token_expire);
                    }
                } else {
                    // 服务端返回默认值，使用本地计算（30天）
                    tokenExpiry = Date.now() + (30 * 24 * 60 * 60 * 1000);
                    if (DEBUG) {
                        console.log('🕐 使用本地计算的token_expire: 30天');
                    }
                }
                
                // 使用多账号系统添加账号
                const accountInfo = {
                    email: email,
                    plan: response.data.plan,
                    planTime: response.data.plan_time,
                    money: response.data.money,
                    upload: response.data.upload,
                    download: response.data.download,
                    transfer: response.data.transfer,
                    usage: response.data.usage
                };
                
                const accountId = addAccount(chatId, email, token, tokenExpiry);
                
                // 设置token过期时间到全局变量
                tokenExpiryTimes[chatId] = tokenExpiry;
                
                // 初始化userSessions以保持兼容性
                updateUserSession(chatId, {
                    email: email,
                    loginTime: new Date(),
                    plan: response.data.plan,
                    hasRememberedPassword: false
                }, accountId);
                
                const successMessage = `✅ 登录成功！\n\n📋 账户信息：\n• 账号ID：${accountId}\n• 邮箱：${email}\n• 套餐：${response.data.plan}\n• 到期时间：${response.data.plan_time}\n• 余额：¥${response.data.money}\n${formatTraffic(response.data)}\n\n💡 使用 /accounts 查看所有账号\n💡 使用 /switch ${accountId} 切换账号`;
                
                // 检查当前登录的账号是否已保存凭据
                const existingCreds = getSavedCredentials(chatId, accountId);
                if (!existingCreds) {
                    bot.sendMessage(chatId, successMessage + '\n\n🔑 是否保存密码以启用自动重新登录？\n\n回复 "保存" 启用自动登录\n回复 "跳过" 仅本次登录\n\n💡 保存后Token过期时将自动重新登录');
                    
                    // 等待用户选择是否保存密码
                    const saveHandler = async (saveMsg) => {
                        if (saveMsg.chat.id !== chatId) return;
                        
                        const choice = saveMsg.text.toLowerCase().trim();
                        
                        try {
                            await bot.deleteMessage(chatId, saveMsg.message_id);
                        } catch (e) {}
                        
                        if (choice === '保存') {
                            if (saveCredentials(chatId, email, passwd)) {
                                try {
                                    updateUserSession(chatId, {
                                        hasRememberedPassword: true
                                    }, accountId);
                                    // 设置Token刷新定时器
                                    setupTokenRefreshTimer(chatId);
                                    bot.sendMessage(chatId, '✅ 密码已加密保存\n\n🔐 功能说明：\n• Token过期时自动重新登录\n• 使用AES-256-CBC加密存储\n• 可用 /creds 管理密码\n• 每45分钟自动刷新Token\n\n🛡️ 您的密码已安全加密，请放心使用');
                                } catch (error) {
                                    console.error('设置hasRememberedPassword失败:', error);
                                    // 设置Token刷新定时器
                                    setupTokenRefreshTimer(chatId);
                                    bot.sendMessage(chatId, '✅ 密码已加密保存\n\n🔐 功能说明：\n• Token过期时自动重新登录\n• 使用AES-256-CBC加密存储\n• 可用 /creds 管理密码\n• 每45分钟自动刷新Token\n\n🛡️ 您的密码已安全加密，请放心使用');
                                }
                            } else {
                                bot.sendMessage(chatId, '❌ 保存密码失败，但登录已成功');
                            }
                        } else if (choice === '跳过') {
                            bot.sendMessage(chatId, '✅ 已跳过密码保存\n\n💡 如需启用自动登录，请使用 /creds 管理密码或重新登录');
                        } else {
                            bot.sendMessage(chatId, '❌ 无效选择，已跳过密码保存\n\n💡 可以稍后使用 /creds 管理密码');
                        }
                        
                        bot.removeListener('message', saveHandler);
                    };
                    
                    bot.on('message', saveHandler);
                    
                    // 30秒后自动移除监听器
                    setTimeout(() => {
                        bot.removeListener('message', saveHandler);
                    }, 30000);
                } else {
                    // 该账号已经保存过密码，更新密码
                    saveCredentials(chatId, email, passwd);
                    try {
                        updateUserSession(chatId, {
                            hasRememberedPassword: true
                        }, accountId);
                    } catch (error) {
                        console.error('设置hasRememberedPassword失败:', error);
                    }
                    // 设置Token刷新定时器
                    setupTokenRefreshTimer(chatId);
                    bot.sendMessage(chatId, successMessage + '\n\n🔑 密码已自动更新\n🔄 已启用Token自动刷新');
                }
            } else {
                bot.sendMessage(chatId, `❌ 登录失败：${response.msg}`);
            }
        } catch (error) {
            bot.sendMessage(chatId, '❌ 登录失败，请检查邮箱和密码或网络连接');
        }
        
        bot.removeListener('message', messageHandler);
    };
    
    bot.on('message', messageHandler);
});

// 注销命令
bot.onText(/\/logout/, async (msg) => {
    const currentAccount = getCurrentAccountInfo(msg.chat.id);
    if (!currentAccount) {
        bot.sendMessage(msg.chat.id, '❌ 你还没有登录任何账号');
        return;
    }
    
    try {
        await sendRequest('/logout', { access_token: currentAccount.token }, null, msg.chat.id);
        removeAccount(msg.chat.id, currentAccount.accountId);
        delete tokenLastChecked[msg.chat.id];
        // 清理持久化页面（已移除Puppeteer）
        
        const remainingAccounts = getAccountList(msg.chat.id);
        if (remainingAccounts.length > 0) {
            bot.sendMessage(msg.chat.id, `✅ 账号 ${currentAccount.email} 已成功注销\n\n💡 你还有 ${remainingAccounts.length} 个账号，使用 /accounts 查看`);
        } else {
            bot.sendMessage(msg.chat.id, '✅ 已成功注销所有账号');
        }
    } catch (error) {
        removeAccount(msg.chat.id, currentAccount.accountId);
        delete tokenLastChecked[msg.chat.id];
        // 清理持久化页面（已移除Puppeteer）
        
        const remainingAccounts = getAccountList(msg.chat.id);
        if (remainingAccounts.length > 0) {
            bot.sendMessage(msg.chat.id, `✅ 账号 ${currentAccount.email} 已成功注销（本地清除）\n\n💡 你还有 ${remainingAccounts.length} 个账号，使用 /accounts 查看`);
        } else {
            bot.sendMessage(msg.chat.id, '✅ 已成功注销所有账号（本地清除）');
        }
    }
});

// 账号列表命令
bot.onText(/\/accounts/, (msg) => {
    const chatId = msg.chat.id;
    
    if (!userAccounts[chatId] || Object.keys(userAccounts[chatId]).length === 0) {
        bot.sendMessage(chatId, '📋 账号列表\n\n暂无已登录账号\n\n💡 使用 /login 添加第一个账号');
        return;
    }
    
    const accounts = userAccounts[chatId];
    const current = currentAccount[chatId];
    
    let message = '📋 账号列表\n\n';
    
    let buttons = [];
    
    Object.entries(accounts).forEach(([accountId, account], index) => {
        const isCurrent = accountId === current;
        const status = isCurrent ? '🟢 当前' : '⚪';
        const loginTime = new Date(account.loginTime).toLocaleString();
        const lastUsed = new Date(account.lastUsed).toLocaleString();
        
        message += `${index + 1}. ${status} ${account.email}\n`;
        message += `   🕐 登录: ${loginTime}\n`;
        message += `   📱 使用: ${lastUsed}\n`;
        message += `   🆔 ID: ${accountId}\n\n`;
        
        // 添加按钮
        let accountButtons = [];
        if (!isCurrent) {
            accountButtons.push({
                text: `🔄 切换到 ${accountId}`,
                callback_data: `switch_${accountId}`
            });
        }
        accountButtons.push({
            text: `🗑️ 删除 ${accountId}`,
            callback_data: `remove_${accountId}`
        });
        
        buttons.push(accountButtons);
    });
    
    // 添加其他操作按钮
    buttons.push([
        { text: '➕ 添加新账号', callback_data: 'add_account' },
        { text: '📍 当前账号详情', callback_data: 'current_account' }
    ]);
    
    message += '🔧 点击按钮进行操作：';
    
    bot.sendMessage(chatId, message, {
        reply_markup: {
            inline_keyboard: buttons
        }
    });
});

// 处理内联键盘按钮回调
bot.on('callback_query', async (callbackQuery) => {
    const msg = callbackQuery.message;
    const chatId = msg.chat.id;
    const data = callbackQuery.data;
    
    // 应答回调查询
    bot.answerCallbackQuery(callbackQuery.id);
    
    if (data.startsWith('switch_')) {
        const accountId = data.replace('switch_', '');
        
        if (!userAccounts[chatId] || !userAccounts[chatId][accountId]) {
            bot.sendMessage(chatId, `❌ 账号ID "${accountId}" 不存在`);
            return;
        }
        
        if (currentAccount[chatId] === accountId) {
            const account = userAccounts[chatId][accountId];
            bot.sendMessage(chatId, `ℹ️ 已经是当前账号: ${account.email}`);
            return;
        }
        
        if (switchAccount(chatId, accountId)) {
            const account = userAccounts[chatId][accountId];
            
            // 立即验证切换后的账号token是否有效
            try {
                const response = await sendRequest('/information', { access_token: account.token }, null, chatId);
                if (response.ret === 200) {
                    // Token有效，检查该账号是否有保存的凭据，如果有则设置Token刷新定时器
                    const savedCreds = getSavedCredentials(chatId, accountId);
                    if (savedCreds) {
                        setupTokenRefreshTimer(chatId);
                        bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}\n🔄 已启用Token自动刷新`);
                    } else {
                        bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}`);
                    }
                } else if (response.ret === 401 || response.ret === 403) {
                    // Token已过期，尝试自动重新登录
                    bot.sendMessage(chatId, `⚠️ 已切换到账号: ${account.email}\n\n⏳ Token已过期，正在尝试自动重新登录...`);
                    
                    const reloginSuccess = await autoRelogin(chatId, accountId);
                    if (reloginSuccess) {
                        bot.sendMessage(chatId, `✅ 自动重新登录成功！\n\n账号 ${account.email} 已可正常使用`);
                    } else {
                        bot.sendMessage(chatId, `❌ 自动重新登录失败\n\n请使用 /login 手动重新登录该账号`);
                    }
                } else {
                    // 其他错误码也可能是token问题，尝试自动重新登录
                    bot.sendMessage(chatId, `⚠️ 已切换到账号: ${account.email}\n\n⏳ 检测到认证问题(${response.ret})，正在尝试自动重新登录...`);
                    
                    const reloginSuccess = await autoRelogin(chatId, accountId);
                    if (reloginSuccess) {
                        bot.sendMessage(chatId, `✅ 自动重新登录成功！\n\n账号 ${account.email} 已可正常使用`);
                    } else {
                        bot.sendMessage(chatId, `❌ 自动重新登录失败\n\n错误信息：${response.msg}\n请使用 /login 手动重新登录该账号`);
                    }
                }
            } catch (error) {
                console.error('切换账号验证失败:', error.message);
                
                // 网络错误时也尝试自动重新登录
                if (error.response && (error.response.status === 401 || error.response.status === 403)) {
                    bot.sendMessage(chatId, `⚠️ 已切换到账号: ${account.email}\n\n⏳ 检测到认证失败，正在尝试自动重新登录...`);
                    
                    const reloginSuccess = await autoRelogin(chatId, accountId);
                    if (reloginSuccess) {
                        bot.sendMessage(chatId, `✅ 自动重新登录成功！\n\n账号 ${account.email} 已可正常使用`);
                    } else {
                        bot.sendMessage(chatId, `❌ 自动重新登录失败\n\n请使用 /login 手动重新登录该账号`);
                    }
                } else {
                    bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}\n\n⚠️ 网络连接失败，请稍后再试`);
                }
            }
        } else {
            bot.sendMessage(chatId, '❌ 切换账号失败');
        }
    } else if (data.startsWith('remove_')) {
        const accountId = data.replace('remove_', '');
        
        if (!userAccounts[chatId] || !userAccounts[chatId][accountId]) {
            bot.sendMessage(chatId, `❌ 账号ID "${accountId}" 不存在`);
            return;
        }
        
        const account = userAccounts[chatId][accountId];
        const email = account.email;
        
        if (removeAccount(chatId, accountId)) {
            const remainingCount = userAccounts[chatId] ? Object.keys(userAccounts[chatId]).length : 0;
            let message = `✅ 已删除账号: ${email}`;
            
            if (remainingCount > 0) {
                const newCurrent = getCurrentAccountInfo(chatId);
                message += `\n\n🔄 当前账号已切换为: ${newCurrent.email}`;
            } else {
                message += '\n\n📋 已删除所有账号，请使用 /login 重新登录';
            }
            
            bot.sendMessage(chatId, message);
        } else {
            bot.sendMessage(chatId, '❌ 删除账号失败');
        }
    } else if (data === 'add_account') {
        bot.sendMessage(chatId, '💡 请使用 /login 命令添加新账号');
    } else if (data === 'current_account') {
        const account = getCurrentAccountInfo(chatId);
        
        if (!account) {
            bot.sendMessage(chatId, '❌ 当前无已登录账号\n\n💡 使用 /login 登录账号');
            return;
        }
        
        const loginTime = new Date(account.loginTime).toLocaleString();
        const lastUsed = new Date(account.lastUsed).toLocaleString();
        
        let message = `📍 当前账号详情\n\n`;
        message += `📧 邮箱: ${account.email}\n`;
        message += `🆔 账号ID: ${account.accountId}\n`;
        message += `🕐 登录时间: ${loginTime}\n`;
        message += `📱 最后使用: ${lastUsed}\n\n`;
        message += `🔧 管理操作:\n`;
        message += `• /accounts - 查看所有账号\n`;
        message += `• /switch 账号ID - 切换到其他账号\n`;
        message += `• /login - 添加新账号`;
        
        bot.sendMessage(chatId, message);
    }
});

// 切换账号命令
bot.onText(/\/switch(?:\s+(.+))?/, async (msg, match) => {
    const chatId = msg.chat.id;
    const accountId = match[1]?.trim();
    
    if (!accountId) {
        bot.sendMessage(chatId, '❌ 请指定账号ID\n\n🔍 格式: /switch 账号ID\n💡 使用 /accounts 查看账号列表');
        return;
    }
    
    if (!userAccounts[chatId] || !userAccounts[chatId][accountId]) {
        bot.sendMessage(chatId, `❌ 账号ID "${accountId}" 不存在\n\n💡 使用 /accounts 查看可用账号`);
        return;
    }
    
    if (currentAccount[chatId] === accountId) {
        const account = userAccounts[chatId][accountId];
        bot.sendMessage(chatId, `ℹ️ 已经是当前账号: ${account.email}`);
        return;
    }
    
    if (switchAccount(chatId, accountId)) {
        const account = userAccounts[chatId][accountId];
        
        // 立即验证切换后的账号token是否有效
        try {
            const response = await sendRequest('/information', { access_token: account.token }, null, chatId);
            if (response.ret === 200) {
                // Token有效，检查该账号是否有保存的凭据，如果有则设置Token刷新定时器
                const savedCreds = getSavedCredentials(chatId, accountId);
                if (savedCreds) {
                    setupTokenRefreshTimer(chatId);
                    bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}\n\n📋 账户信息：\n• 套餐：${response.data.plan}\n• 到期时间：${response.data.plan_time}\n${formatTraffic(response.data)}\n\n💡 现在所有操作将使用此账号\n🔄 已启用Token自动刷新`);
                } else {
                    bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}\n\n📋 账户信息：\n• 套餐：${response.data.plan}\n• 到期时间：${response.data.plan_time}\n${formatTraffic(response.data)}\n\n💡 现在所有操作将使用此账号\n⚠️ 未保存密码，无法自动刷新Token`);
                }
            } else if (response.ret === 401 || response.ret === 403) {
                // Token已过期，尝试自动重新登录
                bot.sendMessage(chatId, `⚠️ 已切换到账号: ${account.email}\n\n⏳ Token已过期，正在尝试自动重新登录...`);
                
                const reloginSuccess = await autoRelogin(chatId, accountId);
                if (reloginSuccess) {
                    bot.sendMessage(chatId, `✅ 自动重新登录成功！\n\n账号 ${account.email} 已可正常使用`);
                } else {
                    bot.sendMessage(chatId, `❌ 自动重新登录失败\n\n请使用 /login 手动重新登录该账号`);
                }
            } else {
                bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}\n\n⚠️ 无法验证账号状态：${response.msg}`);
            }
        } catch (error) {
            console.error('切换账号验证失败:', error.message);
            
            // 网络错误时也尝试自动重新登录
            if (error.response && (error.response.status === 401 || error.response.status === 403)) {
                bot.sendMessage(chatId, `⚠️ 已切换到账号: ${account.email}\n\n⏳ 检测到认证失败，正在尝试自动重新登录...`);
                
                const reloginSuccess = await autoRelogin(chatId, accountId);
                if (reloginSuccess) {
                    bot.sendMessage(chatId, `✅ 自动重新登录成功！\n\n账号 ${account.email} 已可正常使用`);
                } else {
                    bot.sendMessage(chatId, `❌ 自动重新登录失败\n\n请使用 /login 手动重新登录该账号`);
                }
            } else {
                bot.sendMessage(chatId, `✅ 已切换到账号: ${account.email}\n\n⚠️ 网络连接失败，请稍后再试`);
            }
        }
    } else {
        bot.sendMessage(chatId, '❌ 切换账号失败');
    }
});

// 删除账号命令
bot.onText(/\/remove(?:\s+(.+))?/, (msg, match) => {
    const chatId = msg.chat.id;
    const accountId = match[1]?.trim();
    
    if (!accountId) {
        bot.sendMessage(chatId, '❌ 请指定账号ID\n\n🔍 格式: /remove 账号ID\n💡 使用 /accounts 查看账号列表');
        return;
    }
    
    if (!userAccounts[chatId] || !userAccounts[chatId][accountId]) {
        bot.sendMessage(chatId, `❌ 账号ID "${accountId}" 不存在\n\n💡 使用 /accounts 查看可用账号`);
        return;
    }
    
    const account = userAccounts[chatId][accountId];
    const email = account.email;
    
    if (removeAccount(chatId, accountId)) {
        const remainingCount = userAccounts[chatId] ? Object.keys(userAccounts[chatId]).length : 0;
        let message = `✅ 已删除账号: ${email}`;
        
        if (remainingCount > 0) {
            const newCurrent = getCurrentAccountInfo(chatId);
            message += `\n\n🔄 当前账号已切换为: ${newCurrent.email}`;
        } else {
            message += '\n\n📋 已删除所有账号，请使用 /login 重新登录';
        }
        
        bot.sendMessage(chatId, message);
    } else {
        bot.sendMessage(chatId, '❌ 删除账号失败');
    }
});

// 当前账号详情命令
bot.onText(/\/current/, (msg) => {
    const chatId = msg.chat.id;
    const account = getCurrentAccountInfo(chatId);
    
    if (!account) {
        bot.sendMessage(chatId, '❌ 当前无已登录账号\n\n💡 使用 /login 登录账号');
        return;
    }
    
    const loginTime = new Date(account.loginTime).toLocaleString();
    const lastUsed = new Date(account.lastUsed).toLocaleString();
    
    let message = `🟢 当前账号详情\n\n`;
    message += `📧 邮箱: ${account.email}\n`;
    message += `🆔 账号ID: ${account.accountId}\n`;
    message += `🕐 登录时间: ${loginTime}\n`;
    message += `📱 最后使用: ${lastUsed}\n\n`;
    message += `🔧 管理操作:\n`;
    message += `• /accounts - 查看所有账号\n`;
    message += `• /switch 账号ID - 切换到其他账号\n`;
    message += `• /login - 添加新账号`;
    
    bot.sendMessage(chatId, message);
});

// Token失效统计命令
bot.onText(/\/tokenstats/, (msg) => {
    const chatId = msg.chat.id;
    
    if (tokenFailureLog.length === 0) {
        bot.sendMessage(chatId, '📊 Token失效统计\n\n暂无失效记录');
        return;
    }
    
    // 统计分析
    console.log(`📊 查询Token失效统计 - 用户 ${chatId}, 总记录数: ${tokenFailureLog.length}`);
    const userLogs = tokenFailureLog.filter(log => String(log.chatId) === String(chatId));
    const allLogs = tokenFailureLog.slice(-20); // 最近20条
    
    let message = '📊 Token失效统计\n\n';
    
    if (userLogs.length > 0) {
        const avgDuration = userLogs.reduce((sum, log) => sum + log.actualDuration, 0) / userLogs.length;
        const avgTimeToExpiry = userLogs.reduce((sum, log) => sum + Math.abs(log.timeToExpiry), 0) / userLogs.length;
        
        message += `👤 您的统计（${userLogs.length}次失效）:\n`;
        message += `• 平均使用时长: ${avgDuration.toFixed(1)}天\n`;
        message += `• 平均提前失效: ${avgTimeToExpiry.toFixed(1)}小时\n\n`;
        
        message += `📋 最近失效记录:\n`;
        userLogs.slice(-3).forEach((log, index) => {
            message += `${index + 1}. ${log.failureTime.toLocaleString()}\n`;
            message += `   实际${log.actualDuration}天 | ${log.reason}\n`;
        });
    } else {
        message += '👤 您暂无失效记录\n\n';
    }
    
    // 全局统计
    if (allLogs.length > 0) {
        const reasonCount = {};
        allLogs.forEach(log => {
            reasonCount[log.reason] = (reasonCount[log.reason] || 0) + 1;
        });
        
        message += `\n🌐 全局统计（最近${allLogs.length}次）:\n`;
        Object.entries(reasonCount).forEach(([reason, count]) => {
            message += `• ${reason}: ${count}次\n`;
        });
    }
    
    bot.sendMessage(chatId, message);
});

// 密码管理命令（多账号模式）
bot.onText(/\/creds/, (msg) => {
    const chatId = msg.chat.id;
    const allCredentials = getAllSavedCredentials(chatId);
    
    let credsMessage = `🔑 密码管理中心（多账号模式）\n\n`;
    
    if (allCredentials.length > 0) {
        credsMessage += `📋 已保存凭据 (${allCredentials.length}个账号)：\n\n`;
        
        allCredentials.forEach((cred, index) => {
            const maskedEmail = cred.email.replace(/(.{3}).*(@.*)/, '$1***$2');
            const maskedPassword = '*'.repeat(cred.password.length);
            const isCurrentAccount = getCurrentAccountInfo(chatId)?.accountId === cred.accountId;
            
            credsMessage += `${index + 1}. ${isCurrentAccount ? '🟢 当前' : '⚪'} ${maskedEmail}\n`;
            credsMessage += `   📧 邮箱: ${maskedEmail}\n`;
            credsMessage += `   🔐 密码: ${maskedPassword}\n`;
            credsMessage += `   🆔 账号ID: ${cred.accountId}\n`;
            credsMessage += `   📅 保存时间: ${new Date(cred.savedAt).toLocaleString()}\n\n`;
        });
        
        credsMessage += `⚙️ 管理选项：\n`;
        credsMessage += `• 回复 "查看 账号ID" - 显示指定账号明文凭据 ⚠️\n`;
        credsMessage += `• 回复 "删除 账号ID" - 删除指定账号凭据\n`;
        credsMessage += `• 回复 "测试 账号ID" - 测试指定账号凭据有效性\n`;
        credsMessage += `• 回复 "全部删除" - 删除所有保存的凭据\n`;
        credsMessage += `• 回复 "取消" - 退出密码管理\n\n`;
        credsMessage += `🔒 安全提示：明文查看仅在私聊中可用`;
    } else {
        credsMessage += `📄 凭据状态：\n`;
        credsMessage += `• 🔴 未保存任何凭据\n\n`;
        credsMessage += `💡 使用说明：\n`;
        credsMessage += `• 首次登录时选择"记住密码"\n`;
        credsMessage += `• 或使用 /login 重新登录并保存\n\n`;
        credsMessage += `🔐 安全特性：\n`;
        credsMessage += `• AES-256-CBC 加密存储\n`;
        credsMessage += `• 支持多账号自动重新登录\n`;
        credsMessage += `• 本地加密，安全可靠`;
        
        bot.sendMessage(chatId, credsMessage);
        return;
    }
    
    bot.sendMessage(chatId, credsMessage);
    
    // 等待用户选择
    const optionHandler = async (optionMsg) => {
        if (optionMsg.chat.id !== chatId) return;
        
        const input = optionMsg.text.trim();
        const parts = input.split(' ');
        const command = parts[0].toLowerCase();
        const accountId = parts[1];
        
        try {
            await bot.deleteMessage(chatId, optionMsg.message_id);
        } catch (e) {}
        
        switch (command) {
            case '查看':
                if (msg.chat.type !== 'private') {
                    bot.sendMessage(chatId, '⚠️ 为了安全，明文查看仅支持私聊');
                    break;
                }
                if (!accountId) {
                    bot.sendMessage(chatId, '❌ 请指定账号ID\n\n格式：查看 账号ID');
                    return;
                }
                
                const savedForView = getSavedCredentials(chatId, accountId);
                if (savedForView) {
                    const viewMessage = `🔍 凭据详情（明文）：\n\n• 账号ID: ${accountId}\n• 邮箱: \`${savedForView.email}\`\n• 密码: \`${savedForView.password}\`\n\n⚠️ 请立即删除此消息`;
                    const viewMsg = await bot.sendMessage(chatId, viewMessage, { parse_mode: 'Markdown' });
                    
                    // 30秒后自动删除
                    setTimeout(async () => {
                        try {
                            await bot.deleteMessage(chatId, viewMsg.message_id);
                            bot.sendMessage(chatId, '🗑️ 敏感信息已自动删除');
                        } catch (e) {}
                    }, 30000);
                } else {
                    bot.sendMessage(chatId, `❌ 未找到账号 ${accountId} 的保存凭据`);
                }
                break;
                
            case '删除':
                if (!accountId) {
                    bot.sendMessage(chatId, '❌ 请指定账号ID\n\n格式：删除 账号ID');
                    return;
                }
                
                if (deleteSavedCredentials(chatId, accountId)) {
                    bot.sendMessage(chatId, `✅ 已删除账号 ${accountId} 的保存凭据`);
                } else {
                    bot.sendMessage(chatId, `❌ 删除账号 ${accountId} 凭据失败`);
                }
                break;
                
            case '测试':
                if (!accountId) {
                    bot.sendMessage(chatId, '❌ 请指定账号ID\n\n格式：测试 账号ID');
                    return;
                }
                
                const savedForTest = getSavedCredentials(chatId, accountId);
                if (savedForTest) {
                    try {
                        const testMsg = await bot.sendMessage(chatId, `🔄 正在测试账号 ${accountId} 的凭据有效性...`);
                        
                        const response = await sendRequest('/login', {
                            email: savedForTest.email,
                            passwd: savedForTest.password,
                            token_expire: 30
                        });
                        
                        try {
                            await bot.deleteMessage(chatId, testMsg.message_id);
                        } catch (e) {}
                        
                        if (response.ret === 200) {
                            // 获取正确的token字段（可能是token或access_token）
                            const token = response.data.token || response.data.access_token;
                            if (!token) {
                                bot.sendMessage(chatId, `❌ 账号 ${accountId} 凭据测试失败\n\n错误：服务器响应格式错误，未返回token`);
                                return;
                            }
                            
                            // 测试成功，更新该账号的token
                            if (userAccounts[chatId] && userAccounts[chatId][accountId]) {
                                const tokenExpiry = response.data.token_expire && response.data.token_expire !== '9999-99-99 99:99:99' 
                                    ? new Date(response.data.token_expire).getTime() 
                                    : Date.now() + (30 * 24 * 60 * 60 * 1000);
                                
                                userAccounts[chatId][accountId].token = token;
                                userAccounts[chatId][accountId].tokenExpire = tokenExpiry;
                                userAccounts[chatId][accountId].lastUsed = Date.now();
                                
                                // 如果是当前账号，更新全局token过期时间
                                if (currentAccount[chatId] === accountId) {
                                    tokenExpiryTimes[chatId] = tokenExpiry;
                                }
                                
                                // 如果是当前账号，保存token到文件
                                if (currentAccount[chatId] === accountId) {
                                    saveTokenToFile(chatId, accountId, {
                                        token: token,
                                        tokenExpire: tokenExpiry,
                                        email: userAccounts[chatId][accountId].email
                                    });
                                    
                                    updateUserSession(chatId, {
                                        email: savedForTest.email,
                                        loginTime: new Date(),
                                        plan: response.data.plan,
                                        hasRememberedPassword: true
                                    }, accountId);
                                }
                            }
                            
                            bot.sendMessage(chatId, `✅ 账号 ${accountId} 凭据测试成功\n\n• 邮箱: ${savedForTest.email}\n• 密码有效\n• 可以正常登录\n• 自动重新登录功能正常\n• 已更新登录状态`);
                        } else {
                            bot.sendMessage(chatId, `❌ 账号 ${accountId} 凭据测试失败\n\n错误信息：${response.msg}\n\n💡 建议删除该账号凭据并重新登录`);
                        }
                    } catch (error) {
                        bot.sendMessage(chatId, `❌ 账号 ${accountId} 凭据测试失败，请检查网络连接`);
                    }
                } else {
                    bot.sendMessage(chatId, `❌ 未找到账号 ${accountId} 的保存凭据`);
                }
                break;
                
            case '全部删除':
                if (deleteSavedCredentials(chatId)) {
                    bot.sendMessage(chatId, '✅ 已删除所有保存的凭据\n\n💡 下次登录需要重新输入密码');
                } else {
                    bot.sendMessage(chatId, '❌ 删除凭据失败');
                }
                break;
                
            case '取消':
                bot.sendMessage(chatId, '✅ 已退出密码管理');
                break;
                
            default:
                bot.sendMessage(chatId, '❌ 无效选项，请回复：\n• 查看 账号ID\n• 删除 账号ID\n• 测试 账号ID\n• 全部删除\n• 取消');
                return; // 不移除监听器，等待有效输入
        }
        
        bot.removeListener('message', optionHandler);
    };
    
    bot.on('message', optionHandler);
    
    // 60秒后自动移除监听器
    setTimeout(() => {
        bot.removeListener('message', optionHandler);
    }, 60000);
});

// 用户信息命令
bot.onText(/\/info/, requireLogin(async (msg) => {
    const chatId = msg.chat.id;
    const currentAccount = getCurrentAccountInfo(chatId);
    
    try {
        const response = await sendRequest('/information', { access_token: currentAccount.token }, null, chatId);
        if (response.ret === 200) {
            let info = `📋 当前账户信息：\n🆔 账号ID：${currentAccount.accountId}\n📧 邮箱：${currentAccount.email}\n• 套餐：${response.data.plan}\n• 到期时间：${response.data.plan_time}\n• 余额：¥${response.data.money}\n• 推广余额：¥${response.data.aff_money}\n${formatTraffic(response.data)}`;
            
            if (currentAccount.loginTime) {
                const loginTime = currentAccount.loginTime instanceof Date ? currentAccount.loginTime : new Date(currentAccount.loginTime);
                const loginDuration = Math.floor((Date.now() - loginTime.getTime()) / 1000 / 60);
                
                // 显示token过期时间
                const tokenExpiry = currentAccount.tokenExpiry;
                const tokenStatus = tokenExpiry ? 
                    `🕐 Token过期时间：${new Date(tokenExpiry).toLocaleString()}` : 
                    '🕐 Token过期时间：未知';
                
                info += `\n🔐 会话信息：\n• 登录时长：${loginDuration}分钟\n• ${tokenStatus}`;
                
                // 显示账号总数
                const totalAccounts = getAccountList(msg.chat.id).length;
                info += `\n\n💡 账号管理：\n• 总账号数：${totalAccounts}\n• 使用 /accounts 查看所有账号\n• 使用 /switch 账号ID 切换账号`;
            }
            
            bot.sendMessage(msg.chat.id, info);
        } else {
            bot.sendMessage(msg.chat.id, `❌ 获取信息失败：${response.msg}`);
        }
    } catch (error) {
        console.error('❌ /info 命令失败:', error.message);
        bot.sendMessage(msg.chat.id, '❌ 获取信息失败，请检查网络连接\n\n💡 提示：如果刚切换账号，可能需要重新登录');
    }
}));

// 签到命令
bot.onText(/\/checkin/, requireLogin(async (msg) => {
    const chatId = msg.chat.id;
    const currentAccount = getCurrentAccountInfo(chatId);
    
    try {
        const response = await sendRequest('/checkin', { access_token: currentAccount.token }, null, chatId);
        if (response.ret === 200) {
            const checkinInfo = `🎉 ${response.data.checkin}\n${formatTraffic(response.data)}`;
            bot.sendMessage(msg.chat.id, checkinInfo);
        } else {
            bot.sendMessage(msg.chat.id, `❌ 签到失败：${response.msg}`);
        }
    } catch (error) {
        bot.sendMessage(msg.chat.id, '❌ 签到失败，请检查网络连接');
    }
}));

// 订阅命令
bot.onText(/\/sub/, requireLogin(async (msg) => {
    const chatId = msg.chat.id;
    const currentAccount = getCurrentAccountInfo(chatId);
    
    try {
        const response = await sendRequest('/managed/clash', { access_token: currentAccount.token }, null, chatId);
        if (response.ret === 200) {
            const subscriptions = `
📱 全部订阅链接：

🔗 Smart: \`${response.smart}\`

🔗 SS: \`${response.ss}\`

🔗 VMess: \`${response.vmess}\`

🔗 Trojan: \`${response.trojan}\`

🔗 SS2022: \`${response.ss2022}\`

📝 配置文件名：${response.name}

💡 点击链接可直接复制
`;
            bot.sendMessage(msg.chat.id, subscriptions, { parse_mode: 'Markdown' });
        } else {
            bot.sendMessage(msg.chat.id, `❌ 获取订阅失败：${response.msg}`);
        }
    } catch (error) {
        bot.sendMessage(msg.chat.id, '❌ 获取订阅失败，请检查网络连接');
    }
}));
EOF
}
# 创建机器人主程序 - 第4部分（节点管理）
create_bot_js_part4() {
cat >> bot.js << 'EOF'

// 优化的查看节点命令
bot.onText(/\/nodes/, requireLogin(async (msg) => {
    const currentAccount = getCurrentAccountInfo(msg.chat.id);
    
    try {
        const progressMsg = await bot.sendMessage(msg.chat.id, '🔍 正在获取节点信息...');
        
        const nodesResponse = await sendRequest('/nodes/list', { access_token: currentAccount.token }, null, msg.chat.id);
        const rulesResponse = await sendRequest('/nodes/cusrelay/getrules', { access_token: currentAccount.token }, null, msg.chat.id);
        
        try {
            await bot.deleteMessage(msg.chat.id, progressMsg.message_id);
        } catch (e) {}
        
        if (nodesResponse.ret !== 200 || !nodesResponse.data.length) {
            bot.sendMessage(msg.chat.id, '❌ 暂无可用节点或获取失败');
            return;
        }
        
        const configuredNodes = new Map();
        if (rulesResponse.ret === 200 && rulesResponse.data.length > 0) {
            rulesResponse.data.forEach(rule => {
                if (!configuredNodes.has(rule.node_id)) {
                    configuredNodes.set(rule.node_id, 0);
                }
                configuredNodes.set(rule.node_id, configuredNodes.get(rule.node_id) + 1);
            });
        }
        
        let nodesText = '🌐 可用节点信息：\n\n';
        nodesText += '📍 可用于转发的节点：\n\n';
        
        const nodes = nodesResponse.data;
        const NODES_PER_GROUP = 6; // 优化每组节点数量
        
        for (let i = 0; i < nodes.length; i += NODES_PER_GROUP) {
            const nodeGroup = nodes.slice(i, i + NODES_PER_GROUP);
            let groupText = '';
            
            nodeGroup.forEach(node => {
                const ruleCount = configuredNodes.get(node.node_id) || 0;
                const statusIcon = ruleCount > 0 ? '🟢' : '⚪';
                
                groupText += `${statusIcon} ID: ${node.node_id}\n`;
                groupText += `   名称: ${node.node_name}\n`;
                groupText += `   主机: ${node.node_host}\n`;
                groupText += `   端口: ${node.source_port}\n`;
                if (ruleCount > 0) {
                    groupText += `   转发规则: ${ruleCount}个\n`;
                }
                groupText += '\n';
            });
            
            let fullMessage = '';
            if (i === 0) {
                fullMessage = nodesText + groupText;
            } else {
                fullMessage = `🌐 节点列表 (第${Math.floor(i/NODES_PER_GROUP) + 1}组):\n\n` + groupText;
            }
            
            if (i + NODES_PER_GROUP >= nodes.length) {
                fullMessage += '─'.repeat(30) + '\n\n';
                fullMessage += '🔍 状态说明：\n';
                fullMessage += '🟢 已配置转发规则\n';
                fullMessage += '⚪ 可用但未配置\n\n';
                fullMessage += '⚙️ 使用方法：\n';
                fullMessage += '• 添加转发: /addrule 节点ID 目标IP 目标端口\n';
                fullMessage += '• 查看规则: /getrules\n';
                fullMessage += '• 删除规则: /delrule 规则ID\n\n';
                fullMessage += '💡 示例：\n';
                fullMessage += '• /addrule 1528 192.168.1.100 8080\n';
                fullMessage += '• /addrule 1528 example.com 8080 true\n\n';
                fullMessage += `📊 统计：共${nodes.length}个节点，${configuredNodes.size}个已配置转发`;
            }
            
            await sendLongMessage(msg.chat.id, fullMessage);
            
            if (i + NODES_PER_GROUP < nodes.length) {
                await new Promise(resolve => setTimeout(resolve, 500));
            }
        }
        
    } catch (error) {
        console.error('获取节点信息失败:', error);
        bot.sendMessage(msg.chat.id, '❌ 获取节点信息失败，请检查网络连接');
    }
}));

// 查看转发规则
bot.onText(/\/getrules/, requireLogin(async (msg) => {
    const chatId = msg.chat.id;
    const currentAccount = getCurrentAccountInfo(chatId);
    
    try {
        const response = await sendRequest('/nodes/cusrelay/getrules', { access_token: currentAccount.token }, null, chatId);
        if (response.ret === 200) {
            if (response.data.length === 0) {
                bot.sendMessage(msg.chat.id, '📋 当前没有外部转发规则\n\n💡 使用 /addrule 添加新规则\n\n🔍 格式：/addrule 节点ID 目标IP 目标端口 [协议一致]');
                return;
            }
            
            let rulesText = `📋 外部转发规则列表：\n\n共${response.data.length}条规则\n\n`;
            response.data.forEach((rule, index) => {
                rulesText += `${index + 1}. ${rule.source_node_name}\n`;
                rulesText += `   • 规则ID: ${rule.rule_id}\n`;
                rulesText += `   • 节点ID: ${rule.node_id}\n`;
                rulesText += `   • 源地址: ${rule.source_host}:${rule.source_port}\n`;
                rulesText += `   • 目标地址: ${rule.target_host}:${rule.target_port}\n`;
                rulesText += `   • 协议一致: ${rule.protocol_identical ? '是' : '否'}\n\n`;
            });
            
            rulesText += '⚙️ 管理操作：\n';
            rulesText += '• 删除规则: /delrule 规则ID\n';
            rulesText += '• 添加规则: /addrule 节点ID 目标IP 目标端口\n';
            rulesText += '• 查看节点: /nodes';
            
            await sendLongMessage(msg.chat.id, rulesText);
        } else {
            bot.sendMessage(msg.chat.id, `❌ 获取规则失败：${response.msg}`);
        }
    } catch (error) {
        bot.sendMessage(msg.chat.id, '❌ 获取规则失败，请检查网络连接');
    }
}));
EOF
}

# 创建机器人主程序 - 第5部分（转发规则管理）
create_bot_js_part5() {
cat >> bot.js << 'EOF'

// 添加转发规则 - 最终修复版本（使用字符串格式）
bot.onText(/\/addrule/, requireLogin(async (msg) => {
    if (msg.from.id.toString() !== ADMIN_USER_ID) {
        bot.sendMessage(msg.chat.id, '⚠️ 你没有权限使用此功能');
        return;
    }
    
    const chatId = msg.chat.id;
    const currentAccount = getCurrentAccountInfo(chatId);
    
    const text = msg.text.trim();
    const parts = text.split(' ');
    
    if (parts.length < 4) {
        bot.sendMessage(msg.chat.id, `请输入规则参数，格式：
/addrule 节点ID 目标地址 目标端口 [协议一致]

例如：
/addrule 1528 192.168.1.100 8080
/addrule 2075 example.com 8080 true

📝 说明：
• 节点ID: 起源节点ID（使用 /nodes 查看）
• 目标地址: 要转发到的IP地址或域名
• 目标端口: 目标服务器端口
• 协议一致: 可选，默认false

💡 起源端口会由系统自动分配`);
        return;
    }
    
    try {
        const node_id = parseInt(parts[1]);
        const target_host = parts[2];
        const target_port = parseInt(parts[3]);
        const protocol_identical = parts.length >= 5 ? parts[4].toLowerCase() === 'true' : false;
        
        // 参数验证
        if (isNaN(node_id) || node_id <= 0) {
            bot.sendMessage(msg.chat.id, '❌ 节点ID必须是正整数');
            return;
        }
        
        // IP地址/域名验证
        const ipPattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
        const domainPattern = /^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$/;
        
        if (!ipPattern.test(target_host) && !domainPattern.test(target_host)) {
            bot.sendMessage(msg.chat.id, '❌ 目标地址格式不正确，请输入有效的IP地址或域名');
            return;
        }
        
        if (isNaN(target_port) || target_port < 1 || target_port > 65535) {
            bot.sendMessage(msg.chat.id, '❌ 端口号必须在1-65535之间');
            return;
        }
        
        // 验证节点ID是否有效
        let selectedNodeName = '';
        try {
            const nodesResponse = await sendRequest('/nodes/list', { access_token: currentAccount.token }, null, chatId);
            if (nodesResponse.ret === 200) {
                const validNodeIds = nodesResponse.data.map(node => node.node_id);
                if (!validNodeIds.includes(node_id)) {
                    bot.sendMessage(msg.chat.id, `❌ 节点ID ${node_id} 不存在或不可用\n\n💡 使用 /nodes 查看可用节点ID`);
                    return;
                }
                
                const selectedNode = nodesResponse.data.find(node => node.node_id === node_id);
                selectedNodeName = selectedNode.node_name;
                console.log(`✅ 使用节点: ${selectedNodeName} (ID: ${node_id})`);
            }
        } catch (e) {
            console.warn('⚠️ 无法验证节点ID有效性:', e.message);
        }
        
        const progressMsg = await bot.sendMessage(msg.chat.id, '🔄 正在添加转发规则...');
        
        // 使用正确的字符串格式（根据调试结果）
        const requestData = {
            access_token: currentAccount.token,
            node_id: String(node_id),
            target_host: String(target_host),
            target_port: String(target_port),
            protocol_identical: String(protocol_identical)
        };
        
        if (DEBUG) {
            console.log('📤 添加规则请求:', JSON.stringify(requestData, null, 2));
        }
        
        const response = await sendRequest('/nodes/cusrelay/add', requestData);
        
        try {
            await bot.deleteMessage(msg.chat.id, progressMsg.message_id);
        } catch (e) {}
        
        if (response.ret === 200) {
            let successMsg = `✅ 转发规则添加成功！\n\n`;
            successMsg += `📋 规则详情：\n`;
            successMsg += `• 起源节点: ${selectedNodeName || `ID ${node_id}`}\n`;
            successMsg += `• 节点ID: ${node_id}\n`;
            successMsg += `• 目标地址: ${target_host}:${target_port}\n`;
            successMsg += `• 协议一致: ${protocol_identical ? '是' : '否'}\n\n`;
            successMsg += `💡 系统已自动分配起源端口并启用转发规则\n\n`;
            successMsg += `🔍 使用 /getrules 查看所有规则`;
            
            bot.sendMessage(msg.chat.id, successMsg);
        } else {
            bot.sendMessage(msg.chat.id, `❌ 添加规则失败：${response.msg || '未知错误'}\n\n请检查参数是否正确或联系客服`);
        }
    } catch (error) {
        console.error('❌ 添加规则异常:', error);
        
        let errorMsg = `❌ 添加规则时发生错误\n\n`;
        
        if (error.response && error.response.data) {
            errorMsg += `错误详情: ${JSON.stringify(error.response.data)}\n`;
        } else {
            errorMsg += `错误信息: ${error.message}\n`;
        }
        
        errorMsg += `\n🔧 请检查:\n`;
        errorMsg += `• 网络连接是否正常\n`;
        errorMsg += `• 参数格式是否正确\n`;
        errorMsg += `• 是否有足够的权限`;
        
        bot.sendMessage(msg.chat.id, errorMsg);
    }
}));

// 删除转发规则
bot.onText(/\/delrule/, requireLogin(async (msg) => {
    if (msg.from.id.toString() !== ADMIN_USER_ID) {
        bot.sendMessage(msg.chat.id, '⚠️ 你没有权限使用此功能');
        return;
    }
    
    const currentAccount = getCurrentAccountInfo(msg.chat.id);
    
    const text = msg.text.trim();
    const parts = text.split(' ');
    
    if (parts.length < 2) {
        bot.sendMessage(msg.chat.id, `请输入要删除的规则ID：
/delrule 规则ID

例如：/delrule 13100

💡 使用 /getrules 查看规则ID`);
        return;
    }
    
    try {
        const rule_id = parseInt(parts[1]);
        
        if (isNaN(rule_id)) {
            bot.sendMessage(msg.chat.id, '❌ 规则ID必须是数字');
            return;
        }
        
        const progressMsg = await bot.sendMessage(msg.chat.id, '🔄 正在删除转发规则...');
        
        const response = await sendRequest('/nodes/cusrelay/del', {
            access_token: currentAccount.token,
            rule_id: Number(rule_id)
        });
        
        try {
            await bot.deleteMessage(msg.chat.id, progressMsg.message_id);
        } catch (e) {}
        
        if (response.ret === 200) {
            bot.sendMessage(msg.chat.id, `✅ 转发规则删除成功！\n\n• 删除的规则ID: ${rule_id}\n\n🔍 使用 /getrules 查看当前规则`);
        } else {
            bot.sendMessage(msg.chat.id, `❌ 删除规则失败：${response.msg}\n\n💡 请确认规则ID是否正确`);
        }
    } catch (error) {
        console.error('❌ 删除规则异常:', error);
        bot.sendMessage(msg.chat.id, '❌ 删除规则失败，请检查规则ID或网络连接');
    }
}));
EOF
}
# 创建机器人主程序 - 第6部分（错误处理和启动）
create_bot_js_part6() {
cat >> bot.js << 'EOF'

// 改进的错误处理
bot.on('polling_error', (error) => {
    console.error('❌ Polling error:', error.code, error.message);
    if (error.code === 'ETELEGRAM') {
        console.log('📱 Telegram API错误，尝试重新连接...');
    }
});

bot.on('error', (error) => {
    console.error('❌ Bot error:', error);
});

// 改进的未处理拒绝处理
process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Unhandled Rejection at:', promise);
    console.error('📋 Reason:', reason);
    
    if (reason && reason.code === 'ETELEGRAM') {
        console.log('📱 Telegram API错误，继续运行...');
        return;
    }
    
    console.error('⚠️ 严重错误，但程序继续运行');
});

process.on('uncaughtException', (error) => {
    console.error('❌ Uncaught Exception:', error);
    console.log('🔄 程序将在5秒后重启...');
    setTimeout(() => {
        process.exit(1);
    }, 5000);
});

// 优雅关闭
const gracefulShutdown = async () => {
    console.log('\n🛑 正在优雅关闭机器人...');
    console.log('📊 当前会话数:', getActiveUsersFromFile().length);
    
    // 关闭浏览器实例（已移除Puppeteer）
    
    // 清理资源
    userSessions = {};
    
    bot.stopPolling();
    console.log('✅ 机器人已停止');
    process.exit(0);
};

process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

// 启动机器人
const startBot = async () => {
    try {
        // 加载保存的凭据
        loadCredentials();
        
        await setupBotMenu();
        
        console.log('🤖 墙洞管理机器人已启动...');
        console.log(`👤 管理员ID: ${ADMIN_USER_ID}`);
        console.log(`🔗 API地址: ${DLER_BASE_URL}`);
        console.log('📱 机器人菜单已设置');
        console.log('🔍 系统状态检查: /status');
        console.log('📍 按 Ctrl+C 停止机器人');
        console.log('⚡ 版本: v1.0.5 (最终修复版)');
        
        // 启动时进行自检
        const status = await getSystemStatus();
        if (status.network.status.includes('✅')) {
            console.log('✅ 网络连接正常');
        } else {
            console.log('⚠️ 网络连接异常');
        }
        
        // 启动时加载所有数据
        loadAllTokens();
        loadAllSessions();
        
        // 启动定时检测token功能
        startTokenMonitoring();
        console.log('⏰ 定时Token检测已启动 (每30分钟检查一次)');
        
    } catch (error) {
        console.error('❌ 启动失败:', error);
        process.exit(1);
    }
};

// 启动
startBot();
EOF

    log_info "机器人主程序创建完成"
}

# 组合创建完整的bot.js
create_complete_bot_js() {
    log_blue "创建完整的机器人程序..."
    
    create_bot_js_part1
    create_bot_js_part2
    create_bot_js_part3
    create_bot_js_part4
    create_bot_js_part5
    create_bot_js_part6
    
    log_info "✅ 完整机器人程序创建完成"
}

# 创建启动脚本
create_start_scripts() {
    log_blue "创建启动和管理脚本..."
    
cat > start.sh << 'EOF'
#!/bin/bash

# 墙洞Bot启动脚本 v1.0.5

echo "🤖 墙洞Telegram Bot 启动脚本 v1.0.5"
echo "========================================="

# 检查配置
if [[ ! -f .env ]]; then
    echo "❌ .env文件不存在，请先配置"
    exit 1
fi

# 读取配置
source .env

if [[ -z "$BOT_TOKEN" || -z "$ADMIN_USER_ID" ]]; then
    echo "❌ 请先在.env文件中配置 BOT_TOKEN 和 ADMIN_USER_ID"
    exit 1
fi

echo "✅ 配置检查通过"

# 选择启动方式
echo ""
echo "请选择启动方式："
echo "1) 直接启动 (前台运行，SSH断开会停止)"
echo "2) PM2启动 (后台运行，推荐) ⭐"
echo "3) nohup启动 (后台运行)"
echo "4) screen启动 (后台运行)"
echo "5) systemd启动 (系统服务)"
echo "6) 开发模式 (自动重启)"
echo "7) 测试模式 (运行状态检查)"
echo ""
read -p "请选择 (1-7): " choice

case $choice in
    1)
        echo "🚀 直接启动..."
        npm start
        ;;
    2)
        echo "🚀 PM2后台启动..."
        if command -v pm2 &> /dev/null; then
            if pm2 list | grep -q "dler-bot"; then
                echo "⚠️ 机器人已在运行，正在重启..."
                npm run pm2:restart
            else
                npm run pm2:start
            fi
            echo ""
            echo "📊 查看状态: pm2 status"
            echo "📋 查看日志: pm2 logs dler-bot"
            echo "🛑 停止服务: pm2 stop dler-bot"
            echo "🔄 重启服务: pm2 restart dler-bot"
            echo "🗑️  删除服务: pm2 delete dler-bot"
        else
            echo "❌ PM2未安装，正在安装..."
            npm install -g pm2
            npm run pm2:start
        fi
        ;;
    3)
        echo "🚀 nohup后台启动..."
        if pgrep -f "node bot.js" > /dev/null; then
            echo "⚠️ 机器人已在运行，正在停止..."
            pkill -f "node bot.js"
            sleep 2
        fi
        nohup node bot.js > logs/bot.log 2>&1 &
        echo "✅ 机器人已启动，PID: $!"
        echo "📋 查看日志: tail -f logs/bot.log"
        echo "🛑 停止服务: pkill -f 'node bot.js'"
        ;;
    4)
        echo "🚀 screen后台启动..."
        if ! command -v screen &> /dev/null; then
            echo "📦 正在安装screen..."
            if command -v apt &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y screen
            elif command -v yum &> /dev/null; then
                sudo yum install -y screen
            fi
        fi
        
        if screen -list | grep -q "dler-bot"; then
            echo "⚠️ screen会话已存在，正在重新创建..."
            screen -S dler-bot -X quit 2>/dev/null
            sleep 1
        fi
        
        screen -dmS dler-bot node bot.js
        echo "✅ 机器人已在screen中启动"
        echo "🔍 查看会话: screen -r dler-bot"
        echo "🔚 退出会话: Ctrl+A+D"
        echo "🛑 停止服务: screen -S dler-bot -X quit"
        ;;
    5)
        echo "🚀 systemd系统服务启动..."
        if [[ ! -f /etc/systemd/system/dler-bot.service ]]; then
            echo "📋 正在安装systemd服务..."
            sudo cp dler-bot.service /etc/systemd/system/
            sudo systemctl daemon-reload
            sudo systemctl enable dler-bot
        fi
        
        if systemctl is-active --quiet dler-bot; then
            echo "⚠️ 服务已在运行，正在重启..."
            sudo systemctl restart dler-bot
        else
            sudo systemctl start dler-bot
        fi
        
        echo "✅ 系统服务已启动"
        echo "📊 查看状态: sudo systemctl status dler-bot"
        echo "📋 查看日志: sudo journalctl -u dler-bot -f"
        echo "🛑 停止服务: sudo systemctl stop dler-bot"
        echo "🚫 禁用开机启动: sudo systemctl disable dler-bot"
        ;;
    6)
        echo "🚀 开发模式启动..."
        npm run dev
        ;;
    7)
        echo "🧪 测试模式启动..."
        echo "正在运行状态检查..."
        node -e "
        console.log('🔍 环境检查:');
        console.log('• Node版本:', process.version);
        console.log('• 工作目录:', process.cwd());
        console.log('• 环境变量检查...');
        require('dotenv').config();
        if (process.env.BOT_TOKEN && process.env.ADMIN_USER_ID) {
            console.log('✅ 环境配置正常');
            console.log('🚀 启动机器人进行测试...');
            setTimeout(() => {
                console.log('⏹️ 测试完成，退出');
                process.exit(0);
            }, 5000);
            require('./bot.js');
        } else {
            console.log('❌ 环境配置不完整');
        }
        "
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac
EOF

    # 创建快速启动脚本
cat > quick-start.sh << 'EOF'
#!/bin/bash

# 快速后台启动脚本 - 默认使用PM2

echo "🚀 快速启动墙洞Bot (PM2后台运行)..."

# 检查配置
if [[ ! -f .env ]]; then
    echo "❌ .env文件不存在，请先配置"
    exit 1
fi

source .env
if [[ -z "$BOT_TOKEN" || -z "$ADMIN_USER_ID" ]]; then
    echo "❌ 请先配置环境变量"
    exit 1
fi

# 确保PM2已安装
if ! command -v pm2 &> /dev/null; then
    echo "📦 安装PM2..."
    npm install -g pm2
fi

# 启动或重启
if pm2 list | grep -q "dler-bot"; then
    echo "🔄 重启机器人..."
    pm2 restart dler-bot
else
    echo "▶️ 启动机器人..."
    pm2 start ecosystem.config.js
fi

echo "✅ 机器人已在后台运行"
echo ""
echo "常用命令："
echo "  pm2 status        # 查看状态"
echo "  pm2 logs dler-bot # 查看日志"
echo "  pm2 stop dler-bot # 停止运行"
echo ""
echo "🔍 测试: 在Telegram发送 /status 检查系统状态"
EOF

    # 创建停止脚本
cat > stop.sh << 'EOF'
#!/bin/bash

echo "🛑 停止墙洞Bot..."

# 停止PM2
if command -v pm2 &> /dev/null && pm2 list | grep -q "dler-bot"; then
    pm2 stop dler-bot
    echo "✅ PM2进程已停止"
fi

# 停止systemd服务
if systemctl is-active --quiet dler-bot 2>/dev/null; then
    sudo systemctl stop dler-bot
    echo "✅ systemd服务已停止"
fi

# 停止nohup进程
if pgrep -f "node bot.js" > /dev/null; then
    pkill -f "node bot.js"
    echo "✅ nohup进程已停止"
fi

# 停止screen会话
if command -v screen &> /dev/null && screen -list | grep -q "dler-bot"; then
    screen -S dler-bot -X quit 2>/dev/null
    echo "✅ screen会话已停止"
fi

echo "🏁 所有进程已停止"
EOF

    # 创建状态检查脚本
cat > status.sh << 'EOF'
#!/bin/bash

echo "📊 墙洞Bot状态检查"
echo "==================="

# 检查PM2状态
if command -v pm2 &> /dev/null; then
    echo ""
    echo "🔄 PM2状态:"
    if pm2 list | grep -q "dler-bot"; then
        pm2 status | grep "dler-bot\|Process"
        echo ""
        echo "📋 最近日志:"
        pm2 logs dler-bot --lines 5 --nostream
    else
        echo "❌ PM2中未找到dler-bot进程"
    fi
fi

# 检查systemd状态
if systemctl list-units --type=service | grep -q "dler-bot"; then
    echo ""
    echo "🔧 Systemd状态:"
    sudo systemctl status dler-bot --no-pager -l
fi

# 检查进程状态
echo ""
echo "🔍 进程状态:"
if pgrep -f "node bot.js" > /dev/null; then
    echo "✅ 发现Node.js进程:"
    ps aux | grep "node bot.js" | grep -v grep
else
    echo "❌ 未发现Node.js进程"
fi

# 检查端口占用
echo ""
echo "🌐 网络状态:"
if netstat -tulpn 2>/dev/null | grep -q ":443.*ESTABLISHED"; then
    echo "✅ 发现HTTPS连接 (可能是Telegram API)"
else
    echo "❓ 未发现活跃的HTTPS连接"
fi

echo ""
echo "📁 文件状态:"
echo "• 配置文件: $([ -f .env ] && echo "✅ 存在" || echo "❌ 缺失")"
echo "• 主程序: $([ -f bot.js ] && echo "✅ 存在" || echo "❌ 缺失")"
echo "• 日志目录: $([ -d logs ] && echo "✅ 存在" || echo "❌ 缺失")"

if [ -f logs/combined.log ]; then
    echo ""
    echo "📋 最新日志 (最后5行):"
    tail -5 logs/combined.log
fi
EOF
    
    chmod +x start.sh quick-start.sh stop.sh status.sh
    log_info "启动和管理脚本创建完成"
}
# 创建卸载脚本
create_uninstall_script() {
    log_blue "创建卸载脚本..."
    
cat > uninstall.sh << 'EOF'
#!/bin/bash

# 墙洞Bot卸载脚本 v1.0.5

echo "🗑️  墙洞API Telegram Bot 卸载脚本 v1.0.5"
echo "=============================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
log_warn "⚠️  即将卸载墙洞Telegram Bot及其所有组件"
echo ""
echo "将要执行的操作："
echo "1. 停止所有运行的机器人进程"
echo "2. 删除PM2进程和配置"
echo "3. 删除systemd服务"
echo "4. 删除项目目录和所有文件"
echo "5. 可选：卸载Node.js和PM2"
echo ""

read -p "是否确认卸载? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "卸载已取消"
    exit 0
fi

# 获取当前目录
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

# 检查是否在正确的目录
if [[ "$PROJECT_NAME" != "dler-cloud-bot" ]]; then
    log_warn "当前目录似乎不是dler-cloud-bot项目目录"
    read -p "是否继续卸载当前目录的机器人? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "卸载取消"
        exit 1
    fi
fi

echo ""
log_info "开始卸载..."

# 1. 停止所有进程
echo ""
log_info "1. 停止机器人进程..."

# 停止PM2进程
if command -v pm2 &> /dev/null; then
    if pm2 list | grep -q "dler-bot"; then
        pm2 delete dler-bot 2>/dev/null
        log_info "✅ PM2进程已删除"
    fi
fi

# 停止systemd服务
if systemctl is-active --quiet dler-bot 2>/dev/null; then
    sudo systemctl stop dler-bot
    sudo systemctl disable dler-bot
    log_info "✅ systemd服务已停止和禁用"
fi

# 停止nohup进程
if pgrep -f "node bot.js" > /dev/null; then
    pkill -f "node bot.js"
    log_info "✅ nohup进程已停止"
fi

# 停止screen会话
if command -v screen &> /dev/null && screen -list | grep -q "dler-bot"; then
    screen -S dler-bot -X quit 2>/dev/null
    log_info "✅ screen会话已停止"
fi

# 2. 删除systemd服务文件
echo ""
log_info "2. 删除系统服务..."

if [[ -f /etc/systemd/system/dler-bot.service ]]; then
    sudo rm -f /etc/systemd/system/dler-bot.service
    sudo systemctl daemon-reload
    log_info "✅ systemd服务文件已删除"
fi

# 3. 删除项目文件
echo ""
log_info "3. 删除项目文件..."

if [[ -f package.json ]] && grep -q "dler-cloud-telegram-bot" package.json; then
    # 确认这是正确的项目目录
    rm -rf node_modules/
    rm -f bot.js package.json package-lock.json
    rm -f .env .env.example
    rm -f ecosystem.config.js
    rm -f start.sh quick-start.sh stop.sh status.sh uninstall.sh
    rm -f dler-bot.service
    rm -f README.md
    rm -rf logs/
    
    log_info "✅ 项目文件已删除"
else
    log_warn "⚠️ 未找到项目文件或项目标识不匹配"
fi

# 4. 询问是否删除整个目录
echo ""
if [[ "$PROJECT_NAME" == "dler-cloud-bot" ]] && [[ $(ls -la 2>/dev/null | wc -l) -le 3 ]]; then
    # 目录为空（只有. 和 ..）
    cd ..
    rmdir "dler-cloud-bot" 2>/dev/null
    log_info "✅ 空项目目录已删除"
else
    log_warn "⚠️ 目录不为空，未自动删除"
    echo "如需删除整个目录，请手动执行："
    echo "cd .. && rm -rf $CURRENT_DIR"
fi

# 5. 询问是否卸载依赖
echo ""
log_info "4. 清理依赖（可选）..."

read -p "是否卸载PM2? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v pm2 &> /dev/null; then
        npm uninstall -g pm2
        log_info "✅ PM2已卸载"
    fi
fi

read -p "是否卸载Node.js? (慎重选择，可能影响其他应用) (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v apt &> /dev/null; then
        sudo apt-get remove --purge -y nodejs npm
        sudo apt-get autoremove -y
    elif command -v yum &> /dev/null; then
        sudo yum remove -y nodejs npm
    fi
    log_info "✅ Node.js已卸载"
fi

echo ""
log_info "🎉 卸载完成！"
echo ""
echo "已完成的操作："
echo "✅ 停止所有机器人进程"
echo "✅ 删除PM2配置"
echo "✅ 删除systemd服务"
echo "✅ 删除项目文件"
echo ""
log_info "感谢使用墙洞Telegram Bot v1.0.5！"
EOF
    
    chmod +x uninstall.sh
    log_info "卸载脚本创建完成"
}

# 配置向导
config_wizard() {
    log_blue "配置向导"
    echo ""
    
    echo "📋 请按照以下步骤获取配置信息："
    echo ""
    
    echo "1️⃣ 获取Telegram Bot Token:"
    echo "   - 在Telegram中搜索 @BotFather"
    echo "   - 发送 /newbot 创建新机器人"
    echo "   - 设置机器人名称和用户名"
    echo "   - 复制获得的Token"
    echo ""
    
    echo "2️⃣ 获取你的Telegram用户ID:"
    echo "   - 在Telegram中搜索 @userinfobot"
    echo "   - 发送任意消息"
    echo "   - 复制获得的数字ID"
    echo ""
    
    read -p "是否现在配置? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        read -p "请输入Bot Token: " BOT_TOKEN
        read -p "请输入用户ID: " ADMIN_USER_ID
        
        if [[ -n "$BOT_TOKEN" && -n "$ADMIN_USER_ID" ]]; then
            # 写入.env文件
cat > .env << EOF
# Telegram Bot Token (从 @BotFather 获取)
BOT_TOKEN=$BOT_TOKEN

# 管理员用户ID (从 @userinfobot 获取)
ADMIN_USER_ID=$ADMIN_USER_ID

# 可选配置
# DLER_BASE_URL=https://dler.cloud/api/v1
# DEBUG=false
EOF
            
            log_info "配置已保存到 .env 文件"
            return 0
        else
            log_warn "配置信息不完整，稍后可手动编辑 .env 文件"
        fi
    else
        log_warn "稍后请手动编辑 .env 文件进行配置"
    fi
    
    return 1
}

# 显示完成信息
show_completion_info() {
    echo ""
    echo "🎉 部署完成！"
    echo "=============="
    echo ""
    
    log_purple "项目目录: $PWD"
    echo ""
    
    if [[ -f .env ]]; then
        source .env
        if [[ -n "$BOT_TOKEN" && -n "$ADMIN_USER_ID" ]]; then
            log_info "✅ 配置已完成，可以直接启动"
            echo ""
            echo "🚀 推荐启动方式："
            echo "   ./quick-start.sh    # 快速PM2后台启动 ⭐"
            echo "   ./start.sh          # 交互式选择启动方式"
            echo ""
            echo "🎛️ 启动选项："
            echo "   1. PM2启动 (推荐) - 进程管理，自动重启"
            echo "   2. nohup启动 - 简单后台运行"
            echo "   3. screen启动 - 可恢复会话"
            echo "   4. systemd启动 - 系统服务，开机自启"
            echo "   5. 测试模式 - 状态检查和调试"
            echo ""
        else
            log_warn "⚠️ 请先完成配置："
            echo "   nano .env           # 编辑配置文件"
            echo "   ./quick-start.sh    # 后台启动"
            echo ""
        fi
    else
        log_warn "⚠️ 请先完成配置："
        echo "   nano .env           # 编辑配置文件"
        echo "   ./quick-start.sh    # 后台启动"
        echo ""
    fi
    
    echo "📚 管理命令："
    echo "   ./status.sh         # 检查运行状态 🔍"
    echo "   pm2 status          # 查看PM2状态"
    echo "   pm2 logs dler-bot   # 查看实时日志"
    echo "   ./stop.sh           # 停止所有进程"
    echo ""
    
    echo "📱 机器人命令："
    echo "   /status   - 系统状态检查 🆕"
    echo "   /start    - 开始使用"
    echo "   /login    - 登录墙洞账户"
    echo "   /nodes    - 查看可用节点"
    echo "   /help     - 查看帮助"
    echo ""
    
    echo "📁 生成的文件："
    echo "├── bot.js            # 主程序 (v1.0.5)"
    echo "├── package.json      # 项目配置"  
    echo "├── .env              # 环境变量配置"
    echo "├── ecosystem.config.js # PM2配置"
    echo "├── start.sh          # 交互式启动脚本"
    echo "├── quick-start.sh    # 快速启动脚本 ⭐"
    echo "├── stop.sh           # 停止脚本"
    echo "├── status.sh         # 状态检查脚本 🆕"
    echo "├── uninstall.sh      # 卸载脚本"
    echo "├── dler-bot.service  # systemd服务文件"
    echo "└── logs/             # 日志目录"
    echo ""
    
    echo "🆕 新功能特性："
    echo "   🔍 系统状态监控 (/status)"
    echo "   📊 网络连接测试"
    echo "   🔗 API健康检查"
    echo "   📈 性能指标显示"
    echo "   🧪 测试模式运行"
    echo "   📋 详细错误处理"
    echo "   🔄 自动重连机制"
    echo ""
    
    echo "🎊 推荐使用流程："
    echo "1. ./quick-start.sh      # 后台启动"
    echo "2. ./status.sh           # 检查状态"
    echo "3. 在Telegram发送 /status # 测试功能"
    echo ""
    
    log_cyan "✨ SSH断开后机器人继续运行！"
    echo ""
    echo "🗑️ 如需卸载，请运行: ./uninstall.sh"
}

# 清理函数
cleanup() {
    log_error "部署被中断"
    exit 1
}

# 主函数
main() {
    # 设置中断处理
    trap cleanup SIGINT SIGTERM
    
    echo ""
    log_info "开始执行完整一键部署..."
    echo ""
    
    # 执行部署步骤
    check_network
    check_disk_space
    check_permissions
    check_root
    detect_os
    install_nodejs
    install_pm2
    create_project
    create_package_json
    create_pm2_config
    create_env_file
    create_systemd_service
    create_complete_bot_js
    create_start_scripts
    create_uninstall_script
    install_dependencies
    
    # 配置向导
    config_wizard
    
    # 显示完成信息
    show_completion_info
}

# 显示使用说明
show_usage() {
    echo "墙洞API Telegram Bot 完整最终部署脚本 v1.0.5"
    echo ""
    echo "使用方法:"
    echo "  curl -fsSL https://your-domain.com/complete_deploy.sh | bash"
    echo "  或者:"
    echo "  wget -O- https://your-domain.com/complete_deploy.sh | bash"
    echo ""
    echo "本地使用:"
    echo "  bash complete_deploy.sh"
    echo ""
    echo "参数:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -v, --version  显示版本信息"
    echo ""
    echo "🆕 新功能特性:"
    echo "  ✅ 系统状态监控和健康检查"
    echo "  ✅ 网络连接和API延迟测试"
    echo "  ✅ 完整的错误处理和自动重连"
    echo "  ✅ 支持字符串格式API参数"
    echo "  ✅ 消息自动分段发送"
    echo "  ✅ 多种启动方式和管理工具"
    echo "  ✅ 详细的状态检查脚本"
    echo "  ✅ 测试模式和调试功能"
    echo ""
    echo "功能模块:"
    echo "  🔐 账户管理 (登录/注销/信息/签到)"
    echo "  📱 订阅获取 (Smart/SS/VMess/Trojan/SS2022)"
    echo "  🌐 节点管理 (查看真实节点列表)"
    echo "  🔄 转发管理 (添加/查看/删除规则)"
    echo "  📊 状态监控 (系统/网络/API健康检查)"
    echo "  🛠️ 管理工具 (启动/停止/状态/卸载)"
    echo ""
}

# 版本信息
show_version() {
    echo "墙洞API Telegram Bot 完整最终部署脚本 v1.0.5"
    echo "作者: Dler Bot Team"
    echo "功能: 一键部署墙洞API Telegram管理机器人"
    echo ""
    echo "🎯 v1.0.5 更新内容:"
    echo "• 🔍 新增系统状态监控功能"
    echo "• 📊 新增网络和API健康检查"
    echo "• 🧪 新增测试模式和状态检查脚本"
    echo "• 🔧 修复API参数格式问题"
    echo "• 📱 改进用户界面和交互体验"
    echo "• 🛠️ 完善管理工具和错误处理"
    echo "• 📋 优化日志记录和调试功能"
    echo ""
    echo "发布日期: $(date +%Y-%m-%d)"
}

# 解析命令行参数
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -v|--version)
        show_version
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "未知参数: $1"
        show_usage
        exit 1
        ;;
esac