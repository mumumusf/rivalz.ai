#!/bin/bash

# 输出颜色设置
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置文件路径
CONFIG_FILE="$HOME/.rivalz/config"

# 日志函数
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    case $level in
        "INFO")  echo -e "${GREEN}[INFO]  ${timestamp} ${message}${NC}" | tee -a rivalz_monitor.log ;;
        "WARN")  echo -e "${YELLOW}[WARN]  ${timestamp} ${message}${NC}" | tee -a rivalz_monitor.log ;;
        "ERROR") echo -e "${RED}[ERROR] ${timestamp} ${message}${NC}" | tee -a rivalz_monitor.log ;;
        *)       echo -e "${BLUE}[DEBUG] ${timestamp} ${message}${NC}" | tee -a rivalz_monitor.log ;;
    esac
}

# 错误处理
handle_error() {
    local error_msg=$1
    log "ERROR" "$error_msg"
    exit 1
}

# 读取用户配置
read_user_config() {
    log "INFO" "配置系统参数..."
    
    # 显示系统信息
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    local total_cores=$(nproc)
    local total_disk=$(df -BG / | awk 'NR==2 {print $2}' | sed 's/G//')
    
    echo -e "\n${BLUE}系统总资源:${NC}"
    echo "可用内存: $total_ram MB"
    echo "CPU核心数: $total_cores"
    echo "磁盘空间: $total_disk GB"
    
    echo -e "\n${YELLOW}请设置资源分配:${NC}"
    
    # 内存分配
    while true; do
        read -p "分配内存大小(MB) [建议: $((total_ram/2))]: " RAM_LIMIT
        if [[ $RAM_LIMIT =~ ^[0-9]+$ ]] && [ $RAM_LIMIT -gt 512 ] && [ $RAM_LIMIT -le $total_ram ]; then
            break
        fi
        echo -e "${RED}无效输入！请输入512到$total_ram之间的数值${NC}"
    done
    
    # CPU分配
    while true; do
        read -p "分配CPU核心数 [建议: $((total_cores-1))]: " CPU_LIMIT
        if [[ $CPU_LIMIT =~ ^[0-9]+$ ]] && [ $CPU_LIMIT -gt 0 ] && [ $CPU_LIMIT -le $total_cores ]; then
            break
        fi
        echo -e "${RED}无效输入！请输入1到$total_cores之间的数值${NC}"
    done
    
    # 磁盘分配
    while true; do
        read -p "分配磁盘空间(GB) [建议: 10]: " DISK_LIMIT
        if [[ $DISK_LIMIT =~ ^[0-9]+$ ]] && [ $DISK_LIMIT -gt 5 ] && [ $DISK_LIMIT -le $total_disk ]; then
            break
        fi
        echo -e "${RED}无效输入！请输入5到$total_disk之间的数值${NC}"
    done
    
    # 监控参数设置
    echo -e "\n${YELLOW}监控参数设置:${NC}"
    while true; do
        read -p "检查间隔(秒) [建议: 30]: " CHECK_INTERVAL
        if [[ $CHECK_INTERVAL =~ ^[0-9]+$ ]] && [ $CHECK_INTERVAL -ge 10 ]; then
            break
        fi
        echo -e "${RED}无效输入！请输入大于等于10的数值${NC}"
    done
    
    while true; do
        read -p "最大重启次数(每5分钟) [建议: 5]: " MAX_RESTARTS
        if [[ $MAX_RESTARTS =~ ^[0-9]+$ ]] && [ $MAX_RESTARTS -gt 0 ]; then
            break
        fi
        echo -e "${RED}无效输入！请输入大于0的数值${NC}"
    done
    
    # 保存配置
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
RAM_LIMIT=$RAM_LIMIT
CPU_LIMIT=$CPU_LIMIT
DISK_LIMIT=$DISK_LIMIT
CHECK_INTERVAL=$CHECK_INTERVAL
MAX_RESTARTS=$MAX_RESTARTS
EOF
    
    log "INFO" "配置已保存到: $CONFIG_FILE"
}

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        read_user_config
    fi
}

# 系统检查
check_system_requirements() {
    log "INFO" "检查系统要求..."
    
    # 检查内存
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [ $total_ram -lt $RAM_LIMIT ]; then
        handle_error "系统内存不足，需要至少${RAM_LIMIT}MB内存"
    fi
    
    # 检查磁盘空间
    local free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $free_space -lt $DISK_LIMIT ]; then
        handle_error "磁盘空间不足，需要至少${DISK_LIMIT}GB可用空间"
    fi
    
    # 检查CPU核心数
    local cpu_cores=$(nproc)
    if [ $cpu_cores -lt $CPU_LIMIT ]; then
        handle_error "CPU核心数不足，需要至少${CPU_LIMIT}核"
    fi
    
    log "INFO" "系统要求检查通过"
}

