const proxy = require('http-proxy-middleware');
const express = require('express');
const fs = require('fs/promises');
const path = require('path');

var config;
/*fs.readFile('config.json').then(text => {
    config = json.parse(text);
});*/

const proxyOptions = {
    proxyTimeout: 5000,
    timeout: 10000,
    secure: true,
    ws: true,
}

var app = express();

//后台系统
app.use('/config/*', express.static(path.join(__dirname, 'public', 'config')));

//监听端口
var server = app.listen(process.env.PORT || 8002, () => {
    console.log(`开始在端口${server.address().port}上运行PixivProxy.`);
});