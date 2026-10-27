#!/bin/bash

# Detects the architecture the current system is running on.
# Possible outputs are:
#   i386    ( i386, i486, i586, i686, x86 )
#   amd64   ( amd64, x86_64 )
#   arm64   ( arm64, aarch64 )
#   unsupported (everything else)

arch=$(uname -m)
archReturn=$arch

# if forced, just return the raw value
if [[ "$1" != "force" ]]; then
    # translate double namings into single possible output
    if [[   "$arch" == "x86"     || "$arch" == "i486" \
       ||   "$arch" == "i586"    || "$arch" == "i686" ]]; then  archReturn="i386" ;
    elif [[ "$arch" == "x86_64"  ]]; then                       archReturn="amd64" ;
    elif [[ "$arch" == "aarch64" ]]; then                       archReturn="arm64";
    fi

    # check whether supported
    if [[ "$archReturn" != "amd64" ]]; then
        archReturn="unsupported"
    fi

fi

echo "$archReturn"
