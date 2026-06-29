#!/bin/bash

# ====================
# КОНФИГИ (ВСТАВЬ СВОИ ДАННЫЕ)
# ====================
TOKEN="8676216143:AAFVVopZkEuRdLH5ZTsphUAGsrhZJAy2MQo"
CHAT_ID="5101122136"
LOG_FILE="$HOME/monitor.log"

# ====================
# ФУНКЦИЯ ОТПРАВКИ В ТЕЛЕГРАМ
# ====================
send_to_telegram() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$1" > /dev/null 2>&1
}

# ====================
# 1. СБОР ДАННЫХ ПО СИСТЕМЕ
# ====================
get_system_health() {
    CPU=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
    RAM=$(free -m | grep Mem | awk '{print $4}')
    DISK=$(df -h / | grep / | awk '{print $5}' | cut -d% -f1)
    NGINX_STATUS=$(sudo systemctl is-active nginx)
    if [ "$NGINX_STATUS" = "active" ]; then
        NGINX="🟢 Работает"
    else
        NGINX="🔴 НЕ РАБОТАЕТ!"
    fi

    # Формируем красивое сообщение
    MSG="📊 *ОТЧЁТ О ЗДОРОВЬЕ СИСТЕМЫ*
🕒 Время: $(date '+%Y-%m-%d %H:%M:%S')
━━━━━━━━━━━━━━━━━━━━
💻 *CPU:* $CPU
🧠 *RAM:* $RAM MB свободно
💾 *Диск:* $DISK% занято
🖥️ *Nginx:* $NGINX
━━━━━━━━━━━━━━━━━━━━
@$(whoami) (${HOSTNAME})"
    
    echo "$MSG"
}

# ====================
# 2. ЗАПИСЬ В ЛОГ
# ====================
write_log() {
    # Если файла нет — создаём его с правами для текущего пользователя
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CPU: $CPU | RAM: $RAM MB | DISK: $DISK% | Nginx: $NGINX_STATUS" >> "$LOG_FILE"
}

# ====================
# 3. ОТПРАВКА В ТЕЛЕГРАМ
# ====================
send_report() {
    REPORT=$(get_system_health)
    send_to_telegram "$REPORT"
}

# ====================
# 4. ЗАПУСК ВСЕХ ФУНКЦИЙ (С ОТЛАДОЧНЫМ ВЫВОДОМ)
# ====================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🔍 Начинаю сбор данных..."
    
    CPU=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
    echo "✅ CPU: $CPU"
    
    RAM=$(free -m | grep Mem | awk '{print $4}')
    echo "✅ RAM: $RAM MB"
    
    DISK=$(df -h / | grep / | awk '{print $5}' | cut -d% -f1)
    echo "✅ DISK: $DISK%"
    
    NGINX_STATUS=$(sudo systemctl is-active nginx)
    echo "✅ NGINX: $NGINX_STATUS"
    
    echo "📝 Записываю лог..."
    write_log
    
    echo "📨 Отправляю в Telegram..."
    send_report
    
    echo "✅ Готово! Отчёт отправлен и лог записан."
fi

