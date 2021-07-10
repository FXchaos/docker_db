ARG CENTOS_VERSION=8.3.2011
ARG MYSQL_VERSION=8.0.25

FROM centos:$CENTOS_VERSION

RUN set -x \
    && groupadd -f -r mysql \
    && useradd -r -g mysql mysql

RUN dnf -y install dnf-plugins-core
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf config-manager --set-enabled powertools
RUN dnf -y upgrade
RUN dnf -y install \
    bison \
    cmake \
    crypto-devel \
    cyrus-sasl-devel \
    cyrus-sasl-ldap \
    cyrus-sasl-lib \
    cyrus-sasl-md5 \
    cyrus-sasl-plain \
    cyrus-sasl-sql \
    gcc \
    gcc-c++ \
    git \
    libaio-devel \
    libtirpc-devel \
    m4 \
    make \
    ncurses-devel \
    openldap-devel \
    openssl-devel \
    rpcgen \
    wget

WORKDIR /tmp/build/boost

RUN wget -qO- "https://boostorg.jfrog.io/artifactory/main/release/1.73.0/source/boost_1_73_0.tar.gz" \
    | tar -xzv --strip-components=1

WORKDIR /tmp/build/mysql

ARG MYSQL_VERSION
RUN wget -qO- "https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-$MYSQL_VERSION.tar.gz" \
    | tar -xzv --strip-components=1 \
    && mkdir bld

WORKDIR ./bld

RUN cmake .. \
    -DBUILD_CONFIG=mysql_release \
    -DCMAKE_BUILD_TYPE=Release \
    -DCPACK_MONOLITHIC_INSTALL=1 \
    -DCMAKE_C_COMPILER=/usr/bin/gcc \
    -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    -DCMAKE_C_FLAGS_RELEASE="-O3 -g0" \
    -DCMAKE_CXX_FLAGS_RELEASE="-O3 -g0" \
    -DDOWNLOAD_BOOST=0 \
    -DWITH_BOOST=/tmp/build/boost \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install

CMD ["/usr/sbin/init"]
