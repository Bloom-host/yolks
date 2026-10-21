#
# Copyright (c) 2021 Matthew Penner
# Copyright (c) 2021 Razboy20
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM        --platform=$TARGETOS/$TARGETARCH debian:trixie-slim

LABEL       author="Razboy20" maintainer="Razboy20@razboy.dev"

LABEL       org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

# Based on https://github.com/Razboy20/pterodactyl-caddy
# PHP comes from https://packages.sury.org/php, which ships security releases faster than Alpine
# The egg's start.sh uses #!/bin/ash, so /bin/ash points to bash
RUN         apt-get update && apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends ca-certificates curl \
	&& curl -fsSL -o /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
	&& dpkg -i /tmp/debsuryorg-archive-keyring.deb \
	&& rm /tmp/debsuryorg-archive-keyring.deb \
	&& echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ trixie main" > /etc/apt/sources.list.d/php.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends iproute2 lua5.1 tzdata \
	php8.3-apcu php8.3-bcmath php8.3-bz2 php8.3-cli php8.3-curl php8.3-fpm php8.3-gd \
	php8.3-gmp php8.3-imagick php8.3-intl php8.3-mbstring php8.3-mysql php8.3-odbc \
	php8.3-opcache php8.3-pgsql php8.3-soap php8.3-sqlite3 php8.3-sybase php8.3-xml php8.3-zip \
	&& rm -rf /var/lib/apt/lists/* \
	&& ln -s /bin/bash /bin/ash \
	&& useradd -m -d /home/container -s /bin/bash container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
