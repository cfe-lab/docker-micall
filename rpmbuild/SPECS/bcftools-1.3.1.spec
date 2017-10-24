Summary: bcftools version 1.3.1 RPM package for BCCCfe
Name: bcftools
Version: 1.3.1
Release: 0
License: Artistic License
Group: Applications/Engineering
Source: https://github.com/samtools/bcftools/releases/download/1.3.1/bcftools-1.3.1.tar.bz2
BuildRoot: /var/tmp/%{name}-buildroot

%description
Samtools is a suite of programs for interacting with high-throughput sequencing data.
This RPM only includes the bcftools part of the repo, the samtools are in a separate
RPM.
%prep
%setup


%build
make
#prefix=$RPM_BUILD_ROOT/usr/local/bcftools-1.3.1 


%install
mkdir -p $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/bin
install  -m 755 bcftools          $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/bin/bcftools

mkdir -p $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins
install  -m 755 plugins/color-chrs.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/color-chrs.so
install  -m 755 plugins/counts.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/counts.so
install  -m 755 plugins/dosage.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/dosage.so
install  -m 755 plugins/fill-AN-AC.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/fill-AN-AC.so
install  -m 755 plugins/fill-tags.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/fill-tags.so
install  -m 755 plugins/fixploidy.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/fixploidy.so
install  -m 755 plugins/frameshifts.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/frameshifts.so
install  -m 755 plugins/GTisec.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/GTisec.so
install  -m 755 plugins/impute-info.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/impute-info.so
install  -m 755 plugins/mendelian.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/mendelian.so
install  -m 755 plugins/missing2ref.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/missing2ref.so
install  -m 755 plugins/setGT.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/setGT.so
install  -m 755 plugins/tag2tag.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/tag2tag.so
install  -m 755 plugins/vcf2sex.so  $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/plugins/vcf2sex.so


mkdir -p $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/man
install -m 444 doc/bcftools.1    $RPM_BUILD_ROOT/usr/local/bcftools-1.3.1/man




%post
ln -s /usr/local/bcftools-1.3.1/bin/bcftools /usr/local/bin/bcftools

ln -s /usr/local/bcftools-1.3.1/plugins      /usr/local/libexec/bcftools

ln -s /usr/local/bcftools-1.3.1/man/bcftools.1 /usr/local/share/man/man1/bcftools.1

%postun
rm -f /usr/local/bin/bcftools

rm -f /usr/local/share/man/man1/bcftools.1


%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/local/bcftools-1.3.1/bin
/usr/local/bcftools-1.3.1/bin/bcftools
/usr/local/bcftools-1.3.1/man
/usr/local/bcftools-1.3.1/man/bcftools.1
/usr/local/bcftools-1.3.1/plugins
/usr/local/bcftools-1.3.1/plugins/color-chrs.so
/usr/local/bcftools-1.3.1/plugins/counts.so
/usr/local/bcftools-1.3.1/plugins/dosage.so
/usr/local/bcftools-1.3.1/plugins/fill-AN-AC.so
/usr/local/bcftools-1.3.1/plugins/fill-tags.so
/usr/local/bcftools-1.3.1/plugins/fixploidy.so
/usr/local/bcftools-1.3.1/plugins/frameshifts.so
/usr/local/bcftools-1.3.1/plugins/GTisec.so
/usr/local/bcftools-1.3.1/plugins/impute-info.so
/usr/local/bcftools-1.3.1/plugins/mendelian.so
/usr/local/bcftools-1.3.1/plugins/missing2ref.so
/usr/local/bcftools-1.3.1/plugins/setGT.so
/usr/local/bcftools-1.3.1/plugins/tag2tag.so
/usr/local/bcftools-1.3.1/plugins/vcf2sex.so

/usr/local/bcftools-1.3.1


%changelog
* Tue Feb 14 2017 Walter Scott <wscott@bcfenet.ubc.ca> - 1.0.0
- first version: configure and compile, then install in own directory
