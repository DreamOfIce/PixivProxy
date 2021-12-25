#!/bin/sh

#密钥
key=@KEY@

#检查更新
checkUpdate() {
    remoteSha256=$(curl -s https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country\&license_key=${geoIPKey}\&suffix=tar.gz.sha256)
    localSha256=$(sha256sum /home/geoip2/country.mmdb)
    if [ "$remoteSha256" != "$localSha256" ]; then
        return 0
    else
        return 1
    fi
}

#更新数据库
update() {
    curl https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country\&license_key=${geoIPKey}\&suffix=tar.gz -o /tmp/geoip/country.tar.gz
    dbPath=$(tar -zvxf /tmp/geoip/country.tar.gz | grep -i GeoLite2-Country.mmdb)
    remoteSha256=$(curl -s https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country\&license_key=${geoIPKey}\&suffix=tar.gz.sha256)
    localSha256=$(sha256sum /tmp/geoip/${dbPath})
    if [ "$remoteSha256" = "$localSha256" ]; then
        mv /tmp/geoip/"${dbPath}" /home/geoip2/country.mmdb
    else
        echo "\033[33m SHA256不匹配,文件已被修改,放弃下载内容! \033[0m"
    fi
    rm -r /tmp/geoip
}

#执行程序
if checkUpdate; then
    update
fi
