#!/bin/bash
cp tor2 /usr/local/mgr5/addon
cp tor /usr/local/mgr5/addon
cp tor_del /usr/local/mgr5/addon
chmod +x /usr/local/mgr5/addon/tor
chmod +x /usr/local/mgr5/addon/tor2
chmod +x /usr/local/mgr5/addon/tor_del
if [ -f /etc/redhat-release ]; then
    # CentOS here
    OS="-cent"
fi
if [ -f /etc/debian_version ]; then
    # Debian
    OS="-deb"
fi
if [ "`lsb_release -si`" = "Ubuntu" ]; then
    OS=""
fi
cp shallot$OS /usr/local/mgr5/addon/shallot
chmod +x /usr/local/mgr5/addon/shallot
mkdir /usr/local/mgr5/etc/sql/webdomain.addon
cp tor.sql /usr/local/mgr5/etc/sql/webdomain.addon/tor
cp ispmgr_mod_tor.xml /usr/local/mgr5/etc/xml
cp nginx-vhosts-tor.template /usr/local/mgr5/etc/templates/default
echo "{% if \$TOR == on %}" >> /usr/local/mgr5/etc/templates/default/nginx-vhosts.template
echo "{% import etc/templates/default/nginx-vhosts-tor.template %}" >> /usr/local/mgr5/etc/templates/default/nginx-vhosts.template
echo "{% endif %}" >> /usr/local/mgr5/etc/templates/default/nginx-vhosts.template
#killall core
/usr/local/mgr5/sbin/mgrctl -m ispmgr exit
echo "-----------------------------------"
echo "Now installing TOR"
if [ "$OS" = "-cent" ]; then
    yum -y install epel-release
    yum -y install tor
    chkconfig tor on
    #systemctl enable tor
    service tor start
else
    apt --yes install apt-transport-https
    echo "deb https://deb.torproject.org/torproject.org `lsb_release -sc` main" >> /etc/apt/sources.list
    echo "deb-src https://deb.torproject.org/torproject.org `lsb_release -sc` main" >> /etc/apt/sources.list
    apt --yes install curl
    curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
    apt update
    apt --yes install tor deb.torproject.org-keyring
    if [ -z "$OS" ]; then
	apt --yes install apparmor-utils
        aa-complain system_tor
    fi
fi
mkdir /etc/tor/sub
echo "%include /etc/tor/sub/" >> /etc/tor/torrc
