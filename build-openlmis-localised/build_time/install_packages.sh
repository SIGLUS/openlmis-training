#!/usr/bin/env bash

#install prerequisite for cubes
apt-get update
apt-get -y install python-pip \
    python-virtualenv \
    python-dev \
    libpq-dev \
    postgresql-client \
    ruby

#install prerequisite for phantomjs
apt-get install build-essential chrpath libssl-dev libxft-dev -y \
    && apt-get install libfreetype6 libfreetype6-dev -y \
    && apt-get install libfontconfig1 libfontconfig1-dev -y

#install phantomjs
set -xeu \
    \
    && PHANTOM_VERSION="phantomjs-2.1.1" \
    && ARCH=$(uname -m) \
    && PHANTOM_JS="$PHANTOM_VERSION-linux-$ARCH" \
    && wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
    && tar xvjf $PHANTOM_JS.tar.bz2 \
    && mv $PHANTOM_JS /usr/local/share \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin \
    && rm -f $PHANTOM_JS.tar.bz2

#install flyway
mkdir -p /opt/flyway/
cd /opt/flyway/
wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.0.3/flyway-commandline-4.0.3-linux-x64.tar.gz
tar -xvzf flyway-commandline-4.0.3-linux-x64.tar.gz -C . --strip-components=1
rm flyway-commandline-4.0.3-linux-x64.tar.gz