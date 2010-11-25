#!/usr/bin/env python
import os, sys

packages = '''
adblock-plus
amule
aptitude
autoconf
automake
avidemux
bison
bochs
build-essential
bum
byobu
calibre
cgdb
checkinstall
cmake
cmake-curses-gui
cmake-gui
cone
cpufrequtils
crack-attack
cscope
curl
cvs
ddd
dosbox
doxygen
ecryptfs-utils
elinks
exif
expat
exuberant-ctags
fbreader
ffmpeg
flex
fortune-mod
g++
gawk
gcc-doc
gdb-doc
geany
gimp
git-core
gitk
git-svn
gitweb
global
glpk
gltron
gmp-doc
g++-multilib
gnome-mplayer
gnuplot
gparted
gperf
graphviz
gtkpod
htop
human-theme
iamerican
id-utils
imagemagick
indent
iotop
ipython
irussian
ispell
kcachegrind
language-support-ru
latex-beamer
libgmp3-dev
libgmp3-doc
libgsl0-dev
libnotify-bin
libpcap-dev
libssl-dev
libsvm-tools
libusb-1.0-0
libusb-1.0-0-dev
libxt-dev
lm-sensors
mailutils
manpages-dev
manpages-posix
manpages-posix-dev
mc
mercurial
mplayer
mutt
nautilus-open-terminal
network-manager-openvpn-gnome
nmap
ntp
octave3.2
octave3.2-info
openjdk-6-jdk
openoffice.org-thesaurus-ru
openvpn
p7zip-full
pidgin
powertop
pwgen
pychecker
python2.6
python3-all
python-all
python-dev
python-doc
python-gmpy
python-matplotlib
python-pyparsing
python-rpy2
python-scipy
python-setuptools
qbittorrent
qemu
rar
r-base
r-cran-randomforest
rdesktop
rrdtool
ruby
scalable-cyrfonts-tex
sdparm
socat
sox
sqlite
sqlite3
sshfs
strace
subversion
swig
sysfsutils
tcpdump
texlive
texlive-generic-extra
texlive-lang-cyrillic
texlive-latex-extra
texlive-science
texmaker
thunderbird
tkdiff
tofrodos
traceroute
ubuntu-restricted-extras
unetbootin
unrar
valgrind
vim
vim-gnome
vinagre
vlc
wamerican-huge
weka
wine
wireshark
xsel
inkscape
-f-spot
-gwibber
-gwibber-service
-tomboy
-ubuntuone-client
'''.split()

if len(sys.argv) == 2:
    release = int(float(sys.argv[1]) * 100 + 1e-5)
else:
    release = int(float(os.popen('lsb_release -r -s', 'r').read()) * 100 + 1e-5)

if release >= 1010:
    packages += 'g++-4.5 python2.7'.split()

print 'sudo apt-get install ' + ' '.join([s for s in packages if not s.startswith('-')])
print 'sudo apt-get remove ' + ' '.join([s[1:] for s in packages if s.startswith('-')])
print 'sudo easy_install gitserve'
