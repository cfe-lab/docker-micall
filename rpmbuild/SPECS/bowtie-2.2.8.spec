Summary: bowtie2 version 2.2.8 RPM package for BCCCfe
Name: bowtie2
Version: 2.2.8
Release: 0
License: Artistic License
Group: Applications/Engineering
Source: https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.8/bowtie2-2.2.8-source.zip
BuildRoot: /var/tmp/%{name}-buildroot

%description
Bowtie, an ultrafast, memory-efficient short read aligner for short DNA sequences (reads) from next-gen sequencers.
Please cite: Langmead B, et al. Ultrafast and memory-efficient alignment of short DNA sequences to the human genome. Genome Biol 10:R25.
%prep
%setup


%build
# NOTE: make sure staic libraries are installed: yum install glibc-static libstdc++-static.x86_64
make all prefix=/usr/local/bowtie-2.2.8/ EXTRA_FLAGS=-static

%install
mkdir -p $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin

install  -m 755 bowtie2-inspect $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-inspect
install  -m 755 bowtie2-build   $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-build
install  -m 755 bowtie2         $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2

install  -s -m 755 bowtie2-inspect-l  $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-inspect-l
install  -s -m 755 bowtie2-inspect-s  $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-inspect-s

install  -s -m 755 bowtie2-build-l  $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-build-l
install  -s -m 755 bowtie2-build-s  $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-build-s

install  -s -m 755 bowtie2-align-l  $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-align-l
install  -s -m 755 bowtie2-align-s  $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/bin/bowtie2-align-s

mkdir -p $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/doc
install -m 644 doc/manual.html $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/doc/manual.html
install -m 644 doc/style.css   $RPM_BUILD_ROOT/usr/local/bowtie-2.2.8/doc/style.css


%post
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2           /usr/local/bin/bowtie2-2.2.8
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-align-l   /usr/local/bin/bowtie2-align-l-2.2.8
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-align-s   /usr/local/bin/bowtie2-align-s-2.2.8

ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-build     /usr/local/bin/bowtie2-build-2.2.8
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-build-l   /usr/local/bin/bowtie2-build-l-2.2.8
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-build-s   /usr/local/bin/bowtie2-build-s-2.2.8

ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-inspect   /usr/local/bin/bowtie2-inspect-2.2.8
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-inspect-l /usr/local/bin/bowtie2-inspect-l-2.2.8
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-inspect-s /usr/local/bin/bowtie2-inspect-s-2.2.8

ln -s /usr/local/bowtie-2.2.8/bin/bowtie2           /usr/local/bin/bowtie2
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-align-l   /usr/local/bin/bowtie2-align-l
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-align-s   /usr/local/bin/bowtie2-align-s

ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-build     /usr/local/bin/bowtie2-build
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-build-l   /usr/local/bin/bowtie2-build-l
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-build-s   /usr/local/bin/bowtie2-build-s

ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-inspect   /usr/local/bin/bowtie2-inspect
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-inspect-l /usr/local/bin/bowtie2-inspect-l
ln -s /usr/local/bowtie-2.2.8/bin/bowtie2-inspect-s /usr/local/bin/bowtie2-inspect-s


%postun
rm -f /usr/local/bin/bowtie2-2.2.8
rm -f /usr/local/bin/bowtie2-align-l-2.2.8
rm -f /usr/local/bin/bowtie2-align-s-2.2.8

rm -f /usr/local/bin/bowtie2-build-2.2.8
rm -f /usr/local/bin/bowtie2-build-l-2.2.8
rm -f /usr/local/bin/bowtie2-build-s-2.2.8

rm -f /usr/local/bin/bowtie2-inspect-2.2.8
rm -f /usr/local/bin/bowtie2-inspect-l-2.2.8
rm -f /usr/local/bin/bowtie2-inspect-s-2.2.8

%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/local/bowtie-2.2.8/bin/bowtie2-inspect
/usr/local/bowtie-2.2.8/bin/bowtie2-build
/usr/local/bowtie-2.2.8/bin/bowtie2
/usr/local/bowtie-2.2.8/bin/bowtie2-build-s
/usr/local/bowtie-2.2.8/bin/bowtie2-build-l
/usr/local/bowtie-2.2.8/bin/bowtie2-align-s
/usr/local/bowtie-2.2.8/bin/bowtie2-align-l
/usr/local/bowtie-2.2.8/bin/bowtie2-inspect-s
/usr/local/bowtie-2.2.8/bin/bowtie2-inspect-l
/usr/local/bowtie-2.2.8/doc/manual.html
/usr/local/bowtie-2.2.8/doc/style.css
/usr/local/bowtie-2.2.8/bin
/usr/local/bowtie-2.2.8/doc
/usr/local/bowtie-2.2.8

%changelog
* Tue Feb 28 2017 Walter Scott <wscott@bcfenet.ubc.ca> - 1.0.1
- add extra slinks needed by Kive
* Tue Feb 14 2017 Walter Scott <wscott@bcfenet.ubc.ca> - 1.0.0
- first version: compile statically and install in own directory
