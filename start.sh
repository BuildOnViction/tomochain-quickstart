#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/.env"

user_config_fullnode(){
    if [ $NODE_NAME == "FULLNODE_NAME" ]; then
        read -p 'Node name: ' nodeName
        sed -i "s|"FULLNODE_NAME"|$nodeName|g" .env
    fi
}

update_os(){
    if [ $OS == "ubuntu" ]; then
        sudo apt-get update
    elif [ $OS == "centos" ]; then
        sudo yum -y check-update
    fi
}

download_binary(){
    echo "Downloading Tomo" $TOMOCHAIN_VERSION "binary"
    wget -O $BINARY_FOLDER"/tomo" $BINARY_URL
    chmod +x $BINARY_FOLDER"/tomo"
    sudo cp $BINARY_FOLDER"/tomo" /usr/bin
}


setup_install_path(){
    [[ ! -d "$TOMO_DEFAULT_PATH" ]] && mkdir $TOMO_DEFAULT_PATH
    [[ ! -d "$TOMO_DEFAULT_PATH/logs" ]] && mkdir $TOMO_DEFAULT_PATH"/logs"
}

setup_environment(){
    # Set absolute home path
    sed -i "s|"\$HOME"|$HOME|g" .env
    update_os
    setup_install_path
}

download_chain_data(){
    echo "Download chain data, it takes time!"
    wget -O $TOMO_DEFAULT_PATH"/chaindata.tar" $TOMO_CHAIN_DATA_URL
    echo "Extracting chain data ......"
    tar xf $TOMO_DEFAULT_PATH"/chaindata.tar" -C $TOMO_DEFAULT_PATH
}

start_fullnode(){
    # Create account if neccessary
    bash $DIR"/create_account.sh"

    if test -d $DATA_DIR"/tomo/chaindata";then
        systemd_stop_node
        download_binary
        systemd_reload
        systemd_start_node
        systemd_enable
    else
        systemd_stop_node
        download_binary
        download_chain_data

        curl -L $GENESIS_URL -o $TOMO_DEFAULT_PATH"/genesis.json" 
        $BINARY_FILE init $TOMO_DEFAULT_PATH"/genesis.json"  --datadir $DATA_DIR
        rm -rf $DATA_DIR"/tomo/chaindata"
        mv $TOMO_DEFAULT_PATH"/chaindata" $DATA_DIR"/tomo/chaindata"

        systemd_reload
        systemd_start_node
        systemd_enable
    fi
}

systemd_start_node(){
    echo "Starting service"
    sudo systemctl start fullnode.service
    echo "Use command 'tail -f" $TOMO_DEFAULT_PATH"/logs/fullnode.txt'" "to see logs"
}

systemd_stop_node(){
    echo "Stoping service"
    sudo systemctl stop fullnode.service
}

systemd_reload(){
    sudo systemctl daemon-reload
}

systemd_enable(){
    sudo systemctl enable fullnode.service
}

setup_fullnode(){
    #bash setup_mongo.sh
    # update service file
    sed -i "s|"\$HOME"|$DIR|g" fullnode.service
    sudo cp "fullnode.service" /etc/systemd/system

    start_fullnode
}

OS=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
case $OS in
  'ubuntu')
    OS='ubuntu'
    alias ls='ls --color=auto'
    ;;
  'centos')
    OS='centos'
    ;;
    *)
    echo "The script does not support current OS: $OS"
    exit 1
    ;;
esac

echo "Operating system:" $OS

user_config_fullnode
setup_environment
setup_fullnode