#!/usr/bin/env bash

###################################
### Global values
###################################
export DEBIAN_FRONTEND=noninteractive
VERSION_MANAGER='1.4.3'
VERSION=v2.4.11
DEFAULT_FLAGS="/usr/local/reverse_proxy/default.conf"
DEST_DB="/etc/x-ui/x-ui.db"
DIR_REVERSE_PROXY="/usr/local/reverse_proxy/"
SCRIPT_URL="https://raw.githubusercontent.com/cortez24rus/xui-reverse-proxy/refs/heads/main/reverse_proxy.sh"
DB_SCRIPT_URL="https://raw.githubusercontent.com/cortez24rus/xui-reverse-proxy/refs/heads/main/database/x-ui.db"

###################################
### Initialization and Declarations
###################################
declare -A defaults
declare -A args
declare -A regex
declare -A generate

###################################
### Regex Patterns for Validation
###################################
regex[domain]="^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+\.[a-zA-Z]{2,})$"
regex[port]="^[1-9][0-9]*$"
regex[warp_license]="^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{8}-[a-zA-Z0-9]{8}$"
regex[username]="^[a-zA-Z0-9]+$"
regex[ip]="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
regex[tgbot_token]="^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$"
regex[tgbot_admins]="^[a-zA-Z][a-zA-Z0-9_]{4,31}(,[a-zA-Z][a-zA-Z0-9_]{4,31})*$"
regex[domain_port]="^[a-zA-Z0-9]+([-.][a-zA-Z0-9]+)*\.[a-zA-Z]{2,}(:[1-9][0-9]*)?$"
regex[file_path]="^[a-zA-Z0-9_/.-]+$"
regex[url]="^(http|https)://([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(:[0-9]{1,5})?(/.*)?$"
generate[path]="tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 30"

###################################
### INFO
###################################
out_data()   { echo -e "\e[1;33m$1\033[0m \033[1;37m$2\033[0m"; }
tilda()      { echo -e "\033[31m\033[38;5;214m$*\033[0m"; }
warning()    { echo -e "\033[31m [!]\033[38;5;214m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; exit 1; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
question()   { echo -e "\033[32m[?]\e[1;33m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp " $(question "$1")" "$2"; }
text()       { eval echo "\${${L}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${L}[$*]}")"; }

###################################
### Languages
###################################
E[0]="Language:\n  1. English (default) \n  2. Русский"
R[0]="Язык:\n  1. English (по умолчанию) \n  2. Русский"
E[1]="Choose an action:"
R[1]="Выбери действие:"
E[2]="Error: this script requires superuser (root) privileges to run."
R[2]="Ошибка: для выполнения этого скрипта необходимы права суперпользователя (root)."
E[3]="Unable to determine IP address."
R[3]="Не удалось определить IP-адрес."
E[4]="Reinstalling script..."
R[4]="Повторная установка скрипта..."
E[5]="WARNING!"
R[5]="ВНИМАНИЕ!"
E[6]="It is recommended to perform the following actions before running the script"
R[6]="Перед запуском скрипта рекомендуется выполнить следующие действия"
E[7]="Annihilation of the system!"
R[7]="Аннигиляция системы!"
E[8]="Start the XRAY installation? Choose option [y/N]:"
R[8]="Начать установку XRAY? Выберите опцию [y/N]:"
E[9]="CANCEL"
R[9]="ОТМЕНА"
E[10]="\n|-----------------------------------------------------------------------------|\n"
R[10]="\n|-----------------------------------------------------------------------------|\n"
E[11]="Enter username:"
R[11]="Введите имя пользователя:"
E[12]="Enter user password:"
R[12]="Введите пароль пользователя:"
E[13]="Enter your domain A record:"
R[13]="Введите доменную запись типа A:"
E[14]="Error: the entered address '$temp_value' is incorrectly formatted."
R[14]="Ошибка: введённый адрес '$temp_value' имеет неверный формат."
E[15]="Enter your email registered with Cloudflare:"
R[15]="Введите вашу почту, зарегистрированную на Cloudflare:"
E[16]="Enter your Cloudflare API token (Edit zone DNS) or global API key:"
R[16]="Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:"
E[17]="Verifying domain, API token/key, and email..."
R[17]="Проверка домена, API токена/ключа и почты..."
E[18]="Error: invalid domain, API token/key, or email. Please try again."
R[18]="Ошибка: неправильно введён домен, API токен/ключ или почта. Попробуйте снова."
E[19]="Enter SNI for Reality (do not enter your domain):"
R[19]="Введите SNI для Reality (не вводите ваш домен):"
E[20]="Error: failed to connect to WARP. Manual acceptance of the terms of service is required."
R[20]="Ошибка: не удалось подключиться к WARP. Требуется вручную согласиться с условиями использования."
E[21]="Access link to node exporter:"
R[21]="Доступ по ссылке к node exporter:"
E[22]="Access link to shell in a box:"
R[22]="Доступ по ссылке к shell in a box:"
E[23]="Creating a backup and rotation."
R[23]="Создание резевной копии и ротация."
E[24]="Enter Node Exporter path:"
R[24]="Введите путь к Node Exporter:"
E[25]="Enter Adguard-home path:"
R[25]="Введите путь к Adguard-home:"
E[26]="Enter panel path:"
R[26]="Введите путь к панели:"
E[27]="Enter subscription path:"
R[27]="Введите путь к подписке:"
E[28]="Enter JSON subscription path:"
R[28]="Введите путь к JSON подписке:"
E[29]="Error: path cannot be empty, please re-enter."
R[29]="Ошибка: путь не может быть пустым, повторите ввод."
E[30]="Error: path must not contain characters {, }, /, $, \\, please re-enter."
R[30]="Ошибка: путь не должен содержать символы {, }, /, $, \\, повторите ввод."
E[31]="DNS server:\n  1. Systemd-resolved \n  2. Adguard-home"
R[31]="DNS сервер:\n  1. Systemd-resolved \n  2. Adguard-home"
E[32]="Systemd-resolved selected."
R[32]="Выбран systemd-resolved."
E[33]="Error: invalid choice, please try again."
R[33]="Ошибка: неверный выбор, попробуйте снова."
E[34]="Enter the Telegram bot token for the control panel:"
R[34]="Введите токен Telegram бота для панели управления:"
E[35]="Enter your Telegram ID:"
R[35]="Введите ваш Telegram ID:"
E[36]="Updating system and installing necessary packages."
R[36]="Обновление системы и установка необходимых пакетов."
E[37]="Configuring DNS."
R[37]="Настройка DNS."
E[38]="Download failed, retrying..."
R[38]="Скачивание не удалось, пробуем снова..."
E[39]="Adding user."
R[39]="Добавление пользователя."
E[40]="Enabling automatic security updates."
R[40]="Автоматическое обновление безопасности."
E[41]="Enabling BBR."
R[41]="Включение BBR."
E[42]="Disabling IPv6."
R[42]="Отключение IPv6."
E[43]="Configuring WARP."
R[43]="Настройка WARP."
E[44]="Issuing certificates."
R[44]="Выдача сертификатов."
E[45]="Configuring NGINX."
R[45]="Настройка NGINX."
E[46]="Setting up the panel for Xray."
R[46]="Настройка панели для Xray."
E[47]="Configuring UFW."
R[47]="Настройка UFW."
E[48]="Configuring SSH."
R[48]="Настройка SSH."
E[49]="Generate a key for your OS (ssh-keygen)."
R[49]="Сгенерируйте ключ для своей ОС (ssh-keygen)."
E[50]="In Windows, install the openSSH package and enter the command in PowerShell (recommended to research key generation online)."
R[50]="В Windows нужно установить пакет openSSH и ввести команду в PowerShell (рекомендуется изучить генерацию ключей в интернете)."
E[51]="If you are on Linux, you probably know what to do C:"
R[51]="Если у вас Linux, то вы сами все умеете C:"
E[52]="Command for Windows:"
R[52]="Команда для Windows:"
E[53]="Command for Linux:"
R[53]="Команда для Linux:"
E[54]="Configure SSH (optional step)? [y/N]:"
R[54]="Настроить SSH (необязательный шаг)? [y/N]:"
E[55]="Error: Keys not found. Please add them to the server before retrying..."
R[55]="Ошибка: ключи не найдены, добавьте его на сервер, прежде чем повторить..."
E[56]="Key found, proceeding with SSH setup."
R[56]="Ключ найден, настройка SSH."
E[57]="Installing bot."
R[57]="Установка бота."
E[58]="SAVE THIS SCREEN!"
R[58]="СОХРАНИ ЭТОТ ЭКРАН!"
E[59]="Access the panel at the link:"
R[59]="Доступ по ссылке к панели:"
E[60]="Quick subscription link for connection:"
R[60]="Быстрая ссылка на подписку для подключения:"
E[61]="Access Adguard-home at the link:"
R[61]="Доступ по ссылке к adguard-home:"
E[62]="SSH connection:"
R[62]="Подключение по SSH:"
E[63]="Username:"
R[63]="Имя пользователя:"
E[64]="Password:"
R[64]="Пароль:"
E[65]="Log file path:"
R[65]="Путь к лог файлу:"
E[66]="Prometheus monitor."
R[66]="Мониторинг Prometheus."
E[67]="Set up the Telegram bot? [y/N]:"
R[67]="Настроить telegram бота? [y/N]:"
E[68]="Bot:\n  1. IP limit (default) \n  2. Torrent ban"
R[68]="Бот:\n  1. IP limit (по умолчанию) \n  2. Torrent ban"
E[69]="Enter the Telegram bot token for IP limit, Torrent ban:"
R[69]="Введите токен Telegram бота для IP limit, Torrent ban:"
E[70]="Secret key:"
R[70]="Секретный ключ:"
E[71]="Current operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/cortez24rus/xui-reverse-proxy/issues]"
R[71]="Текущая операционная система: \$SYS.\\\n Система с версией ниже, чем \$SYSTEM \${MAJOR[int]}, не поддерживается. Обратная связь: [https://github.com/cortez24rus/xui-reverse-proxy/issues]"
E[72]="Install dependence-list:"
R[72]="Список зависимостей для установки:"
E[73]="All dependencies already exist and do not need to be installed additionally."
R[73]="Все зависимости уже установлены и не требуют дополнительной установки."
E[74]="OS - $SYS"
R[74]="OS - $SYS"
E[75]="Invalid option for --$key: $value. Use 'true' or 'false'."
R[75]="Неверная опция для --$key: $value. Используйте 'true' или 'false'."
E[76]="Unknown option: $1"
R[76]="Неверная опция: $1"
E[77]="List of dependencies for installation:"
R[77]="Список зависимостей для установки:"
E[78]="All dependencies are already installed and do not require additional installation."
R[78]="Все зависимости уже установлены и не требуют дополнительной установки."
E[79]="Configuring site template."
R[79]="Настройка шаблона сайта."
E[80]="Random template name:"
R[80]="Случайное имя шаблона:"
E[81]="Enter your domain CNAME record:"
R[81]="Введите доменную запись типа CNAME:"
E[82]="Enter Shell in a box path:"
R[82]="Введите путь к Shell in a box:"
E[83]="Terminal emulator Shell in a box."
R[83]="Эмулятор терминала Shell in a box."
E[84]="0. Exit script"
R[84]="0. Выход из скрипта"
E[85]="Press Enter to return to the menu..."
R[85]="Нажмите Enter, чтобы вернуться в меню..."
E[86]="Reverse proxy manager $VERSION_MANAGER"
R[86]="Reverse proxy manager $VERSION_MANAGER"
E[87]="1. Standard installation"
R[87]="1. Стандартная установка"
E[88]="2. Restore from a rescue copy."
R[88]="2. Восстановление из резевной копии."
E[89]="3. Migration to a new version with client retention."
R[89]="3. Миграция на новую версию с сохранением клиентов."
E[90]="4. Change the domain name for the proxy."
R[90]="4. Изменить доменное имя для прокси."
E[91]="5. Forced reissue of certificates."
R[91]="5. Принудительный перевыпуск сертификатов."
E[92]="6. Integrate custom JSON subscription."
R[92]="6. Интеграция кастомной JSON подписки."
E[93]="7. Copy someone else's website to your server."
R[93]="7. Скопировать чужой сайт на ваш сервер."
E[94]="8. Disable IPv6."
R[94]="8. Отключение IPv6."
E[95]="9. Enable IPv6."
R[95]="9. Включение IPv6."
E[96]="10. Find out the size of the directory."
R[96]="10. Узнать размер директории."
E[97]="Client migration initiation (experimental feature)."
R[97]="Начало миграции клиентов (экспериментальная функция)."
E[98]="Client migration is complete."
R[98]="Миграция клиентов завершена."
E[99]="Settings custom JSON subscription."
R[99]="Настройки пользовательской JSON-подписки."
E[100]="Restore from backup."
R[100]="Восстановление из резервной копии."
E[101]="Backups:"
R[101]="Резервные копии:"
E[102]="Enter the number of the archive to restore:"
R[102]="Введите номер архива для восстановления:"
E[103]="Restoration is complete."
R[103]="Восстановление завершено."
E[104]="Restoration is complete."
R[104]="Выбран архив:"
E[105]="11. Traffic statistics."
R[105]="11. Статистика трафика."
E[106]="Traffic statistics:\n  1. By years \n  2. By months \n  3. By days \n  4. By hours"
R[106]="Статистика трафика:\n  1. По годам \n  2. По месяцам \n  3. По дням \n  4. По часам"

###################################
### Help output
###################################
show_help() {
  echo
  echo "Usage: reverse_proxy [-u|--utils <true|false>] [-d|--dns <true|false>] [-a|--addu <true|false>]"
  echo "         [-r|--autoupd <true|false>] [-b|--bbr <true|false>] [-i|--ipv6 <true|false>] [-w|--warp <true|false>]"
  echo "         [-c|--cert <true|false>] [-m|--mon <true|false>] [-l|--shell <true|false>] [-n|--nginx <true|false>]"
  echo "         [-p|--panel <true|false>] [--custom <true|false>] [-f|--firewall <true|false>] [-s|--ssh <true|false>]"
  echo "         [-t|--tgbot <true|false>] [-g|--generate <true|false>] [-x|--skip-check <true|false>] [-o|--subdomain <true|false>]"
  echo "         [--update] [-h|--help]"
  echo
  echo "  -u, --utils <true|false>       Additional utilities                             (default: ${defaults[utils]})"
  echo "                                 Дополнительные утилиты"
  echo "  -d, --dns <true|false>         DNS encryption                                   (default: ${defaults[dns]})"
  echo "                                 Шифрование DNS"
  echo "  -a, --addu <true|false>        User addition                                    (default: ${defaults[addu]})"
  echo "                                 Добавление пользователя"
  echo "  -r, --autoupd <true|false>     Automatic updates                                (default: ${defaults[autoupd]})"
  echo "                                 Автоматические обновления"
  echo "  -b, --bbr <true|false>         BBR (TCP Congestion Control)                     (default: ${defaults[bbr]})"
  echo "                                 BBR (управление перегрузкой TCP)"
  echo "  -i, --ipv6 <true|false>        Disable IPv6 support                             (default: ${defaults[ipv6]})"
  echo "                                 Отключить поддержку IPv6 "
  echo "  -w, --warp <true|false>        WARP setting                                     (default: ${defaults[warp]})"
  echo "                                 Настройка WARP"
  echo "  -c, --cert <true|false>        Certificate issuance for domain                  (default: ${defaults[cert]})"
  echo "                                 Выпуск сертификатов для домена"
  echo "  -m, --mon <true|false>         Monitoring services (node_exporter)              (default: ${defaults[mon]})"
  echo "                                 Сервисы мониторинга (node_exporter)"
  echo "  -l, --shell <true|false>       Shell In A Box installation                      (default: ${defaults[shell]})"
  echo "                                 Установка Shell In A Box"
  echo "  -n, --nginx <true|false>       NGINX installation                               (default: ${defaults[nginx]})"
  echo "                                 Установка NGINX"
  echo "  -p, --panel <true|false>       Panel installation for user management           (default: ${defaults[panel]})"
  echo "                                 Установка панели для управления пользователями"
  echo "      --custom <true|false>      Custom JSON subscription                         (default: ${defaults[custom]})"
  echo "                                 Кастомная JSON-подписка"  
  echo "  -f, --firewall <true|false>    Firewall configuration                           (default: ${defaults[firewall]})"
  echo "                                 Настройка файрвола"
  echo "  -s, --ssh <true|false>         SSH access                                       (default: ${defaults[ssh]})"
  echo "                                 SSH доступ"
  echo "  -t, --tgbot <true|false>       Telegram bot integration                         (default: ${defaults[tgbot]})"
  echo "                                 Интеграция Telegram бота"
  echo "  -g, --generate <true|false>    Generate a random string for configuration       (default: ${defaults[generate]})"
  echo "                                 Генерация случайных путей для конфигурации"
  echo "  -x, --skip-check <true|false>  Disable the check functionality                  (default: ${defaults[skip-check]})"
  echo "                                 Отключение проверки"
  echo "  -o, --subdomain <true|false>   Support for subdomains                           (default: ${defaults[subdomain]})"
  echo "                                 Поддержка субдоменов"
  echo "      --update                   Update version of Reverse-proxy manager (Version on github: ${VERSION_MANAGER})"
  echo "                                 Обновить версию Reverse-proxy manager (Версия на github: ${VERSION_MANAGER})"
  echo "  -h, --help                     Display this help message"
  echo "                                 Показать это сообщение помощи"
  echo
  exit 0
}

###################################
### Reverse_proxy manager
###################################
update_reverse_proxy() {
  info "Script update and integration."

  CURRENT_VERSION=$(wget -qO- $SCRIPT_URL | grep -E "^\s*VERSION_MANAGER=" | cut -d'=' -f2)
  warning "Script version: $CURRENT_VERSION"
  UPDATE_SCRIPT="${DIR_REVERSE_PROXY}reverse_proxy"
  wget -O $UPDATE_SCRIPT $SCRIPT_URL
  ln -sf $UPDATE_SCRIPT /usr/local/bin/reverse_proxy
  chmod +x "$UPDATE_SCRIPT"
  add_cron_rule "0 0 * * * reverse_proxy --update"

  tilda "\n|-----------------------------------------------------------------------------|\n"
}

###################################
### Reading values ​​from file
################################### 
read_defaults_from_file() {
  if [[ -f $DEFAULT_FLAGS ]]; then
    # Чтение и выполнение строк из файла
    while IFS= read -r line; do
      # Пропускаем пустые строки и комментарии
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      eval "$line"
    done < $DEFAULT_FLAGS
  else
    # Если файл не найден, используем значения по умолчанию
    defaults[utils]=true
    defaults[dns]=true
    defaults[addu]=true
    defaults[autoupd]=true
    defaults[bbr]=true
    defaults[ipv6]=true
    defaults[warp]=false
    defaults[cert]=true
    defaults[mon]=false
    defaults[shell]=false
    defaults[nginx]=true
    defaults[panel]=true
    defaults[custom]=true
    defaults[firewall]=true
    defaults[ssh]=true
    defaults[tgbot]=false
    defaults[generate]=true
    defaults[skip-check]=false
    defaults[subdomain]=false
  fi
}

###################################
### Writing values ​​to a file
###################################
write_defaults_to_file() {
  cat > ${DEFAULT_FLAGS}<<EOF
defaults[utils]=false
defaults[dns]=false
defaults[addu]=false
defaults[autoupd]=false
defaults[bbr]=false
defaults[ipv6]=false
defaults[warp]=false
defaults[cert]=false
defaults[mon]=false
defaults[shell]=false
defaults[nginx]=true
defaults[panel]=true
defaults[custom]=true
defaults[firewall]=false
defaults[ssh]=false
defaults[tgbot]=false
defaults[generate]=true
defaults[skip-check]=false
defaults[subdomain]=false
EOF
}

###################################
### Lowercase characters
################################### 
normalize_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

###################################
### Validation of true/false value
###################################
validate_true_false() {
  local key=$1
  local value=$2
  case ${value} in
    true)
      args[$key]=true
      ;;
    false)
      args[$key]=false
      ;;
    *)
      warning " $(text 75) "
      return 1
      ;;
  esac
}

