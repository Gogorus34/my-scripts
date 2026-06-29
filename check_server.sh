#!/bin/bash
TOKEN="8676216143:AAFVVopZkEuRdLH5ZTsphUAGsrhZJAy2MQo"
CHAT_ID="5101122136"
send_message() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$1" > /dev/null 2>&1
}

if sudo systemctl is-active --quiet nginx; then
   echo "Сервер работает стабильно :3 Отправляю уведомление"
   send_message "Серверу заебись, Не переживай"
else 
    echo "сервер упал! Перезапускаю!"
    sudo systemctl restart nginx 
    echo "перезапускаю сервер..."
    send_message "[$(date '+%H:%M:%S') Nginx был перезапущен.."
fi


