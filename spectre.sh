#!/bin/bash

# 节点安装功能
function install_node() {
	
    sudo apt update
    sudo apt install -y screen unzip

	# 安装 Go
    if ! check_go_installation; then
        sudo rm -rf /usr/local/go
        curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
        source $HOME/.bash_profile
        go version
    fi
    
    mkdir $HOME/spectre-network
	wget https://github.com/spectre-project/spectred/releases/download/v0.3.14/spectred-v0.3.14-linux-x86_64.zip
	unzip spectred-v0.3.14-linux-x86_64.zip -d $HOME/spectre-network
	cd $HOME/spectre-network/bin
	./spectred --utxoindex &
	SPECTRED_PID=$!
	sleep 3
	kill $SPECTRED_PID
	cd $HOME
	wget https://spectre-network.org/downloads/datadir2.zip
	unzip datadir2.zip -d $HOME/.spectred/spectre-mainnet
	cd $HOME/spectre-network/bin
	screen -dmS spectre_node bash -c './spectred --utxoindex'
    
	echo "部署完成，请先生成钱包，然后开始挖矿"
}

# 创建钱包
function create_wallet(){

    # 创建钱包
    read -p "钱包名称:" wallet_name
    $HOME/spectre-network/bin/spectrewallet create $wallet_name
    echo "创建成功，请备份好钱包信息"

}

# 开始挖矿
function start_mining(){
	
    # 启动挖矿
	cd ~/bin
	read -p "钱包地址: " wallet_addr
	cpu_core=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
	read -p "当前设备CPU数量：$cpu_core , 请输入挖矿的CPU核心数: " cpu_core
	screen -dmS spewa bash -c "./spectreminer --miningaddr='$wallet_addr' --workers '$cpu_core'"
    echo "ctrl + a + d 退出"
	sleep 2
	screen -r spewa
}

# 查看日志
function view_logs(){
	clear
	echo "5秒后进入screen，查看完请ctrl + a + d 退出"
	sleep 5
	screen -r spewa
}

# 主菜单
function main_menu() {
	while true; do
	    clear
	    echo "===================Nimble一键部署脚本==================="
		echo "沟通电报群：https://t.me/lumaogogogo"
		echo "最低配置：8C16G256G+RTX2080，推荐配置：16C32G256G+RTX3090"
	    echo "请选择要执行的操作:"
	    echo "1. 部署节点"
	    echo "2. 创建钱包"
	    echo "3. 开始挖矿"
	    echo "4. 查看日志"
	    echo "0. 退出脚本exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_node ;;
	    2) create_wallet ;;
	    3) start_mining ;;
	    4) view_logs ;;
	    0) echo "退出脚本。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 3 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

main_menu