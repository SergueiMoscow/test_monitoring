#!/bin/bash

# Скрипт для остановки и удаления мониторинга процесса test

source ./monitor.conf
# Останавливаем процесс test, если он запущен
if pgrep -x "test" > /dev/null; then
    echo "Останавливаем процесс test"
    pkill -x "test"
    if [ $? -eq 0 ]; then
        echo "Процесс test успешно остановлен"
    else
        echo "Ошибка при остановке процесса test"
    fi
else
    echo "Процесс test не запущен"
fi

# Останавливаем и отключаем таймер
sudo systemctl stop test_monitor.timer
sudo systemctl disable test_monitor.timer

# Удаляем systemd-юниты
sudo rm -f /etc/systemd/system/test_monitor.service
sudo rm -f /etc/systemd/system/test_monitor.timer

# Перезагружаем конфигурацию systemd
sudo systemctl daemon-reload

# Удаляем лог-файл
sudo rm -f $LOG_FILE

# Удаляем PID-файл
sudo rm -f /var/run/test_monitor.pid

# Удаляем скопированный скрипт
sudo rm -f /usr/local/bin/test_monitor.sh

# Удаляем файл конфигурации
sudo rm -f /etc/test_monitor.conf

echo "Мониторинг остановлен, файлы удалены."