###################################
### Parse args
###################################
declare -A arg_map=(
  [-u]=utils      [--utils]=utils
  [-d]=dns        [--dns]=dns
  [-a]=addu       [--addu]=addu
  [-r]=autoupd    [--autoupd]=autoupd
  [-b]=bbr        [--bbr]=bbr
  [-i]=ipv6       [--ipv6]=ipv6
  [-w]=warp       [--warp]=warp
  [-c]=cert       [--cert]=cert
  [-m]=mon        [--mon]=mon
  [-l]=shell      [--shell]=shell
  [-n]=nginx      [--nginx]=nginx
  [-p]=panel      [--panel]=panel
                  [--custom]=custom
  [-f]=firewall   [--firewall]=firewall
  [-s]=ssh        [--ssh]=ssh
  [-t]=tgbot      [--tgbot]=tgbot
  [-g]=generate   [--generate]=generate
  [-x]=skip-check [--skip-check]=skip-check
  [-o]=subdomain  [--subdomain]=subdomain
)

parse_args() {
  local opts
  opts=$(getopt -o hu:d:a:r:b:i:w:c:m:l:n:p:f:s:t:g:x:o --long utils:,dns:,addu:,autoupd:,bbr:,ipv6:,warp:,cert:,mon:,shell:,nginx:,panel:,custom:,firewall:,ssh:,tgbot:,generate:,skip-check:,subdomain:,update,depers,help -- "$@")

  if [[ $? -ne 0 ]]; then
    return 1
  fi

  eval set -- "$opts"
  while true; do
    case $1 in
      --update)
        echo
        update_reverse_proxy
        exit 0
        ;;
      --depers)
        echo "Depersonalization database..."
        depersonalization_db
        exit 0
        ;;
      -h|--help)
        return 1
        ;;
      --)
        shift
        break
        ;;
      *)
        if [[ -n "${arg_map[$1]}" ]]; then
          local key="${arg_map[$1]}"
          args[$key]="$2"
          normalize_case "$key"
          validate_true_false "$key" "$2" || return 1
          shift 2
          continue
        fi
        warning " $(text 76) "
        return 1
        ;;
    esac
  done

  for key in "${!defaults[@]}"; do
    if [[ -z "${args[$key]}" ]]; then
      args[$key]=${defaults[$key]}
    fi
  done
}

###################################
### Logging
###################################
log_entry() {
  mkdir -p ${DIR_REVERSE_PROXY}
  LOGFILE="${DIR_REVERSE_PROXY}reverse_proxy.log"
  exec > >(tee -a "$LOGFILE") 2>&1
}

###################################
### Language selection
###################################
select_language() {
  L=E
  hint " $(text 0) \n"  # Показывает информацию о доступных языках
  reading " $(text 1) " LANGUAGE  # Запрашивает выбор языка

  # Устанавливаем язык в зависимости от выбора
  case "$LANGUAGE" in
    1) L=E ;;   # Если выбран английский
    2) L=R ;;   # Если выбран русский
#    3) L=C ;;   # Если выбран китайский
#    4) L=F ;;   # Если выбран персидский
    *) L=E ;;   # По умолчанию — английский
  esac
}

