#!/bin/bash

ERRORS=0

echo
echo "Checking toolset availability in environment ..."

for program in git cmake mingw32-make; do
    if command -v "$program" >/dev/null 2>&1; then
        echo "[  FOUND  ] $program"
    else
        echo "[ MISSING ] $program"
        ERRORS=1
    fi
done

if [ "$ERRORS" -eq 0 ]; then
    echo "OK"
    exit 0
fi

echo "ERROR: One or more programs are missing!"
exit 1
