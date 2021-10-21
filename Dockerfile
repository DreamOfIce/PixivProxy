FROM ubuntu:20.04
RUN echo "Pixiv Proxy" \
    && echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn" \
    && echo "Using GPL3.0 License" \
    && echo "Please abide by the use agreement of relevant service providers!" \
    && echo "===============================" \
    && echo "Start building image." \
    && echo "Update source..." \
    && sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
    && apt update -qq \
    && apt upgrade -y -qq \
    && echo "Done." \
    && echo "Install Nginx" \
    && apt install curl nginx libnginx-mod-http-subs-filter -y -qq --no-install-recommends \
    && echo "Done." \
    && echo "Add user www..." \
    && groupadd -r www \
    && useradd -r -g www www \
    && echo "Done." \
    && echo "Prepare to copy files..." \
    && rm /etc/nginx/nginx.conf \
    && echo "Done."
COPY nginx.conf /etc/nginx
COPY init.sh /home
RUN echo "Run final processing..." \
    && nginx -t \
    && chmod +x /home/init.sh \
    && apt clean -qq \
    && apt autoremove -qq \
    && echo "done." \
    && echo "Finish!"
CMD [ "/home/init.sh" ]