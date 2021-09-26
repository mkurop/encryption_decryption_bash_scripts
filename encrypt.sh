#!/bin/bash


if [ "$#" -eq 0 ]; then
  echo "Usage: ./encrypt.sh <public key in ssh-keygen format (id_rsa.pub)> <plain text file to encrypt>"
  echo "produces <plain text file to encrypt>.enc.base64 - the file with symmetric key encrypted input message"
  echo "and <plain text file to encrypt>.symmetrickey.enc.base64 - the RSA encrypted symmetric key in base64 format"
  exit 0
fi


KEY=$(openssl rand 32); 
echo "$KEY" > "symmetric_key.bin"
# convert ssh-keygen key format to pem format
RSA_PUB_KEY=$(ssh-keygen -f "$1" -e -m PKCS8)
TMP_RSA_PUB_KEY_PEM_FILE=$(mktemp)
echo "$RSA_PUB_KEY" > "$TMP_RSA_PUB_KEY_PEM_FILE"
echo $(ssh-keygen -lf "$1")

# encrypt plain text message using aes symmetric cipher
openssl enc -aes-256-cbc -pbkdf2 -pass pass:"$KEY" -base64 -in "$2" -out "${2}.enc.base64"

# encrypt the symmetric key using the pub key
TMP_AES_KEY_FILE=$(mktemp)
echo "$KEY" > "$TMP_AES_KEY_FILE"
echo "$TMP_RSA_PUB_KEY_PEM_FILE"
cat "$TMP_RSA_PUB_KEY_PEM_FILE"
openssl rsautl -encrypt -pubin -inkey "$TMP_RSA_PUB_KEY_PEM_FILE" -in "$TMP_AES_KEY_FILE" -out "${2}.symmetrickey.enc" 
base64 "${2}.symmetrickey.enc" > "${2}.symmetrickey.enc.base64"


