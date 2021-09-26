#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Usage: decrypt.sh <private key in ssh-keygen format (id_rsa)> <base64 enrypted message> <base64 encrypted symmetric aes-256 key>"
  exit 0
fi

# convert the private key to PEM format
# save the key file to tmp file
TMP_KEY_FILE=$(mktemp)
cp "$1" "$TMP_KEY_FILE"
ssh-keygen -p -f "$1" -m PKCS8
PRIVATE_KEY_TMP_FILE=$(mktemp)
cp "$1" "$PRIVATE_KEY_TMP_FILE"
mv "$TMP_KEY_FILE" "$1"

# save enrypted symmetric key in binary file
SYMMETRIC_TMP_FILE=$(mktemp)
base64 -d "$3" > "$SYMMETRIC_TMP_FILE"

# decrypt the symmetric key
DECRYPTEDSYMMETRICKEYFILE=$(mktemp)
openssl rsautl -decrypt -inkey "$PRIVATE_KEY_TMP_FILE" -in "$SYMMETRIC_TMP_FILE" -out "${3}.dec"
sha256sum "${3}.dec"
# decrypt the message
openssl enc -aes-256-cbc -d -pbkdf2 -base64 -in "$2" -out "${2}.dec" -pass file:"./${3}.dec"


