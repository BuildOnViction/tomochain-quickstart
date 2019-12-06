#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/.env"

check_path(){
    [[ ! -f "$BINARY_FILE" ]] && { echo "Binary file not found"; exit 1; }
    [[ ! -d "$KEYSTORE_DIR" ]] && mkdir $KEYSTORE_DIR -p
}

createPassword(){
    if ! test -f "$PASSWORD_FILE"; then
        touch $PASSWORD_FILE
        PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        echo $PASS >> $PASSWORD_FILE;
        echo "Account's password is in" $KEYSTORE_DIR;
    fi
}

createAccount(){
    if test -f "$PASSWORD_FILE"; then
        FILECOUNT=$(find $TOMO_DEFAULT_PATH"/keystore" -type f | wc -l)
        if [ $FILECOUNT -lt 2 ]; then
            # echo "Creating new account("$KEYSTORE_DIR")"
            $BINARY_FOLDER"/tomo" account new --password $PASSWORD_FILE --keystore $KEYSTORE_DIR
        fi
    fi
}

check_path
createPassword
createAccount