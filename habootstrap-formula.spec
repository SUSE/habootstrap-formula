#
# spec file for package habootstrap-formula
#
# Copyright (c) 2018 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


# See also http://en.opensuse.org/openSUSE:Specfile_guidelines
%define fname cluster
%define fdir  %{_datadir}/susemanager/formulas

Name:           habootstrap-formula
Version:        0.1.0
Group:          System/Packages
Release:        1
Summary:        HA cluster (crmsh) deployment salt formula

License:        Apache-2.0
Url:            https://github.com/SUSE/%{name}
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
Requires:       salt-saphana
Requires:       salt-minion >= 2018.3.0


%description
HA cluster (crmsh) deployment salt formula

# package to deploy on SUMA specific path.
%package suma
Summary:        HA cluster (crmsh) deployment salt formula (SUMA specific)
Requires:       salt-saphana

%description suma
HA Cluster Bootstrap Salt Formula for SUSE Manager. Used to configure a basic HA cluster.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}/srv/salt/
cp -R %{fname} %{buildroot}/srv/salt

# SUMA Specific
mkdir -p %{buildroot}%{fdir}/states/%{fname}
mkdir -p %{buildroot}%{fdir}/metadata/%{fname}
cp -R %{fname} %{buildroot}%{fdir}/states
cp -R form.yml %{buildroot}%{fdir}/metadata/%{fname}
if [ -f metadata.yml ]
then
  cp -R metadata.yml %{buildroot}%{fdir}/metadata/%{fname}
fi

%files
%defattr(-,root,root,-)
%license LICENSE
%doc README.md
/srv/salt/%{fname}

%dir %attr(0755, root, salt) /srv/salt


%files suma
%defattr(-,root,root,-)
%license LICENSE
%doc README.md
%dir %{_datadir}/susemanager
%dir %{fdir}
%dir %{fdir}/states
%dir %{fdir}/metadata
%{fdir}/states/%{fname}
%{fdir}/metadata/%{fname}

%dir %attr(0755, root, salt) %{_datadir}/susemanager
%dir %attr(0755, root, salt) %{fdir}
%dir %attr(0755, root, salt) %{fdir}/states
%dir %attr(0755, root, salt) %{fdir}/metadata

%changelog
