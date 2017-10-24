Summary: samtools version 1.3.1 RPM package for BCCCfe
Name: samtools
Version: 1.3.1
Release: 0
License: Artistic License
Group: Applications/Engineering
Source: https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
BuildRoot: /var/tmp/%{name}-buildroot

%description
Samtools is a suite of programs for interacting with high-throughput sequencing data.
This RPM only includes the samtools part of the repo, the BCFtools are in a separate
RPM.
%prep
%setup


%build
./configure --prefix=$RPM_BUILD_ROOT/usr/local/samtools-1.3.1 --enable-plugins --enable-libcurl --with-plugin-path=$PWD/htslib-1.3.1
make all plugins-htslib


%install
mkdir -p $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin

install  -m 755 samtools          $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin/samtools
install  -m 755 misc/ace2sam      $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin/ace2sam
install  -m 755 misc/maq2sam-long $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin/maq2sam-long
install  -m 755 misc/md5fa        $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin/md5fa
install  -m 755 misc/md5sum-lite  $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin/md5sum-lite
install  -m 755 misc/wgsim        $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/bin/wgsim

mkdir -p $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/man
install -m 444 samtools.1    $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/man
install -m 444 misc/wgsim.1  $RPM_BUILD_ROOT/usr/local/samtools-1.3.1/man



%post
ln -s /usr/local/samtools-1.3.1/bin/samtools /usr/local/bin/samtools
ln -s /usr/local/samtools-1.3.1/bin/ace2sam /usr/local/bin/ace2sam
ln -s /usr/local/samtools-1.3.1/bin/maq2sam-long /usr/local/bin/maq2sam-long
ln -s /usr/local/samtools-1.3.1/bin/md5fa /usr/local/bin/md5fa
ln -s /usr/local/samtools-1.3.1/bin/md5sum-lite /usr/local/bin/md5sum-lite
ln -s /usr/local/samtools-1.3.1/bin/wgsim /usr/local/bin/wgsim

ln -s /usr/local/samtools-1.3.1/man/samtools.1 /usr/local/share/man/man1/samtools.1
ln -s /usr/local/samtools-1.3.1/man/wgsim.1 /usr/local/share/man/man1/wgsim.1

%postun
rm -f /usr/local/bin/samtools
rm -f /usr/local/bin/ace2sam
rm -f /usr/local/bin/maq2sam-long
rm -f /usr/local/bin/md5fa
rm -f /usr/local/bin/md5sum-lite
rm -f /usr/local/bin/wgsim

rm -f /usr/local/share/man/man1/wgsim.1
rm -f /usr/local/share/man/man1/samtools.1


%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/local/samtools-1.3.1/bin/samtools
/usr/local/samtools-1.3.1/bin/ace2sam
/usr/local/samtools-1.3.1/bin/maq2sam-long
/usr/local/samtools-1.3.1/bin/md5fa
/usr/local/samtools-1.3.1/bin/md5sum-lite
/usr/local/samtools-1.3.1/bin/wgsim
/usr/local/samtools-1.3.1/bin
/usr/local/samtools-1.3.1/man
/usr/local/samtools-1.3.1/man/samtools.1
/usr/local/samtools-1.3.1/man/wgsim.1
/usr/local/samtools-1.3.1


%changelog
* Tue Feb 14 2017 Walter Scott <wscott@bcfenet.ubc.ca> - 1.0.0
- first version: configure and compile, then install in own directory
