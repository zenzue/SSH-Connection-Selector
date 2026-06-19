#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="SSH Connection Selector"
VERSION="v2.3.2"
AUTHOR="Aung Myat Thu / w01f"

SSH_DIR="$HOME/.ssh"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    RED=$'\033[0;31m'
    BLUE=$'\033[0;34m'
    CYAN=$'\033[0;36m'
    DIM=$'\033[2m'
    BOLD=$'\033[1m'
    NC=$'\033[0m'
else
    GREEN=""
    YELLOW=""
    RED=""
    BLUE=""
    CYAN=""
    DIM=""
    BOLD=""
    NC=""
fi

CONNECT_TIMEOUT=10
HACKER_MODE=1
DRY_RUN=0
TARGET=""

SERVERS=(
    "1|Server 1|user1|server1.example.com|22|key|id_ed25519"
    "2|Server 2|user2|server2.example.com|22|key|id_ed25519"
    "3|Server 3|user3|server3.example.com|22|key|id_ed25519"
    "4|Server 4|user4|server4.example.com|22|key|id_ed25519"
    "5|Server 5|user5|server5.example.com|22|key|id_ed25519"
    "6|Server 6|user6|server6.example.com|22|key|id_ed25519"
    "7|Server 7|user7|server7.example.com|22|key|id_ed25519"
    "8|Server 8|user8|server8.example.com|22|key|id_ed25519"
    "9|Server 9|user9|server9.example.com|22|prompt|"
)

center_line() {
    local text="$1"
    local width=57
    local text_len=${#text}
    local left=$(( (width - text_len) / 2 ))
    local right=$(( width - text_len - left ))

    printf "│%*s%s%*s│\n" "$left" "" "$text" "$right" ""
}

print_banner() {
    clear
    printf "%s╭─────────────────────────────────────────────────────────╮%s\n" "$BLUE" "$NC"

    printf "%s" "$BLUE"
    center_line "$APP_NAME"
    printf "%s" "$NC"

    printf "%s" "$BLUE"
    center_line "$VERSION by $AUTHOR"
    printf "%s" "$NC"

    printf "%s╰─────────────────────────────────────────────────────────╯%s\n" "$BLUE" "$NC"
    echo
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf "%sError: '%s' is not installed.%s\n" "$RED" "$1" "$NC"
        exit 1
    fi
}

check_key() {
    local key_path="$1"

    if [[ ! -f "$key_path" ]]; then
        printf "%sError: SSH key not found: %s%s\n" "$RED" "$key_path" "$NC"
        printf "%sPlease check your ~/.ssh folder.%s\n" "$YELLOW" "$NC"
        exit 1
    fi

    chmod 600 "$key_path" 2>/dev/null || true
}

auth_label() {
    case "$1" in
        key)
            printf "key"
            ;;
        prompt)
            printf "secure"
            ;;
        *)
            printf "unknown"
            ;;
    esac
}

hacker_loader() {
    local target="$1"

    [[ "$HACKER_MODE" -eq 0 ]] && return 0

    local steps=(
        "[+] Initializing secure terminal"
        "[+] Loading SSH profile"
        "[+] Checking authentication mode"
        "[+] Preparing encrypted channel"
        "[+] Target locked: $target"
        "[+] Launching session"
    )

    echo
    for step in "${steps[@]}"; do
        printf "%s%s%s" "$GREEN" "$step" "$NC"
        for _ in 1 2 3; do
            printf "%s.%s" "$GREEN" "$NC"
            sleep 0.12
        done
        echo
    done
    echo
}

show_menu() {
    printf "%sSelect a server to connect:%s\n" "$YELLOW" "$NC"
    echo

    local item id name user host port auth key label

    for item in "${SERVERS[@]}"; do
        IFS="|" read -r id name user host port auth key <<< "$item"
        label="$(auth_label "$auth")"

        printf " %s) %-16s %-8s %s%s@%s:%s%s\n" \
            "$id" "$name" "[$label]" "$CYAN" "$user" "$host" "$port" "$NC"
    done

    echo
    echo " r) Reload menu"
    echo " l) List servers"
    echo " q) Quit"
    echo
}

list_servers() {
    printf "%s%s Servers%s\n\n" "$BOLD" "$APP_NAME" "$NC"

    local item id name user host port auth key key_display label

    printf "%-4s %-18s %-18s %-32s %-8s %-10s %-16s\n" \
        "ID" "Name" "User" "Host" "Port" "Auth" "Key"
    echo "---------------------------------------------------------------------------------------------------------"

    for item in "${SERVERS[@]}"; do
        IFS="|" read -r id name user host port auth key <<< "$item"
        label="$(auth_label "$auth")"

        if [[ "$auth" == "prompt" ]]; then
            key_display="-"
        else
            key_display="$key"
        fi

        printf "%-4s %-18s %-18s %-32s %-8s %-10s %-16s\n" \
            "$id" "$name" "$user" "$host" "$port" "$label" "$key_display"
    done

    echo
}

lower_text() {
    printf "%s" "$1" | tr "[:upper:]" "[:lower:]"
}

