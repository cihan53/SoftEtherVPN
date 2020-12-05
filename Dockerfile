FROM alpine:3.12 as prep

LABEL maintainer="Tomohisa Kusano <siomiz@gmail.com> cihan ozturk <cihanozturk53@gmail.com>" \
      contributors="See CONTRIBUTORS file <https://github.com/cihan53/SoftEtherVPN/blob/master/CONTRIBUTORS>"

ENV BUILD_VERSION=5.01.9674 \
    SHA256_SUM=0e63188a29afc8364814139cb8a3b3eca42af9ac4f28c4b6c4b1f582b14b2690

RUN wget https://github.com/SoftEtherVPN/SoftEtherVPN/archive/${BUILD_VERSION}.tar.gz \
    && echo "${SHA256_SUM}  ${BUILD_VERSION}.tar.gz" | sha256sum -c \
    && mkdir -p /usr/local/src \
    && tar -x -C /usr/local/src/ -f ${BUILD_VERSION}.tar.gz \
    && rm ${BUILD_VERSION}.tar.gz

# FIXME: can "git submodule update" (or "git clone") be properly secured?
RUN apk add git gnupg \
    && gpg --keyserver hkp://keys.gnupg.net --recv-keys ${CPU_FEATURES_VERIFY} \
    && git clone https://github.com/google/cpu_features.git /usr/local/src/SoftEtherVPN-${BUILD_VERSION}/src/Mayaqua/3rdparty/cpu_features \
    && cd /usr/local/src/SoftEtherVPN-${BUILD_VERSION}/src/Mayaqua/3rdparty/cpu_features \
    && git checkout ${CPU_FEATURES_VERSION} \
    && git verify-commit ${CPU_FEATURES_VERSION} \
    && cd -

FROM centos:8 as build

COPY --from=prep /usr/local/src /usr/local/src

RUN yum -y update \
    && yum -y groupinstall "Development Tools" \
    && yum -y install ncurses-devel openssl-devel readline-devel \
    && cd /usr/local/src/SoftEtherVPN-* \
    && ./configure \
    && make \
    && make install \
    && touch /usr/vpnserver/vpn_server.config \
    && zip -r9 /artifacts.zip /usr/vpn* /usr/bin/vpn*

FROM centos:8

COPY --from=build /artifacts.zip /

COPY copyables /

RUN yum -y update \
    && yum -y install unzip iptables \
    && rm -rf /var/log/* /var/cache/yum/* /var/lib/yum/* \
    && chmod +x /entrypoint.sh /gencert.sh \
    && unzip -o /artifacts.zip -d / \
    && rm /artifacts.zip \
    && rm -rf /opt \
    && ln -s /usr/vpnserver /opt \
    && find /usr/bin/vpn* -type f ! -name vpnserver \
       -exec sh -c 'ln -s {} /opt/$(basename {})' \;

WORKDIR /usr/vpnserver/

VOLUME ["/usr/vpnserver/server_log/", "/usr/vpnserver/packet_log/", "/usr/vpnserver/security_log/"]

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 500/udp 4500/udp 1701/tcp 1194/udp 5555/tcp 443/tcp

CMD ["/usr/bin/vpnserver", "execsvc"]
