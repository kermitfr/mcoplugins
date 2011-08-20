%define plugindir %{_libexecdir}/mcollective/mcollective
%define agent_name agentinfo 
%define gitrev 26323ed 

Name:      mcollective-plugins-agentinfo
Summary:   Mcollective plugin agent that lets you get information on agents 
Version:   1.0
Release:   3%{?dist}
License:   GPLv3
Group:     Development/Libraries
#Source0:   %{name}-%{version}.tar.gz 
Source0:   thinkfr-mcoplugins-%{gitrev}.tar.gz 
Requires:  mcollective >= 1.1.0
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch
Packager:  Louis Coilliot

%description
The agentinfo agent lets you get information on actions, inputs,
outputs of agents on your mcollective nodes.

%prep
%setup -n thinkfr-mcoplugins-%{gitrev} 

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{plugindir}
install -d -m 755 %{buildroot}%{plugindir}/agent
install %{agent_name}* %{buildroot}%{plugindir}/agent

%clean
rm -rf %{buildroot}

%files
%defattr(644,root,root,-)
%{plugindir}/agent/%{agent_name}.rb
%{plugindir}/agent/%{agent_name}.ddl

%changelog
* Sat Aug 20 2011 Louis Coilliot
- improvements to the ddl
* Fri Aug 12 2011 Louis Coilliot
- fix of file permissions, spec description and code comments
* Thu Aug 11 2011 Louis Coilliot
- inspired with a spec file from Dan Carley
(https://gist.github.com/957029)
- Initial build