find_server() {
    local query="$1"
    local query_lc
    query_lc="$(lower_text "$query")"

    local item id name user host port auth key name_lc

    for item in "${SERVERS[@]}"; do
        IFS="|" read -r id name user host port auth key <<< "$item"
        name_lc="$(lower_text "$name")"

        if [[ "$query" == "$id" || "$query_lc" == "$name_lc" ]]; then
            echo "$item"
            return 0
        fi
    done

    return 1
}

connect_ssh() {
    local name="$1"
    local user="$2"
    local host="$3"
    local port="$4"
    local auth="$5"
    local key_name="${6:-}"
    local key_path=""
    local ssh_cmd=()

    case "$auth" in
        key)
            key_path="$SSH_DIR/$key_name"
            check_key "$key_path"

            ssh_cmd=(
                ssh
                -i "$key_path"
                -p "$port"
                -o IdentitiesOnly=yes
                -o RequestTTY=yes
                -o ConnectTimeout="$CONNECT_TIMEOUT"
                -o ServerAliveInterval=60
                -o ServerAliveCountMax=3
                -o LogLevel=ERROR
                "${user}@${host}"
            )
            ;;
        prompt)
            ssh_cmd=(
                ssh
                -p "$port"
                -o PubkeyAuthentication=no
                -o PreferredAuthentications=password,keyboard-interactive
                -o RequestTTY=yes
                -o ConnectTimeout="$CONNECT_TIMEOUT"
                -o ServerAliveInterval=60
                -o ServerAliveCountMax=3
                -o LogLevel=ERROR
                "${user}@${host}"
            )
            ;;
        *)
            printf "%sError: invalid auth type '%s'. Use 'key' or 'prompt'.%s\n" "$RED" "$auth" "$NC"
            return 1
            ;;
    esac

    echo
    printf "%sSelected:%s %s\n" "$GREEN" "$NC" "$name"
    printf "%s%s@%s:%s%s\n" "$CYAN" "$user" "$host" "$port" "$NC"

    if [[ "$auth" == "key" ]]; then
        printf "%sAuth: key%s\n" "$DIM" "$NC"
        printf "%sKey: %s%s\n" "$DIM" "$key_path" "$NC"
    else
        printf "%sAuth: secure prompt%s\n" "$DIM" "$NC"
        printf "%sPassword input will be hidden by SSH.%s\n" "$YELLOW" "$NC"
        printf "%sPassword is not saved, printed, or logged by this script.%s\n" "$YELLOW" "$NC"
    fi

    printf "%sTTY Mode: enabled. ssh -T is not used.%s\n" "$YELLOW" "$NC"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo
        printf "%sDry run mode. No password will be printed.%s\n" "$YELLOW" "$NC"
        printf "%q " "${ssh_cmd[@]}"
        echo
        return 0
    fi

    hacker_loader "${user}@${host}:${port}"

    "${ssh_cmd[@]}"
}

connect_by_choice() {
    local choice="$1"
    local selected id name user host port auth key

    if ! selected="$(find_server "$choice")"; then
        printf "%sInvalid choice: %s%s\n" "$RED" "$choice" "$NC"
        return 1
    fi

    IFS="|" read -r id name user host port auth key <<< "$selected"
    connect_ssh "$name" "$user" "$host" "$port" "$auth" "$key"
}

usage() {
    cat <<EOF
$APP_NAME $VERSION
By $AUTHOR

Usage:
  ssh-selector.sh
  ssh-selector.sh <id>
  ssh-selector.sh <name>
  ssh-selector.sh --list
  ssh-selector.sh --dry-run 4
  ssh-selector.sh --no-hacker
  ssh-selector.sh --help

Server format:
  ID|Name|User|Host|Port|Auth|Key

Auth types:
  key
  prompt

Examples:
  ssh-selector.sh
  ssh-selector.sh 4
  ssh-selector.sh "Server 4"
  ssh-selector.sh --dry-run 9
  ssh-selector.sh --no-hacker "Server 9"
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                usage
                exit 0
                ;;
            --list|-l)
                list_servers
                exit 0
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --no-hacker)
                HACKER_MODE=0
                shift
                ;;
            *)
                TARGET="$1"
                shift
                ;;
        esac
    done
}

main() {
    check_command ssh
    parse_args "$@"

    if [[ -n "$TARGET" ]]; then
        connect_by_choice "$TARGET"
        exit 0
    fi

    while true; do
        print_banner
        show_menu

        read -rp "Enter your choice: " choice

        case "$choice" in
            q|Q)
                printf "%sBye.%s\n" "$GREEN" "$NC"
                exit 0
                ;;
            r|R)
                continue
                ;;
            l|L)
                clear
                list_servers
                read -rp "Press Enter to return to menu..."
                ;;
            "")
                continue
                ;;
            *)
                connect_by_choice "$choice" || {
                    sleep 1
                    continue
                }

                echo
                read -rp "Press Enter to return to menu..."
                ;;
        esac
    done
}

main "$@"
