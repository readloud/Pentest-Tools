#!/usr/bin/perl
$ENV{LC_ALL} = 'C'; $0='bash'; $ENV{'PATH'} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:'.$ENV{'PATH'}; $ttime1=time;
@mm=("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"); my($s,$m,$h,$dm,$mm,$y,$wd,$yd,$is)=localtime(time);
$n_date="$mm[$mm] ".sprintf("%2d %02d",$dm,$h); $n_date .= "\|$mm[$mm] ".sprintf("%2d %02d",$dm,$h-1) if ($m<5);

$_=`id`; if (~m/uid\=\d*?\((.*?)\)/) {$u=$1,push(@bad_str,$1)};
if ($ENV{SSH_CLIENT} =~ /.*?(\d*\.\d*\.\d*\.\d*) /) {$ip=$1;push(@bad_str,$1)}
if ($ENV{SSH_CONNECTION} =~ /.*?(\d*\.\d*\.\d*\.\d*) /) {$ip=$1;push(@bad_str,$1)}
if ($ENV{SSH2_CLIENT} =~ /.*?(\d*\.\d*\.\d*\.\d*) /) {$ip=$1;push(@bad_str,$1)}
if ($ENV{REMOTEHOST} =~ /(\d*\.\d*\.\d*\.\d*)/) {$ip=$1;push(@bad_str,$1)}
if (exists $ENV{USER} ) { $u=$ENV{USER}; push(@bad_str,$u)}
if (exists $ENV{LOGNAME} ) { $u=$ENV{LOGNAME}; push(@bad_str,$u)}
if (exists $ENV{SUDO_USER} ) { $u=$ENV{SUDO_USER}; push(@bad_str,$u)}
if ($ENV{TTY} =~ m|/dev/(.*)|) { $tty=$1 }; $stty="|grep $tty" if $tty;
print "ALERT we can't find IP in ENV\n" unless ($ip); print "ALERT we can't find user in ENV\n" unless $u;
$h=gethostbyaddr(pack("C4",split /\./,$ip),2); if ($h) { push(@bad_str,$h) } else { $h=$ip }

foreach (@bad_str) { $string.="$_|" unless $temp{$_}; $temp{$_}++ }
$string.="Failed password"; print "Bad strings is: '$string'\n";

#print "Parse all logs.\n"; #!
`mkdir -p /home/tmpq`; $tfile = '/home/tmpq/q3def';
@blist=`find  /var/log -type f -mtime -1 -size +100M -ls`; print @blist if @blist;
@logs=`cat /etc/syslog.conf|grep -vi \"#\"|grep -vi dev`;
foreach (@logs) {next unless -f $_; $logs{$1}++ if m|.*?(/.+)| and not m|/mail| }
foreach $file (keys %logs) {
    next if checktime($file); # print "Check $file\n";
    $system="cat $file|egrep -i \"$n_date\"|egrep -i \"$string\""; #print "$system\n";
    $test=`$system`; print "Found in $file. Try to correct\n" if $test; next unless $test;
    $system="cat $file|egrep -vi \"$n_date\">$tfile;cat $file|egrep \"$n_date\"|egrep -vi \"$string\"\>>$tfile;cat $tfile>$file;rm -f $tfile";
#    print "$system\n";	#!
    system($system) }

#print "\nSearch for bad str in /var/log\n";	#!
$nocheck = 'apache|munin|dcpumon|bandwidth|httpd|exim|maillog|/mail|nscd|btmp|mail\.|nginx|asterisk|iscsi|mysql|pmta|rsync|mirror|vsftpd|proftpd|php-fpm|php5-fpm|tomcat|squid|uwsgi|gammu|mrtg|chkservd|cron|rabbitmq|dovecot|quagga|access_log|roundcubemail|directadmin|redis|atop|pdns|kannel|glusterfs|/www/|powerdns|mongo|zimbra|access\.log';
$system="find  /var/log -type f -cmin -10 -print|egrep -v '$nocheck'|xargs egrep -i \"$ip\|$h\" /dev/null|grep -vi Binary";
$lpt1=time; @list=`$system`; $lpt2=time; if (($lpt2 - $lpt1) > 2*60) { printf "_prof_ search time: %d min\n",($lpt2 - $lpt1)/60 }
foreach $record (@list) { ($filename,undef)=split(/\:/,$record); $filelist{$filename}++ }
$i=0; foreach $file (keys %filelist) {
    $i++; print "ALERT Bugs found in $file\n";
    $system="cat $file|egrep -vi \"$ip\|$h\" >$tfile;cat $tfile>$file;rm -f $tfile"; print "$system\n";	#!
    system($system) } print "ALERT $i bugs found\n";

`rm -rf /home/tmpq`; $|=1;

$ttime2=time; if (($ttime2 - $ttime1) > 5*50) { printf "_prof_ total time: %d min\n",($ttime2 - $ttime1)/60 }


#############
my $fldpr = '/etc/ld.so.preload'; my @alert; my $al; my $alert;
if ( -e $fldpr) { @alert = `cat $fldpr`; chomp @alert; print "\n\tlALERT!!! $fldpr: ".join('_',@alert)."\n";
    $al = join('_',@alert); if ($al ne '/lib/libsafe.so.2') { $alert++ } }
eval { require 'syscall.ph'; my $b = " " x 10240; my $f = syscall(&SYS_open,$fldpr,0,0); die if $f == -1; my $s = syscall(&SYS_read,$f,$b,10240);
$b = substr($b,0,$s); if ($s == -1) { print "\n\tlALERT!!! HIDDEN $fldpr: open ok ($f), but read fail\n" }
elsif ($s == 0) { print "\n\tlALERT!!! HIDDEN $fldpr: open ok ($f), but read 0\n" }
elsif (!$al and $b) { $b =~ s|\n|_|g; print "\n\tlALERT!!! HIDDEN $fldpr: $b\n" } syscall(&SYS_close,$f);
if ($b =~ /\/lib\/libc\.so\.0/) { $fldpr = '/lib/libc.so.0'; my $c = " " x 1024000; $f = syscall(&SYS_open,$fldpr,0,0); die if $f == -1;
 $s = syscall(&SYS_read,$f,$c,1024000); $c = substr($c,0,$s); syscall(&SYS_close,$f); if ($c =~ /\0sshd: ([^\0]+)\0/) { print "\n\tALERT!!! preload_pass:'$1'\n" } }
};
if ( -e '/etc/ssh/sshrc') { @alert = `cat /etc/ssh/sshrc`; chomp @alert;  print "\n\tlALERT!!! /etc/ssh/sshrc: ".join('_',@alert)."\n"; $alert++; }
if ( -e '/root/.ssh/rc')  { @alert = `cat /root/.ssh/rc`; chomp @alert; print "\n\tlALERT!!! /root/.ssh/rc: ".join('_',@alert)."\n"; $alert++; }
if (exists $ENV{LD_PRELOAD})  { print "\n\tALERT!!! LD_PRELOAD: $ENV{LD_PRELOAD}\n"; $alert++ }
#print "\n\tlALERT!!! no /usr/sbin/atd\n" unless -e '/usr/sbin/atd';

$dssh = `ssh -G1 -V 2>&1 | egrep "illegal|unknown"`; if ($? && -e '/usr/bin/ssh') { print "\n\tlALERT!!! strange ssh version\n"; $alert++ }
my @sfc = `grep -i ForceCommand /etc/ssh/sshd_config |grep -v ^#`; print "!!! lALERT: ".join('',@sfc) if @sfc;
@alert = `lsattr /usr/sbin/sshd /usr/bin/ssh /lib/libke* /lib64/libke* 2>/dev/null`;
for (@alert) { my @a = split; $a[0] =~ s|[e\-]||g; next if $a[0] eq '';print "\n\tlALERT!!! lsattr:$_"; $alert++; }
if ( -l '/bin') { print "\n\tlALERT!!! /bin is link, seems like bsd jail\n"; }
if ( -e '/usr/lib/openssh/sshd') { print "\n\tlALERT!!! strange ssh location\n" }
if ( -e '/etc/cron.hourly/mcelog')  { print "\n\tlALERT!!! hacked reinstall script\n" }
if ( -e '/etc/cron.hourly/verify')  { print "\n\tlALERT!!! hack md5sum checked\n"; $alert++; }
if ( -e '/etc/cron.hourly/cron.sh')  { print "\n\tlALERT!!! china bot\n"; }
if ( -e '/proc/rs_dev')  { print "\n\tlALERT!!! china rootkit\n"; }
@alert = `ldconfig -N -X  2>&1`; chomp(@alert); if (@alert) { print "\n\tlALERT!!! ldconfig: ".join('|',@alert)."\n"; }
@alert = `grep -e libkey -e keyutil -e ebury -e libns -e /proc/udev -e "ldd " -e strace -e rootkit.sh .bash_history`; chomp(@alert);
if (@alert) { print "\n\tlALERT!!! libkeysubstr: ".join('|',@alert)."\n"; $alert++ }
@spu = `grep -i AuthorizedKeysFile /etc/ssh/sshd_config|grep -v ^#|grep -wv .ssh/authorized_keys`; chomp @spu;
if (@spu) { print "\n\tlALERT!!! AuthorizedKeysFile ssh: ".join('|',@spu)."\n"; $alert++}
@csf = `grep ssh /etc/csf/csf.tempint 2>/dev/null`; print "\n\tALERT!!! csf checksumm\n" if @csf;
@csf = `grep ssh /var/lib/csf/csf.tempint 2>/dev/null`; print "\n\tALERT!!! new_csf checksumm\n" if @csf;
@alert = `ls .bash_history.cpanel_ticket.* .cpkyle.* 2>/dev/null`; print "\n\tALERT!!! CPanel supported\n" if (@alert);
@alert = `grep -r md5 /etc/cron.* 2>/dev/null`; for (@alert) { print "\n\tlALERT!!! cron_md5: $_" }
if    ( -e '/etc/debian_version') { $fname='/etc/debian_version' }
elsif ( -e '/etc/redhat-release') { $fname='/etc/redhat-release' }
elsif ( -e '/etc/gentoo-release') { $fname='/etc/gentoo-release' }
elsif ( -e '/etc/slackware-version') { $fname='/etc/slackware-version' }
else  { $fname='' }

