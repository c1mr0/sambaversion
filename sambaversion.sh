#!/bin/sh
#
# Licensed under MIT - Copyright (c) 2019 C1mr0 /\
#
# Detect which Samba version is running on a host.
#
# INFO:
# This script depends on smbclient and tcpdump.

name=${0##*/}
if [ -z "$1" ]; then
  echo "Usage: $name <host> ['username%password']"
  echo "Detect which Samba version is running on host."
  echo
  echo "When username%password is not supplied, a null session will be attempted."
  echo
  echo "Examples:"
  echo "  $name 10.0.0.1"
  echo "  $name 192.168.1.1 'john%secret123456'"
  exit
fi

SAMBA_VERSION_PATTERN="Samba [0-9]+\.[0-9]+\..*"
host=$1
credentials=$2

if [ $(which mktemp) ]; then
  outfile=$(mktemp)
else
  outfile=/tmp/$name.$$
fi
trap "rm -f $outfile" EXIT

tcpdump -s0 -n -i any src $host and '(port 139 or port 445)' -A -c 100 2>/dev/null > $outfile &
pid=$!

if [ -z "$credentials" ]; then
  smbclient -L $host -N 1>/dev/null 2>/dev/null
else
  smbclient -L $host -N -U "$credentials" 1>/dev/null 2>/dev/null
fi

kill $pid >/dev/null 2>&1

if [ ! -f "$outfile" ]; then
  echo "$host: ERROR: no SMB network traffic detected"
  exit 1
fi

version=$(grep 'Samba' $outfile | grep -m1 -oP "$SAMBA_VERSION_PATTERN" | sed 's/\.$//')
if [ -z "$version" ]; then
  version=$(grep 'S.a.m.b.a' $outfile | sed 's/\.\./_/g' | sed 's/\.//g' | sed 's/_/./g' | grep -m1 -oP "$SAMBA_VERSION_PATTERN" | sed 's/\.$//')
fi

if [ -z "$version" ]; then
  echo "$host: no Samba version found"
  exit 2
fi

for i in 1 2; do
  lw=$(echo $version | rev | cut -d"." -f1 | rev)
  case $lw in
  [A-Z]*)
    version=$(echo $version | sed "s/\.$lw//g")
    ;;
  *)
    break
    ;;
  esac
done

echo "$host: $version"
