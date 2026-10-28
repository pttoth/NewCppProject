#!/usr/bin/env bash

# Detects the platform the current system is running on.
# Possible outputs are:
#   debian          ( linux system )
#   win64           ( win64 in WSL debian container )
#   win64native     ( win64 native )
#   unsupported     (everything else)

set -euo pipefail

detect_platform() {
    local kernel
    local machine

    kernel="$(uname -s)"
    machine="$(uname -m)"

    case "$kernel" in
        MINGW*|MSYS*|CYGWIN*)
            # Native Windows shell, e.g. Git Bash
            echo "win64native"
            return 0
            ;;

        Linux*)
            # WSL, including Debian running inside WSL
            if grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease 2>/dev/null; then
                echo "win64"
                return 0
            fi

            # known debian distros
            if [[ -r /etc/os-release ]] &&
                grep -qE '^ID=(debian|ubuntu|linuxmint)$' /etc/os-release; then
                echo "debian"
                return 0
            fi

            # unknown debian distros ( if they show 'debian' in ID_LIKE )
            if [[ -r /etc/os-release ]] &&
            [[ "debian" == $(grep '^ID_LIKE=' /etc/os-release | grep -oE '\bdebian\b') ]];
            then
                echo "debian"
                return 0
            fi


            #printf 'Unsupported Linux platform: %s (%s)\n' "$kernel" "$machine" >&2
            echo ${kernel}_${machine}
            return 1
            ;;

        *)

        #printf 'Unsupported platform: %s (%s)\n' "$kernel" "$machine" >&2
        echo ${kernel}_${machine}
        return 1
        ;;
    esac
}

detect_platform