# 优化系统设置
optimize_system() {
    log "INFO" "正在优化系统设置..."
    
    # 调整系统限制
    if [ -w /etc/security/limits.conf ]; then
        echo "* soft nofile 65535" >> /etc/security/limits.conf
        echo "* hard nofile 65535" >> /etc/security/limits.conf
    else
        log "WARN" "无法调整系统限制，需要root权限"
    fi
    
    # 调整TCP参数
    if [ -w /etc/sysctl.conf ]; then
        echo "net.ipv4.tcp_keepalive_time = 60" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_keepalive_intvl = 10" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_keepalive_probes = 6" >> /etc/sysctl.conf
        sysctl -p > /dev/null 2>&1
    else
        log "WARN" "无法调整TCP参数，需要root权限"
    fi
}

# 安装依赖
install_dependencies() {
    log "INFO" "开始安装依赖..."
    
    # 检查并安装Node.js
    if ! command -v node &> /dev/null; then
        log "INFO" "正在安装Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - || handle_error "Node.js安装源配置失败"
        sudo apt-get update || handle_error "apt更新失败"
        sudo apt-get install -y nodejs || handle_error "Node.js安装失败"
    fi
    
    # 检查Node.js版本
    local node_version=$(node -v)
    log "INFO" "Node.js版本: $node_version"
    
    # 安装必要的系统工具
    sudo apt-get install -y htop iftop net-tools || log "WARN" "系统工具安装失败"
}

# 智能监控函数
monitor_and_restart() {
    local restart_count=0
    local last_restart=0
    local restart_interval=300  # 5分钟
    
    # 设置资源限制
    if command -v cpulimit &> /dev/null; then
        cpulimit -e rivalz -l $((CPU_LIMIT * 100)) &
    fi
    
    if command -v cgroups-mount &> /dev/null; then
        cgcreate -g memory:rivalz
        echo $((RAM_LIMIT * 1024 * 1024)) > /sys/fs/cgroup/memory/rivalz/memory.limit_in_bytes
    fi
    
    while true; do
        # 检查进程状态
        if ! pgrep -f "rivalz run" > /dev/null; then
            local current_time=$(date +%s)
            
            # 检查重启频率
            if [ $((current_time - last_restart)) -lt $restart_interval ]; then
                restart_count=$((restart_count + 1))
                if [ $restart_count -gt $MAX_RESTARTS ]; then
                    log "ERROR" "检测到频繁重启，可能存在严重问题，请检查日志"
                    sleep 300
                    restart_count=0
                fi
            else
                restart_count=1
            fi
            
            last_restart=$current_time
            
            log "WARN" "Rivalz客户端已断开，正在重新启动... (重启次数: $restart_count)"
            pkill -f "rivalz"
            sleep 2
            
            # 检查系统资源
            local mem_usage=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
            local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
            
            if [ $mem_usage -gt 90 ] || [ $cpu_usage -gt 90 ]; then
                log "WARN" "系统资源使用率过高 (CPU: ${cpu_usage}%, 内存: ${mem_usage}%)"
                sleep 10
            fi
            
            # 重启客户端
            rivalz run > rivalz.log 2>&1 &
            log "INFO" "Rivalz客户端已重新启动"
            
            # 验证启动状态
            sleep 5
            if pgrep -f "rivalz run" > /dev/null; then
                log "INFO" "客户端启动成功"
            else
                log "ERROR" "客户端启动失败"
            fi
        fi
        
        # 定期检查系统状态
        if [ $((RANDOM % 60)) -eq 0 ]; then
            local disk_usage=$(df -h / | awk 'NR==2 {print int($5)}')
            if [ $disk_usage -gt $((DISK_LIMIT * 90 / 100)) ]; then
                log "WARN" "磁盘使用率接近限制: ${disk_usage}%"
            fi
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# 显示帮助信息
show_help() {
    echo -e "\n${YELLOW}可用命令:${NC}"
    echo "status    - 显示当前状态"
    echo "config    - 修改配置"
    echo "restart   - 重启客户端"
    echo "stop      - 停止客户端"
    echo "start     - 启动客户端"
    echo "log       - 查看日志"
    echo "monitor   - 查看监控日志"
    echo "system    - 查看系统状态"
    echo "limit     - 显示资源限制"
    echo "help      - 显示此帮助"
    echo "quit      - 退出控制台"
}

# 显示当前状态
show_status() {
    echo -e "\n${BLUE}当前状态:${NC}"
    if pgrep -f "rivalz run" > /dev/null; then
        echo -e "客户端状态: ${GREEN}运行中${NC}"
    else
        echo -e "客户端状态: ${RED}未运行${NC}"
    fi
    
    local mem_usage=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    local disk_usage=$(df -h / | awk 'NR==2 {print int($5)}')
    
    echo "CPU使用率: ${cpu_usage}%"
    echo "内存使用率: ${mem_usage}%"
    echo "磁盘使用率: ${disk_usage}%"
    echo "配置文件: $CONFIG_FILE"
}

# 显示资源限制
show_limits() {
    echo -e "\n${BLUE}资源限制:${NC}"
    echo "CPU限制: ${CPU_LIMIT}核"
    echo "内存限制: ${RAM_LIMIT}MB"
    echo "磁盘限制: ${DISK_LIMIT}GB"
    echo "检查间隔: ${CHECK_INTERVAL}秒"
    echo "最大重启次数: ${MAX_RESTARTS}次/5分钟"
}

# 交互式控制台
start_console() {
    local HISTFILE="$HOME/.rivalz_history"
    history -c
    echo -e "\n${GREEN}欢迎使用 Rivalz 控制台${NC}"
    echo -e "输入 'help' 查看可用命令\n"
    
    while true; do
        read -e -p "rivalz> " cmd
        history -s "$cmd"
        
        case $cmd in
            "status")
                show_status
                ;;
            "config")
                read_user_config
                ;;
            "restart")
                pkill -f "rivalz"
                sleep 2
                rivalz run > rivalz.log 2>&1 &
                log "INFO" "客户端已重启"
                ;;
            "stop")
                pkill -f "rivalz"
                log "INFO" "客户端已停止"
                ;;
            "start")
                if ! pgrep -f "rivalz run" > /dev/null; then
                    rivalz run > rivalz.log 2>&1 &
                    log "INFO" "客户端已启动"
                else
                    log "WARN" "客户端已在运行"
                fi
                ;;
            "log")
                tail -n 50 rivalz.log
                ;;
            "monitor")
                tail -n 50 rivalz_monitor.log
                ;;
            "system")
                htop
                ;;
            "limit")
                show_limits
                ;;
            "help")
                show_help
                ;;
            "quit"|"exit")
                echo -e "${GREEN}感谢使用，再见！${NC}"
                break
                ;;
            "")
                continue
                ;;
            *)
                echo -e "${RED}未知命令。输入 'help' 查看可用命令${NC}"
                ;;
        esac
    done
}

