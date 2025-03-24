#!/bin/zsh

BARCODES=("ABC123" "XYZ789" "CODE42")
DEVICE="/dev/pts/2"   # Barcode scanner side
ACK_HEX="06"           # ASCII ACK
STX=$'\x02'
ETX=$'\x03'

# Open file descriptor for reading ACKs
exec 3<> $DEVICE

while true; do
  for code in $BARCODES; do
    framed="${STX}${code}${ETX}"
    print -n -- "$framed" >&3
    echo "Sent barcode: $code"

    # Read ACK (wait max 5 seconds)
    read -t 5 -k 1 -u 3 ack
    ack_hex=$(printf "%x" "'$ack")

    if [[ "$ack_hex" == "$ACK_HEX" ]]; then
      echo "ACK received for $code"
    else
      echo "No ACK received or wrong response. Retrying..."
      sleep 1
      continue  # retry same code
    fi

    sleep 1  # pause before next
  done
done
  
