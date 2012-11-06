%define plugindir %{_libexecdir}/mcollective/mcollective
%define agents agentinfo check curb jboss7 jboss libvirtvnc nodeinfo oracledb ovirt postgresql puppetagent sysinventory system

Name: kermit-mcollective-plugins
Summary: Collection of Mcollective plugins for KermIT 
Version: 1.1
Release: 1%{?dist}
License: GPLv3
Group: Development/Libraries
Source0: kermit-mcollective-plugins-%{version}.tar.gz 
Requires: mcollective >= 2.0.0
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch
Packager: Marco Mornati <ilmorna@gmail.com>

%description
%{summary}.

%package all
Summary: Skeleton package that pulls in all KermIT Mcollective plugins
Group: Development/Libraries
Requires: mcollective
Requires: kermit-mcollective-plugins-agentinfo = %{version}
Requires: kermit-mcollective-plugins-check = %{version}
Requires: kermit-mcollective-plugins-curb = %{version}
Requires: kermit-mcollective-plugins-jboss7 = %{version}
Requires: kermit-mcollective-plugins-jboss = %{version}
Requires: kermit-mcollective-plugins-libvirtvnc = %{version}
Requires: kermit-mcollective-plugins-nodeinfo = %{version}
Requires: kermit-mcollective-plugins-oracledb = %{version}
Requires: kermit-mcollective-plugins-ovirt = %{version}
Requires: kermit-mcollective-plugins-postgresql = %{version}
Requires: kermit-mcollective-plugins-puppetagent = %{version}
Requires: kermit-mcollective-plugins-sysinventory = %{version}
Requires: kermit-mcollective-plugins-system = %{version}
Requires: kermit-mcollective-plugins-config = %{version}

%description all
%{summary}.

%package agentinfo
Summary         : Retrieve agents information
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description agentinfo
%{summary}.

%package check
Summary         : Various Check on MCollective/Puppet environment
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description check
%{summary}.

%package curb
Summary         : Download URL file using Curb/Curl
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description curb
%{summary}.

%package jboss7
Summary         : JBoss Application Server 7 Management
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description jboss7
%{summary}.

%package jboss
Summary         : JBoss Application Server (<= 6) Management
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description jboss
%{summary}.

%package libvirtvnc
Summary         : VNC Console for Libvirt Virtual Machines
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}
Requires        : websockify >= 0.2
Requires        : numpy

%description libvirtvnc
%{summary}.

%package nodeinfo
Summary         : General information on MCollective node
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description nodeinfo
%{summary}.

%package oracledb
Summary         : Control Oracle Database
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description oracledb
%{summary}.

%package ovirt
Summary         : Create and manage oVirt Virtual Machines
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description ovirt
%{summary}.

%package postgresql
Summary         : PostgreSQL Database Management
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description postgresql
%{summary}.

%package puppetagent
Summary         : Methods to Control and retrieve information from PuppetMaster server
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description puppetagent
%{summary}.

%package sysinventory
Summary         : Get inventory information from the OS
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description sysinventory
%{summary}.

%package system
Summary         : Operating System Basic Operations
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0
Requires        : kermit-mcollective-plugins-config = %{version}

%description system
%{summary}.

%package config
Summary         : Configuration for Kermit Mcollective Plusins
Group           : Development/Libraries
Requires        : mcollective >= 2.0.0

%description config
%{summary}.

%prep
%setup -n kermit-mcollective-plugins

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{plugindir}
install -d -m 755 %{buildroot}%{plugindir}/agent
install -d -m 755 %{buildroot}%{plugindir}/application
install -d -m 755 %{buildroot}/etc/kermit

#Install all defined Agents
for agent_name in %{agents}; do
    install ${agent_name}/*.* %{buildroot}%{plugindir}/agent
    #if [ -f agent/${agent_name}/application/*.* ]; then
    #    install agent/${agent_name}/application/*.* %{buildroot}%{plugindir}/application
    #fi
done

#Install Configuration Files
install misc/kermit.cfg %{buildroot}/etc/kermit

%clean
rm -rf %{buildroot}

%files config
%defattr(-,root,root)
/etc/kermit/kermit.cfg

%files agentinfo
%defattr(-,root,root)
%{plugindir}/agent/agentinfo.rb
%{plugindir}/agent/agentinfo.ddl

%files check
%defattr(-,root,root)
%{plugindir}/agent/check.rb
%{plugindir}/agent/check.ddl

%files curb
%defattr(-,root,root)
%{plugindir}/agent/curb.rb
%{plugindir}/agent/curb.ddl

%files jboss7
%defattr(-,root,root)
%{plugindir}/agent/jboss7.rb
%{plugindir}/agent/jboss7.ddl

%files jboss
%defattr(-,root,root)
%{plugindir}/agent/jboss.rb
%{plugindir}/agent/jboss.ddl

%files libvirtvnc
%defattr(-,root,root)
%{plugindir}/agent/libvirtvnc.rb
%{plugindir}/agent/libvirtvnc.ddl

%files nodeinfo
%defattr(-,root,root)
%{plugindir}/agent/nodeinfo.rb
%{plugindir}/agent/nodeinfo.ddl

%files oracledb
%defattr(-,root,root)
%{plugindir}/agent/oracledb.rb
%{plugindir}/agent/oracledb.ddl

%files ovirt
%defattr(-,root,root)
%{plugindir}/agent/ovirt.rb
%{plugindir}/agent/ovirt.ddl

%files postgresql
%defattr(-,root,root)
%{plugindir}/agent/postgresql.rb
%{plugindir}/agent/postgresql.ddl

%files puppetagent
%defattr(-,root,root)
%{plugindir}/agent/puppetagent.rb
%{plugindir}/agent/puppetagent.ddl

%files sysinventory
%defattr(-,root,root)
%{plugindir}/agent/sysinventory.rb
%{plugindir}/agent/sysinventory.ddl

%files system
%defattr(-,root,root)
%{plugindir}/agent/system.rb
%{plugindir}/agent/system.ddl

%changelog
* Mon Nov 05 2012 Marco Mornati
- Created single Spec to build all rpms
* Wed Aug 31 2011 Louis Coilliot
- facts chomped
* Sun Aug 28 2011 Louis Coilliot
- system information compatible with AIX 
* Sat Aug 20 2011 Louis Coilliot
- improvements to the ddl
* Fri Aug 12 2011 Louis Coilliot
- inspired with a spec file from Dan Carley
(https://gist.github.com/957029)
- Initial build

