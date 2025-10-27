#!/bin/bash

# Скрипт для развертывания мониторинга процесса test

# Подгружаем переменные окружения
if [ ! -f "monitor.conf" ]; then
    echo "Ошибка: Не найден файл конфигурации monitor.conf"
    exit 1
fi
source ./monitor.conf

# Проверяем, что все необходимые файлы существуют
if [ ! -f "test" ] || [ ! -f "test_monitor.sh" ] || [ ! -f "test_monitor.service" ] || [ ! -f "test_monitor.timer" ]; then
    echo "Ошибка: Не найдены все необходимые файлы (test, test_monitor.sh, test_monitor.service, test_monitor.timer)"
    exit 1
fi

# Получаем текущую директорию
echo "Текущая директория: $(pwd)"
CURRENT_DIR=$(pwd)
TARGET_SCRIPT="/usr/local/bin/test_monitor.sh"

# Проверяем, не запущен ли уже процесс test
if ! pgrep -x "test" > /dev/null; then
    echo "Запускаем скрипт test в фоновом режиме"
    "$CURRENT_DIR/test" &
    TEST_PID=$!
    echo "Скрипт test запущен с PID: $TEST_PID"
else
    echo "Скрипт test уже запущен"
    # Если процесс уже запущен, находим его текущий PID
    TEST_PID=$(pgrep -x "test" | head -n 1)
fi

echo "Копируем test_monitor.sh в $TARGET_SCRIPT"
sudo cp test_monitor.sh "$TARGET_SCRIPT"
sudo chmod +x "$TARGET_SCRIPT"

# Копируем systemd-units в /etc/systemd/system/
echo "Копируем: /etc/systemd/system/test_monitor.service и .timer"
sudo cp test_monitor.service /etc/systemd/system/test_monitor.service
sudo cp test_monitor.timer /etc/systemd/system/test_monitor.timer

echo "Создаём лог-файл: $LOG_FILE и PID-файл: $PID_FILE"
sudo touch "$LOG_FILE"
sudo chmod 664 "$LOG_FILE"

sudo touch "$PID_FILE"
echo "$TEST_PID" | sudo tee "$PID_FILE" > /dev/null
sudo chmod 664 "$PID_FILE"

# Копируем конфигурацию
echo "Копируем monitor.conf в /etc/test_monitor.conf"
sudo cp monitor.conf /etc/test_monitor.conf
sudo chmod 644 /etc/test_monitor.conf

# Перезагружаем конфигурацию systemd
sudo systemctl daemon-reload

# Активируем и запускаем таймер
echo "Активируем и запускаем таймер"
sudo systemctl enable test_monitor.timer
sudo systemctl start test_monitor.timer

echo "Мониторинг успешно развернут. Таймер запущен."