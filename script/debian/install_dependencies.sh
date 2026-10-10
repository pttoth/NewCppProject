#!/bin/bash

packages=""
packages="$packages git"
packages="$packages cmake"
packages="$packages build-essential"


echo "installing packages:"
echo "  $packages"
echo ""
echo ""

sleep 5

apt install $packages -y
