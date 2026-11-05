# Руководство по настройке серверов для AuraVPN

## 1. Российский сервер (Zapret + VLESS для YouTube 4K & Discord)

На сервере в РФ запускаем установку Zapret (обход DPI ТСПУ) и VLESS-прокси:

```bash
# 1. Обновляем пакеты
sudo apt update && sudo apt install -y curl git iptables

# 2. Устанавливаем Zapret (автоматический установщик bol-van/zapret)
git clone https://github.com/bol-van/zapret.git
cd zapret
sudo ./install_easy.sh
# Выбираем:
# - режим: nfqws
# - интерфейс: eth0 (или ваш основной интерфейс)
# - стратегия: desync (fake, split2 для YouTube и Discord)

# 3. Ставим легковесный прокси (Xray / 3X-UI) для подключения айфона
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

В панели 3X-UI создаем профиль **VLESS Reality** (порт 443, маскировка под любой популярный домен, например `dl.google.com` или `microsoft.com`).

---

## 2. Немецкий сервер (Германия для Instagram, ChatGPT и остального мира)

На сервере в Германии ставим стандартный VLESS Reality:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```
Создаем подключение VLESS Reality.

---

## 3. Как собрать приложение под iPhone прямо сейчас:

1. Залейте папку `AuraVPN` на свой GitHub:
   ```bash
   cd AuraVPN
   git init
   git add .
   git commit -m "Initial AuraVPN with Dribbble UI"
   git remote add origin https://github.com/ВАШ_НИК/AuraVPN.git
   git push -u origin main
   ```
2. В репозитории на GitHub перейдите во вкладку **Actions**.
3. Запустится рабочий процесс **Build iOS .IPA** на виртуальном Mac от GitHub.
4. Через 2-3 минуты в блоке **Artifacts** появится готовый файл **`AuraVPN.ipa`**!
5. Скачайте его на Windows и установите на iPhone через бесплатную программу **Sideloadly** (просто перетащите файл мышкой и нажмите Start).
