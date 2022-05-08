FROM quay.io/gravitational/teleport:9

# configure teleport to be restarted if it crashes. Do this because restarting ACI sucks
ARG S6_OVERLAY_VERSION=3.1.0.1
RUN apt-get update && apt-get install -y xz-utils inotify-tools
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
# set teleport up to always restart if killed
    mkdir -p /etc/s6-overlay/s6-rc.d/teleport && \
    echo "longrun" | tee /etc/s6-overlay/s6-rc.d/teleport/type && \
    echo "#!/bin/sh" > /etc/s6-overlay/s6-rc.d/teleport/run && \
    echo "exec teleport start -c /etc/teleport/teleport.yaml" | tee --append /etc/s6-overlay/s6-rc.d/teleport/run && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/teleport && \
# watch teleport.yaml for restarts
    mkdir -p /etc/s6-overlay/s6-rc.d/notify && \
    echo "longrun" | tee /etc/s6-overlay/s6-rc.d/notify/type && \
    echo "#!/bin/sh" > /etc/s6-overlay/s6-rc.d/notify/run && \
    echo "exec inotifywait -qm --event modify /etc/teleport/teleport.yaml | while read path action file; do pkill -f teleport; done" | tee --append /etc/s6-overlay/s6-rc.d/notify/run && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/notify

ENTRYPOINT ["/init"]
CMD []

COPY app/config/teleport.yaml /etc/teleport/
RUN mkdir /var/lib/teleport && \
    groupadd --gid 1000 teleport && \
    useradd -M --gid 1000 --uid 1000 teleport && \
    chown 1000:1000 /var/lib/teleport /etc/teleport/teleport.yaml
USER 1000