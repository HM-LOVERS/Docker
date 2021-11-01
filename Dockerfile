FROM ubuntu:21.10

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq -y install software-properties-common \
    && add-apt-repository universe && add-apt-repository multiverse \
    && add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable \
    && apt-get -qq update && apt-get -qq -y upgrade \
    && apt-get -qq -y install --no-install-recommends \
        python3 python3-pip python3-lxml aria2 \
        qbittorrent-nox tzdata p7zip-full p7zip-rar xz-utils wget curl pv jq \
        ffmpeg locales unzip neofetch mediainfo git make g++ gcc automake \
        autoconf libtool libcurl4-openssl-dev qt5-default \
        libsodium-dev libssl-dev libcrypto++-dev libc-ares-dev \
        libsqlite3-dev libfreeimage-dev swig libboost-all-dev \
        libpthread-stubs0-dev zlib1g-dev \
    && apt-get -qq -y autoremove --purge \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    # MegaSDK
    && MEGA_SDK_VERSION='3.9.8' \
    && git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && autoupdate -fIv && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl

RUN add-apt-repository --remove universe && add-apt-repository --remove multiverse && add-apt-repository \
    && apt-get -qq -y purge --autoremove \
    && autoconf automake g++ gcc libtool make software-properties-common swig \
    && apt-get -qq -y clean && apt-get clean --dry-run \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /home/sdk

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-