# 主程序
main() {
    log "INFO" "开始安装 Rivalz rClient..."
    
    # 加载或创建配置
    load_config
    
    # 系统检查和优化
    check_system_requirements
    optimize_system
    install_dependencies
    
    # 获取钱包地址
    read -p "请输入您的钱包地址: " WALLET_ADDRESS
    log "INFO" "输入的钱包地址: $WALLET_ADDRESS"

    # 验证钱包地址格式
    if [[ ! $WALLET_ADDRESS =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        log "ERROR" "无效的钱包地址格式"
        exit 1
    fi

    log "INFO" "钱包地址验证通过"

    # 检查 npm 是否安装
    if ! command -v npm &> /dev/null; then
        log "ERROR" "npm 未安装，请先安装 Node.js"
        exit 1
    fi

    # 显示 npm 版本
    log "INFO" "npm 版本: $(npm -v)"

    # 清理 npm 缓存
    log "INFO" "清理 npm 缓存..."
    npm cache clean --force

    # 设置 npm 源为官方源
    log "INFO" "设置 npm 源..."
    npm config set registry https://registry.npmjs.org/

    # 尝试安装 rivalz-node-cli
    log "INFO" "正在安装 rivalz-node-cli..."
    npm install -g rivalz-node-cli --verbose 2>&1 | tee npm_install.log || {
        log "ERROR" "安装 rivalz-node-cli 失败"
        log "ERROR" "安装日志已保存到 npm_install.log"
        log "ERROR" "请检查以下问题："
        log "ERROR" "1. 网络连接是否正常"
        log "ERROR" "2. npm 源是否可访问"
        log "ERROR" "3. 是否有足够的磁盘空间"
        exit 1
    }

    # 验证安装
    if ! command -v rivalz &> /dev/null; then
        log "ERROR" "rivalz 命令未找到，安装可能失败"
        log "ERROR" "请尝试手动运行: npm install -g rivalz-node-cli"
        exit 1
    fi

    # 显示安装的版本
    RIVALZ_VERSION=$(rivalz --version 2>&1 || echo "未知")
    log "INFO" "rivalz-node-cli 安装成功，版本: $RIVALZ_VERSION"

    # 创建配置目录
    mkdir -p ~/.rivalz || {
        log "ERROR" "创建配置目录失败"
        exit 1
    }

    # 保存钱包地址到配置
    echo "WALLET_ADDRESS=$WALLET_ADDRESS" > ~/.rivalz/wallet.conf || {
        log "ERROR" "保存钱包配置失败"
        exit 1
    }

    log "INFO" "钱包配置已保存"

    # 启动客户端
    log "INFO" "正在启动 Rivalz 客户端..."
    rivalz run --wallet $WALLET_ADDRESS > rivalz.log 2>&1 &
    CLIENT_PID=$!

    # 等待确认客户端是否成功启动
    sleep 5
    if ! ps -p $CLIENT_PID > /dev/null; then
        log "ERROR" "客户端启动失败，请检查 rivalz.log"
        cat rivalz.log
        exit 1
    fi

    log "INFO" "客户端启动成功，PID: $CLIENT_PID"
    log "INFO" "运行日志: $(pwd)/rivalz.log"
    log "INFO" "监控日志: $(pwd)/rivalz_monitor.log"
    log "INFO" "npm 安装日志: $(pwd)/npm_install.log"
}

# 启动主程序
main 