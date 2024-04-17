ARG BUILDER_IMAGE=arm64v8/debian:buster
ARG MAINTAINER="Andrey Volk <andrey@signalwire.com>"

FROM ${BUILDER_IMAGE} AS builder

ARG BUILD_NUMBER=42
ARG GIT_SHA=0000000000

MAINTAINER ${MAINTAINER}

SHELL ["/bin/bash", "-c"]

RUN apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        apt-transport-https \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        debhelper \
        devscripts \
        dh-autoreconf \
        dos2unix \
        doxygen \
        git \
        graphviz \
        libglib2.0-dev \
        libssl-dev \
        lsb-release \
        pkg-config \
        wget

RUN update-ca-certificates --fresh

ENV DATA_DIR=/data
WORKDIR ${DATA_DIR}

COPY . ${DATA_DIR}
RUN git reset --hard HEAD && git clean -xfd

RUN echo "export CODENAME=$(lsb_release -sc | tr -d '\n')" | tee ~/.env && \
    chmod +x ~/.env

RUN git config --global --add safe.directory '*'

# Bootstrap and Build
RUN echo "export VERSION=$(dpkg-parsechangelog --show-field Version | cut -f1 -d'-')" | tee -a ~/.env
RUN . ~/.env && dch \
    --controlmaint \
    --distribution "${CODENAME}" \
    --force-bad-version \
    --force-distribution \
    --newversion "${VERSION}-${BUILD_NUMBER}-${GIT_SHA}~${CODENAME}" \
    "Nightly build, ${GIT_SHA}"

RUN apt-get -q update && \
    mk-build-deps --install --remove debian/control --tool "apt-get -y --no-install-recommends" && \
    apt-get -y -f install

ENV DEB_BUILD_OPTIONS="parallel=1"
RUN . ~/.env && dch -b -M -v "${VERSION}-${BUILD_NUMBER}-${GIT_SHA}~${CODENAME}" \
  --force-distribution -D "${CODENAME}" "Nightly build, ${GIT_SHA}"
RUN debuild -b -us -uc && mkdir OUT && mv -v ../*.deb OUT/.

# Artifacts image (mandatory part, the resulting image must have a single filesystem layer)
FROM scratch
COPY --from=builder /data/OUT/ /
