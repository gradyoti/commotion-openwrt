#!/bin/sh

svn co svn://svn.openwrt.org/openwrt/branches/attitude_adjustment openwrt

cd openwrt
patch -p1 < ../patches/unifi.patch
patch -p1 < ../patches/wpa_supplicant-mini.config.patch

[ ! -e feeds.conf ] && cp -v ../feeds.conf feeds.conf
[ ! -e files ] && mkdir files
cp -rf -v ../default-files/* files/
if ! grep -q commotion feeds.conf; then
    echo "adding commotion package feed..."
    echo "src-git commotion git://github.com/reseaulibre-polymtl/commotion-feed.git;ReseauLibre" >> feeds.conf
fi

scripts/feeds update -a
scripts/feeds install -a
scripts/feeds uninstall olsrd libldns libcyassl
# cyassl is an openwrt package, not feeds. Temporary solution:
echo "Removing package/cyassl/ (cyassl-1.6.5)"
rm -rf package/cyassl/
scripts/feeds install -p commotion olsrd libldns libcyassl

# Copy in Commotion-specific patches
cp -v ../patches/910-fix-out-of-bounds-index.patch feeds/packages/utils/collectd/patches/
cp -v ../patches/010-remove_exec.patch feeds/packages/net/netcat/patches/
cp -v ../patches/010-initialize_vars_fix.patch feeds/packages/libs/avahi/patches/
cp -v ../patches/640-store_freq_ibss.patch package/hostapd/patches/
mkdir -p package/netifd/patches
cp -v ../patches/010-iface_name_len.patch package/netifd/patches/
cp -v ../config .config

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " Commotion OpenWrt is prepared. To build the firmware, type:"
echo " cd openwrt"
echo " make menuconfig #If you wish to add or change packages."
echo " make V=99"
