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
            printf '%s\n' "win64native"
            ;;

        Linux*)
            # WSL, including Debian running inside WSL
            if grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease 2>/dev/null; then
                printf '%s\n' "win64"
                return
            fi

            # Native Debian-based Linux on x86-64
            if [[ -r /etc/os-release ]] &&
			   grep -qE '^ID=(debian|ubuntu)$' /etc/os-release; then
				printf '%s\n' "debian"
				return
			fi

            printf 'Unsupported platform: %s (%s)\n' "$kernel" "$machine" >&2
            return 1
            ;;

        *)
            printf 'Unsupported platform: %s (%s)\n' "$kernel" "$machine" >&2
            return 1
            ;;
    esac
}

detect_platform