###################################
### Checking the operating system
###################################
check_operating_system() {
  if [ -s /etc/os-release ]; then
    SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  elif [ -x "$(type -p hostnamectl)" ]; then
    SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  elif [ -x "$(type -p lsb_release)" ]; then
    SYS="$(lsb_release -sd)"
  elif [ -s /etc/lsb-release ]; then
    SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  elif [ -s /etc/redhat-release ]; then
    SYS="$(grep . /etc/redhat-release)"
  elif [ -s /etc/issue ]; then
    SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"
  fi

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky")
  RELEASE=("Debian" "Ubuntu" "CentOS")
  EXCLUDE=("---")
  MAJOR=("10" "20" "7")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update --skip-broken")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  # Проверка на кастомизированные системы от различных производителей
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  # Определение основной версии Linux
  MAJOR_VERSION=$(sed "s/[^0-9.]//g" <<< "$SYS" | cut -d. -f1)

  # Сначала исключаем системы, указанные в EXCLUDE, затем для оставшихся делаем сравнение по основной версии
  for ex in "${EXCLUDE[@]}"; do [[ ! "${SYS,,}" =~ $ex ]]; done &&
  [[ "$MAJOR_VERSION" -lt "${MAJOR[int]}" ]] && error " $(text 71) "
}

###################################
### Checking and installing dependencies
###################################
check_dependencies() {
  # Зависимости, необходимые для трех основных систем
  [ "${SYSTEM}" = 'CentOS' ] && ${PACKAGE_INSTALL[int]} vim-common epel-release
  DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip" "sudo")
  DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2" "sudo")

  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=(${DEPS_INSTALL[g]})
  done

  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 72) ${DEPS[@]} \n"
    ${PACKAGE_UPDATE[int]}
    ${PACKAGE_INSTALL[int]} ${DEPS[@]}
  else
    info "\n $(text 73) \n"
  fi
}

###################################
### Root check
###################################
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error " $(text 8) "
  fi
}

###################################
### Obtaining your external IP address
###################################
check_ip() {
  IP4_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
  IP4=$(ip route get 8.8.8.8 2>/dev/null | grep -Po -- 'src \K\S*')

  if [[ ! $IP4 =~ $IP4_REGEX ]]; then
      IP4=$(curl -s --max-time 5 ipinfo.io/ip 2>/dev/null)
  fi

  if [[ ! $IP4 =~ $IP4_REGEX ]]; then
    echo "Не удалось получить внешний IP."
    return 1
  fi
}

###################################
### Banner
###################################
banner_xray() {
  echo
  echo " █░█ █░░█ ░▀░ ░░ █▀▀█ █▀▀ ▀█░█▀ █▀▀ █▀▀█ █▀▀ █▀▀ ░░ █▀▀█ █▀▀█ █▀▀█ █░█ █░░█  "
  echo " ▄▀▄ █░░█ ▀█▀ ▀▀ █▄▄▀ █▀▀ ░█▄█░ █▀▀ █▄▄▀ ▀▀█ █▀▀ ▀▀ █░░█ █▄▄▀ █░░█ ▄▀▄ █▄▄█  "
  echo " ▀░▀ ░▀▀▀ ▀▀▀ ░░ ▀░▀▀ ▀▀▀ ░░▀░░ ▀▀▀ ▀░▀▀ ▀▀▀ ▀▀▀ ░░ █▀▀▀ ▀░▀▀ ▀▀▀▀ ▀░▀ ▄▄▄█  "
  echo
  echo
}

###################################
### Installation request
###################################
warning_banner() {
  warning " $(text 5) "
  echo
  info " $(text 6) "
  warning " apt-get update && apt-get full-upgrade -y && reboot "
}

###################################
### Cron rules
###################################
add_cron_rule() {
  local rule="$1"
  ( crontab -l | grep -Fxq "$rule" ) || ( crontab -l 2>/dev/null; echo "$rule" ) | crontab -
}

###################################
### Request and response from Cloudflare API
###################################
get_test_response() {
  testdomain=$(echo "${DOMAIN}" | rev | cut -d '.' -f 1-2 | rev)

  if [[ "$CFTOKEN" =~ [A-Z] ]]; then
    test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "Authorization: Bearer ${CFTOKEN}" --header "Content-Type: application/json")
  else
    test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "X-Auth-Key: ${CFTOKEN}" --header "X-Auth-Email: ${EMAIL}" --header "Content-Type: application/json")
  fi
}

###################################
### Function to clean the URL (removes the protocol, port, and path)
###################################
clean_url() {
  local INPUT_URL_L="$1"  # Входной URL, который нужно очистить от префикса, порта и пути.
  # Убираем префикс https:// или http:// и порт/путь
  local CLEANED_URL_L=$(echo "$INPUT_URL_L" | sed -E 's/^https?:\/\///' | sed -E 's/(:[0-9]+)?(\/[a-zA-Z0-9_\-\/]+)?$//')
  echo "$CLEANED_URL_L"  # Возвращаем очищенный URL (без префикса, порта и пути).
}

###################################
### Function to crop the domain to the last two parts
###################################
crop_domain() {
  local DOMAIN_L=$1  # Получаем домен как аргумент
  IFS='.' read -r -a parts <<< "$DOMAIN_L"  # Разбиваем домен на части по точкам.

  # Если в домене больше двух частей (например, для субдоменов), обрезаем до последних двух.
  if [ ${#parts[@]} -gt 2 ]; then
    DOMAIN_L="${parts[${#parts[@]}-2]}.${parts[${#parts[@]}-1]}"  # Берем последние две части домена.
  else
    DOMAIN_L="${parts[0]}.${parts[1]}"  # Если домен второго уровня, оставляем только его.
  fi

  echo "$DOMAIN_L"  # Возвращаем результат через echo.
}

###################################
### Domain validation in cloudflare
###################################
check_cf_token() {
  # Пока не получим правильный ответ, продолжаем выполнение.
  while ! echo "$test_response" | grep -qE "\"${testdomain}\"|\"#dns_records:edit\"|\"#dns_records:read\"|\"#zone:read\""; do
    local TEMP_DOMAIN_L_L  # Переменная для временного домена
    DOMAIN=""  # Обнуляем переменную домена
    SUB_DOMAIN=""  # Обнуляем переменную субдомена

    # Если флаг subdomain равен true, запрашиваем субдомен и домен.
    if [[ ${args[subdomain]} == "true" ]]; then
      reading " $(text 13) " TEMP_DOMAIN_L  # Запрашиваем домен
      DOMAIN=$(clean_url "$TEMP_DOMAIN_L")  # Очищаем домен
      echo
      reading " $(text 81) " TEMP_DOMAIN_L  # Запрашиваем субдомен
      SUB_DOMAIN=$(clean_url "$TEMP_DOMAIN_L")  # Очищаем субдомен
    else
      # Если subdomain не задан, продолжаем работать с доменом.
      while [[ -z "$TEMP_DOMAIN_L" ]]; do
        reading " $(text 13) " TEMP_DOMAIN_L  # Запрашиваем домен
        TEMP_DOMAIN_L=$(clean_url "$TEMP_DOMAIN_L")  # Очищаем домен
      done

      # Проверяем, если домен соответствует регулярному выражению
      if [[ "$TEMP_DOMAIN_L" =~ ${regex[domain]} ]]; then
        DOMAIN=$(crop_domain "$TEMP_DOMAIN_L")  # Обрезаем домен до последних двух частей
        SUB_DOMAIN="$TEMP_DOMAIN_L"  # Весь домен сохраняем в SUB_DOMAIN
      else
        DOMAIN="$TEMP_DOMAIN_L"  # Если домен второго уровня, сохраняем его без изменений
        SUB_DOMAIN="www.$TEMP_DOMAIN_L"  # Для домена второго уровня добавляем www в SUB_DOMAIN
      fi
    fi

    echo

    # Запрашиваем email пользователя
    while [[ -z $EMAIL ]]; do
      reading " $(text 15) " EMAIL
      echo
    done
    # Запрашиваем Cloudflare токен
    while [[ -z $CFTOKEN ]]; do
      reading " $(text 16) " CFTOKEN
    done

    get_test_response
    info " $(text 17) "
  done
}

###################################
### Processing paths with a loop
###################################
validate_path() {
  local VARIABLE_NAME="$1"
  local PATH_VALUE

  # Проверка на пустое значение
  while true; do
    case "$VARIABLE_NAME" in
      METRICS)
        reading " $(text 24) " PATH_VALUE
        ;;
      SHELLBOX)
        reading " $(text 24) " PATH_VALUE
        ;;
      ADGUARDPATH)
        reading " $(text 25) " PATH_VALUE
        ;;
      WEB_BASE_PATH)
        reading " $(text 26) " PATH_VALUE
        ;;
      SUB_PATH)
        reading " $(text 27) " PATH_VALUE
        ;;
      SUB_JSON_PATH)
        reading " $(text 28) " PATH_VALUE
        ;;
    esac

    if [[ -z "$PATH_VALUE" ]]; then
      warning " $(text 29) "
      echo
    elif [[ $PATH_VALUE =~ ['{}\$/\\'] ]]; then
      warning " $(text 30) "
      echo
    else
      break
    fi
  done

  # Экранируем пробелы в пути
  local ESCAPED_PATH=$(echo "$PATH_VALUE" | sed 's/ /\\ /g')

  # Присваиваем значение переменной
  case "$VARIABLE_NAME" in
    METRICS)
      export METRICS="$ESCAPED_PATH"
      ;;
    SHELLBOX)
      export SHELLBOX="$ESCAPED_PATH"
      ;;
    ADGUARDPATH)
      export ADGUARDPATH="$ESCAPED_PATH"
      ;;
    WEB_BASE_PATH)
      export WEB_BASE_PATH="$ESCAPED_PATH"
      ;;
    SUB_PATH)
      export SUB_PATH="$ESCAPED_PATH"
      ;;
    SUB_JSON_PATH)
      export SUB_JSON_PATH="$ESCAPED_PATH"
      ;;
  esac
}

###################################
### DNS Selection
###################################
choise_dns () {
  while true; do
    hint " $(text 31) \n" && reading " $(text 1) " CHOISE_DNS
    case $CHOISE_DNS in
      1)
        info " $(text 32) "
        break
        ;;
      2)
        info " $(text 25) "
        if [[ ${args[generate]} == "true" ]]; then
          ADGUARDPATH=$(eval ${generate[path]})
        else
          echo
          tilda "$(text 10)"
          validate_path ADGUARDPATH
        fi
        echo
        break
        ;;
      *)
        info " $(text 33) "
        ;;
    esac
  done
}

###################################
### Generating paths for cdn
###################################
generate_path_cdn(){
  CDNGRPC=$(eval ${generate[path]})
  CDNXHTTP=$(eval ${generate[path]})
  CDNHTTPU=$(eval ${generate[path]})
  CDNWS=$(eval ${generate[path]})
}

###################################
### Data entry
###################################
data_entry() {
  tilda "$(text 10)"

  reading " $(text 11) " USERNAME
  echo
  reading " $(text 12) " PASSWORD

  tilda "$(text 10)"

  [[ ${args[addu]} == "true" ]] && add_user

  check_cf_token

  tilda "$(text 10)"

  choise_dns

  generate_path_cdn

  if [[ ${args[generate]} == "true" ]]; then
    WEB_BASE_PATH=$(eval ${generate[path]})
    SUB_PATH=$(eval ${generate[path]})
    SUB_JSON_PATH=$(eval ${generate[path]})
  else
    echo
    validate_path WEB_BASE_PATH
    echo
    validate_path SUB_PATH
    echo
    validate_path SUB_JSON_PATH
  fi
  if [[ ${args[mon]} == "true" ]]; then
    if [[ ${args[generate]} == "true" ]]; then
      METRICS=$(eval ${generate[path]})
    else
      echo
      validate_path METRICS
    fi
  fi
  if [[ ${args[shell]} == "true" ]]; then
    if [[ ${args[generate]} == "true" ]]; then
      SHELLBOX=$(eval ${generate[path]})
    else
      echo
      validate_path SHELLBOX
    fi
  fi

  if [[ ${args[ssh]} == "true" ]]; then
    tilda "$(text 10)"
    reading " $(text 54) " ANSWER_SSH
    if [[ "${ANSWER_SSH,,}" == "y" ]]; then
      info " $(text 48) "
      out_data " $(text 49) "
      echo
      out_data " $(text 50) "
      out_data " $(text 51) "
      echo
      out_data " $(text 52)" "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${USERNAME}@${IP4} \"cat >> ~/.ssh/authorized_keys\""
      out_data " $(text 53)" "ssh-copy-id -p 22 ${USERNAME}@${IP4}"
      echo
      # Цикл проверки наличия ключей
      while true; do
        if [[ -s "/home/${USERNAME}/.ssh/authorized_keys" || -s "/root/.ssh/authorized_keys" ]]; then
          info " $(text 56) " # Ключи найдены
          SSH_OK=true
          break
        else
          warning " $(text 55) " # Ключи отсутствуют
          echo
          reading " $(text 54) " ANSWER_SSH
          if [[ "${ANSWER_SSH,,}" != "y" ]]; then
            warning " $(text 9) " # Настройка отменена
            SSH_OK=false
            break
          fi
        fi
      done
    else
      warning " $(text 9) " # Настройка пропущена
      SSH_OK=false
    fi
  fi

  if [[ ${args[tgbot]} == "true" ]]; then
    tilda "$(text 10)"
    reading " $(text 35) " ADMIN_ID
    echo
    reading " $(text 34) " BOT_TOKEN
  fi
  tilda "$(text 10)"
}

