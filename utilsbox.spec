Name: utilsbox
Version: 0.1
Release: 1.1
Summary: Набор маленьких утилит для linux
License: MIT
URL: https://github.com/watermelon-os/utilsbox
Source0: https://github.com/watermelon-os/%{name}/archive/v%{version}.tar.gz

BuildRequires: gcc
BuildRequires: make
BuildRequires: bash


# BuildArch: x86_64 aarch64
BuildArch: x86_64

# полное описание пакета
%description 
utilsbox многофункциональная утилита, для доступа к каждой выделенной функции обращение через arg[0] или arg[1].
utilsbox ps - выводит снимок статусов процессов, как это делает ps(1)

%prep
%setup

%build
make release

%install
# %make_install = make install DESTDIR=%{buildroot}. prefix передаём явно,
# иначе Makefile по умолчанию поставит в /usr/local, а %files ждёт /usr.
%make_install prefix=%{_prefix}

%files
%{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*
%license %{_licensedir}/%{name}/LICENSE