%{!?package_release: %global package_release 1}

Name: watermelon-ps
# rpmbuld --define "package_version 1.2.3"
Version: %{package_version}
Release: %{package_release}

# краткое описание пакета
Summary: watermelon-ps, вывод снимка статуса процессов
License: MIT

URL: https://github.com/dsaime/linux-tools-edu/tree/master/tools/%{name}
# Source: https://github.com/dsaime/linux-tools-edu/%{name}/releases/download/%{version}/%{name}-%{version}.tar.gz
Source: %{name}-%{version}.tar.gz

# BuildRequires: gcc
BuildRequires: make
BuildRequires: bash


# BuildArch: x86_64 aarch64
BuildArch: x86_64

# полное описание пакета
%description 
watermelon-ps это утилита для вывода снимка статуса процессов, как это делает ps(1)

%prep
%setup

%build
# tar.gz уже с подготовленным bin

%install
# %make_install = make install DESTDIR=%{buildroot}. prefix передаём явно,
# иначе Makefile по умолчанию поставит в /usr/local, а %files ждёт /usr.
%make_install prefix=%{_prefix}

%files
%{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*
%license %{_licensedir}/%{name}/LICENSE