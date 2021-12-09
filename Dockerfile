FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive

ADD https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks /winetricks
RUN chmod +x /winetricks
RUN dpkg --add-architecture i386

RUN apt update \
    && apt install -y --no-install-recommends locales \
    && sed -i '/^#.*\s*en_US.UTF-8\sUTF-8/s/^#//' /etc/locale.gen \
    && sed -i '/^#.*\s*ru_RU.UTF-8\sUTF-8/s/^#//' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

RUN apt install -y --no-install-recommends curl gnupg winbind xvfb xauth x11vnc fluxbox procps cabextract xautomation xdotool ca-certificates

RUN echo "deb http://dl.winehq.org/wine-builds/debian/ buster main" >> /etc/apt/sources.list \
    && curl -fsSL  https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && apt update \
    && apt install -y --no-install-recommends winehq-staging=6.23~buster-1

RUN apt clean -y && apt autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY start.sh /root
RUN chmod +x /root/start.sh

CMD ["/root/start.sh"]
