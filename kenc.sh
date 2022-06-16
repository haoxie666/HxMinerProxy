#!/bin/bash
stty erase ^H

red='\e[91m'
green='\e[92m'
yellow='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
'amd64' | x86_64) ;;
*)
    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1
    ;;
esac

if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e " 
	 这个 ${red}安装脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

if [ ! -d "/etc/kenc/" ]; then
    mkdir /etc/kenc/
fi

error() {
    echo -e "\n$red 输入错误!$none\n"
}

install_download() {
    installPath="/etc/kenc"
    $cmd update -y
    if [[ $cmd == "apt-get" ]]; then
        $cmd install -y lrzsz git zip unzip curl wget supervisor
        service supervisor restart
    else
        $cmd install -y epel-release
        $cmd update -y
        $cmd install -y lrzsz git zip unzip curl wget supervisor
        systemctl enable supervisord
        service supervisord restart
    fi

    [ -d ./kenc ] && rm -rf ./kenc
    mkdir ./kenc

    echo "请选择安装版本"
    echo "  1、kenc"
    read -p "$(echo -e "请输入[1-2]:")" choose
    case $choose in
    1)
        wget https://github.com/haoxie666/HxMinerProxy/tree/main/kenc/kenc -O ./kenc/kenc

        cp -rf ./kenc /etc/

        if [[ ! -d $installPath ]]; then
            echo
            echo -e "$red 复制文件出错了...$none"
            echo
            echo -e " 使用最新版本的Ubuntu或者CentOS再试试"
            echo
            exit 1
        fi

        echo
        echo "下载完成，开启守护"
        echo
        chmod a+x $installPath/kenc
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/kenc.conf -f
            echo "[program:kenc]" >>/etc/supervisor/conf/kenc.conf
            echo "command=${installPath}/kenc_6.0.4_linux" >>/etc/supervisor/conf/kenc.conf
            echo "directory=${installPath}/" >>/etc/supervisor/conf/kenc.conf
            echo "autostart=true" >>/etc/supervisor/conf/kenc.conf
            echo "autorestart=true" >>/etc/supervisor/conf/kenc.conf
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/kenc.conf -f
            echo "[program:kenc]" >>/etc/supervisor/conf.d/kenc.conf
            echo "command=${installPath}/kenc_6.0.4_linux" >>/etc/supervisor/conf.d/kenc.conf
            echo "directory=${installPath}/" >>/etc/supervisor/conf.d/kenc.conf
            echo "autostart=true" >>/etc/supervisor/conf.d/kenc.conf
            echo "autorestart=true" >>/etc/supervisor/conf.d/kenc.conf
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/kenc.ini -f
            echo "[program:kenc]" >>/etc/supervisord.d/kenc.ini
            echo "command=${installPath}/kenc" >>/etc/supervisord.d/kenc.ini
            echo "directory=${installPath}/" >>/etc/supervisord.d/kenc.ini
            echo "autostart=true" >>/etc/supervisord.d/kenc.ini
            echo "autorestart=true" >>/etc/supervisord.d/kenc.ini
        else
            echo
            echo "----------------------------------------------------------------"
            echo
            echo " Supervisor安装目录没了,安装失败,请更换系统在尝试安装!"
            echo
            exit 1
        fi

        ;;
    2)
        wget https://github.com/haoxie666/HxMinerProxy/tree/main/kenc/kenc -O ./kenc/kenc
        cp -rf ./kenc /etc/

        if [[ ! -d $installPath ]]; then
            echo
            echo -e "$red 复制文件出错了...$none"
            echo
            echo -e " 使用最新版本的Ubuntu或者CentOS再试试"
            echo
            exit 1
        fi

        echo
        echo "下载完成，开启守护"
        echo
        chmod a+x $installPath/kenc
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/kenc.conf -f
            echo "[program:kenc]" >>/etc/supervisor/conf/kenc.conf
            echo "command=${installPath}/kenc >>/etc/supervisor/conf/kenc.conf
            echo "directory=${installPath}/" >>/etc/supervisor/conf/kenc.conf
            echo "autostart=true" >>/etc/supervisor/conf/kenc.conf
            echo "autorestart=true" >>/etc/supervisor/conf/kenc.conf
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/kenc.conf -f
            echo "[program:kenc]" >>/etc/supervisor/conf.d/kenc.conf
            echo "command=${installPath}/kenc_6.0.5_linux" >>/etc/supervisor/conf.d/kenc.conf
            echo "directory=${installPath}/" >>/etc/supervisor/conf.d/kenc.conf
            echo "autostart=true" >>/etc/supervisor/conf.d/kenc.conf
            echo "autorestart=true" >>/etc/supervisor/conf.d/kenc.conf
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/kenc.ini -f
            echo "[program:kenc]" >>/etc/supervisord.d/kenc.ini
            echo "command=${installPath}/kenc" >>/etc/supervisord.d/kenc.ini
            echo "directory=${installPath}/" >>/etc/supervisord.d/kenc.ini
            echo "autostart=true" >>/etc/supervisord.d/kenc.ini
            echo "autorestart=true" >>/etc/supervisord.d/kenc.ini
        else
            echo
            echo "----------------------------------------------------------------"
            echo
            echo " Supervisor安装目录没了,安装失败,请更换系统在尝试安装!"
            echo
            exit 1
        fi

        ;;
    *)
        wget https://github.com/haoxie666/HxMinerProxy/tree/main/kenc/kenc -O ./kenc/kenc
        cp -rf ./kenc /etc/

        if [[ ! -d $installPath ]]; then
            echo
            echo -e "$red 复制文件出错了...$none"
            echo
            echo -e " 使用最新版本的Ubuntu或者CentOS再试试"
            echo
            exit 1
        fi

        echo
        echo "下载完成，开启守护"
        echo
        chmod a+x $installPath/kenc
        if [ -d "/etc/supervisor/conf/" ]; then
            rm /etc/supervisor/conf/kenc.conf -f
            echo "[program:kenc]" >>/etc/supervisor/conf/kenc.conf
            echo "command=${installPath}/kenc" >>/etc/supervisor/conf/kenc.conf
            echo "directory=${installPath}/" >>/etc/supervisor/conf/kenc.conf
            echo "autostart=true" >>/etc/supervisor/conf/kenc.conf
            echo "autorestart=true" >>/etc/supervisor/conf/kenc.conf
        elif [ -d "/etc/supervisor/conf.d/" ]; then
            rm /etc/supervisor/conf.d/kenc.conf -f
            echo "[program:kenc]" >>/etc/supervisor/conf.d/kenc.conf
            echo "command=${installPath}/kenc" >>/etc/supervisor/conf.d/kenc.conf
            echo "directory=${installPath}/" >>/etc/supervisor/conf.d/kenc.conf
            echo "autostart=true" >>/etc/supervisor/conf.d/kenc.conf
            echo "autorestart=true" >>/etc/supervisor/conf.d/kenc.conf
        elif [ -d "/etc/supervisord.d/" ]; then
            rm /etc/supervisord.d/kenc.ini -f
            echo "[program:kenc]" >>/etc/supervisord.d/kenc.ini
            echo "command=${installPath}/kenc" >>/etc/supervisord.d/kenc.ini
            echo "directory=${installPath}/" >>/etc/supervisord.d/kenc.ini
            echo "autostart=true" >>/etc/supervisord.d/kenc.ini
            echo "autorestart=true" >>/etc/supervisord.d/kenc.ini
        else
            echo
            echo "----------------------------------------------------------------"
            echo
            echo " Supervisor安装目录没了,安装失败,请更换系统在尝试安装!"
            echo
            exit 1
        fi

        ;;
    esac
}