check_zbd(); check_suid(); #print "\n\tlALERT!!! hack1\n"  if -e '/usr/lib/libapt-inst-libc6.7-6.so.1.3.9';
if (-e '/etc/yum.conf') { my @q=`grep openssh /etc/yum.conf`; if (@q) {print "\n\tALERT!!! yum.conf: ".join("|",@q)."\n" } }
my $f='/etc/audit/audit.rules'; if (-r $f) { my $a;open($a,"<$f"); my @a=<$a>; close $a;chomp @a; my @aa;
for (@a) { next if $_ eq '' or /^#/ or $_ eq '-D' or /^\-b\s*\d+$/; push @aa,$_ }
if (@aa) { print "\n\tlALERT!!! audit: ".join('|',@aa)."\n"; $alert++ } }

@sd = `strings /usr/sbin/sshd |grep -e "^/usr/local/libexec"`;chomp @sd;if (@sd) { print "\n\tALERT!!! , ".join("|",@sd)."\n" }
my $ppid=getppid;my $pb=readlink("/proc/$ppid/exe"); if ($pb ne '/usr/sbin/sshd') { print "\n\tlALERT!!! parent:$pb, $ppid\n";$alert++ }

print '_#_#_ sysinfo:'."\n";
print '_#_#_ uname:';system('uname -a');
$dname = "\n"; $dname = `echo -n "$fname :";cat $fname` if -e $fname;
print '_#_#_ dname:'.$dname;
if ( -e '/etc/issue' ) { @issue = `cat /etc/issue`;chomp @issue }
print '_#_#_ issue:'.join('_',@issue)."\n";
@prg = `which make gcc patch yum apt-get bash 2>/dev/null`;
for (@prg) { chomp; if (m|.*/(.+)|) {$prg{$1} = $_ } }
$dssh = `ssh -V 2>&1` || "\n";
print '_#_#_ ssh:'.$dssh;
#print '_#_#_ perl:'.$prl || "\n";
print '_#_#_ pkg:'.$prg{'yum'}.$prg{'apt-get'}."\n" ;
print '_#_#_ gcc:'.$prg{'gcc'}."\n" ;
print '_#_#_ patch:'.$prg{'patch'}."\n" ;
print '_#_#_ bash:'.$prg{'bash'}."\n" ;
print '_#_#_ zlib-dev:'; -e '/usr/include/zlib.h' ? print "ok\n" : print "\n";
print '_#_#_ ssl-dev:';  -e '/usr/include/openssl/opensslv.h' ? print "ok\n" : print "\n";
print '_#_#_ pam-dev:';  -e '/usr/include/security/pam_client.h' ? print "ok\n" : print "\n";
print '_#_#_ krb-dev:';  -e '/usr/include/krb5.h' ? print "ok\n" : print "\n";
print '_#_#_ wrap-dev:'; -e '/usr/include/tcpd.h' ? print "ok\n" : print "\n";
@w=`w`; for (@w) { print '_#_#_ who:'.$_ }

my $lf='libkeyutils.so.1';for (qw{/lib /lib64 /lib/x86_64-linux-gnu /lib/i386-linux-gnu}) { -e "$_/$lf" && system("ls -l $_/$lf;ls -lL $_/$lf") }

$prl = `file -L \`which perl\``; $wgt = `file -L \`which wget\``;
if ($prl !~ /, stripped/) { print "\n\tALERT!!! perl:$prl" } if ($wgt !~ /, stripped/) { print "\n\tlALERT!!! wget:$wgt" }
my @binssh = `file /usr/bin/ssh /usr/sbin/sshd`; for (@binssh) { print "\n\tlALERT!!! ssh-bin:$_" unless /, stripped/ and /LSB  ?shared object/ }

my @pamlib; for ('/lib64/security/pam_unix.so','/lib/security/pam_unix.so') { push @pamlib,$_ if -e $_}
my @plo = `file @pamlib`; for (@plo) { print "\n\tlALERT!!! pam-bin:$_" unless /, stripped/ }
for (@pamlib) { local $/ = undef; open(IN,"<$_"); my $plo = <IN>; close IN; my @plo = ($plo =~ /([\x09\x20-\x7e]{4,})/g);
my @pls = pgrep(\@plo,'-UN\*X-PASS','-A 2'); next if $pls[1] =~ /^auth could not identify/ or $pls[1] eq 'Password: ' or $pls[1] eq '';
if ($pls[1] !~ m|^/|) { print "\nmod_ssh_pam1: '$pls[1]' $_\n" } else {
  print "\nmod_ssh_pam2: $_: '$pls[4]' pass:'$pls[3]'; file:'$pls[1]'\n";system("ls -l $pls[1] ;cat $pls[1]") if -e $pls[1] } }

print "\n\n"; system('id;df -h;wc -l .ssh/known_hosts');
$prf = '/etc/profile ~/.bash_profile ~/.bash_login ~/.profile /etc/bash.bashrc /etc/bashrc ~/.bashrc /etc/profile.d/* 2>/dev/null ';
$prfg =  ' |fgrep -v -e /complete. -e profile.d/profile -e /bindkey. -e /limits. -e /locallib. -e /lang. -e ":# " -e LESS ';
$prfg .= ' -e "MAIL=" -e mc-wrapper -e SSH_ASKPASS -e lesspipe -e "/etc/profile.d/*.sh" ';
system('fgrep -e trap -e mail -e who -e exec -e logger -e php -e perl -e ssbutil -e \.sh -e script '.$prf.$prfg);
system('grep -i hist '.$prf.' |grep -v -e ":#" -e HISTCONTROL -e histappend -e /complete. -e /bindkey.');
system('grep @ /etc/syslog.conf /etc/rsyslog.conf 2>/dev/null');
system('grep destination /etc/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf 2>/dev/null |grep -e tcp -e udp');

print "bin_md5_sum: \n";my $md5d;my $md5c; #system('md5sum /usr/sbin/sshd /usr/bin/ssh');
sub md5_file { my $f = shift; my $fp; open($fp,"<$f") or die "Can't open '$f': $!";
binmode($fp); my $md5 = Digest::MD5->new->addfile($fp)->hexdigest; close $fp; return $md5 }
eval { require Digest::MD5; $md5d = md5_file('/usr/sbin/sshd'); $md5c = md5_file('/usr/bin/ssh');
print "$md5d  /usr/sbin/sshd\n$md5c  /usr/bin/ssh\n"}; if ($@) { system('md5sum /usr/sbin/sshd /usr/bin/ssh') }

my @rpl = `rpm -qV openssh-server openssh-clients openssh pam 2>/dev/null |fgrep -v -e ' c ' -e '  d ' -e '.......T';rpm -qv openssh-server openssh-clients openssh openssh-askpass fipscheck keyutils-libs`;
if (@rpl) { print "\nRPM check:\n".join('',@rpl)."\n" }
print "\nDEB check: "; my $debsc='/var/lib/dpkg/info'; if ( -e "$debsc/openssh-server.md5sums" ) {
  @rpl = `cd /;md5sum -c $debsc/openssh-server.md5sums $debsc/openssh-client.md5sums $debsc/libpam-modules*.md5sums 2>&1 |grep -v ': OK\$'`;
if (@rpl) { print "\n".join('',@rpl)."\n" } else { print "ok\n" } } else { print "no deb sums found\n" }
print '_#_#_ ifconfig:'."\n";my @if = `ifconfig 2>/dev/null |grep inet`; for (@if) { s| Bcast:.*||; s| netmask .*|| }
print join('',@if)."_#_#_ ifconfig_end\n";

my %pw = ('/usr/include/gpm2.h' => 0, '/lib/initr' => 0,'/usr/include/symc.h' => 0,'/usr/include/pwd2.h' => 0,'/var/lib/nfs/gpm2.h' => 0,
'/usr/share/sshd.sync' => 0, '/rescue/mount_fs' => 0, '/usr/lib/libiconv.so.0' => 0, '/usr/share/man/mann/options' => 0,
'/etc/ssh/.sshd_auth' => 0, '/usr/lib/.sshd.h' => 0, '/usr/include/kix.h' => 0, '/usr/include/pthread2x.h' => 0, '/tmp/.lost+found' => 0,
'/usr/lib/jlib.h' => 0, '/usr/include/zaux.h' => 0, '/usr/local/include/uconf.h' => 0, '/usr/include/netda.h' => 0,
'/usr/include/zconf2.h' => 0, '/usr/lib/libm.c' => 0, '/etc/gpufd' => 0, '/usr/include/syslog2.h' => 0, '/var/run/.options' => 0,
'/usr/include/lwpin.h' => 0, '/usr/lib/libsplug.2.so' => 0, '/dev/devno' => 0, '/usr/include/ncurse.h' => 0, '/usr/include/linux/byteorder/ssh.h' => 0,
'/usr/include/client.h' => 0, '/usr/include/linux/byteorder/ssh.h' => 0, '/var/log//.login' => 0, '/usr/ofed/bin/bin' => 0, '/usr/ofed/bin/ssh' => 0,
'/usr/lib/libsplug.4.so' => 0, '/usr/share/core.h' => 0, '/usr/games/.blane' => 0, '/tmp/.ICE-unix/error.log' => 0, '/usr/lib/.sshd.h' => 0,
'/usr/include/filearch.h' => 0, '/usr/include/usr.h' => 0, '/var/html/lol' => 0, '/etc/listpr' => 0, '/usr/share/boot.sync' => 0,
'/usr/include/true.h' => 0, '/var/run/npss.state' => 0, '/var/run/.ssh.pid' => 0, '/usr/lib/libQtNetwork.so.4.0.1' => 0,
'/usr/lib/libgssapi_krb5.so.9.9' => 0, '/etc/security/pam_env' => 0, '/usr/lib/rpm/rpm.cx' => 0,
# binary
'/usr/include/boot.h' => 0, '/usr/include/linux/arp.h' => 0, '/usr/include/libssh.h' => 0, '/usr/include/linux/boot.h' => 0,
'/usr/games/.lost+found' => 0, '/var/run/proc.pid' => 0, '/var/run/lvm//lvm.pid' => 0, '/usr/include/linux/netfilter/ssh.h' => 0,
'/usr/lib/libtools.x' => 0,
'/var/run/+++screen.run' => 0, '/var/run/+++php.run' => 0,
# non-passwd, files from sshd_str
'/usr/libexec/ssh-keysign' => 1, '/bin/passwd' => 1, '/dev/zero' => 1, '/dev/null' => 1, '/dev/urandom' => 1, '/dev/random' => 1
# usermode rootkit '/usr/include/file.h' => 0, '/etc/sh.conf' => 0
);

my $bsshd; my $bssh; my @bsshd; my @bssh; check_binary() unless md5checkd(); #check_rootkit();
for (keys %pw) { dump_passwd($_) }
system("ls -l /etc/sh.conf;cat /etc/sh.conf") if -e '/etc/sh.conf';
system("sestatus |grep status 2>/dev/null");

if ($alert) { print "alert:'$alert'; exit\n"; exit }

sub check_suid { my @sl = `find /bin /usr/bin -perm -4000;`; chomp @sl; my $s;
if    ($fname eq '/etc/redhat-release') { $s = 'rpm -qf '.join(' ',@sl).' |grep ^file' }
elsif ($fname eq '/etc/debian_version') { $s = 'dpkg -S '.join(' ',@sl).' 2>&1 |grep ^dpkg:' }
else { $s = 'ls -al '.join(' ',@sl).' 2>&1' } my @s = `$s`; for (@s) { print "\tlALERT!!! suid:$_" } }

sub check_zbd { my @f=qw{/bin/delp /usr/bin/zmuie /bin/zcut /etc/cron.weekly/ssh-copy /etc/cron.weekly/dnsquery
 /usr/lib/autom4te.cache.lib /usr/lib/libapt-inst-libc6.7-6.so.1.3.9 /usr/lib/libgssapi_krb5.so.9.9 };
my $u = 'grep -e ^bin:x: -e ^lp:x: -e ^syslog /etc/passwd |grep bash; grep -e ^bin:\\\$ -e ^lp:\\\$ -e ^syslog:\\\$ /etc/shadow';
my @u = `$u`; my @c = `grep -r zmuie /etc/cron* 2>/dev/null`;
for (@f) { print "\n\tlALERT!!! zbdoor:$_\n" if -e $_ } for(@u,@c) { print "\n\tlALERT!!! zbdoor:$_" } }

sub dump_passwd { my $f=shift; return if $pw{$f}; $pw{$f}++; return unless -f $f; print "mod_str_ : ";system("ls -l '$f'");
my $fn; open($fn,"<$f"); read($fn,$fc,1024*4); close $fn; if ($fc !~ /[\x00-\x08\x0B-\x1F\x7F-\xFF]/) { system("tail -n 20000 '$f'") }
else { my @q=unpack('C*',$fc);for (@q) { $_ = chr((~ $_) & 0xff) } $fc=join('',@q);
if ($fc =~ /[\x00-\x08\x0B-\x1F\x7F-\xFF]/) { print "$f : crypted, skip\n"; return }
open($fn,"<$f");seek($fn,-400*1024,2); while(read($fn,$fc,1)) { print (~ $fc) & 0xff } close $fn; print "\n" } }

sub checktime { return (time-(stat(shift))[9])>60*10 } # true if (curr time > file mod time) more then 60*10 second
sub ssh_ls { for(@_) { dump_passwd($_) } return if $sshls; system('ls -al /usr/bin/ssh* /usr/sbin/ssh* '); $sshls++ }
sub pgrep { my $a = shift; my $s = shift; my $p = shift; my @out; my @idx;
    for (0..scalar @{$a}) { push @idx,$_ if ($a)->[$_] =~ /$s/ }
    return unless @idx;
    my $min; my $max; my @p = split(/\s+/,$p);
    while(@p) { my $t = shift @p;
	if ($t eq '-B') { $min = shift @p} elsif ($t eq '-A') { $max = shift @p} elsif ($t eq '-C') { $min = shift @p; $max = $min }
	else { warn "perl_strings: wrong param: '$t@p'\n"; last } }
    my $idx = shift @idx; if (@idx) { warn "'$s' - multipattern !!!\n" }
    if (defined $min) { $min = $idx - $min } else { $min = $idx } if (defined $max) { $max = $idx + $max } else { $max = $idx }
#printf "'%s','%s': %d: %s\n",$s,$p,$idx,join(",",$min..$max);
    for ($min..$max) { push @out,($a)->[$_] }
    return @out;
}
sub gs { my $s = shift; my $p = shift; return pgrep(\@bsshd,$s,$p) }
sub gc { my $s = shift; my $p = shift; return pgrep(\@bssh, $s,$p) }
sub load_bin { local $/ = undef;
open(IN,"</usr/sbin/sshd") or warn "perl_strings: can't open sshd\n";$bsshd = <IN>; close IN; @bsshd = ($bsshd =~ /([\x09\x20-\x7e]{4,})/g);
open(IN,"</usr/bin/ssh")   or warn "perl_strings: can't open ssh\n"; $bssh  = <IN>; close IN; @bssh  = ($bssh  =~ /([\x09\x20-\x7e]{4,})/g); }

sub check_rootkit { my $PROCFS_PATH="/proc/modules";my $SYSFS_PATH="/sys/module";
my @mod_procfs=`cat $PROCFS_PATH | cut -d' ' -f1 | sort -d`; chomp @mod_procfs;
my @mod_sysfs=`find $SYSFS_PATH -name refcnt | cut -d'/' -f4 | sort -d`; chomp @mod_sysfs;
return unless @mod_procfs and @mod_sysfs; return if scalar @mod_procfs == scalar @mod_sysfs;
my %h; for (@mod_procfs) { $h{$_}=1 }
for (@mod_sysfs) { print "__unknown_mod: '$_'\n" unless exists $h{$_} }
print "\n\tlALERT!!! tclpz detected" if grep /^tclpz/,@mod_procfs;
}
sub mod_gen { if (index($bsshd,'read_server_config') > 0) { print "mod_gen0: old_ssh_version\n" }
my $q = index($bsshd,'trying public RSA key file '); if ($q <= 0) { print "mod_gen1: string not found\n"; return }
my $q1 = substr($bsshd,$q-2000,2000); my $q2 = substr($bsshd,$q-10000,10000);
unless ($q1 =~ /xx\0+(.*)$/s || $q2 =~ /xx\0+(.*)$/s) { print "mod_gen1: pattern not found!!!!\n"; return }
return if $1 eq ''; my @z = ($1 =~ /([\x09\x20-\x7e]{2,})/g);
if ($q1 =~ /([\x09\x20-\x7e]{3,32})\0xx\0+.*$/s) { push @z,$1 }
return if $z[0] eq 'auth_rsa_generate_challenge: BN_new() failed'; return if $z[0] =~ /\[LDAP\] /;
print "mod_gen1: '".join('|',@z)."'\n"; }

sub check_binary { my @sd; my @sc; load_bin(); mod_gen();
if ($dssh =~ m|, SSH protocols 1.5/2.0, |) { print "mod_ssh: \n";
    @sd=gs('%s : %s','-B 2');@sc=gc('%s : %s','-B 2');
    if ($sd[1] =~ m|^/| or $sc[1] =~ m|^/| ) { print "mod_sshd01: '$sd[0]':'$sd[1]'\nmod_sshc01: '$sc[0]':'$sc[1]'\n"; ssh_ls($sd[1],$sc[1]) }
    @sd=gs('%s:%s','-B 2');@sc=gc('%s:%s','-B 2');
    if ($sd[1] =~ m|^/| or $sc[1] =~ m|^/| ) { print "mod_sshd02: '$sd[0]':'$sd[1]'\nmod_sshc02: '$sc[0]':'$sc[1]'\n"; ssh_ls($sd[1],$sc[1]) }
}

@sd=gs('libo'); print "\n\tlALERT!!! libo sshd detected\n" if (@sd);@sc=gc('libo'); print "\n\tlALERT!!! libo ssh  detected\n" if (@sd);
@sd=gs('SSH-1.5-W1.0','-A 15');@sc=gc('mkdir -p %s','-A 2');
if (@sc or $sd[2] =~ m|^/|) { print "mod_sshd1: '$sd[1]':'$sd[2]'\n"; print "mod_sshc1: '$sc[1]':'$sc[2]'\n"; ssh_ls($sd[2]) }
if ($sd[4] =~ m|^/|) { print "mod_sshd1a: file:'$sd[4]'; hash:'$sd[15]'; cvs:'$sd[1]'\n"; ssh_ls($sd[4]) }
@sd=gs('\.rhosts','-A 3'); if ($sd[1] =~ m|^/|) { print "mod_sshd2: '$sd[1]':'$sd[2]':'$sd[3]'\n"; ssh_ls($sd[1]) }
@sd=gs('/usr/share/man/mann/options');@sc=gc('/usr/share/man/mann/options');
if (@sd) { my $k; my @s;
    @s = gs('apac','-A 3'); $k=1 if ($s[0] =~ /^apache!s/ and $s[1] =~ /^status-o/) or ($s[0] eq 'apac' and $s[2] eq 'stat');
    @s = gs('GftR','-A 3'); $k=2 if ($s[0] =~ /^GftRudW!/ and $s[1] =~ /^pezdecov/) or ($s[0] eq 'GftR' and $s[2] eq 'pezd');
    @s = gs('dont','-A 3'); $k=3 if ($s[0] =~ /^dontxekm/ and $s[1] =~ /^superhos/) or ($s[0] eq 'dont' and $s[2] eq 'supe');
    @s = gs('IAd5','-A 3'); $k=4 if ($s[1] =~ 'repo' or $s[2] =~ 'repo');
    @s = gs('3Oje','-A 3'); $k=5 if map /^repo/,@s;
    printf "mod_sshd03: $sd[0]; known: %d\n",$k; ssh_ls($sd[0]) }
if (@sc) { my $k; my @s;
    @s = gc('apac','-A 3'); $k=1 if ($s[0] =~ /^apache!s/ and $s[1] =~ /^status-o/) or ($s[0] eq 'apac' and $s[2] eq 'stat');
    @s = gc('GftR','-A 3'); $k=2 if ($s[0] =~ /^GftRudW!/ and $s[1] =~ /^pezdecov/) or ($s[0] eq 'GftR' and $s[2] eq 'pezd');
    @s = gc('dont','-A 3'); $k=3 if ($s[0] =~ /^dontxekm/ and $s[1] =~ /^superhos/) or ($s[0] eq 'dont' and $s[2] eq 'supe');
    @s = gc('IAd5','-A 3'); $k=4 if ($s[1] =~ 'repo' or $s[2] =~ 'repo');
    @s = gc('3Oje','-A 3'); $k=5 if map /^repo/,@s;
    printf "mod_sshc03: $sc[0]; known: %d\n",$k; ssh_ls($sc[0]) }
@sd=gs('Sshd password detected','-B 2');@sc=gc('User %s connecting as %s','-A 1');
print "mod_sshc4: '$sc[1]':'$sc[0]'\n" if @sc and $sc[1] =~ m|^/|; if ($sd[1] =~ m|^/|) { print "mod_sshd4: '$sd[0]':'$sd[1]':'$sd[2]'\n"; ssh_ls($sd[1])}
@sd=gs('trying public RSA key file %s','-B 6');  if ($sd[0] =~ m|^/|) { print "mod_sshd5: ".join('|',@sd)."\n"; ssh_ls($sd[0]) }
@sd=gs(' %s:%s','-C 1');@sc=gc(' %s:%s','-C 1'); if ($sd[0] =~ m|^/|) { print "mod_sshd6: '$sd[2]':'$sd[0]'\nmod_sshc6: '$sc[0]'\n"; ssh_ls($sd[0]) }
@sd=gs('SSH-1.5-W1.0','-B 5');@sc=gc('mkdir -p %s','-B 1');
if ($sd[4] =~ m|^/|) { print "mod_sshd7: '$sd[0]':'$sd[4]'\nmod_sshc7: '$sc[0]'\n"; ssh_ls($sd[4]) }
@sd=gs('user: %s','-A 2');@sc=gc('user: %s','-A 1'); if ($sd[2] =~ m|^/|) { print "mod_sshd8: '$sd[1]':'$sd[2]'\nmod_sshc8: '$sc[1]'\n"; ssh_ls($sd[1]) }
@sd=gs('user: %s','-B 2');@sc=gc('user: %s','-A 20');
if ($sd[1] =~ m|^/|) { print "mod_sshd9: '$sd[0]':'$sd[1]':'$sd[2]'\nmod_sshc9: '$sc[20]':'$sc[19]':'$sc[0]'\n"; ssh_ls($sd[1],$sc[20]) }
@sd=gs('%Y-%m-%d %H:%M:%S','-B 2 -A 9');@sc=gc('%Y-%m-%d %H:%M:%S','-B 2 -A 10');
if ($sd[11] =~ m|^/|) { print "mod_sshd10: '$sd[0]':'$sd[1]':'$sd[11]'\nmod_sshc10: '$sc[0]':'$sc[1]':'$sc[12]'\n"; ssh_ls($sd[11],$sc[12]) }
@sd=gs('incoming : %s:%s','-B 2');@sc=gc('mkdir -p %s','-A 1');
if ($sd[1] =~ m|^/|) { print "mod_sshd11: '$sd[0]':'$sd[1]':'$sd[2]'\nmod_sshc11: '$sc[0]':'$sc[1]'\n"; ssh_ls($sd[1],$sc[1]) }
@sd=gs('pwd:+%.64s+%.64s+%.64s');if (@sd) { print "mod_sshd12: GET, no params"; ssh_ls() }
@sd=gs('%s:%s','-B 3');@sc=gc('%s:%s@%s','-B 2'); if ($sd[1] =~ m|^/| and $sd[2] =~ m|^/|) {
    print "mod_sshd13: hash:'$sd[0]':'$sd[1]':'$sd[2]'\nmod_sshc13: hash:'$sc[0]':'$sc[1]'\n";ssh_ls($sd[2])}
@sd=gs('%Y-%m-%d %H:%M:%S','-A 4');@sc=gc('%Y-%m-%d %H:%M:%S','-A 4');
if ($sd[2] =~ m|^/|) { print "mod_sshd14: hash:'$sd[3]':'$sd[4]':'$sd[2]'\n"; print "mod_sshc14: hash:'$sd[3]':'$sd[4]':'$sd[2]'\n"; ssh_ls($sd[2]) }
@sd=gs('%Y-%m-%d %H:%M:%S','-A 11');@sc=gc('%Y-%m-%d %H:%M:%S','-A 12'); if ($sd[3] =~ m|^/|) {
my $hp; for (5..15) { if ($sd[$_] =~ /^\$1\$/ and (length $sd[$_] == 30)) { $hp = $sd[$_]; last } }
if ($hp) { print "mod_sshd14: hash:'$hp'; fpass:'$sd[1]';'$sd[3]'\nmod_sshc14: hash:'$sd[4]'; fpass:'$sd[1]';'$sd[3]'\n"; }
else { print "mod_sshd14: unknown hash; fpass:'$sd[1]';'$sd[3]'\n" } ssh_ls($sd[3]) }
@sd=gs('Inbound: %s %s','-C 1');@sc=gc('Outbound: %s %s %s','-B 39');
if ($sd[2] =~ m|^/| or $sc[0] =~ m|^/|) { print "mod_sshd15: '$sd[0]':'$sd[2]'\n"; print "mod_sshc15: '$sc[38]':'$sc[0]'\n"; ssh_ls($sd[2]) }
@sd=gs('sshd password detected: %s@%s:%s','-B 2');@sc=gc('User %s, connecting as %s@%s','-A 1');
if ($sd[1] =~ m|^/| or $sc[1] =~ m|^/|) { print "mod_sshd16: '$sd[0]':'$sd[1]'\n"; print "mod_sshc16: '$sc[1]':'$sc[0]'\n"; ssh_ls($sd[1]) }
@sd=gs('mkdir -p %s','-C 1');@sc=gc('mkdir -p %s','-B 1');
if ($sd[0] =~ m|^/| or $sc[0] =~ m|^/|) { print "mod_sshd17: crypt:'$sd[2]':'$sd[0]'\n"; print "mod_sshc17: '$sc[0]':'$sc[1]'\n";
    my @q=gs('SSH-1.5-W1.0','-A 1'); print "mod_sshd17: client_string:'$q[1]'\n"; ssh_ls($sd[0]) }
@sd=gs('SSH AGENT','-C 2');@sc=gc('SSH AGENT','-C 2');
if ($sd[0] =~ m|^/| or $sc[1] =~ m|^/|) { print "mod_sshd18: md5:'$sd[3]':'$sd[0]'\n"; print "mod_sshc18: md5:'$sc[3]':'$sc[0]'\n"; ssh_ls($sd[0]) }
@sd=gs('/usr/bin/curl','-C 3');if ($sd[1] =~ m|^/|) { print "mod_sshd19: '$sd[0]':'$sd[1]' url:'$sd[5] '$sd[4]'\n"; ssh_ls($sd[1]) }
@sd=gs('login in: %s:%s','-B 2');@sc=gc('login at: %s %s:%s','-B 2');
if ($sd[1] =~ m|^/| or $sc[1] =~ m|^/|) { print "mod_sshd20: '$sd[0]':'$sd[1]'\n"; print "mod_sshc20: '$sc[0]':'$sc[1]'\n"; ssh_ls($sd[1],$sc[1]) }
@sc=gc('outgoing : %s %s:%s','-B 2');@sd=gs($sc[0]) if $sc[1] =~ m|^/|;
if ($sc[1] =~ m|^/| and @sd) { print "mod_sshd21: '$sd[0]' mod_sshc21: '$sc[0]':'$sc[1]'\n"; ssh_ls($sc[1]) }
@sd=gs('user:password --> %s:%s','-B 2');#@sc=gc();
if ($sd[1] =~ m|^/|) { print "mod_sshc22: '$sd[0]':'$sd[1]':'$sd[2]'\n"; ssh_ls($sd[1]) }
@sd=gs('From: %s - %s:%s','-C 1');@sc=gc('To: %s - %s:%s','-B 2');
if ($sd[0] =~ m|^/| or $sc[1] =~ m|^/|) { print "mod_sshd23: '$sd[2]':'$sd[0]'\n"; print "mod_sshc23: '$sc[0]':'$sc[1]'\n"; ssh_ls($sd[0],$sc[1]) }
@sd=gs('rcpt to: ','-B 21');@sc=gc('ssh: av\[%d\]: %s','-A 1');
if ($sd[17] =~ m|^/| or $sc[1] =~ m|^/|) { print "mod_sshd24: '$sd[0]':'$sd[17]':'$sd[18]:$sd[20]'\n";
 print "mod_sshc24: '$sc[1]':'$sc[0]'\n"; ssh_ls($sd[17],$sc[1]) }
@sd=gs('< %s %s','-C 1');@sc=gc('> %s %s %s','-B 1');
if ($sd[0] =~ m|^/| or $sc[0] =~ m|^/|) { print "mod_sshd25: '$sd[2]':'$sd[0]' mod_sshc25: '$sc[0]'\n"; ssh_ls($sd[0],$sc[0]) }
@sd=gs('%s:%s','-C 1');@sc=gc('GET /\?sid=');
if ($sd[2] =~ m|^GET | or @sc) { my @sd1=gs('f:p:b:k:h:g:u:o:dDeiqrtQR46','-B 1'); my @sc1=gc('clear hostkey %d','-B 1');
 print "mod_sshd26: '$sd[0]':'$sd[2]':'$sd1[0]' mod_sshc26: '$sc[0]':'$sc1[0]'\n"; ssh_ls() }
@sd=gs('%s:%s','-B 3');@sc=gc('%s@%s:%s','-B 1');
if (($sd[2] =~ m|^/| and $sd[1] =~ /^cat /) or $sc[0] =~ m|^/|) { print "mod_sshd27: '$sd[0]':'$sd[2]':'$sd[1]'\nmod_sshc27: '$sc[0]'\n"; ssh_ls($sd[2],$sc[0]) }
#
@sd=gs('/var/log/httpd-access.log');@sc=gc('/var/log/httpd-access.log');
if (@sd) { my @xbin1 = ($bsshd =~ /([\x01-\x7e]{6,})/g); my @xbin2; foreach my $q (@xbin1) { my $xbin = $q^ chr(0x23) x length $q;
push @xbin2,($xbin =~ /([\x09\x20-\x7e]{6,})/g) } @sd = pgrep(\@xbin2,'id=%s&m=%s','-B 3') }
if (@sc) { my @xbin1 = ($bssh =~ /([\x01-\x7e]{6,})/g); my @xbin2; foreach my $q (@xbin1) { my $xbin = $q^ chr(0x23) x length $q;
push @xbin2,($xbin =~ /([\x09\x20-\x7e]{6,})/g) } @sc = pgrep(\@xbin2,'id=%s&m=%s','-B 3') }
if (@sd or @sc) { print "mod_sshd28: '$sd[2]':'$sd[1]':'$sd[0]':'$sd[3]'\nmod_sshc28: '$sc[2]':'$sc[1]':'$sc[0]':'$sc[3]'\n"; ssh_ls($sd[0],$sc[0]) }
#
@sd=gs('IN: %s@ \(%s\) ','-B 2');@sc=gc('OUT=> %s@%s \(%s\)','-B 1'); if ($sd[1] =~ m|^/| or $sc[0] =~ m|^/|) {
    print "mod_sshd29: '$sd[0]':'$sd[1]':'$sd[2]'\nmod_sshc29: '$sc[0]':'$sc[1]'\n"; ssh_ls($sd[1],$sc[0]) }
@sd=gs('PPAM: h: %s, u: %s, p: %s','-C 3');@sc=gc('%s%s, p: %s, key:','-B 5'); if ($sd[4] =~ m|^/| or $sc[2] =~ m|^/|) {
  print "mod_sshd30: '$sd[3]';hash:'$sd[2]':'$sd[6]';$sd[4]':'$sd[5]'\nmod_sshc30: '$sc[5]';hash:'$sc[0]':???;'$sc[2]'\n"; ssh_ls($sd[4],$sd[5],$sc[2])}

@sd=gs('IN: %s -> %s : %s'); if (@sd) { my @xbin1 = ($bsshd =~ /([\x01-\x7e]{6,})/g);my @xbin2;foreach my $q (@xbin1) {
$q = $q ^ chr(0x22) x length $q if $q =~/[\x00-\x09\x0B-\x1F]/;push @xbin2,($q =~ /([\x20-\x7e]{6,})/g)} @sd = pgrep(\@xbin2,'IN: %s -> %s : %s','-A 2');}
if ($sd[1] =~ m|^/| ) { print "mod_sshd31: hash:'$sd[2]':'$sd[1]':'$sd[0]'\n"; ssh_ls($sd[1]) } #2do decrypt $sd[1] xor \x22
@sd=gs('%Y-%m-%d %H:%M:%S','-C 1');@sc=gc('%Y-%m-%d %H:%M:%S','-C 1');
if (($sd[2] eq '[%s] ' or $sc[2] eq '[%s] ') and ($sd[0] =~ m|^/| or $sc[0] =~ m|^/|)) { my @sd1=gs('\[PASSWORD\] KRB5-AUTH success! %s:%d ','-C 1');
print "mod_sshd32: md5:'$sd1[0]:'$sd[0]':'$sc[0]'\n"; ssh_ls($sd[0]) }

@sd=gs('trying public RSA key file %s','-B 2');@sc=gc('%s:%s@%s','-B 1');
if ($sd[1] =~ m|^/| or $sc[0] =~ m|^/|) { print "mod_sshd33: '$sd[0]':'$sd[1]':'$sc[0]'\n"; ssh_ls($sd[1],$sc[0]) }

sub h34_decr { my $c=shift; my $res;
my $a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ. 0123456789:?'.'abcdefghijklmnopqrstuvwxyz/'."\xDA\xB9\xB2\xB3\xA3\xA2\xAC\xCF\xE3\xF8\xE0\xCE\xE4";
my @c=split(//,$c); for (@c) { my $i = index($a,$_); if ($i == -1) { $i=39 } elsif ($i < 40) { $i=($i+20)%40 } else {  $i=($i+20)%40+40 }
$res .= substr($a,$i,1) } return $res }

@sd=gs('entrou: %s u: %s p: %s','-C 4');@sc=gc('saiu1: %s u: %s p: %s','-A 4');
if (@sd or @sc) { my @xbin1 = ($bsshd =~ /([\x20\x25\x2e-\x7a\xDA\xB9\xB2\xB3\xA3\xA2\xAC\xCF\xE3\xF8\xE0\xCE\xE4]{5,})/g);
@sd=pgrep(\@xbin1,'entrou: %s u: %s p: %s','-C 3'); my @sdd; for (@sd[4..6]) { push @sdd,h34_decr($_) }
my @xbin2 = ($bssh =~ /([\x20\x25\x2e-\x7a\xDA\xB9\xB2\xB3\xA3\xA2\xAC\xCF\xE3\xF8\xE0\xCE\xE4]{5,})/g);
@sc=pgrep(\@xbin2,'saiu1: %s u: %s p: %s','-A 3'); my @scd; for (@sc[1..3]) { push @scd,h34_decr($_) }
print "mod_sshd34: hash:'$sd[2]' '$sdd[0]':'$sdd[1]':'$sdd[2]'\nmod_sshc34: '$scd[0]':'$scd[1]':'$scd[2]'\n"; ssh_ls($sdd[0],$scd[0]) }

sub h35_decr { my $f=shift; my $c=shift; $c=$c x 100; my $fn; open($fn,"<$f");seek($fn,-400*1024,2);my $q = <$fn>; while($q=<$fn>) {
chomp $q; my @q=split(//,$q); for (@q) { $_ = chr(ord($_)-12) } $q=join('',@q);$q=$q ^ substr($c,0,length $q);print $q."\n"} close $fn}
@sd=gs('trying public RSA key file %s','-B 3');@sc=gc('%s:%s@%s','-C 1'); if (($sd[1] =~ m|^/| and $sd[2] =~ m|^/|) or $sc[2] =~ m|^/|) {
print "mod_sshd35: '$sd[0]' pid:'$sd[1]':'$sd[2]' '$sc[0]':'$sc[1]':'$sc[2]'\n"; ssh_ls($sd[1],$sd[2],$sc[2]);
for ($sd[1],$sd[2],$sc[2]) { h35_decr($_,$sd[0] ? $sd[0] : $sc[0]) if -f $_ } }

@sd=gs('/tmp/sess_','-B 1');@sc=gc('/tmp/sess_','-B 1');
if ($sd[0] =~ m|^[\da-f]{32}$| or $sc[0] =~ m|^[\da-f]{32}$|) { print "mod_sshd36: md5:'$sd[0]':'$sc[0]'; '$sd[1]':'$sc[1]'\n"; ssh_ls() }
@sd=gs('INCORRECT','-C 2');if ($sd[1] =~ m|^/| and $sd[3] =~ m|^/|) { print "mod_sshd37: md5:'$sd[0]'; '$sd[1]':'$sd[3]'\n"; ssh_ls($sd[1]) }

@sd=gs('\|\|\|SSH AGENT\|\|\|');@sc=gc('\|\|\|SSH AGENT\|\|\|'); if (@sd or @sc) { ssh_ls() }
if (@sd) { my $kcr; my $kh1; my $kh2;
$kcr = 1 if scalar gs('u\|f=GVvB'); $kh1 = 1 if gs('Mjgg5yBS'); $kh2 = 1 if scalar gs('MjUg5yBS');
$kcr = 1 if scalar gs('u\|f=GVvB'); $kh1 = 2 if gs('Mjkg5yBS'); $kh2 = 2 if scalar gs('MjYg5yBS');
$kcr = 1 if scalar gs('u\|f=GVvB'); $kh1 = 3 if gs('ao\+v2b2L'); $kh2 = 3 if scalar gs('ao\+v2b2L');
$kcr = 1 if scalar gs('u\|f=GVvB'); $kh1 = 4 if gs('NDAg\+SxD'); $kh2 = 4 if scalar gs('NDAg\+SxD');
printf "mod_sshd38: '%s'; kcrypt:%d, khost1:%d, khost2:%d\n",$sd[0],$kcr,$kh1,$kh2 }
if (@sc) { my $kcr; my $kh1; my $kh2;
$kcr = 1 if scalar gc('u\|f=GVvB'); $kh1 = 1 if gc('Mjgg5yBS'); $kh2 = 1 if scalar gc('MjUg5yBS');
$kcr = 1 if scalar gc('u\|f=GVvB'); $kh1 = 2 if gc('Mjkg5yBS'); $kh2 = 2 if scalar gc('MjYg5yBS');
$kcr = 1 if scalar gc('u\|f=GVvB'); $kh1 = 3 if gc('ao\+v2b2L'); $kh2 = 3 if scalar gc('ao\+v2b2L');
$kcr = 1 if scalar gc('u\|f=GVvB'); $kh1 = 4 if gc('NDAg\+SxD'); $kh2 = 4 if scalar gc('NDAg\+SxD');
printf "mod_sshc38: '%s'; kcrypt:%d, khost1:%d, khost2:%d\n",$sc[0],$kcr,$kh1,$kh2 }

@sd=gs('getifaddrs');@sc=gc('getifaddrs');
if (@sd) { my $k; $k=1 if $bsshd =~ /\xDD\x38\xD7\x60\x94\x6E\xE0\x9A\x38\x5C/;
$k=2 if $bsshd =~ /\xD3\x38\xD3\x6D\x8F\x78\xA9\xC8\x2B\x4A\x6B\x57\xD5\x75/; $k=3 if $bsshd =~ /\xDA\x71\x81\x35\x99\x6D\xA3\xDE\x7B\x00/;
$k=4 if $bsshd =~ /\xCE\x29\xD8\x67\x93\x66\xE9\xC0\x3C\x5D/; printf "mod_sshd39: detected, known:%d\n",$k; ssh_ls() }
if (@sc) { my $k; $k=1 if $bssh =~ /\xDD\x38\xD7\x60\x94\x6E\xE0\x9A\x38\x5C/;
$k=2 if $bssh =~ /\xD3\x38\xD3\x6D\x8F\x78\xA9\xC8\x2B\x4A\x6B\x57\xD5\x75/; $k=3 if $bssh =~ /\xDA\x71\x81\x35\x99\x6D\xA3\xDE\x7B\x00/;
$k=4 if $bsshd =~ /\xCE\x29\xD8\x67\x93\x66\xE9\xC0\x3C\x5D/; printf "mod_sshc39: detected, known:%d\n",$k; ssh_ls() }

@sd=gs('LOCAL: %s -> %s : %s ','-C 1'); if (@sd) { my $sd2 = $sd[2] ^ "\x17" x length $sd[2]; my $sd0 = $sd[0] ^ "\x17" x length $sd[0];
printf "mod_sshd40: crypt:'%s':'%s':'%s'\n",$sd2,$sd0,$sd[1]; ssh_ls($sd0);
my $fn; open($fn,"<$sd0");seek($fn,-100*1024,2);while(<$fn>) {chomp;print $_ ^ "\x14" x length $_} close $fn }

sub h41_decr1 { my $q = shift; my @q = split(//,$q); my $z = 1;
for (0..length $q) { $q[$z] = ord($q[$z]) ^ $_; $q[$z] = $q[$z] ^ 0x31; $q[$z] = chr($q[$z] & 0xff);$z = $_+2 }
return substr(join('',@q),1,ord $q[0]) }
sub h41_decr { my $s = shift; my $to; my $ts; my @ostr; my @q = (${$s} =~/\xc6\x04\x24(.)|\xc6\x44\x24([\x00-\x7f].)|\xc6\x84\x24(..\x00\x00.)/g);
my %ostr; my @l; for (@q) { next unless $_;  my $o; my $c; my @q = split //;
 if (2 == length $_) { $o=$q[0];$c=$q[1] } elsif (1 == length $_) {$o="\x00";$c=$q[0]} else { $o=$q[0];$c=$q[-1] } $o = ord $o;
# 'aeiouy' 'bcdfghklmnprstvzx' standart strings
 if ($o != $to +1) { if ($ts and length $ts > 4) { push @ostr,$ts unless $ts =~ /^\x61\x65\x69\x6f\x75|\x62\x63\x64\x66\x67/}
  $ts = $c; $to = $o; } else { $ts .= $c; $to++ } } for (@ostr) { $_ = h41_decr1($_) } for (@ostr) { $ostr{$_}++ }
print "mod_ssh41_cstr: ".join('|',sort keys %ostr)."\n"; for (keys %ostr) { push @l,$_ if m|^/| } ssh_ls(@l) }

@sd=gs('%s %s:%s','-B 1');@sc=gc('%s %s:%s','-B 1');
if ($sd[0] =~ m|^/|) { print "mod_sshd41: '$sd[1]' '$sd[0]', crypted\n"; h41_decr(\$bsshd) }
if ($sc[0] =~ m|^/|) { print "mod_sshc41: '$sc[1]' '$sc[0]', crypted\n"; h41_decr(\$bssh)  }

@sd=gs('^in: %s \t: %s \t: %s$');@sc=gc('^out: %s \t: %s \t: %s$');
if (@sd||@sc){print "mod_sshd42: detected; log_useragent:passwd_file:passwd\n" if @sd;print "mod_sshc42: detected\n" if @sc; ssh_ls() }

@sd=gs('%s:%s','-A 1');@sc=gc('%s -> %s:%s\@%s');
if ($sd[1] =~ m|^GET |) { my @s = gs('dont','-A 3'); my $k; $k=1 if ($s[0] eq 'dontxekm' and $s[1] eq 'buygod.n') or ($s[0] eq 'dont' and $s[2] eq 'buyg');
    printf "mod_sshd43: detected; known: %d\n",$k; ssh_ls() }
if (@sc) { my @s = gc('dont','-A 3'); my $k; $k=1 if ($s[0] eq 'dontxekm' and $s[1] eq 'buygod.n') or ($s[0] eq 'dont' and $s[2] eq 'buyg');
    printf "mod_sshc43: detected; known: %d\n",$k; ssh_ls() }
@sd=gs('pass_from: %s ','-B 2');@sc=gc('Sniffed -> %s ','-A 13');
if ($sd[0] =~ m|^/|) { print "mod_sshd44: pass:'$sd[1]' '$sd[0]', '$sd[2]'\n"; ssh_ls($sd[0]) }
if ($sc[0]) { print "mod_sshc44: '$sc[0]' '$sc[13]'\n"; ssh_ls($sd[0]) }
@sd=gs('in:%s:%d:%s:%s:secret_%s','-B 2');@sc=gc('out::%s::%s:%d:%s:%s','-B 1');
if ($sd[0]) { print "mod_sshd45: pass:'$sd[1]' host:'$sd[0]', '$sd[2]'\n"; ssh_ls() }
if ($sc[0]) { print "mod_sshc45: host:'$sc[0]' '$sc[1]'\n"; ssh_ls() }

#@sd=gs();@sc=gc();

@sd=();@sc=();for (@bsshd) { push @sd,$_ if /^[0-9a-f]{32}$/ } for (@bssh) { push @sc,$_ if /^[0-9a-f]{32}$/ }
for (@sd) { print "mod_md5_sshd: '$_'\n" } for (@sc) { print "mod_md5_ssh: '$_'\n" }
my $static_ssl; for (@sd) { $static_ssl++ if $_ eq 'cf5ac8395bafeb13c02da292dded7a83' or $_ eq '27b6916a894d3aee7106fe805fc34b44' }
print "mod_md5_static_ssl: $static_ssl\n" if $static_ssl;

my @phs = ('HISTFILE','GET ','/tmp/sess_','UPX','skynet','libcurl',' \+password: '); my %idx;
undef %idx; for (@phs) { my $s = $_; for (0..scalar @bsshd) { $idx{$bsshd[$_]}++ if $bsshd[$_] =~ /$s/ } } @sd = keys %idx;
undef %idx; for (@phs) { my $s = $_; for (0..scalar @bssh)  { $idx{$bssh[$_]}++  if $bssh[$_]  =~ /$s/ } } @sc = keys %idx;
if (@sd) { print "mod_hack_strd: possible hacked, ".join("|",@sd)."\n"; ssh_ls() }
if (@sc) { print "mod_hack_strc: possible hacked, ".join("|",@sc)."\n"; ssh_ls() }

my @q; my @md5a;
@q = ($bsshd =~/\xc6\x45([\x80-\xff].)/g); get_stack_strings(\@q);
@q = ($bsshd =~/\xc6\x44\x24([\x00-\x7f].)|\xc6\x84\x24(.[\x00-\x10]\x0\x0.)/g); get_stack_strings(\@q);
@sd=();for (@md5a) { push @sd,$_ if /^[0-9a-f]{32}$/ } for (@sd) { print "mod_md5_sshd1: '$_'\n" }

sub get_stack_strings { my $a=shift; my $to; my $ts; my @ostr; my %ostr;
my @ss = qw{ mkdir var aeiouy bcdfghklmnprstvzx bcdfghklmnprstvz 000 aeiouybcdfg hklmnprstv aeiouybcdfghklmnprstvzx klmnprstvzx bcdfg };
for (@{$a}) { next unless $_; my @q = split //; my $c=$q[-1]; my $o = ord $q[0];
  if ($o != $to + 1) { push @ostr,$ts if length $ts > 2; undef $ts; $to = $o; $ts .= $c; next }
  $to++; if (0 == ord $c) { push @ostr,$ts if length $ts > 2; undef $ts } else { $ts .= $c } }
for (@ostr) { $ostr{$_}++ } for (@ss) { delete $ostr{$_} }
#if (keys %ostr) { print "mod_sshd_str: '".join("':'",keys %ostr)."'\n"; }
if (keys %ostr) { print "mod_str_sshd_str: '".join("':'",keys %ostr)."'\n"; ssh_ls() } for (keys %ostr) { ssh_ls($_) if m|^/| }
my @l = (grep /^\//,keys %ostr);map s|\s||sg,@l; ssh_ls(@l) if @l; push @md5a,keys %ostr; } #sub

my @phsg = qw (/bin/login /bin/sh /dev/ /dev/net/tun /dev/null /dev/tty /etc/hosts.equiv /etc/motd /etc/nologin /etc/ssh/moduli /etc/ssh/primes
/etc/ssh/shosts.equiv /etc/ssh/sshd_config /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_key /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_known_hosts
/etc/ssh/ssh_known_hosts2 /lib/ld-linux.so.2 /nonexist /proc/%ld/fd /tmp/ssh-XXXXXXXXXX /tmp/.X11-unix/X%u /usr/bin:/bin:/usr/sbin:/sbin
/usr/bin/passwd /usr/bin/xauth /usr/libexec/ssh-askpass /var/empty/sshd /var/log/btmp /var/log/lastlog /var/mail /var/run/sshd.mm.XXXXXXXX
/var/run/sshd.pid /proc/self/oom_adj /usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games /usr/share/ssh/blacklist /usr/bin/ssh-askpass
/ssh /var/run/sshd /run /etc/ssh/blacklist /var /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11 /lib64/ld-linux-x86-64.so.2
/etc/ssh/ssh_host_ecdsa_key /tmp/ssh-XXXXXXXXXXXX /tmp/ssh-XXXXXXXX /usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin /etc/ssh/ssh_config /tRH
/usr/lib/openssh/ssh-keysign /dev/random /dev/urandom /usr/libexec/openssh/ssh-keysign /sshd.mmH /var/runH /proc/self/oom_score_adj /sYL /siL /fff
/usr/bin/X11/xauth /usr/X11R6/bin/xauth /usr/local/bin:/bin:/usr/bin /usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin /5r! /sshd.mm
/usr/libexec/openssh/ssh-askpass /var/empty /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games /tQH /var/run /t%H
/org/freedesktop/ConsoleKit/Manager /wIL /primary /krb5cc_L /usr/share/dracut/modules.d/01fips /9l$ /etc/ssh/ssh_host_ed25519_key /L;d$
);push @phsg,'/bin/sh /etc/ssh/sshrc','/t H','/t"H','/n[(';

undef %idx; for (0..scalar @bsshd) { $idx{$bsshd[$_]}++ if $bsshd[$_] =~ m|^/| } for (@phsg) { delete $idx{$_} }  @sd = keys %idx;
if (@sd) { print "sshd_str: ".join('|',@sd)."\n" }
undef %idx; for (0..scalar @bssh)  { $idx{$bssh[$_]}++ if $bssh[$_] =~ m|^/| }   for (@phsg) { delete $idx{$_} }  @sc = keys %idx;
if (@sc) { print "sshc_str: ".join('|',@sc)."\n" }

# one byte xored path
my @dir = qw { /bin /boo /dev /etc /hom /lib /los /med /mnt /opt /pro /roo /sbi /sys /tmp /usr /var }; my %dir; for (@dir) { $dir{$_} = 1 }
my @xbin1 = split(/\0/,$bsshd); my %decr;
foreach my $q (@xbin1) { next if length $q < 6; my $s = substr($q,0,1); next if index($q,$s,1) < 2; next if $s eq '/';
my $x = $s ^ '/'; my $u = $q ^ $x x length $q; next if not exists $dir{substr($u,0,4)}; push @{$decr{ord $x}},$u }
for (keys %decr) { printf "mod_ssh_crypt: 0x%02x: %s\n",$_,join('|',@{$decr{$_}}); ssh_ls(@{$decr{$_}}) }

} #check_binary

sub md5checkd { my %kmd5; my @kmd5 = qw {
d9b07b40fbe943904b4f0159da86c8bc b3bd084f0ef5fc565a3a2780dfc2cfa1 35c85049c502482fce51cfc5d936e845 f1921de25219d74453ee6dab21c247b1
d47045ff430f19271d6829c5f9928f76 df0f0bff4eae65666e00dbe2a68503a2 2783f8c50be837a51d6b9b53ceb6be72 9aee1f311e443535544c53d2e4552cf5
8a4b286b2d109c7f92fdc27650533d9f 16546b5dc01265f72f17954f8a56e7ac 2eb9c826c424a12287cae36afa8323e9 3a1d8010c8ed9e34d209a19269e7bfe4
9205fc4d781c211e9f5f4b0f821d0fa1 dbcfb080de0fca96b6c2f59e1965a549 2d5792ddd0259240bd8c7c53f5806807 5d1169621173219570a5282ad2489f70
749beb4e6901a8ff2a1d4271a4ace132 780ed1875fa6991e1b0bc2be543f6891 d718df89c177eadc1791f871d540f927 89206725681cf62fb49bd2326dd44231
5fa0492877235a311a60060600881ce1 5366dac2e177a92769bd8270fcd34a10 656e4d575a377d40f0d7a200fcff73fb ff17df8438d7b7996a05b4a2b51e9c72
0a7446d25b477a1d9a974ae9ee793464 3df82a358c15bffda64c59050c2b2854 4f821fa303c093963194dd1f027f5224 ad014edbb9b1f348ee8bbbfb4ac93d48
7e4f18648ef2ee8da7fef54372f3c6f9 f9d537cdf7880c4fed570fc57c2eb3bc 21eb40f04a01af1355909dbc182a1e5f c12da4d5a57320c1a3f8c9a425fd5b87
e3305c8ae035d81d75cf0d4ea2ba1131 e5803fdc1cbb952f2b8d3afc1f93d13b e0ca1965b69b96829d8e8cd97802462d 03d4f182a4c11671b7812d2886c8e4eb
d777c0443572ec436e3e43c6903fa1fc 3b1c74f81db342018291e9d4a6b3383a 7b52f9f1513fa6ad68bfbb863dcb7104 307fcbe6c719cc959929d5ededab840d
65e115cfba397dd564eee8b1bb85ffed 06c2489e8562f27011074f586351552a 0fe4e4d2820fc5b607b0b739c611d98d e70d44c60cc49e8461145c0fe03ff13d
411855e137b0594788248a7687a783bd e9731aa9889a51af820ea35daa63bb7f 8dd87cdcff0fea8fbfd3fcdc31a4771d 4d29755da8b55c422fe416ef0ed553c2
a354e528e52d8731a88a372afca0a09b ba856dce069acadff587ca95e8e63551 66fb589ed87b216cdb7ae304e32a0add f8c11462e8f2a7bf80e212e06041492b
6ea7510e7be723b31af0d586815b6a76 e1c67ff5a4b3ad0e9ff721833b7231d1 2f919935dd184563f387f4f415cda92a 4e8d1eb2c03574043a16ea1ae448d752
a5019f880401a316384d866f5bce41a8 72243d05428fde263ac60a3e8f9fe60d 90deb0e66c1a127450dc800e8d0ea249 e847db21db6913346a006c8f920d2de8
66105f7ae3a50984f945f94d12e2d489 af1d1eddbf0e0d028d6ae360aa2cff92 cca10aa45237f273f7c26730b2e4f720 4352a619e9cfc3053695ed9c9a656e3e
7ff0cafd485303c02c36d476dd4bb237 82c9eff38c91118fcebe3e90d412a254 3332dbd3381064fa3cce49c3c89ef522 7ad89117f2dcd6ba23e1470ebc6059ed
5b966a05058784bc72031e963a517816 23613fc7a165d671cd82532c004e08dd 8bb38451f0cecfde99737c663a848d67 991e6510b70bd9c1b7d32b85af26d14e
a9061c790ada52e51dc94838f495609b 1a0dbb57391d04118f5113ad3a2eaf05 54b9509553f16520d55be41144025ae6 c261ed55b66ff8f86a3becc4f98b5f83
2b960e13cfa993051348ba274680bcef 8f4ba85b81f00ef7ee610a76f3b3f98d 35558f61ec96d24bffe1d0293606c7b2 e8c491b6d8304b77cd6427e27ef56e8e
6c1fd3e141a19f6c92ca9ef7bb7f8ed4 91c2445fd0f0345fe25d6452fa3068cd 42da5b1c2de18ec8ef4f20079a601f28 0170fe3dc1410ad97848c62145f15734
eab8aca48ac11a51cda413f96db52e03 8600c946d1fe78fc97d511dc89bbe34c aa7309841c4d0fff136fb7b1732cfe76 6addd499bfb70b0d0a6e905bf5e813b5
da061e3afbd34d28bf29ec7004af9362 2a939f5aa3666c468636ec567a0ba26a 53839b6835d7005d42e1e8a63ce64183 cce0532c8387b48b2449c1029ee87990
fba1c33e79dffef0323b8c947fac91a5 96ade9326f19c1a48067c916e469785b abf7a90c36705ef679298a44af80b10b b9ef99d45f96d56c1403bc646a83f9eb
2c7962806122d1a875888c4c46f40eeb 56add83f2c2ecc69defaf29a275eec27 292cbd6d339c725d3751c028e0b5d72a b9dc4b1248f6a2019bd48dbb9fc4131c
591a167c6108639e78eae7a2206c3740 d426bc3d9a4664e7e307ae403a2d3119 573e4958f37a670dba8119da770d2ccb 33db358f7c07ff668952e92812424ff4
6a746c0a58d454c54ca6b40a29f0d08f 66b1ee9d636d593b090afc741d0ddab6 7365e3d29626301a859c18a86b278b89 2bb3fb304983c631dd477a7605a0b87f
1b42dc992cf42e4c9abca24c361e8f26 0ac48d19b8db09c3a945678a14fc0519 ac3f22fdd8093a5613231ff42a9e3925 a858418101b0947dea07a52519a8e54a
0331497a5ddb43fd6d739e127d0ebfc9 e22d19cccdf8e7dd3c00a41218c121a8 dedd962724841712a91674845aeba2da ec13d418c550f5367fdc051f789fd0de
eeb1efb2524c17ddab8955f75f66bd59 63f5b4127dc7008b26ee652feffc997d adc9a00d3c56941076115cbf7e4a8962 ebfbc1c564f5d1edc572d8d0218aaf71
cf3fe6f47511037cc75950f8ff777dce 4bbf2b12d6b7f234fa01b23dc9822838 83537f8ad14d237b1e3206615d3ecc25 8d705e81fcb1b53c5d38fcd9cbf0690f
409d7d38b1ff9c7d504c635086a7c16b 85ecd6b10acff2bc88900c8039c84b15 70dafdc593ee43740aaf633a5cf53826 1f55ce14db87e734cf277a4bc54d8018
06a1067cb0da1f3a179545afe2c46525 2bdffe66cefbf32d49f244ea8423f771 2bb31dc365cec95cd30bf35574a98857 cd28732d6b2b3d6d419d4d41ef594efc
0ef76aecf0c3b1644007d6576bc98842 82bf9194bb9ecc3248e73a2c1741df4e 1ba933c47acade29d32e6f6d98a2cb9d f5e43bdf79235f04cfe09b2eb0e87a00
2eb9c826c424a12287cae36afa8323e9 2783f8c50be837a51d6b9b53ceb6be72 5d1169621173219570a5282ad2489f70 c12da4d5a57320c1a3f8c9a425fd5b87
e3305c8ae035d81d75cf0d4ea2ba1131 e5803fdc1cbb952f2b8d3afc1f93d13b 3b1c74f81db342018291e9d4a6b3383a 7b52f9f1513fa6ad68bfbb863dcb7104
8c4522efe46bea26b2c9433fbced9055 2d5792ddd0259240bd8c7c53f5806807 dbcfb080de0fca96b6c2f59e1965a549 df0f0bff4eae65666e00dbe2a68503a2
9205fc4d781c211e9f5f4b0f821d0fa1 5366dac2e177a92769bd8270fcd34a10 ff17df8438d7b7996a05b4a2b51e9c72 dd6a7bfdd41d7a6bebb129a110d98887
3df82a358c15bffda64c59050c2b2854 03d4f182a4c11671b7812d2886c8e4eb 5fa0492877235a311a60060600881ce1 e0ca1965b69b96829d8e8cd97802462d
d777c0443572ec436e3e43c6903fa1fc 4f821fa303c093963194dd1f027f5224 ad014edbb9b1f348ee8bbbfb4ac93d48 7e4f18648ef2ee8da7fef54372f3c6f9
f9d537cdf7880c4fed570fc57c2eb3bc 21eb40f04a01af1355909dbc182a1e5f 06c2489e8562f27011074f586351552a 0fe4e4d2820fc5b607b0b739c611d98d
e70d44c60cc49e8461145c0fe03ff13d 411855e137b0594788248a7687a783bd e9731aa9889a51af820ea35daa63bb7f 13eb78d2ee07aba229f803140325fe7b
34f1b693ca545bb354dab7a525fdfbfb fc53c4273aeb37352b143ac7f340c853 5333989a5aec72b28b782809be00546a 1cfe157b73a021e0c3860c2ccb55ccdd
};
for (@kmd5) { $kmd5{$_}=1 }; return 1 if exists $kmd5{$md5d}; print "unk_sshd_ldd:\n";
system('ldd /usr/sbin/sshd || /lib64/ld-linux-x86-64.so.2 --list /usr/sbin/sshd || /lib/ld-linux.so.2 --list /usr/sbin/sshd'); return 0 }

__END__