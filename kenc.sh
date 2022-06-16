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
	 此 ${red}安装脚本${none} 不支持您的操作系统。

	备注: 推荐使用 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1
    ;;
esac

if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e "
	 此 ${red}安装脚本${none} 不支持您的操作系统。

	备注: 推荐使用 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
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
        $cmd install -y zip unzip curl wget supervisor
        service supervisor restart
    else
        $cmd install -y epel-release
        $cmd update -y
        $cmd install -y zip unzip curl wget supervisor
        systemctl enable supervisord
        service supervisord restart
    fi

    [ -d /root/kenc ] && rm -rf /root/kenc
    mkdir /root/kenc
    wget https://raw.githubusercontent.com/kenc/MinerProxy/main/kenc/kenc -O /root/kenc/kenc
    if [[ ! -d /root/kenc ]]; then
        echo
        echo -e "$red 下载 kenc 出错...$none"
        echo
        echo -e " 请尝试重新运行此安装脚本"
        echo
        exit 1
    fi

    cp -rf /root/kenc /etc/
    if [[ ! -d $installPath ]]; then
        echo
        echo -e "$red 复制 kenc 到安装目录出错...$none"
        echo
        echo -e " 请尝试重新运行此安装脚本"
        echo
        exit 1
    fi
}

start_write_config() {
    echo
    echo "安装完成，正在后续处理..."
    echo
    supervisorctl stop all
    chmod a+x $installPath/kenc_linux
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/kenc.conf -f
        echo "[program:kenc]" >>/etc/supervisor/conf/kenc.conf
        echo "command=${installPath}/kenc_linux" >>/etc/supervisor/conf/kenc.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf/kenc.conf
        echo "autostart=true" >>/etc/supervisor/conf/kenc.conf
        echo "autorestart=true" >>/etc/supervisor/conf/kenc.conf
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/kenc.conf -f
        echo "[program:kenc]" >>/etc/supervisor/conf.d/kenc.conf
        echo "command=${installPath}/kenc_linux" >>/etc/supervisor/conf.d/kenc.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf.d/kenc.conf
        echo "autostart=true" >>/etc/supervisor/conf.d/kenc.conf
        echo "autorestart=true" >>/etc/supervisor/conf.d/kenc.conf
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/kenc.ini -f
        echo "[program:kenc]" >>/etc/supervisord.d/kenc.ini
        echo "command=${installPath}/kenc_linux" >>/etc/supervisord.d/kenc.ini
        echo "directory=${installPath}/" >>/etc/supervisord.d/kenc.ini
        echo "autostart=true" >>/etc/supervisord.d/kenc.ini
        echo "autorestart=true" >>/etc/supervisord.d/kenc.ini
    else
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " Supervisor安装目录不存在，安装失败"
        echo
        exit 1
    fi

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
        echo "系统连接数限制已经修改，如果第一次运行本程序，需要重启服务器!"
        echo
    fi

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

update(){
    supervisorctl stop kenc
    [ -d /root/kenc ] && rm -rf /root/kenc
    mkdir -p /root/kenc
    wget https://github.com/haoxie666/HxMinerProxy/tree/main/kenc/kenc -O /root/kenc/kenc
    if [[ ! -d /root/kenc ]]; then
        echo
        echo -e "$red 下载 kenc 更新出错...$none"
        echo
        echo -e " 请尝试重新运行此更新脚本"
        echo
        exit 1
    fi
    cp -rf /root/kenc/kenc /etc/kenc
    chmod a+x /etc/kenc/kenc
    supervisorctl start kenc
    sleep 3s
    echo
    echo "kenc 已更新至最新版本并已经启动"
    echo
    exit
}

start(){
    supervisorctl start kenc
    echo "kenc 已启动"
}

restart(){
    supervisorctl restart kenc
    echo "kenc 重启完成"
}

stop(){
    supervisorctl stop kenc
    echo "kenc 已停止"
}

change_limit(){
    changeLimit="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 102400" >>/etc/security/limits.conf
        changeLimit="y"
    fi

    if [[ "$changeLimit" = "y" ]]; then
        echo "系统连接数限制已修改为102400, 重启服务器后生效"
    else
        echo -n "当前系统连接数限制："
        ulimit -n
    fi
}

check_limit(){
    echo -n "当前系统连接数限制："
    ulimit -n
}

clear
while :; do
  echo
  echo "-------- kenc 一键安装脚本 --------"
  echo "GitHub下载地址:https://github.com/haoxie666/HXminerProxy"
  echo
  echo " 1. 安  装"
  echo
  echo " 2. 卸  载"
  echo
  echo " 3. 更  新"
  echo
  echo " 4. 启  动"
  echo
  echo " 5. 重  启"
  echo
  echo " 6. 停  止"
  echo
  echo " 7. 一键解除Linux连接数限制 (需手动重启操作系统后生效)"
  echo
  echo " 8. 查看系统当前连接数限制"
  echo
  echo " 9. 退  出"
  echo
  read -p "$(echo -e "请选择 [${magenta}1-8$none]:")" choose
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
      update
      ;;
  4)
      start
      ;;
  5)
      restart
      ;;
  6)
      stop
      ;;
  7)
      change_limit
      ;;
  8)
      check_limit
      ;;
  9)
      break
      ;;
  *)
echo "请输入正确的数字序号！"
      ;;
  esac
done