start_write_config() {
    if [[ $cmd == "apt-get" ]]; then
        ufw disable
    else
        systemctl stop firewalld
        sleep 1
        systemctl disable firewalld.service
    fi

    changeLimit="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 102400" >>/etc/security/limits.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root hard nofile 102400" >>/etc/security/limits.conf
        changeLimit="y"
    fi

    if [ $(grep -c "root soft nofile" /etc/systemd/system.conf) -eq '0' ]; then
        echo "DefaultLimitNOFILE=102400" >>/etc/systemd/system.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /etc/systemd/system.conf) -eq '0' ]; then
        echo "DefaultLimitNPROC=102400" >>/etc/systemd/system.conf
        changeLimit="y"
    fi

    if [ $(grep -c "root soft nofile" /etc/systemd/user.conf) -eq '0' ]; then
        echo "DefaultLimitNOFILE=102400" >>/etc/systemd/user.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /etc/systemd/user.conf) -eq '0' ]; then
        echo "DefaultLimitNPROC=102400" >>/etc/systemd/user.conf
        changeLimit="y"
    fi

    clear
    echo
    echo "----------------------------------------------------------------"
    echo
    if [[ "$changeLimit" = "y" ]]; then
        echo "系统连接数限制已经改了，如果第一次运行本程序需要重启!"
        echo
    fi
    sleep 1
    supervisorctl reload
    sleep 1
    echo
    echo "安装完成...守护模式无日志，需要日志的请登录后台查看"
    echo
    echo "[*---------]"
    sleep 1
    echo "[**--------]"
    sleep 1
    echo "[***-------]"
    sleep 1
    echo "[****------]"
    sleep 1
    echo "[*****-----]"
    sleep 1
    echo "[******----]"
    sleep 1
    if [ -f /etc/kenc/pwd.txt ]; then
        echo
        cat /etc/kenc/pwd.txt
        echo
    else
    fi
    echo "----------------------------------------------------------------"
}

uninstall() {
    clear
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/kenc.conf -f
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/kenc.conf -f
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/kenc.ini -f
    fi
    supervisorctl reload
    echo -e "$yellow 已关闭自启动${none}"
}

Reset() {
    clear
    if [ -f "/etc/kenc/config.json" ]; then
        rm -f /etc/kenc/config.json
    fi
    killall kenc
    echo "----------------------------------------------------------------"
    echo "成功重置配置文件"
    echo
    echo "[*---------]"
    sleep 1
    echo "[**--------]"
    sleep 1
    echo "[***-------]"
    sleep 1
    echo "[****------]"
    sleep 1
    echo "[*****-----]"
    sleep 1
    echo "[******----]"
    sleep 1
    if [ -f /etc/kenc/pwd.txt ]; then
        echo
        cat /etc/kenc/pwd.txt
        echo
    else
    fi
    echo "----------------------------------------------------------------"
}

clear
while :; do
    echo
    echo "-------- kenc 一键安装脚本 --------"
    echo
    echo " 1. 安装(kenc)"
    echo
    echo " 2. 卸载(kenc)"
    echo
    echo " 3. 重启(kenc)"
    echo
    echo
    read -p "$(echo -e "请选择 [${magenta}1-4$none]:")" choose
    case $choose in
    1)
        install_download
        start_write_config
        break
        ;;
    2)
        uninstall
        break
        ;;
    3)
        killall kenc
        echo "重启成功"
        break
        ;;
    4)
        Reset
        break
        ;;
    *)
        error
        ;;
    esac
done