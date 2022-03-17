ARG BASE_VERSION=unknow
FROM linuxserver/bookstack:${BASE_VERSION}

# Make directory for storage of font
RUN mkdir -p /usr/share/fonts/chinese/TrueType
COPY fonts/simsun.ttc /usr/share/fonts/chinese/TrueType/

