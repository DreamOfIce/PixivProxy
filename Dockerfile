FROM debian:stable-slim
WORKDIR /home
COPY ./ /home/
ARG IN_DOCKER='true'
RUN echo "开始构建镜像..." \
    && chmod +x /home/setup.sh \
    && /home/setup.sh \
    && apt clean \
    && apt autoremove -y \
    && echo "镜像构建完成"
CMD [ "/home/scripts/init.sh" ]