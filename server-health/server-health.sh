#!/bin/bash
# ============================================
#  Server Health Dashboard - 一键安装/使用
#  安装: bash <(curl -s URL)
#  运行: server-health
# ============================================

VERSION="1.0.0"
INSTALL_DIR="/usr/local/bin"

show_help() {
    cat << 'HELP'
用法: server-health [选项]

选项:
  -r, --run        单次运行，显示当前服务器状态
  -w, --watch      持续监控（每5秒刷新）
  -i, --install    安装到系统
  -h, --help       显示帮助

安装后用法: 直接在终端输入 server-health
HELP
}

collect_stats() {
    # CPU负载
    load=$(uptime | awk -F'load average:' '{print $2}')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_cores=$(nproc)

    # 内存
    mem_total=$(free -m | awk '/Mem:/{print $2}')
    mem_used=$(free -m | awk '/Mem:/{print $3}')
    mem_percent=$(( mem_used * 100 / mem_total ))

    # 磁盘
    disk_info=$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')
    disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')

    # 网络
    net_rx=$(ip -s link | awk '/RX:/{getline; print $1}' | head -1 | numfmt --to=iec 2>/dev/null || echo "N/A")
    net_tx=$(ip -s link | awk '/TX:/{getline; print $1}' | head -1 | numfmt --to=iec 2>/dev/null || echo "N/A")

    # 进程
    total_proc=$(ps aux | wc -l)

    # 运行时间
    uptime_str=$(uptime -p | sed 's/up //')
    uptime_sec=$(awk '{print int($1)}' /proc/uptime)

    # 温度
    temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.1f°C", $1/1000}' || echo "N/A")
}

show_dashboard() {
    clear
    collect_stats

    # 颜色
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🖥️  Server Health Dashboard${NC}        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  v$VERSION • $(hostname)            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""

    # CPU
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then color=$RED
    elif (( $(echo "$cpu_usage > 50" | bc -l) )); then color=$YELLOW
    else color=$GREEN; fi
    
    cpu_bar=$(printf "%-${cpu_percent}s" "=" | tr ' ' '=' | head -c $(( cpu_usage / 2 )))
    echo -e "  ${BOLD}CPU${NC}          $color$cpu_usage%${NC}"
    echo -e "  负载: $load  |  核心: $cpu_cores"

    # 内存
    if [ "$mem_percent" -gt 80 ]; then color=$RED
    elif [ "$mem_percent" -gt 60 ]; then color=$YELLOW
    else color=$GREEN; fi
    mem_bar=$(printf "%-$(( mem_percent / 2 ))s" "=" | tr ' ' '=')
    echo -e "  ${BOLD}内存${NC}        $color${mem_percent}%${NC}  (${mem_used}MB / ${mem_total}MB)"

    # 磁盘
    if [ "$disk_usage" -gt 80 ]; then color=$RED
    elif [ "$disk_usage" -gt 60 ]; then color=$YELLOW
    else color=$GREEN; fi
    echo -e "  ${BOLD}磁盘 ${NC}        $color${disk_usage}%${NC}  ($disk_info)"

    # 网络
    echo -e "  ${BOLD}网络${NC}        收: $net_rx  |  发: $net_tx"

    # 进程/运行时间
    echo -e "  ${BOLD}进程${NC}        $total_proc"
    echo -e "  ${BOLD}运行时间${NC}    $uptime_str"
    echo -e "  ${BOLD}温度${NC}        $temp"
    echo ""
    echo -e "  ${CYAN}━━━ Ctrl+C 退出 ━━━${NC}"
}

# 安装
install_self() {
    cp "$0" "$INSTALL_DIR/server-health"
    chmod +x "$INSTALL_DIR/server-health"
    echo "✅ 已安装到 $INSTALL_DIR/server-health"
    echo "用法: server-health --run"
}

# 主逻辑
case "${1:-}" in
    -r|--run|"")   show_dashboard ;;
    -w|--watch)    while true; do show_dashboard; sleep 5; done ;;
    -i|--install)  install_self ;;
    -h|--help)     show_help ;;
    *)             echo "未知选项: $1"; show_help; exit 1 ;;
esac
