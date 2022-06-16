#!/bin/bash
[[ $(id -u) != 0 ]] && echo -e "请使用root权限运行安装脚本" && exit 1

cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
    if [[ $(command -v yum) ]]; then
        cmd="yum"
    fi
else
    echo "此脚本不支持该系统" && exit 1
fi

install() {
    if [ -d "/root/kenc" ]; then
        echo -e "您已安装了该软件,如果确定没有安装,请输入rm -rf /root/kenc" && exit 1
    fi
	if [ -d "/root/miner_Proxy" ]; then
        echo -e "您已安装了该软件,如果确定没有安装,请输入rm -rf /root/kenc" && exit 1
    fi
    if screen -list | grep -q "kenc"; then
        echo -e "检测到您已启动了kenc,请输入killall kenc关闭后再安装" && exit 1
    fi

    $cmd update -y
    $cmd install curl wget screen -y
    mkdir /root/kenc
    wget https://github.com/haoxie666/HxMinerProxy/tree/main/kenc/kenc-O /root/kenc/kenc

    chmod 777 /root/kenc/kenc

	
    echo "如果没有报错则安装成功"
    echo "正在启动..."
    screen -dmS kenc
    sleep 0.2s
    screen -r kenc -p 0 -X stuff "cd /root/kenc"
    screen -r kenc -p 0 -X stuff $'\n'
    screen -r kenc -p 0 -X stuff "./run.sh"
    screen -r kenc -p 0 -X stuff $'\n'
    sleep 1s
    cat /root/kenc/config.yml
    echo "<<<如果成功了,这是您的端口号 请打开 http://服务器ip:端口 访问web服务进行配置:默认端口号为18888,请记录您的token,请尽快登陆并修改账号密码"
    echo "已启动web后台 您可运行 screen -r kenc 查看程序输出"

}

uninstall() {
    read -p "是否确认删除kenc[yes/no]：" flag
    if [ -z $flag ]; then
        echo "输入错误" && exit 1
    else
        if [ "$flag" = "yes" -o "$flag" = "ye" -o "$flag" = "y" ]; then
            screen -X -S kenc quit
            rm -rf /root/kenc
            echo "卸载kenc成功"
        fi
    fi
}


start() {
    if screen -list | grep -q "kenc"; then
        echo -e "kenc已启动,请勿重复启动" && exit 1
    fi
    screen -dmS kenc
    sleep 0.2s
    screen -r kenc -p 0 -X stuff "cd /root/kenc"
    screen -r kenc -p 0 -X stuff $'\n'
    screen -r kenc -p 0 -X stuff "./run.sh"
    screen -r kenc -p 0 -X stuff $'\n'
    echo "kenc已启动"
    echo "您可以使用指令screen -r kenc查看程序输出"
}

restart() {
    if screen -list | grep -q "kenc"; then
    screen -X -S kenc quit
    fi
    screen -dmS kenc
    sleep 0.2s
    screen -r kenc -p 0 -X stuff "cd /root/kenc"
    screen -r kenc -p 0 -X stuff $'\n'
    screen -r kenc -p 0 -X stuff "./run.sh"
    screen -r kenc -p 0 -X stuff $'\n'
	
    echo "kenc 重新启动成功"
    echo "您可运行 screen -r kenc 查看程序输出"
}

stop() {
    if screen -list | grep -q "kenc"; then
        screen -X -S kenc quit
    fi
    echo "kenc 已停止"
}

change_limit(){
    num="n"
    if [ $(grep -c "root soft nofile" /etc/security/kenc.conf) -eq '0' ]; then
        echo "root soft nofile 102400" >>/etc/security/kenc.conf
        num="y"
    fi

    if [[ "$num" = "y" ]]; then
        echo "连接数限制已修改为102400,重启服务器后生效"
    else
        echo -n "当前连接数限制："
        ulimit -n
    fi
}

check_limit(){
    echo -n "当前连接数限制："
    ulimit -n
}

echo "======================================================="
echo "加密中转kenc一键管理工具"
echo "  1、安装(默认安装到/root/kenc)"
echo "  2、卸载"
echo "  3、启动"
echo "  4、重启"
echo "  5、停止"
echo "  6、解除linux系统连接数限制(需要重启服务器生效)"
echo "  7、查看当前系统连接数限制"
#echo "  8、配置开机启动"
echo "======================================================="
read -p "$(echo -e "请选择[1-7]：")" choose
case $choose in
1)
    install
    ;;
2)
    uninstall
    ;;
3)
    start
    ;;
4)
    restart
    ;;
5)
    stop
    ;;
6)
    change_limit
    ;;
7)
    check_limit
    ;;
*)
    echo "输入错误请重新输入！"
    ;;
esac