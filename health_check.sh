#!/bin/bash

echo "=== ЗДОРОВЬЕ СИСТЕМЫ ==="

# CPU
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1)
echo "Загрузка CPU (средняя за 1 мин): $CPU_LOAD"

# RAM
FREE_RAM=$(free -m | grep Mem | awk '{print $4}')
echo "Свободно RAM: $FREE_RAM MB"

# DISK
DISK_USED=$(df -h / | grep / | awk '{print $5}' | cut -d% -f1)
echo "Занято диска: $DISK_USED%"

# Проверка RAM
if [ $FREE_RAM -lt 500 ]; then
    echo "⚠️ МАЛО ПАМЯТИ! Свободно меньше 500 MB"
fi

# Проверка диска
if [ $DISK_USED -gt 80 ]; then
    echo "⚠️ ДИСК ПЕРЕПОЛНЕН! Занято больше 80%"
fi

echo "=========================="