###################################
### Install NGINX
###################################
nginx_gpg() {
  case "$SYSTEM" in
    Debian)
      ${PACKAGE_INSTALL[int]} debian-archive-keyring
      curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
      gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/debian `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list
      echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx
      ;;

    Ubuntu)
      ${PACKAGE_INSTALL[int]} ubuntu-keyring
      curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
      gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list
      echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx
      ;;

    CentOS|Fedora)
      ${PACKAGE_INSTALL[int]} yum-utils
      cat <<EOL > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOL
      ;;
  esac
  ${PACKAGE_UPDATE[int]}
  ${PACKAGE_INSTALL[int]} nginx
  systemctl daemon-reload
  systemctl start nginx
  systemctl enable nginx
  systemctl restart nginx
  systemctl status nginx --no-pager
}

###################################
### Installing packages
###################################
installation_of_utilities() {
  info " $(text 36) "
  case "$SYSTEM" in
    Debian|Ubuntu)
      DEPS_PACK_CHECK=("jq" "ufw" "zip" "wget" "gpg" "nano" "cron" "sqlite3" "certbot" "vnstat" "openssl" "netstat" "htpasswd" "update-ca-certificates" "add-apt-repository" "unattended-upgrades" "certbot-dns-cloudflare")
      DEPS_PACK_INSTALL=("jq" "ufw" "zip" "wget" "gnupg2" "nano" "cron" "sqlite3" "certbot" "vnstat" "openssl" "net-tools" "apache2-utils" "ca-certificates" "software-properties-common" "unattended-upgrades" "python3-certbot-dns-cloudflare")

      for g in "${!DEPS_PACK_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_PACK_CHECK[g]})" ] && [[ ! "${DEPS_PACK[@]}" =~ "${DEPS_PACK_INSTALL[g]}" ]] && DEPS_PACK+=(${DEPS_PACK_INSTALL[g]})
      done

      if [ "${#DEPS_PACK[@]}" -ge 1 ]; then
        info " $(text 77) ": ${DEPS_PACK[@]}
        ${PACKAGE_UPDATE[int]}
        ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]}
      else
        info " $(text 78) "
      fi
      ;;

    CentOS|Fedora)
      DEPS_PACK_CHECK=("jq" "zip" "tar" "wget" "gpg" "nano" "crontab" "sqlite3" "openssl" "netstat" "nslookup" "htpasswd" "certbot" "update-ca-certificates" "certbot-dns-cloudflare")
      DEPS_PACK_INSTALL=("jq" "zip" "tar" "wget" "gnupg2" "nano" "cronie" "sqlite" "openssl" "net-tools" "bind-utils" "httpd-tools" "certbot" "ca-certificates" "python3-certbot-dns-cloudflare")

      for g in "${!DEPS_PACK_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_PACK_CHECK[g]})" ] && [[ ! "${DEPS_PACK[@]}" =~ "${DEPS_PACK_INSTALL[g]}" ]] && DEPS_PACK+=(${DEPS_PACK_INSTALL[g]})
      done

      if [ "${#DEPS_PACK[@]}" -ge 1 ]; then
        info " $(text 77) ": ${DEPS_PACK[@]}
        ${PACKAGE_UPDATE[int]}
        ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]}
      else
        info " $(text 78) "
      fi
      ;;
  esac

  nginx_gpg
  ${PACKAGE_INSTALL[int]} systemd-resolved
  tilda "$(text 10)"
}

###################################
### DNS Systemd-resolved
###################################
dns_systemd_resolved() {
  tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=1.1.1.1 8.8.8.8 8.8.4.4
#FallbackDNS=
Domains=~.
DNSSEC=yes
DNSOverTLS=yes
EOF
  systemctl restart systemd-resolved.service
}

###################################
### DNS Adguardhome
###################################
dns_adguard_home() {
  rm -rf AdGuardHome_*
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz; do
    warning " $(text 38) "
    sleep 3
  done
  tar -zxvf AdGuardHome_linux_amd64.tar.gz

  AdGuardHome/AdGuardHome -s install
  HASH=$(htpasswd -B -C 10 -n -b ${USERNAME} ${PASSWORD} | cut -d ":" -f 2)

  rm -f AdGuardHome/AdGuardHome.yaml
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/adh/AdGuardHome.yaml" -O AdGuardHome/AdGuardHome.yaml; do
    warning " $(text 38) "
    sleep 3
  done

  sleep 1
  sed -i \
    -e "s|username|${USERNAME}|g" \
    -e "s|hash|${HASH}|g" \
    AdGuardHome/AdGuardHome.yaml

  AdGuardHome/AdGuardHome -s restart
}

###################################
### Dns systemd for adguard
###################################
dns_systemd_resolved_for_adguard() {
  tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=127.0.0.1
#FallbackDNS=
#Domains=
#DNSSEC=no
DNSOverTLS=no
DNSStubListener=no
EOF
  systemctl restart systemd-resolved.service
}

###################################
### DNS menu
###################################
dns_encryption() {
  info " $(text 37) "
  dns_systemd_resolved
  case $CHOISE_DNS in
    1)
      COMMENT_AGH=""
      tilda "$(text 10)"
      ;;

    2)
      mkdir -p /etc/nginx/locations/

      cat > /etc/nginx/locations/adguard.conf <<EOF
location /${ADGUARDPATH}/ {
  if (\$hack = 1) {return 404;}
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header Range \$http_range;
  proxy_set_header If-Range \$http_if_range;
  proxy_redirect /login.html /${ADGUARDPATH}/login.html;
  proxy_pass http://127.0.0.1:8081/;
  break;
}
EOF
      dns_adguard_home
      dns_systemd_resolved_for_adguard
      tilda "$(text 10)"
      ;;

    *)
      warning " $(text 33)"
      dns_encryption
      ;;
  esac
}

###################################
### Creating a user
###################################
add_user() {
  info " $(text 39) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      useradd -m -s $(which bash) -G sudo ${USERNAME}
      ;;

    CentOS|Fedora)
      useradd -m -s $(which bash) -G wheel ${USERNAME}
      ;;
  esac
  echo "${USERNAME}:${PASSWORD}" | chpasswd
  mkdir -p /home/${USERNAME}/.ssh/
  touch /home/${USERNAME}/.ssh/authorized_keys
  chown -R ${USERNAME}: /home/${USERNAME}/.ssh
  chmod -R 700 /home/${USERNAME}/.ssh

  tilda "$(text 10)"
}

###################################
### Automatic system update
###################################
setup_auto_updates() {
  info " $(text 40) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
      echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
      dpkg-reconfigure -f noninteractive unattended-upgrades
      systemctl restart unattended-upgrades
      ;;

    CentOS|Fedora)
      cat > /etc/dnf/automatic.conf <<EOF
[commands]
upgrade_type = security
random_sleep = 0
download_updates = yes
apply_updates = yes

[email]
email_from = root@localhost
email_to = root
email_host = localhost
EOF
      systemctl enable --now dnf-automatic.timer
      systemctl status dnf-automatic.timer
      ;;
  esac

  tilda "$(text 10)"
}

###################################
### BBR
###################################
enable_bbr() {
  info " $(text 41) "

  if ! grep -q "net.core.default_qdisc = fq" /etc/sysctl.conf; then
      echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv4.tcp_congestion_control = bbr" /etc/sysctl.conf; then
      echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
  fi

  sysctl -p
}

###################################
### Disable IPv6
###################################
disable_ipv6() {
  info " $(text 42) "
  interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')

  if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.lo.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.$interface_name.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.$interface_name.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi

  sysctl -p
  tilda "$(text 10)"
}

###################################
### Enable IPv6
###################################
enable_ipv6() {
  info " $(text 42) "
  interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')

  sed -i "/net.ipv6.conf.all.disable_ipv6 = 1/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.default.disable_ipv6 = 1/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.lo.disable_ipv6 = 1/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.$interface_name.disable_ipv6 = 1/d" /etc/sysctl.conf

  echo -e "IPv6 включен"
  sysctl -p
  tilda "$(text 10)"
}

###################################
### Swapfile
###################################
swapfile() {
  echo
  echo "Setting up swapfile and restarting the WARP service if necessary"
  swapoff /swapfile*
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  swapon --show

  cat > ${DIR_REVERSE_PROXY}restart_warp.sh <<EOF
#!/bin/bash
# Получаем количество занятого пространства в swap (в мегабайтах)
SWAP_USED=\$(free -m | grep Swap | awk '{print \$3}')
# Проверяем, больше ли оно 300 Мб
if [ "\$SWAP_USED" -gt 200 ]; then
    # Перезапускаем warp-svc.service
    systemctl restart warp-svc.service
    # Записываем дату и время в лог-файл
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - warp-svc.service перезапущен из-за превышения swap" >> ${DIR_REVERSE_PROXY}warp_restart_time
fi
EOF
  chmod +x ${DIR_REVERSE_PROXY}restart_warp.sh
  add_cron_rule "* * * * * ${DIR_REVERSE_PROXY}restart_warp.sh"
}

###################################
### WARP
###################################
warp() {
  info " $(text 43) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
      ;;

    CentOS|Fedora)
      curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | tee /etc/yum.repos.d/cloudflare-warp.repo
      ;;
  esac

  ${PACKAGE_UPDATE[int]}
  ${PACKAGE_INSTALL[int]} cloudflare-warp

  warp-cli --accept-tos registration new
  warp-cli --accept-tos mode proxy
  warp-cli --accept-tos proxy port 40000
  warp-cli --accept-tos connect
  warp-cli debug qlog disable

  warp-cli tunnel stats
  if curl -x socks5h://localhost:40000 https://2ip.io; then
    echo "WARP is connected successfully."
  else
    warning " $(text 20) "
  fi

  swapfile
  tilda "$(text 10)"
}

###################################
### Certificates
###################################
issuance_of_certificates() {
  info " $(text 44) "
  CF_CREDENTIALS_PATH="/root/cloudflare.credentials"
  touch ${CF_CREDENTIALS_PATH}
  chown root:root ${CF_CREDENTIALS_PATH}
  chmod 600 ${CF_CREDENTIALS_PATH}

  if [[ "$CFTOKEN" =~ [A-Z] ]]; then
    cat > ${CF_CREDENTIALS_PATH} <<EOF
dns_cloudflare_api_token = ${CFTOKEN}
EOF
  else
    cat > ${CF_CREDENTIALS_PATH} <<EOF
dns_cloudflare_email = ${EMAIL}
dns_cloudflare_api_key = ${CFTOKEN}
EOF
  fi

  attempt=0
  max_attempts=2
  while [ $attempt -lt $max_attempts ]; do
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials ${CF_CREDENTIALS_PATH} --dns-cloudflare-propagation-seconds 30 --rsa-key-size 4096 -d ${DOMAIN},*.${DOMAIN} --agree-tos -m ${EMAIL} --cert-name ${DOMAIN} --no-eff-email --non-interactive
	  if [ $? -eq 0 ]; then
      break
    else
      attempt=$((attempt + 1))
      sleep 5
    fi
  done

  add_cron_rule "0 5 1 */2 * certbot -q renew"
  tilda "$(text 10)"
}

###################################
### Node exporter
###################################
monitoring() {
  info " $(text 66) "
  mkdir -p /etc/nginx/locations/
  bash <(curl -Ls https://github.com/cortez24rus/grafana-prometheus/raw/refs/heads/main/prometheus_node_exporter.sh)

  cat > /etc/nginx/locations/monitoring.conf <<EOF
location /${METRICS} {
  if (\$hack = 1) {return 404;}
  auth_basic "Restricted Content";
  auth_basic_user_file /etc/nginx/.htpasswd;
  proxy_pass http://127.0.0.1:9100/metrics;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  break;
}
EOF

  tilda "$(text 10)"
}

###################################
### Shell In A Box
###################################
shellinabox() {
  info " $(text 83) "
  apt-get install shellinabox
  mkdir -p /etc/nginx/locations/

  cat > /etc/default/shellinabox <<EOF
# Should shellinaboxd start automatically
SHELLINABOX_DAEMON_START=1
# TCP port that shellinboxds webserver listens on
SHELLINABOX_PORT=4200
# Parameters that are managed by the system and usually should not need
# changing:
# SHELLINABOX_DATADIR=/var/lib/shellinabox
# SHELLINABOX_USER=shellinabox
# SHELLINABOX_GROUP=shellinabox
# Any optional arguments (e.g. extra service definitions).  Make sure
# that that argument is quoted.
#   Beeps are disabled because of reports of the VLC plugin crashing
#   Firefox on Linux/x86_64.
SHELLINABOX_ARGS="--no-beep --localhost-only --disable-ssl"
EOF

  cat > /etc/nginx/locations/shellinabox.conf <<EOF
location /${SHELLBOX} {
  if (\$hack = 1) {return 404;}
  auth_basic "Restricted Content";
  auth_basic_user_file /etc/nginx/.htpasswd;
  proxy_pass http://127.0.0.1:4200;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  break;
}
EOF

  systemctl restart shellinabox
  tilda "$(text 10)"
}

###################################
### Selecting a random site
###################################
random_site() {
  info " $(text 79) "
  mkdir -p /var/www/html/ ${DIR_REVERSE_PROXY}

  cd ${DIR_REVERSE_PROXY}

  if [[ ! -d "simple-web-templates-main" ]]; then
      while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/simple-web-templates/archive/refs/heads/main.zip"; do
        warning " $(text 38) "
        sleep 3
      done
      unzip -q main.zip &>/dev/null && rm -f main.zip
  fi

  cd simple-web-templates-main || echo "Не удалось перейти в папку с шаблонами"

  rm -rf assets ".gitattributes" "README.md" "_config.yml"

  RandomHTML=$(ls -d */ | shuf -n1)  # Обновил для выбора случайного подкаталога
  info " $(text 80) ${RandomHTML}"

  # Если шаблон существует, копируем его в /var/www/html
  if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
      echo "Копируем шаблон в /var/www/html/..."
      rm -rf /var/www/html/*  # Очищаем старую папку
      cp -a "${RandomHTML}/." /var/www/html/ || echo "Ошибка при копировании шаблона"
  else
      echo "Ошибка при извлечении шаблона!"
  fi

  cd ~
  tilda "$(text 10)"
}

###################################
### http conf
###################################
nginx_conf() {
  cat > /etc/nginx/nginx.conf <<EOF
user                                   ${USERNGINX};
pid                                    /var/run/nginx.pid;
worker_processes                       auto;
worker_rlimit_nofile                   65535;
error_log                              /var/log/nginx/error.log;
include                                /etc/nginx/modules-enabled/*.conf;
events {
  multi_accept                         on;
  worker_connections                   1024;
}

http {
  map \$request_uri \$cleaned_request_uri {
    default \$request_uri;
    "~^(.*?)(\?x_padding=[^ ]*)\$" \$1;
  }
  log_format json_analytics escape=json '{'
    '\$time_local, '
    '\$http_x_forwarded_for, '
    '\$proxy_protocol_addr, '
    '\$request_method '
    '\$status, '
    '\$http_user_agent, '
    '\$cleaned_request_uri, '
    '\$http_referer, '
    '}';
  set_real_ip_from                     127.0.0.1;
  real_ip_header                       X-Forwarded-For;
  real_ip_recursive                    on;
  access_log                           /var/log/nginx/access.log json_analytics;
  sendfile                             on;
  tcp_nopush                           on;
  tcp_nodelay                          on;
  server_tokens                        off;
  log_not_found                        off;
  types_hash_max_size                  2048;
  types_hash_bucket_size               64;
  client_max_body_size                 16M;
  keepalive_timeout                    75s;
  keepalive_requests                   1000;
  reset_timedout_connection            on;
  include                              /etc/nginx/mime.types;
  default_type                         application/octet-stream;
  ssl_session_timeout                  1d;
  ssl_session_cache                    shared:SSL:1m;
  ssl_session_tickets                  off;
  ssl_prefer_server_ciphers            on;
  ssl_protocols                        TLSv1.2 TLSv1.3;
  ssl_ciphers                          TLS13_AES_128_GCM_SHA256:TLS13_AES_256_GCM_SHA384:TLS13_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305;
  ssl_stapling                         on;
  ssl_stapling_verify                  on;
  resolver                             127.0.0.1 valid=60s;
  resolver_timeout                     2s;
  gzip                                 on;
  add_header X-XSS-Protection          "0" always;
  add_header X-Content-Type-Options    "nosniff" always;
  add_header Referrer-Policy           "no-referrer-when-downgrade" always;
  add_header Permissions-Policy        "interest-cohort=()" always;
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
  add_header X-Frame-Options           "SAMEORIGIN";
  proxy_hide_header                    X-Powered-By;
  include                              /etc/nginx/conf.d/*.conf;
}
stream {
  include /etc/nginx/stream-enabled/stream.conf;
}
EOF
}

###################################
### Stream conf
###################################
stream_conf() {
  cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_server_name \$backend {
  ${DOMAIN}                            web;
  ${SUB_DOMAIN}                        xtls;
  default                              block;
}
upstream web {
  server 127.0.0.1:7443;
}
upstream xtls {
  server 127.0.0.1:8443;
}
upstream block {
  server 127.0.0.1:36076;
}
server {
  listen 443                           reuseport;
  ssl_preread                          on;
  proxy_protocol                       on;
  proxy_pass                           \$backend;
}
EOF
}

###################################
### Server conf
###################################
local_conf() {
  cat > /etc/nginx/conf.d/local.conf <<EOF
server {
  listen                               80;
  server_name                          ${DOMAIN} *.${DOMAIN};
  location / {
    return 301                         https://\$host\$request_uri;
  }
}
server {
  listen                               9090 default_server;
  server_name                          ${DOMAIN} *.${DOMAIN};
  location / {
    return 301                         https://\$host\$request_uri;
  }
}
server {
  listen                               36076 ssl proxy_protocol;
  ssl_reject_handshake                 on;
}
server {
  listen                               36077 ssl proxy_protocol;
  http2                                on;
  http3                                on;
  server_name                          ${DOMAIN} *.${DOMAIN};

  # SSL
  ssl_certificate                      /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
  ssl_certificate_key                  /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
  ssl_trusted_certificate              /etc/letsencrypt/live/${DOMAIN}/chain.pem;

  # Diffie-Hellman parameter for DHE ciphersuites
  ssl_dhparam                          /etc/nginx/dhparam.pem;

  # Site
  index index.html index.htm index.php index.nginx-debian.html;
  root /var/www/html/;

  if (\$host !~* ^(.+\.)?${DOMAIN}\$ ){return 444;}
  if (\$scheme ~* https) {set \$safe 1;}
  if (\$ssl_server_name !~* ^(.+\.)?${DOMAIN}\$ ) {set \$safe "\${safe}0"; }
  if (\$safe = 10){return 444;}
  if (\$request_uri ~ "(\"|'|\`|~|,|:|--|;|%|\\$|&&|\?\?|0x00|0X00|\||\\|\{|\}|\[|\]|<|>|\.\.\.|\.\.\/|\/\/\/)"){set \$hack 1;}
  error_page 400 402 403 500 501 502 503 504 =404 /404;
  proxy_intercept_errors on;

  # Enable locations
  include /etc/nginx/locations/*.conf;
}
EOF
}

location_panel() {
  cat > /etc/nginx/locations/panel.conf <<EOF
# PANEL
location /${WEB_BASE_PATH} {
  if (\$hack = 1) {return 404;}
  proxy_redirect off;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header Range \$http_range;
  proxy_set_header If-Range \$http_if_range;
  proxy_pass http://127.0.0.1:36075/${WEB_BASE_PATH};
  break;
}
EOF
}

location_sub() {
  cat > /etc/nginx/locations/sub.conf <<EOF
# SUB
location /${SUB_PATH} {
  if (\$hack = 1) {return 404;}
  proxy_redirect off;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_pass http://127.0.0.1:36074/${SUB_PATH};
  break;
}
EOF
}

location_sub_json() {
  cat > /etc/nginx/locations/sub_json.conf <<EOF
# SUB JSON
location /${SUB_JSON_PATH} {
  if (\$hack = 1) {return 404;}
  proxy_redirect off;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_pass http://127.0.0.1:36074/${SUB_JSON_PATH};
  break;
}
EOF
}

location_xhttp() {
  cat > /etc/nginx/locations/xhttp.conf <<EOF
# XHTTP
location /${CDNXHTTP} {
  grpc_pass grpc://unix:/dev/shm/uds2023.sock;
  grpc_buffer_size         16k;
  grpc_socket_keepalive    on;
  grpc_read_timeout        1h;
  grpc_send_timeout        1h;
  grpc_set_header Connection         "";
  grpc_set_header X-Forwarded-For    \$proxy_add_x_forwarded_for;
  grpc_set_header X-Forwarded-Proto  \$scheme;
  grpc_set_header X-Forwarded-Port   \$server_port;
  grpc_set_header Host               \$host;
  grpc_set_header X-Forwarded-Host   \$host;
}
EOF
}

location_cdn() {
  cat > /etc/nginx/locations/grpc_ws.conf <<EOF
# GRPC WEBSOCKET HTTPUpgrade
location ~ ^/(?<fwdport>\d+)/(?<fwdpath>.*)\$ {
  if (\$hack = 1) {return 404;}
  client_max_body_size 0;
  client_body_timeout 1d;
  grpc_read_timeout 1d;
  grpc_socket_keepalive on;
  proxy_read_timeout 1d;
  proxy_http_version 1.1;
  proxy_buffering off;
  proxy_request_buffering off;
  proxy_socket_keepalive on;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection "upgrade";
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  if (\$content_type ~* "GRPC") { grpc_pass grpc://127.0.0.1:\$fwdport\$is_args\$args; break; }
  proxy_pass http://127.0.0.1:\$fwdport\$is_args\$args;
  break;
}
EOF
}

###################################
### NGINX
###################################
nginx_setup() {
  info " $(text 45) "

  mkdir -p /etc/nginx/stream-enabled/
  mkdir -p /etc/nginx/conf.d/
  mkdir -p /etc/nginx/locations/
  rm -rf /etc/nginx/conf.d/default.conf
  touch /etc/nginx/.htpasswd
  htpasswd -nb "$USERNAME" "$PASSWORD" > /etc/nginx/.htpasswd
  openssl dhparam -out /etc/nginx/dhparam.pem 2048

  case "$SYSTEM" in
    Debian|Ubuntu)
      USERNGINX="www-data"
      ;;

    CentOS|Fedora)
      USERNGINX="nginx"
      ;;
  esac

  nginx_conf
  stream_conf
  local_conf
  location_panel
  location_sub
  location_sub_json
  location_xhttp
  location_cdn

  systemctl daemon-reload
  systemctl restart nginx
  nginx -s reload

  tilda "$(text 10)"
}

###################################
### Key generation
###################################
generate_keys() {
  # Генерация пары ключей X25519 с использованием xray
  local KEY_PAIR=$(/usr/local/x-ui/bin/xray-linux-amd64 x25519)
  local PRIVATE_KEY=$(echo "$KEY_PAIR" | grep "Private key:" | awk '{print $3}')
  local PUBLIC_KEY=$(echo "$KEY_PAIR" | grep "Public key:" | awk '{print $3}')

  # Возвращаем ключи в виде строки, разделенной пробелом
  echo "$PRIVATE_KEY $PUBLIC_KEY"
}

###################################
### Grpc
###################################
settings_grpc() {
  STREAM_SETTINGS_GRPC=$(cat <<EOF
{
  "network": "grpc",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "grpcSettings": {
  "serviceName": "/2053/${CDNGRPC}",
  "authority": "${DOMAIN}",
  "multiMode": false
  }
}
EOF
  )
}

###################################
### xhttp
###################################
settings_xhttp() {
  STREAM_SETTINGS_XHTTP=$(cat <<EOF
{
  "network": "xhttp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "tls",
      "dest": "${DOMAIN}",
      "port": 443,
      "remark": ""
    }
  ],
  "xhttpSettings": {
    "path": "/${CDNXHTTP}",
    "host": "",
    "headers": {},
    "scMaxBufferedPosts": 30,
    "scMaxEachPostBytes": "1000000",
    "noSSEHeader": false,
    "xPaddingBytes": "100-1000",
    "mode": "packet-up"
  },
  "sockopt": {
    "acceptProxyProtocol": false,
    "tcpFastOpen": true,
    "mark": 0,
    "tproxy": "off",
    "tcpMptcp": true,
    "tcpNoDelay": true,
    "domainStrategy": "UseIP",
    "tcpMaxSeg": 1440,
    "dialerProxy": "",
    "tcpKeepAliveInterval": 0,
    "tcpKeepAliveIdle": 300,
    "tcpUserTimeout": 10000,
    "tcpcongestion": "bbr",
    "V6Only": false,
    "tcpWindowClamp": 600,
    "interface": ""
  }
}
EOF
  )
}

###################################
### Httpu
###################################
settings_httpu() {
  STREAM_SETTINGS_HTTPU=$(cat <<EOF
{
  "network": "httpupgrade",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "httpupgradeSettings": {
  "acceptProxyProtocol": false,
  "path": "/2073/${CDNHTTPU}",
  "host": "${DOMAIN}",
  "headers": {}
  }
}
EOF
  )
}

###################################
### Ws
###################################
settings_ws() {
  STREAM_SETTINGS_WS=$(cat <<EOF
{
  "network": "ws",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "wsSettings": {
  "acceptProxyProtocol": false,
  "path": "/2083/${CDNWS}",
  "host": "${DOMAIN}",
  "headers": {}
  }
}
EOF
  )
}

###################################
### Settings reality (Steal Oneself)
###################################
settings_steal() {
  read PRIVATE_KEY0 PUBLIC_KEY0 <<< "$(generate_keys)"
  STREAM_SETTINGS_STEAL=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "${SUB_DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "realitySettings": {
  "show": false,
  "xver": 2,
  "dest": "36077",
  "serverNames": [
    "${DOMAIN}"
  ],
  "privateKey": "${PRIVATE_KEY0}",
  "minClient": "",
  "maxClient": "",
  "maxTimediff": 0,
  "shortIds": [
    "22dff0",
    "0041e9ca",
    "49afaa139d",
    "89",
    "1addf92cc1bd50",
    "6e122954e9df",
    "8d93026df5de065c",
    "bc85"
  ],
  "settings": {
    "publicKey": "${PUBLIC_KEY0}",
    "fingerprint": "chrome",
    "serverName": "",
    "spiderX": "/"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

###################################
### Settings xtls
###################################
settings_xtls() {
  STREAM_SETTINGS_XTLS=$(cat <<EOF
{
  "network": "tcp",
  "security": "tls",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "${SUB_DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "tlsSettings": {
  "serverName": "${SUB_DOMAIN}",
  "minVersion": "1.3",
  "maxVersion": "1.3",
  "cipherSuites": "",
  "rejectUnknownSni": false,
  "disableSystemRoot": false,
  "enableSessionResumption": false,
  "certificates": [
    {
    "certificateFile": "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem",
    "keyFile": "/etc/letsencrypt/live/${DOMAIN}/privkey.pem",
    "ocspStapling": 3600,
    "oneTimeLoading": false,
    "usage": "encipherment",
    "buildChain": false
    }
  ],
  "alpn": [
    "http/1.1"
  ],
  "settings": {
    "allowInsecure": false,
    "fingerprint": "chrome"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

###################################
### Sniffing
###################################
sniffing_inbounds() {
  SNIFFING=$(cat <<EOF
{
  "enabled": true,
  "destOverride": [
    "http",
    "tls",
    "quic",
    "fakedns"
  ],
  "metadataOnly": false,
  "routeOnly": false
}
EOF
  )
}

###################################
### Json routing rules
###################################
json_rules() {
  # [{"type":"field","outboundTag":"direct","domain":["keyword:xn--","keyword:yandex","keyword:avito","keyword:2gis","keyword:gismeteo","keyword:livejournal"]},{"type":"field","outboundTag":"direct","domain":["domain:ru","domain:su","domain:kg","domain:by","domain:kz"]},{"type":"field","outboundTag":"direct","domain":["geosite:category-ru","geosite:category-gov-ru","geosite:yandex","geosite:vk","geosite:whatsapp","geosite:apple","geosite:mailru","geosite:github","geosite:gitlab","geosite:duckduckgo","geosite:google","geosite:wikimedia","geosite:mozilla"]},{"type":"field","outboundTag":"direct","ip":["geoip:private","geoip:ru"]}]
  SUB_JSON_RULES=$(cat <<EOF
[{"type":"field","outboundTag":"direct","domain":["geosite:category-ru","geosite:apple","geosite:google"]},{"type":"field","outboundTag":"direct","ip":["geoip:private","geoip:ru"]}]
EOF
)
}

###################################
### Xray template json
###################################
xray_template() {
  if [[ ${args[warp]} == "true" ]]; then
    RULES="warp"
  else
    RULES="IPv4"
  fi
  XRAY_TEMPLATE_CONFIG=$(cat <<EOF
{
  "log": {
    "access": "./access.log",
    "dnsLog": false,
    "error": "./error.log",
    "loglevel": "warning",
    "maskAddress": ""
  },
  "api": {
    "tag": "api",
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ]
  },
  "inbounds": [
    {
      "tag": "api",
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "ForceIPv4",
        "redirect": "",
        "noises": []
      }
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    },
    {
      "tag": "IPv4",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4"
      }
    },
    {
      "tag": "warp",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000,
            "users": []
          }
        ]
      }
    }
  ],
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true,
      "statsOutboundDownlink": true,
      "statsOutboundUplink": true
    }
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "domain": [
          "geosite:category-ads-all",
          "ext:geosite_IR.dat:category-ads-all",
          "ext:geosite_IR.dat:malware",
          "ext:geosite_IR.dat:phishing",
          "ext:geosite_IR.dat:cryptominers"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "domain": [
          "geosite:google"
        ],
        "outboundTag": "${RULES}"
      },
      {
        "type": "field",
        "domain": [
          "domain:gemini.google.com"
        ],
        "outboundTag": "${RULES}"
      },
      {
        "type": "field",
        "domain": [
          "keyword:xn--"
        ],
        "outboundTag": "${RULES}"
      },
      {
        "type": "field",
        "domain": [
          "geosite:intel",
          "category-ru"
        ],
        "outboundTag": "${RULES}"
      },
      {
        "type": "field",
        "ip": [
          "geoip:ru"
        ],
        "outboundTag": "${RULES}"
      },
      {
        "type": "field",
        "domain": [
          "regexp:.*\\\\.ru$",
          "regexp:.*\\\\.su$"
        ],
        "outboundTag": "${RULES}"
      }
    ]
  },
  "stats": {}
}
EOF
  )
}

###################################
### Updating username, password in users
###################################
update_user_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE users SET username = '$USERNAME', password = '$PASSWORD' WHERE id = 1;
EOF
}

###################################
### Updating stream_settings in inbound
###################################
update_stream_settings_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_GRPC' WHERE LOWER(remark) LIKE '%grpc%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_XHTTP' WHERE LOWER(remark) LIKE '%xhttp%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_HTTPU' WHERE LOWER(remark) LIKE '%httpu%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_WS' WHERE LOWER(remark) LIKE '%ws%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_STEAL' WHERE LOWER(remark) LIKE '%steal%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_XTLS' WHERE LOWER(remark) LIKE '%xtls%';
EOF
}

###################################
### Updating sniffing in inbound
###################################
update_sniffing_settings_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%grpc%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%xhttp%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%httpu%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%ws%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%steal%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%xtls%';
EOF
}

###################################
### Updating value in settings
###################################
update_settings_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE settings SET value = '/${WEB_BASE_PATH}/' WHERE LOWER(key) LIKE '%webbasepath%';
UPDATE settings SET value = '/${SUB_PATH}/' WHERE LOWER(key) LIKE '%subpath%';
UPDATE settings SET value = '${SUB_URI}' WHERE LOWER(key) LIKE '%suburi%';
UPDATE settings SET value = '/${SUB_JSON_PATH}/' WHERE LOWER(key) LIKE '%subjsonpath%';
UPDATE settings SET value = '${SUB_JSON_URI}' WHERE LOWER(key) LIKE '%subjsonuri%';
UPDATE settings SET value = '${XRAY_TEMPLATE_CONFIG}' WHERE LOWER(key) LIKE '%xraytemplateconfig%';
EOF
}

###################################
### Setting bot
###################################
update_settings_tgbot_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE settings SET value = 'true' WHERE LOWER(key) LIKE '%tgbotenable%';
UPDATE settings SET value = '${ADMIN_ID}' WHERE LOWER(key) LIKE '%tgbottoken%';
UPDATE settings SET value = '${BOT_TOKEN}' WHERE LOWER(key) LIKE '%tgbotchatid%';
EOF
}

###################################
### Updating json rules in the database
###################################
update_json_rules_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE settings SET value = '${SUB_JSON_RULES}' WHERE LOWER(key) LIKE '%subjsonrules%';
EOF
}

###################################
### Changing the Database
###################################
change_db() {
  settings_grpc
  settings_xhttp
  settings_httpu
  settings_ws
  settings_steal
  settings_xtls
  sniffing_inbounds
  json_rules
  xray_template

  update_user_db
  update_stream_settings_db
  update_sniffing_settings_db
  update_settings_db
  if [[ ${args[tgbot]} == "true" ]]; then
    update_settings_tgbot_db
  fi
  update_json_rules_db
}

###################################
### Panel installation
###################################
install_panel() {
  info " $(text 46) "
  SUB_URI=https://${DOMAIN}/${SUB_PATH}/
  SUB_JSON_URI=https://${DOMAIN}/${SUB_JSON_PATH}/

  echo -e "n" | bash <(curl -sS "https://raw.githubusercontent.com/mhsanaei/3x-ui/$VERSION/install.sh") $VERSION >/dev/null 2>&1
  if ! systemctl is-active fail2ban.service; then
    echo -e "20\n1" | x-ui
  fi
  x-ui stop

  mv -f "$DEST_DB" "$DEST_DB.backup"
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused -O "$DEST_DB" "$DB_SCRIPT_URL"; do
    warning " $(text 38) "
    sleep 3
  done

  change_db

  x-ui start
  tilda "$(text 10)"
}

###################################
### Custom subscription json
###################################
custom_sub_json(){
  cat > /etc/nginx/locations/webpagesub.conf <<EOF
# Web Page Subscription Path
location ~ ^/${WEB_SUB_PATH} {
  default_type application/json;
  root /var/www/subpage;
  index index.html;
  try_files /index.html =404;
}
EOF

  cat > /etc/nginx/locations/subsingbox.conf <<EOF
# Sub2sing-box
location /${SUB2_SINGBOX_PATH}/ {
  proxy_redirect off;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_pass http://127.0.0.1:8080/;
}
EOF
}

###################################
### Settings web sub page
###################################
settings_web(){
  DEST_DIR_SUB_PAGE="/var/www/subpage"
  DEST_FILE_SUB_PAGE="$DEST_DIR_SUB_PAGE/index.html"
  sudo mkdir -p "$DEST_DIR_SUB_PAGE"

  URL_SUB_PAGE="https://github.com/legiz-ru/x-ui-pro/raw/master/sub-3x-ui.html"
  sudo curl -L "$URL_SUB_PAGE" -o "$DEST_FILE_SUB_PAGE"

  sed -i "s/\${DOMAIN}/$DOMAIN/g" "$DEST_FILE_SUB_PAGE"
  sed -i "s#\${SUB_JSON_PATH}#$SUB_JSON_PATH#g" "$DEST_FILE_SUB_PAGE"
  sed -i "s#\${SUB_PATH}#$SUB_PATH#g" "$DEST_FILE_SUB_PAGE"
  sed -i "s|sub.legiz.ru|$DOMAIN/$SUB2_SINGBOX_PATH|g" "$DEST_FILE_SUB_PAGE"
}

###################################
### Install sing-box converter
###################################
install_singbox_converter(){
  wget -q -P /root/ https://github.com/nitezs/sub2sing-box/releases/download/v0.0.9-beta.2/sub2sing-box_0.0.9-beta.2_linux_amd64.tar.gz
  tar -xvzf /root/sub2sing-box_0.0.9-beta.2_linux_amd64.tar.gz -C /root/ --strip-components=1 sub2sing-box_0.0.9-beta.2_linux_amd64/sub2sing-box
  mv /root/sub2sing-box /usr/bin/
  chmod +x /usr/bin/sub2sing-box
  rm /root/sub2sing-box_0.0.9-beta.2_linux_amd64.tar.gz
  su -c "/usr/bin/sub2sing-box server & disown" root
}

###################################
### Update subscription json uri database
###################################
update_subjsonuri_db() {
  sqlite3 $DEST_DB <<EOF
UPDATE settings SET value = '${SUB_JSON_URI}' WHERE LOWER(key) LIKE '%subjsonuri%';
EOF
}

###################################
### Settings custom json
###################################
settings_custom_json(){
  info " $(text 99) "
  mkdir -p /etc/nginx/locations/

  while [[ -z "$DOMAIN" ]]; do
    reading " $(text 13) " DOMAIN  # Запрашиваем домен
    DOMAIN=$(clean_url "$DOMAIN")  # Очищаем домен
  done

  select_from_db
  WEB_SUB_PATH=$(eval ${generate[path]})
  SUB2_SINGBOX_PATH=$(eval ${generate[path]})
  SUB_JSON_URI=https://${DOMAIN}/${WEB_SUB_PATH}?name=

  custom_sub_json
  install_singbox_converter
  settings_web

  update_subjsonuri_db
  if ! grep -Fq "include /etc/nginx/locations/*.conf;" /etc/nginx/conf.d/local.conf; then
    sed -i '$ s/}/\n  # Enable locations\n  include \/etc\/nginx\/locations\/\*.conf;\n}/' /etc/nginx/conf.d/local.conf
  fi
  nginx -s reload

  add_cron_rule "@reboot /usr/bin/sub2sing-box server > /dev/null 2>&1"
  tilda "$(text 10)"
}

###################################
### BACKUP DIRECTORIES
###################################
backup_dir() {
  cat > ${DIR_REVERSE_PROXY}backup_dir.sh <<EOF
#!/bin/bash

# Путь к директории резервного копирования
DIR_REVERSE_PROXY="/usr/local/reverse_proxy/"
BACKUP_DIR="\${DIR_REVERSE_PROXY}backup"
CURRENT_DATE=\$(date +"%y-%m-%d")
ARCHIVE_NAME="\${BACKUP_DIR}/backup_\${CURRENT_DATE}.7z"

# Создаем директорию для резервных копий, если её нет
mkdir -p "\$BACKUP_DIR"

# Архивируем все три директории в один архив
7za a -mx9 "\$ARCHIVE_NAME" "/etc/nginx" "/etc/x-ui" "/etc/letsencrypt" || echo "Ошибка при создании архива"

# Проверка успешного создания архива
if [[ -f "\$ARCHIVE_NAME" ]]; then
  echo "Архив успешно создан: \$ARCHIVE_NAME"
else
  echo "Ошибка при создании архива"
fi

EOF
  chmod +x ${DIR_REVERSE_PROXY}backup_dir.sh
  bash "${DIR_REVERSE_PROXY}backup_dir.sh"
  add_cron_rule "0 0 * * * ${DIR_REVERSE_PROXY}backup_dir.sh"
}

###################################
### ROTATE BACKUPS
###################################
rotation_backup() {
  cat > ${DIR_REVERSE_PROXY}rotation_backup.sh <<EOF
#!/bin/bash

# Путь к директории резервного копирования
DIR_REVERSE_PROXY="/usr/local/reverse_proxy/"
BACKUP_DIR="${DIR_REVERSE_PROXY}backup"

# Количество дней хранения архивов
days_to_keep=6

# Удаление архивов старше 7 дней
find "\$BACKUP_DIR" -type f -name "backup_*.7z" -mtime +\$days_to_keep -exec rm -f {} \;
EOF
  chmod +X ${DIR_REVERSE_PROXY}rotation_backup.sh
  bash "${DIR_REVERSE_PROXY}rotation_backup.sh"
  add_cron_rule "0 0 * * * ${DIR_REVERSE_PROXY}rotation_backup.sh"
}

###################################
### BACKUP & ROTATION SCHEDULER
###################################
rotation_and_archiving() {
  info " $(text 23) "
  ${PACKAGE_UPDATE[int]}
  ${PACKAGE_INSTALL[int]} p7zip-full
  backup_dir
  rotation_backup
  tilda "$(text 10)"
}

###################################
### Firewall
###################################
enabling_security() {
  info " $(text 47) "
  BLOCK_ZONE_IP=$(echo ${IP4} | cut -d '.' -f 1-3).0/22

  case "$SYSTEM" in
    Debian|Ubuntu)
      ufw --force reset
      ufw limit 22/tcp comment 'SSH'
      ufw allow 443/tcp comment 'WEB'
      ufw insert 1 deny from "$BLOCK_ZONE_IP"
      ufw --force enable
      ;;

    CentOS|Fedora)
      systemctl enable --now firewalld
      firewall-cmd --permanent --zone=public --add-port=22/tcp
      firewall-cmd --permanent --zone=public --add-port=443/tcp
      firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$BLOCK_ZONE_IP' reject"
      firewall-cmd --reload
      ;;
  esac

  tilda "$(text 10)"
}

###################################
### SSH
###################################
ssh_setup() {
  if [[ "${ANSWER_SSH,,}" == "y" ]]; then
    info " $(text 48) "
    sed -i -e "
      s/#Port/Port/g;
      s/Port 22/Port 22/g;
      s/#PermitRootLogin/PermitRootLogin/g;
      s/PermitRootLogin yes/PermitRootLogin prohibit-password/g;
      s/#PubkeyAuthentication/PubkeyAuthentication/g;
      s/PubkeyAuthentication no/PubkeyAuthentication yes/g;
      s/#PasswordAuthentication/PasswordAuthentication/g;
      s/PasswordAuthentication yes/PasswordAuthentication no/g;
      s/#PermitEmptyPasswords/PermitEmptyPasswords/g;
      s/PermitEmptyPasswords yes/PermitEmptyPasswords no/g;
    " /etc/ssh/sshd_config

    bash <(curl -Ls https://raw.githubusercontent.com/cortez24rus/motd/refs/heads/main/install.sh)
    systemctl restart ssh
    tilda "$(text 10)"
  fi
}

###################################
### Information output
###################################
data_output() {
  info " $(text 58) "
  echo
  printf '0\n' | x-ui | grep --color=never -i ':'
  echo
  out_data " $(text 59) " "https://${DOMAIN}/${WEB_BASE_PATH}/"
  out_data " $(text 60) " "${SUB_URI}user"
  echo
  if [[ $CHOISE_DNS = "2" ]]; then
    out_data " $(text 61) " "https://${DOMAIN}/${ADGUARDPATH}/login.html"
    echo
  fi
  if [[ ${args[mon]} == "true" ]]; then
    out_data " $(text 21) " "https://${DOMAIN}/${METRICS}/"
    echo
  fi
  if [[ ${args[shell]} == "true" ]]; then
    out_data " $(text 22) " "https://${DOMAIN}/${SHELLBOX}/"
    echo
  fi
  out_data " $(text 62) " "ssh -p 22 ${USERNAME}@${IP4}"
  echo
  out_data " $(text 63) " "$USERNAME"
  out_data " $(text 64) " "$PASSWORD"
  echo
  out_data " $(text 65) " "$LOGFILE"
  tilda "$(text 10)"
}

###################################
### Downloadr webiste
###################################
download_website() {
  reading " $(text 13) " sitelink
  local NGINX_CONFIG_L="/etc/nginx/conf.d/local.conf"
  wget -P /var/www --mirror --convert-links --adjust-extension --page-requisites --no-parent https://${sitelink}

  mkdir -p ./testdir
  wget -q -P ./testdir https://${sitelink}
  index=$(ls ./testdir)
  rm -rf ./testdir

  if [[ "$sitelink" =~ "/" ]]
  then
    sitedir=$(echo "${sitelink}" | cut -d "/" -f 1)
  else
    sitedir="${sitelink}"
  fi

  chmod -R 755 /var/www/${sitedir}
  filelist=$(find /var/www/${sitedir} -name ${index})
  slashnum=1000

  for k in $(seq 1 $(echo "$filelist" | wc -l))
  do
    testfile=$(echo "$filelist" | sed -n "${k}p")
    if [ $(echo "${testfile}" | tr -cd '/' | wc -c) -lt ${slashnum} ]
    then
      resultfile="${testfile}"
      slashnum=$(echo "${testfile}" | tr -cd '/' | wc -c)
    fi
  done

  sitedir=${resultfile#"/var/www/"}
  sitedir=${sitedir%"/${index}"}

  NEW_ROOT=" root /var/www/${sitedir};"
  NEW_INDEX=" index ${index};"

  sed -i '/^\s*root\s.*/c\ '"$NEW_ROOT" $NGINX_CONFIG_L
  sed -i '/^\s*index\s.*/c\ '"$NEW_INDEX" $NGINX_CONFIG_L

  systemctl restart nginx
}

###################################
### Create a backup of certificates
###################################
create_cert_backup() {
  local DOMAIN=$1
  local ACTION=$2 # Тип действия: "cp" или "mv"
  local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  local BACKUP_DIR="/etc/letsencrypt/backups/${DOMAIN}_${TIMESTAMP}"

  mkdir -p "${BACKUP_DIR}"

  $ACTION /etc/letsencrypt/live ${BACKUP_DIR}
  $ACTION /etc/letsencrypt/archive ${BACKUP_DIR}
  $ACTION /etc/letsencrypt/renewal ${BACKUP_DIR}
}

###################################
### Database change in domain
###################################
database_change_domain() {
  sqlite3 $DEST_DB <<EOF
UPDATE settings
SET value = REPLACE(value, '$OLD_DOMAIN', '$DOMAIN')
WHERE value LIKE '%$OLD_DOMAIN%';

UPDATE inbounds
SET stream_settings = REPLACE(stream_settings, '$OLD_SUB_DOMAIN', '$SUB_DOMAIN')
WHERE stream_settings LIKE '%$OLD_SUB_DOMAIN%';

UPDATE inbounds
SET stream_settings = REPLACE(stream_settings, '$OLD_DOMAIN', '$DOMAIN')
WHERE stream_settings LIKE '%$OLD_DOMAIN%';
EOF
}

###################################
### Change domain name
###################################
change_domain() {
  select_from_db
  check_cf_token
  create_cert_backup "$OLD_DOMAIN" "mv"
  issuance_of_certificates

  database_change_domain
  sed -i -e "
    s/$OLD_SUB_DOMAIN/$SUB_DOMAIN/g;
    s/$OLD_DOMAIN/$DOMAIN/g;
  " /etc/nginx/stream-enabled/stream.conf
  sed -i -e "s/$OLD_DOMAIN/$DOMAIN/g" /etc/nginx/conf.d/local.conf

  echo "$OLD_DOMAIN > $DOMAIN"
  echo "$OLD_SUB_DOMAIN > $SUB_DOMAIN"

  systemctl restart nginx
  tilda "$(text 10)"
}

###################################
### Reissue of certificates
###################################
renew_cert() {
  # Получение домена из конфигурации Nginx
  NGINX_DOMAIN=$(grep "ssl_certificate" /etc/nginx/conf.d/local.conf | head -n 1)
  NGINX_DOMAIN=${NGINX_DOMAIN#*"/live/"}
  NGINX_DOMAIN=${NGINX_DOMAIN%"/"*}

  # Проверка наличия сертификатов
  if [ ! -d /etc/letsencrypt/live/${NGINX_DOMAIN} ]; then
    check_cf_token
    issuance_of_certificates
  else
    create_cert_backup "$NGINX_DOMAIN" "cp"
    certbot renew --force-renewal
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi
  # Перезапуск Nginx
  systemctl restart nginx
}

###################################
### Depersonalization of the database
###################################
depersonalization_db() {
  cp ${DEST_DB} ${DEST_DB}.temp
  change_db
  mv ${DEST_DB} /root/
  mv ${DEST_DB}.temp ${DEST_DB}
}

###################################
### Directory size
###################################
directory_size() {
  read -e -p "Enter a directory: " DIRECTORY
  echo
  free -h
  echo
  du -ah ${DIRECTORY} --max-depth=1 | grep -v '/$' | sort -rh | head -10
  echo
}

###################################
### Query from database
###################################
select_from_db(){
  result1=$(sqlite3 "$DEST_DB" "SELECT username, password FROM users WHERE id = 1;")
  USERNAME=$(echo "$result1" | cut -d '|' -f 1)  # Первая часть (username)
  PASSWORD=$(echo "$result1" | cut -d '|' -f 2)  # Вторая часть (password)

  result2=$(sqlite3 "$DEST_DB" "SELECT value FROM settings WHERE key IN ('webBasePath', 'subPath', 'subJsonPath');")
  WEB_BASE_PATH=$(echo "$result2" | sed -n '1p' | sed 's/^\/\(.*\)\/$/\1/')
  SUB_PATH=$(echo "$result2" | sed -n '2p' | sed 's/^\/\(.*\)\/$/\1/')
  SUB_JSON_PATH=$(echo "$result2" | sed -n '3p' | sed 's/^\/\(.*\)\/$/\1/')
}

###################################
### Client traffic migration
###################################
client_traffics_migration_db(){
  sqlite3 "$DEST_DB" <<EOF
ATTACH '$SOURCE_DB' AS source_db;
INSERT OR REPLACE INTO client_traffics SELECT * FROM source_db.client_traffics;
DETACH source_db;
EOF
}

###################################
### Settings migration
###################################
settings_migration_db(){
  sqlite3 "$DEST_DB" <<EOF
ATTACH '$SOURCE_DB' AS source_db;
INSERT OR REPLACE INTO settings SELECT * FROM source_db.settings;
DETACH source_db;
EOF
}

###################################
### Inbounds settings migration
###################################
inbounds_settings_migration_db(){
  sqlite3 "$DEST_DB" <<EOF
ATTACH DATABASE '$SOURCE_DB' AS source_db;

UPDATE inbounds
SET settings = NULL
WHERE remark IN (
  SELECT remark
  FROM source_db.inbounds
  WHERE source_db.inbounds.remark = inbounds.remark
);

UPDATE inbounds
SET settings = (
  SELECT CASE 
    WHEN source_db.settings IS NOT NULL THEN source_db.settings 
    ELSE inbounds.settings
  END
  FROM source_db.inbounds AS source_db
  WHERE source_db.remark = inbounds.remark
)
WHERE remark IN (
  SELECT remark FROM source_db.inbounds
);

DETACH DATABASE source_db;
EOF
}

###################################
### Migration to a new version
###################################
migration(){
  info " $(text 97) "
  SOURCE_DB="/etc/x-ui/source.db"

  rotation_and_archiving
  select_from_db
  generate_path_cdn

  x-ui stop

  cp "$DEST_DB" "/root/source.db"
  mv -f "$DEST_DB" "$SOURCE_DB"
  cp -r /etc/nginx /root/source.nginx

  DOMAIN=""
  SUB_DOMAIN=""

  echo
  reading " $(text 13) " TEMP_DOMAIN_L
  DOMAIN=$(clean_url "$TEMP_DOMAIN_L")
  echo
  reading " $(text 81) " TEMP_DOMAIN_L
  SUB_DOMAIN=$(clean_url "$TEMP_DOMAIN_L")
  echo

  nginx_setup
  install_panel

  x-ui stop
  client_traffics_migration_db
  settings_migration_db
  inbounds_settings_migration_db
  x-ui start

  info " $(text 98) "
}

###################################
### Unzips the selected backup
###################################
unzip_backup() {
  BACKUP_DIR="${DIR_REVERSE_PROXY}backup"

  if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Ошибка: Директория $BACKUP_DIR не существует."
    exit 1
  fi

  echo
  hint " $(text 101) "
  mapfile -t backups < <(ls "$BACKUP_DIR"/backup_*.7z 2>/dev/null)
  if [[ ${#backups[@]} -eq 0 ]]; then
    echo "Нет доступных резервных копий."
    exit 1
  fi
  for i in "${!backups[@]}"; do
    hint " $((i + 1))) $(basename "${backups[i]}")"
  done

  echo
  reading " $(text 102) " CHOICE_BACKUP
  if [[ ! "$CHOICE_BACKUP" =~ ^[0-9]+$ ]] || (( CHOICE_BACKUP < 1 || CHOICE_BACKUP > ${#backups[@]} )); then
    echo "Ошибка: Неверный ввод."
    exit 1
  fi

  SELECTED_ARCHIVE="${backups[CHOICE_BACKUP - 1]}"
  info " $(text 104) $(basename "$SELECTED_ARCHIVE")"

  mkdir -p "$RESTORE_DIR"
  7za x "$SELECTED_ARCHIVE" -o"$RESTORE_DIR" -y > /dev/null 2>&1 || { echo "Ошибка при разархивировании!"; exit 1; }
}

###################################
### Migrates backup files to the system directories
###################################
backup_migration() {
  echo
  x-ui stop
  
  rm -rf /etc/x-ui/
  rm -rf /etc/nginx/
  rm -rf /etc/letsencrypt/

  mv /tmp/restore/x-ui/ /etc/
  mv /tmp/restore/nginx/ /etc/
  mv /tmp/restore/letsencrypt/ /etc/

  systemctl restart nginx
  x-ui restart
  echo
}

###################################
### Restores the backup by first unzipping and then migrating
###################################
restore_backup() {
  info " $(text 100) "
  RESTORE_DIR="/tmp/restore"
  unzip_backup
  backup_migration
  info " $(text 103) "
}

###################################
### Displays traffic statistics
###################################
traffic_stats() {
  ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
  ${PACKAGE_INSTALL[int]} vnstat >/dev/null 2>&1

  hint " $(text 106) \n"  # Показывает информацию о доступных языках
  reading " $(text 1) " CHOICE_STATS  # Запрашивает выбор языка

  case $CHOICE_STATS in
    1)
      vnstat -m  # Показать статистику по месяцам
      ;;
    2)
      vnstat -m  # Показать статистику по месяцам
      ;;
    3)
      vnstat -d  # Показать статистику по дням
      ;;
    4)
      vnstat -d  # Показать статистику по дням
      ;;
    *)
      vnstat -m
      ;;
  esac
  echo
}

###################################
### Removing all escape sequences
###################################
log_clear() {
  sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$LOGFILE"
}

###################################
### Main function
###################################
main() {
  log_entry
  read_defaults_from_file
  parse_args "$@" || show_help
  [[ ${args[skip-check]} == "false" ]] && check_root
  [[ ${args[skip-check]} == "false" ]] && check_ip
  check_operating_system
  banner_xray
  select_language
  if [ -f ${DEFAULT_FLAGS} ]; then
    warning " $(text 4) "
  fi
  sleep 2
  while true; do
    clear
    banner_xray
    tilda "|-----------------------------------------------------------------------------|"
    info " $(text 86) "                      # MENU
    tilda "|-----------------------------------------------------------------------------|"
    info " $(text 87) "                      # 1. Install
    echo
    info " $(text 88) "                      # 2. Restore backup
    info " $(text 89) "                      # 3. Migration
    info " $(text 90) "                      # 4. Change domain
    info " $(text 91) "                      # 5. Renew cert
    echo
    info " $(text 92) "                      # 6. Custom json
    info " $(text 93) "                      # 7. Steal web site
    info " $(text 94) "                      # 8. Disable IPv6
    info " $(text 95) "                      # 9. Enable IPv6
    info " $(text 96) "                      # 10. Directory size
    info " $(text 105) "                     # 11. Traffic statistics
    echo
    info " $(text 84) "                      # Exit
    tilda "|-----------------------------------------------------------------------------|"
    echo
    reading " $(text 1) " CHOICE_MENU        # Choise
    tilda "$(text 10)"
    case $CHOICE_MENU in
      1)
        clear
        check_dependencies
        banner_xray
        warning_banner
        data_entry
        [[ ${args[utils]} == "true" ]] && installation_of_utilities
        [[ ${args[dns]} == "true" ]] && dns_encryption
        [[ ${args[autoupd]} == "true" ]] && setup_auto_updates
        [[ ${args[bbr]} == "true" ]] && enable_bbr
        [[ ${args[ipv6]} == "true" ]] && disable_ipv6
      	[[ ${args[warp]} == "true" ]] && warp
        [[ ${args[cert]} == "true" ]] && issuance_of_certificates
        [[ ${args[mon]} == "true" ]] && monitoring
        [[ ${args[shell]} == "true" ]] && shellinabox
        write_defaults_to_file
        update_reverse_proxy
        random_site
        [[ ${args[nginx]} == "true" ]] && nginx_setup
        [[ ${args[panel]} == "true" ]] && install_panel
        [[ ${args[custom]} == "true" ]] && settings_custom_json
        rotation_and_archiving
        [[ ${args[firewall]} == "true" ]] && enabling_security
        [[ ${args[ssh]} == "true" ]] && ssh_setup
        data_output
        ;;
      2)
        if [ ! -d "/usr/local/reverse_proxy/backup" ]; then
          rotation_and_archiving
        fi
        restore_backup
        ;;
      3)
        migration
        ;;
      4)
        change_domain
        ;;
      5)
        renew_cert
        ;;
      6)
        settings_custom_json
        ;;
      7)
        download_website
        ;;
      8)
        enable_ipv6
        ;;
      9)
        disable_ipv6
        ;;
      10)
        directory_size
        ;;
      11)
        traffic_stats
        ;;
      0)
        clear
        break
        ;;
      *)
        warning " $(text 76) "
        ;;
    esac
    info " $(text 85) "
    read -r dummy
  done
  log_clear
}

main "$@"