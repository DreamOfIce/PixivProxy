#!/bin/bash
#安装脚本

echo -e "\033[33m Pixiv Proxy\n \033[0m"
echo -e "\033[36m Github: https://github.com/dream/pixiv-proxy \033[0m"
echo -e "\033[33m 请遵守您所在国家的法律以及相关服务商的政策 \033[0m"
echo -e "\n===============================\n"

echo "设置脚本权限..."
chmod -R +x ./scripts
echo "完成."
apt update >/dev/null
echo "安装nginx..."
apt install -y nginx libnginx-mod-http-subs-filter curl
echo "完成."
echo "复制nginx.conf"
if [ -e /etc/nginx/nginx.conf && $IN_DOCKER != 'true' ]; then
    read -n1 -p '检测到nginx.conf,是否覆盖?[y/N]' cover
    if [ "${cover,,}" == 'y' ]; then
        cp -f nginx.conf /etc/nginx/nginx.conf
    fi
else
    cp nginx.conf /etc/nginx/nginx.conf
fi
echo "完成"
echo "添加用户pixiv..."
groupadd -r pxiv
useradd -r -g pixiv pixiv
echo "完成."

#完善配置
if [ -s ./_config || $IN_DOCKER = 'true' ]; then
    echo "使用_config中的配置"
else
    echo "请根据引导完善配置"
    ./scripts/config.sh
fi

#运行初始化脚本
if [ $IN_DOCKER != 'true' ]; then
    echo "开始初始化..."
    ./scripts/init.sh
    echo "脚本运行完毕,现在你可以愉快的访问P站了!ヾ(≧▽≦*)o"
fi
