#!/bin/sh
#GeoIP过滤

source ../_config
echo "安装maxmindDB..."
apt install -y libmaxminddb0 libmaxminddb-dev mmdb-bin >/dev/null
echo "完成"
echo "安装nginx geoip2模块..."
apt install -y libnginx-mod-http-geoip2 >/dev/null
echo "完成."
echo "获取GeoIPLite2数据库..."
curl https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country\&license_key=${geoIPKey}\&suffix=tar.gz -o /tmp/geoip/country.tar.gz
dbPath=$(tar -zvxf /tmp/geoip/country.tar.gz | grep -i GeoLite2-Country.mmdb)
mkdir /home/geoip2
mv /tmp/geoip/${dbPath} /home/geoip2/country.mmdb
rm -r /tmp/geoip
echo "完成"
echo "创建更新脚本..."
sed -i "s/@KEY@/${geoIPKey}/g" ${PWD}/geoipupdate.sh
cron_job="* * * * 2 ${PWD}/geoipupdate.sh"
(crontab -l | grep -v "${cron_job}"; echo "${cron_job}") | crontab -
echo "完成"
echo "安装nginx geoip2模块..."
apt install -y libnginx-mod-http-geoip2 >/dev/null
echo "完成."
echo "修改nginx配置..."
sed -i 's/#@geoip@//g' /etc/nginx/sites-available/proxy.conf
echo "完成."
echo "设置成功!"
exit 0
