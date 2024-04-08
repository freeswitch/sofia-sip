ARG BUILDER_IMAGE=centos:7.2.1511

FROM ${BUILDER_IMAGE} AS builder

ARG MAINTAINER="Andrey Volk <andrey@signalwire.com>"
ARG BUILD_NUMBER=42
ARG GIT_SHA=0000000000

MAINTAINER ${MAINTAINER}
ENV MAINTAINER=${MAINTAINER}

RUN yum -y update && \
	yum install -y \
		audiofile-devel \
		autoconf \
		automake \
		bind-license \
		centos-release-scl \
		cyrus-sasl-lib \
		dbus \
		dbus-libs \
		devtoolset-9-gcc* \
		dos2unix \
		doxygen \
		dpkg-dev \
		dracut \
		epel-release \
		expat \
		gcc \
		gcc-c++ \
		git \
		glib2 \
		glib2-devel \
		gnupg2 \
		gzip \
		krb5-dxevel \
		libatomic \
		libcurl-devel \
		libtool \
		libuuid-devel \
		libxml2 \
		lksctp-tools-devel \
		lsb_release \
		make \
		multilib-rpm-config \
		openssl-devel \
		pkg-config \
		procps-ng \
		python \
		python-libs \
		rpm-build \
		rpmdevtools \
		scl-utils \
		sqlite \
		swig \
		unzip \
		uuid-devel \
		vim-minimal \
		wget \
		which \
		xz \
		xz-libs \
		yum-plugin-fastestmirror \
		yum-plugin-ovl \
		yum-utils \
		zlib-devel && \
	yum -y clean all

ENV DATA_DIR=/data
WORKDIR ${DATA_DIR}

COPY . ${DATA_DIR}/src/
RUN cd ${DATA_DIR}/src/ && \
	git reset --hard HEAD && git clean -xfd && \
	cd ${DATA_DIR}

ARG SPEC_FILE=sofia-sip

# Bootstrap and Build
RUN cat <<EOF > ~/.rpmmacros
%packager ${MAINTAINER}
%_topdir ${DATA_DIR}/rpmbuild
EOF
RUN rpmdev-setuptree

RUN echo "export VERSION=$(rpm -q --qf '%{VERSION}\n' --specfile ${DATA_DIR}/src/${SPEC_FILE}.spec 2>/dev/null | head -1)" \
	| tee ~/.env && \
	chmod +x ~/.env

RUN . ~/.env && \
	mv -v ${DATA_DIR}/src/ ${DATA_DIR}/${SPEC_FILE}-${VERSION}/ && \
	tar cvzf ${DATA_DIR}/rpmbuild/SOURCES/${SPEC_FILE}-${VERSION}.tar.gz --exclude .git -C ${DATA_DIR} ${SPEC_FILE}-${VERSION}/ && \
	cp -v ${DATA_DIR}/${SPEC_FILE}-${VERSION}/${SPEC_FILE}.spec ${DATA_DIR}/rpmbuild/SPECS/ && \
	sed -i "s/\(Release:\)\([[:space:]]*\)1%{?dist}/\1\2${BUILD_NUMBER}.${GIT_SHA}/" ${DATA_DIR}/rpmbuild/SPECS/${SPEC_FILE}.spec

RUN rpmbuild -bs ${DATA_DIR}/rpmbuild/SPECS/${SPEC_FILE}.spec
RUN find ${DATA_DIR}/rpmbuild/SRPMS/ -type f | xargs -rI{} yum-builddep -y {}
RUN rpmbuild -ba ${DATA_DIR}/rpmbuild/SPECS/${SPEC_FILE}.spec

# Artifacts image (mandatory part, the resulting image must have a single filesystem layer)
FROM scratch
COPY --from=builder /data/rpmbuild/ /
