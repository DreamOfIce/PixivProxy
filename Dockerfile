FROM ubuntu:20.04
ENV PIXIV_DOMAIN="pixiv.creeper2077.online" PXIMG_DOMAIN="pximg.creeper2077.online" 
ARG ARCHIVE_SOURCE='default' SECURITY_SOURCE='default'
RUN echo "Pixiv Proxy" \
    && echo "Author:Creeper2077" \
    && echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn" \
    && echo "Using GPL3.0 License" \
    && echo "Please abide by the use agreement of relevant service providers!" \
    && echo "===============================" \
    && echo "Start building image." \
    && echo "Update source..." \
    && if [ ${ARCHIVE_SOURCE} != 'default' ]; then sed -i "s/archive.ubuntu.com/${ARCHIVE_SOURCE}/g" /etc/apt/sources.list; fi \
    && if [ ${SECURITY_SOURCE} != 'default' ]; then sed -i "s/security.ubuntu.com/${SECURITY_SOURCE}/g" /etc/apt/sources.list; fi \
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
    && chmod +x /home/init.sh \
    && apt clean -qq \
    && apt autoremove -qq \
    && echo "done." \
    && echo "Finish!"
CMD [ "/home/init.sh" ]