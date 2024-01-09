FROM ubuntu:20.04 AS dependency-base

RUN \
    rm /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
    ca-certificates \
    tzdata \
    procps \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

RUN apt-get update && \
    apt-get install -y logrotate tini gettext libintl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /logs && \
    mkdir -p /etc/logrotate.d

FROM dependency-base AS builder

ENV CRON_SCHEDULE='0 * * * *' \
    LOGROTATE_SIZE='100M' \
    LOGROTATE_MODE='copytruncate' \
    LOGROTATE_PATTERN='/logs/*.log' \
    LOGROTATE_ROTATE='0'


COPY logrotate.tpl.conf /logrotate.tpl.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/crond", "-f", "-L", "/dev/stdout"]
