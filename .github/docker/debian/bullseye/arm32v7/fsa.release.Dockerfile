ARG BUILDER_IMAGE=arm32v7/debian:bullseye-20240513

FROM --platform=linux/arm/v7 ${BUILDER_IMAGE} AS builder

ARG MAINTAINER_NAME="Andrey Volk"
ARG MAINTAINER_EMAIL="andrey@signalwire.com"

ARG CODENAME=bullseye
ARG ARCH=arm32

ARG BUILD_NUMBER=42
ARG GIT_SHA=0000000000

ARG DATA_DIR=/data

LABEL maintainer="${MAINTAINER_NAME} <${MAINTAINER_EMAIL}>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update \
    && apt-get -y -q install \
        apt-transport-https \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        debhelper \
        devscripts \
        dh-autoreconf \
        dos2unix \
        doxygen \
        dpkg-dev \
        git \
        graphviz \
        libglib2.0-dev \
        libssl-dev \
        lsb-release \
        pkg-config \
        wget

RUN update-ca-certificates --fresh

RUN echo "export CODENAME=${CODENAME}" | tee ~/.env \
    && echo "export ARCH=${ARCH}" | tee -a ~/.env \
    && chmod +x ~/.env

RUN git config --global --add safe.directory '*' \
    && git config --global user.name "${MAINTAINER_NAME}" \
    && git config --global user.email "${MAINTAINER_EMAIL}"

# Bootstrap and Build
COPY . ${DATA_DIR}
WORKDIR ${DATA_DIR}

RUN echo "export VERSION=$(dpkg-parsechangelog --show-field Version | cut -f1 -d'-')" \
    | tee -a ~/.env

RUN apt-get -q update \
    && mk-build-deps \
        --install \
        --remove debian/control \
        --tool "apt-get -y --no-install-recommends" \
    && apt-get -y -f install

ENV DEB_BUILD_OPTIONS="parallel=1"

RUN . ~/.env \
    && dch \
        --controlmaint \
        --distribution "${CODENAME}" \
        --force-bad-version \
        --force-distribution \
        --newversion "${VERSION}-${BUILD_NUMBER}-${GIT_SHA}~${CODENAME}" \
    "Nightly build, ${GIT_SHA}" \
    && debuild \
        --no-tgz-check \
        --build=binary \
        --unsigned-source \
        --unsigned-changes \
    && mkdir OUT \
    && mv -v ../*.{deb,changes} OUT/.

# Artifacts image (mandatory part, the resulting image must have a single filesystem layer)
FROM scratch
COPY --from=builder /data/OUT/ /
