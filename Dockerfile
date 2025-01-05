FROM alpine
#MAINTAINER Ramil Minkhanov  <digerfight@gmail.com>

# Install tor and privoxy
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl privoxy shadow tini tor tzdata lyrebird &&\
    cp /etc/privoxy/config.new /etc/privoxy/config &&\
    cp /etc/privoxy/default.filter.new /etc/privoxy/default.filter &&\
    cp /etc/privoxy/user.filter.new /etc/privoxy/user.filter &&\
    cp /etc/privoxy/match-all.action.new /etc/privoxy/match-all.action &&\
    cp /etc/privoxy/default.action.new /etc/privoxy/default.action &&\
    cp /etc/privoxy/user.action.new /etc/privoxy/user.action &&\
    chmod -R 777 /etc/privoxy/ &&\
    file='/etc/privoxy/config' && \
    sed -i 's|^\(accept-intercepted-requests\) .*|\1 1|' $file && \
    sed -i '/^listen/s|127\.0\.0\.1||' $file && \
    sed -i '/^listen.*::1/s|^|#|' $file && \
    sed -i 's|^\(logfile\)|#\1|' $file && \
    sed -i 's|^#\(log-messages\)|\1|' $file && \
    sed -i 's|^#\(log-highlight-messages\)|\1|' $file && \
    sed -i '/forward *localhost\//a forward-socks5t / 127.0.0.1:9050 .' $file&&\
    sed -i '/^forward-socks5t \//a forward 172.16.*.*/ .' $file && \
    sed -i '/^forward 172\.16\.\*\.\*\//a forward 172.17.*.*/ .' $file && \
    sed -i '/^forward 172\.17\.\*\.\*\//a forward 172.18.*.*/ .' $file && \
    sed -i '/^forward 172\.18\.\*\.\*\//a forward 172.19.*.*/ .' $file && \
    sed -i '/^forward 172\.19\.\*\.\*\//a forward 172.20.*.*/ .' $file && \
    sed -i '/^forward 172\.20\.\*\.\*\//a forward 172.21.*.*/ .' $file && \
    sed -i '/^forward 172\.21\.\*\.\*\//a forward 172.22.*.*/ .' $file && \
    sed -i '/^forward 172\.22\.\*\.\*\//a forward 172.23.*.*/ .' $file && \
    sed -i '/^forward 172\.23\.\*\.\*\//a forward 172.24.*.*/ .' $file && \
    sed -i '/^forward 172\.24\.\*\.\*\//a forward 172.25.*.*/ .' $file && \
    sed -i '/^forward 172\.25\.\*\.\*\//a forward 172.26.*.*/ .' $file && \
    sed -i '/^forward 172\.26\.\*\.\*\//a forward 172.27.*.*/ .' $file && \
    sed -i '/^forward 172\.27\.\*\.\*\//a forward 172.28.*.*/ .' $file && \
    sed -i '/^forward 172\.28\.\*\.\*\//a forward 172.29.*.*/ .' $file && \
    sed -i '/^forward 172\.29\.\*\.\*\//a forward 172.30.*.*/ .' $file && \
    sed -i '/^forward 172\.30\.\*\.\*\//a forward 172.31.*.*/ .' $file && \
    sed -i '/^forward 172\.31\.\*\.\*\//a forward 10.*.*.*/ .' $file && \
    sed -i '/^forward 10\.\*\.\*\.\*\//a forward 192.168.*.*/ .' $file && \
    sed -i '/^forward 192\.168\.\*\.\*\//a forward 127.*.*.*/ .' $file && \
    sed -i '/^forward 127\.\*\.\*\.\*\//a forward localhost/ .' $file && \
    echo 'AutomapHostsOnResolve 1' >>/etc/tor/torrc && \
    echo 'ControlPort 9051' >>/etc/tor/torrc && \
    echo 'ControlSocket /etc/tor/run/control' >>/etc/tor/torrc && \
    echo 'ControlSocketsGroupWritable 1' >>/etc/tor/torrc && \
    echo 'CookieAuthentication 1' >>/etc/tor/torrc && \
    echo 'CookieAuthFile /etc/tor/run/control.authcookie' >>/etc/tor/torrc && \
    echo 'CookieAuthFileGroupReadable 1' >>/etc/tor/torrc && \
    echo 'DNSPort 5353' >>/etc/tor/torrc && \
    echo 'DataDirectory /var/lib/tor' >>/etc/tor/torrc && \
    echo 'ExitPolicy reject *:*' >>/etc/tor/torrc && \
    echo 'Log notice stderr' >>/etc/tor/torrc && \
    echo 'RunAsDaemon 0' >>/etc/tor/torrc && \
    echo 'SocksPort 0.0.0.0:9050 IsolateDestAddr' >>/etc/tor/torrc && \
    echo 'TransPort 0.0.0.0:9040' >>/etc/tor/torrc && \
    echo 'User tor' >>/etc/tor/torrc && \
    echo 'VirtualAddrNetworkIPv4 10.192.0.0/10' >>/etc/tor/torrc && \
    echo 'UseBridges 1' >> /etc/tor/torrc && \
    echo 'ClientTransportPlugin obfs4 exec /usr/bin/lyrebird managed' >> /etc/tor/torrc && \
    # You can change bridge
    echo 'Bridge obfs4 194.164.161.57:34182 E2D9A6819DF983B4FC138601399249E33E7CCE31 cert=OH2TOTA/EtDOEaKEMD1gAcDEKMOQwH+ZhxSVfa98b0yybvGCg5Eo5tYnhNk0CWWeLBctFQ iat-mode=0' >> /etc/tor/torrc && \
    echo 'Bridge obfs4 195.231.85.247:10021 AD26290480151BAA4A8F695C11BD7B141284B691 cert=iohB8SdMNEkqxItwuRi78F/AFczuTUPC7C+2cfh81PN/yhWE/NQci7RW8VLMZwLPfK1dYg iat-mode=0' >> /etc/tor/torrc && \
    mkdir -p /etc/tor/run && \
    chown -Rh tor /var/lib/tor /etc/tor/run && \
    chmod 0750 /etc/tor/run && \
    rm -rf /tmp/*

COPY torproxy.sh /usr/bin/

EXPOSE 8118 9050 9051

HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
            CMD curl -sx localhost:8118 'https://check.torproject.org/' | \
            grep -qm1 Congratulations

VOLUME ["/etc/tor", "/var/lib/tor"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/torproxy.sh"]