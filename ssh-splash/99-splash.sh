#!/bin/bash

# Only run for interactive SSH sessions
[[ $- != *i* ]] && return
[[ -z "$SSH_CONNECTION" ]] && return

clear

# Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"

# System information
HOSTNAME=$(hostname)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2- | tr -d '"')
KERNEL=$(uname -r)
CPU=$(lscpu | awk -F: '/Model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}')
MEM_USED=$(free -h | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_PERCENT=$(df -h / | awk 'NR==2 {print $5}')
UPTIME=$(uptime -p | sed 's/^up //')
LOAD=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
IP=$(hostname -I 2>/dev/null | awk '{print $1}')

# CPU usage
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {printf "%.1f%%", 100-$8}')

# Header
echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v figlet >/dev/null 2>&1; then
    figlet -f big "$HOSTNAME"
else
    echo "=== $HOSTNAME ==="
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

printf "🖥  Hostname        : ${GREEN}%s${RESET}\n" "$HOSTNAME"
printf "🌐 IP Address      : ${GREEN}%s${RESET}\n" "$IP"
printf "💻 OS              : %s\n" "$OS"
printf "🐧 Kernel          : %s\n" "$KERNEL"
printf "⚡ CPU             : %s\n" "$CPU"
printf "🔥 CPU Usage       : %s\n" "$CPU_USAGE"
printf "🧠 Memory          : ${YELLOW}%s / %s${RESET}\n" "$MEM_USED" "$MEM_TOTAL"
printf "💾 Root Disk       : ${YELLOW}%s / %s (%s)${RESET}\n" \
    "$DISK_USED" "$DISK_TOTAL" "$DISK_PERCENT"
printf "📈 Load Average    : %s\n" "$LOAD"
printf "⏱  Uptime          : %s\n" "$UPTIME"

# Temperature in Fahrenheit
TEMP=""

if command -v sensors >/dev/null 2>&1; then
    TEMP=$(sensors -f 2>/dev/null |
        awk '/Package id 0:/ {print $4; exit}')
fi

if [[ -n "$TEMP" ]]; then
    printf "🌡  CPU Temp        : %s\n" "$TEMP"
fi

# K3s
if command -v k3s >/dev/null 2>&1; then
    K3S_VERSION=$(k3s --version 2>/dev/null | awk 'NR==1 {print $3}')
    printf "☸  K3s Version     : ${MAGENTA}%s${RESET}\n" "$K3S_VERSION"
fi

# Running services
if command -v systemctl >/dev/null 2>&1; then
    SERVICES=$(systemctl --type=service --state=running --no-legend 2>/dev/null | wc -l)
    printf "⚙️ Services        : %s running\n" "$SERVICES"

    FAILED=$(systemctl --failed --no-legend 2>/dev/null | wc -l)

    if (( FAILED > 0 )); then
        printf "🚨 Failed Services : ${RED}%s${RESET}\n" "$FAILED"
    else
        printf "✅ Failed Services : ${GREEN}0${RESET}\n"
    fi
fi

# Available package updates
if command -v apt >/dev/null 2>&1; then
    UPDATES=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)

    if (( UPDATES > 0 )); then
        printf "📦 Updates         : ${YELLOW}%s available${RESET}\n" "$UPDATES"
    else
        printf "📦 Updates         : ${GREEN}System up to date${RESET}\n"
    fi
fi

# Reboot required
if [[ -f /var/run/reboot-required ]]; then
    printf "🔄 Reboot          : ${RED}${BOLD}REQUIRED${RESET}\n"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"


# Random quote
if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    QUOTE_JSON=$(curl -s --max-time 2 https://dummyjson.com/quotes/random)

    if [[ -n "$QUOTE_JSON" ]]; then
        QUOTE=$(echo "$QUOTE_JSON" | jq -r '.quote // empty')
        AUTHOR=$(echo "$QUOTE_JSON" | jq -r '.author // empty')

        if [[ -n "$QUOTE" ]]; then
            echo
            echo -e "${CYAN}💬 Quote of the login:${RESET}"
            echo "\"$QUOTE\"" | fold -s -w 58 | sed 's/^/   /'

            if [[ -n "$AUTHOR" ]]; then
                printf "   - %s\n" "$AUTHOR"
            fi
        fi
    fi
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo