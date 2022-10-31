FROM quay.io/gravitational/teleport:11

# configure teleport to be restarted if it crashes. Do this because restarting ACI sucks
ARG S6_OVERLAY_VERSION=3.1.2.1
RUN apt-get update && apt-get install -y xz-utils inotify-tools

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

COPY app/s6/teleport /etc/s6-overlay/s6-rc.d/teleport
COPY app/s6/notify /etc/s6-overlay/s6-rc.d/notify
COPY app/config/teleport.yaml /etc/teleport/

RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/teleport && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/notify && \
    mkdir -p /var/lib/teleport && \
    mkdir -p /etc/teleport/ && \
    #teleport configure > /etc/teleport/teleport.yaml && \
    groupadd --gid 1000 teleport && \
    useradd -M --gid 1000 --uid 1000 teleport && \
    chown 1000:1000 /var/lib/teleport /etc/teleport/teleport.yaml

USER 1000

EXPOSE 3023
EXPOSE 3025
EXPOSE 3080

ENTRYPOINT ["/init"]
CMD []