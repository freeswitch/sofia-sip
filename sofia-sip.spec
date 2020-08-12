Name:           sofia-sip
Version:        1.13.0
Release:        1%{?dist}
Summary:        Sofia SIP User-Agent library

License:        LGPLv2+
URL:            https://github.com/freeswitch/sofia-sip
Source0:        https://files.freeswitch.org/downloads/libs/%{name}-%{version}.tar.gz

BuildRequires:  gcc-c++
BuildRequires:  openssl-devel >= 0.9.7
BuildRequires:  lksctp-tools-devel

%description
Sofia SIP is a RFC-3261-compliant library for SIP user agents and
other network elements.  The Session Initiation Protocol (SIP) is an
application-layer control (signaling) protocol for creating,
modifying, and terminating sessions with one or more
participants. These sessions include Internet telephone calls,
multimedia distribution, and multimedia conferences.

%package devel
Summary:        Sofia-SIP Development Package
Requires:       sofia-sip = %{version}-%{release}
Requires:       pkgconfig

%description devel
Development package for Sofia SIP UA library.

%package utils
Summary:        Sofia-SIP Command Line Utilities
Requires:       sofia-sip = %{version}-%{release}

%description utils
Command line utilities for the Sofia SIP UA library.

%prep
%setup0 -q -n sofia-sip-%{version}%{?work:work%{work}}


%build
./autogen.sh
%configure --disable-rpath --disable-static --with-glib=no --without-doxygen --disable-stun
make %{?_smp_mflags}
#make doxygen

%check
#TPORT_DEBUG=9 TPORT_TEST_HOST=0.0.0.0 make check

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}
find %{buildroot} -name \*.la -delete
find %{buildroot} -name \*.h.in -delete
find . -name installdox -delete

%files
%doc AUTHORS ChangeLog ChangeLog.ext-trees COPYING COPYRIGHTS
%doc README README.developers RELEASE TODO 
%{_libdir}/libsofia-sip-ua.so.*

%files devel
#%doc libsofia-sip-ua/docs/html
%dir %{_includedir}/sofia-sip-1.13
%dir %{_includedir}/sofia-sip-1.13/sofia-sip
%{_includedir}/sofia-sip-1.13/sofia-sip/*.h
%dir %{_includedir}/sofia-sip-1.13/sofia-resolv
%{_includedir}/sofia-sip-1.13/sofia-resolv/*.h
%{_libdir}/libsofia-sip-ua.so
%{_libdir}/pkgconfig/sofia-sip-ua.pc
%{_datadir}/sofia-sip

%files utils
%{_bindir}/*
#%{_mandir}/man1/*.1*

%changelog
* Tue Jul 28 2020 FreeSWITCH Project <andrey@freeswitch.com> - 1.13.1-1
- Initial release for the FreeSWITCH Project
