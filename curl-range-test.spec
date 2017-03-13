Name:	        curl-range-test	
Version:	0.1
Release:	1%{?dist}
Summary:	script to test "curl --range"

Group:		Unspecified
License:	GPL
URL:		https://bitbucket.org/cunctat0r/curl-range-test
Source0:	curl-range-test-%{version}.tar.gz
BuildArch: noarch


Requires:	bash
Requires:	curl

%description
Bash script to test "curl --range"

%prep
%setup -q


%build


%install
mkdir -p ${RPM_BUILD_ROOT}/opt/curl-range-test
install -m 755 test.sh ${RPM_BUILD_ROOT}/opt/curl-range-test/test.sh
install -m 444 testplan.txt ${RPM_BUILD_ROOT}/opt/curl-range-test/testplan.txt


%clean
rm -rf ${RPM_BUILD_ROOT}

%files
%defattr(-,root,root)
%attr(755,root,root) /opt/curl-range-test/test.sh
%attr(444,root,root) /opt/curl-range-test/testplan.txt

%doc



%changelog

