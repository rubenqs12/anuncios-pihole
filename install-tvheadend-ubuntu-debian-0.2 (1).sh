#!/bin/bash

if [ $(id -u) = "0" ]; then
    echo "You are root, starting installation"

#install required package
echo "installing requires packages"
apt-get -y install coreutils curl wget apt-transport-https lsb-release ca-certificates gnupg-agent software-properties-common

CODENAME=$(awk '/VERSION_CODENAME=/' /etc/*-release | sed 's/VERSION_CODENAME=//' | tr '[:upper:]' '[:lower:]')

case "`uname -m`" in
  x86_64|amd64|i?86)
    echo X64
    #add the Tvheadend Repository PGP key
    echo "adding Tvheadend Repository PGP key"
    wget -qO- https://doozer.io/keys/tvheadend/tvheadend/pgp | apt-key add -

    #Add Tvheadend repository
    echo "Add Tvheadend repository"
     #deb https:/apt.tvheadend.orgunstable '$CODENAME' main'
     echo "deb https://apt.tvheadend.org/unstable $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/tvheadend.list
    ;;
  arm*|aarch64)
    sudo apt-get install software-properties-common
    sudo add-apt-repository -y ppa:mamarley/tvheadend-git
    echo ARM
    ;;
  powerpc|ppc64)
    echo PowerPC
    ;;
esac


#Updating repositories
echo "Updating repositories"
apt-get update

#Installing Tvheadend
echo "Installing tvheadend"
apt-get install -y tvheadend

#sleeping 10 seconds
echo "sleeping 10 seconds"
sleep 10

#Accesing a tvheadend folder
echo "Accesing a tvheadend folder"
cd /home/hts/.hts/tvheadend

systemctl stop tvheadend.service

#Making backup
echo "making backup in personal folder"
mkdir -p $HOME/backup-tvheadend
tar -czvf $HOME/backup-tvheadend/original-tvheadend-backup.tar.gz /home/hts/.hts/tvheadend/

#Downloading koala epg
echo "Downloading epg koala"
wget https://raw.githubusercontent.com/koala-mecool/koala-EPG/master/individual/epg_koala.tar.gz

#Uncompessing epg koala
echo "Uncompressing epg koala"
mkdir -p /home/hts/.hts/tvheadend/.instalacion_tmp
tar -xzvf epg_koala.tar.gz -C .instalacion_tmp
rm -fr epg_koala.tar.gz

#deleting old config
echo "deleting old config"
rm -r /home/hts/.hts/tvheadend/channel/
rm -r /home/hts/.hts/tvheadend/input/
rm -r /home/hts/.hts/tvheadend/epggrab/config

#Copying koala config
cp -r .instalacion_tmp/input/ /home/hts/.hts/tvheadend
cp -r .instalacion_tmp/channel/ /home/hts/.hts/tvheadend
mkdir /home/hts/.hts/tvheadend/epggrab
cp -r .instalacion_tmp/config /home/hts/.hts/tvheadend/epggrab/
cp -r .instalacion_tmp/tv_grab_koala /usr/bin/
cp -r .instalacion_tmp/koala.txt /home/hts/koala_version.tx
rm -fr .instalacion_tmp/

#Downloading and installing picons
echo "Downloading and installing picons"
wget https://raw.githubusercontent.com/koala-mecool/Koala-picon/master/spainE2_transparent.tar.gz
rm -rf /home/hts/.hts/tvheadend/imagecache/*
tar -xzvf spainE2_transparent.tar.gz
rm -r spainE2_transparent.tar.gz
chmod 755 /home/hts/.hts/tvheadend/picons

#Creating config file for cas
echo "Creating config file for cas"
mkdir -p /home/hts/.hts/tvheadend/caclient
cat > /home/hts/.hts/tvheadend/caclient/bb96bbd3b859975e8be0ff829160021f <<EOF
{
	"mode": 5,
	"camdfilename": "127.0.0.1",
	"port": 9000,
	"cwmode": 0,
	"pmtmode": 0,
	"class": "caclient_capmt",
	"index": 1,
	"enabled": true,
	"name": "tvheadend",
	"comment": "tvheadend"
}
EOF

#Creating config files for accesscontrol with * user
echo "Creating config files for accesscontrol with * user"
mkdir -p /home/hts/.hts/tvheadend/accesscontrol
cat > /home/hts/.hts/tvheadend/accesscontrol/39df139440afc0d1abc2ca1d72872a06 <<EOF
{
	"index": 1,
	"enabled": true,
	"username": "*",
	"prefix": "0.0.0.0/0,::/0",
	"change": [
		"change_rights",
		"change_chrange",
		"change_chtags",
		"change_dvr_configs",
		"change_profiles",
		"change_conn_limit",
		"change_lang",
		"change_lang_ui",
		"change_theme",
		"change_uilevel"
	],
	"uilevel": 2,
	"uilevel_nochange": 0,
	"lang": "spa",
	"langui": "eng_US",
	"themeui": "blue",
	"streaming": [
		"basic",
		"advanced",
		"htsp"
	],
	"profile": [
		"801dde0337b7ff2c476c0707f5b40aea",
		"7dd588f0eebab52c94d0044833f6da05",
		"da6a5f570be5bbd9aa133c30204cf55f",
		"25581168a48e94907a634831fe501e4a",
		"b32d271dc913b4f022d6b071076922fc",
		"60080b81c3f1dd1be7044bbeed28fcf6",
		"4c03b987cb9ce34dd90805c1a4ecfaa8"
	],
	"dvr": [
		"basic",
		"htsp",
		"all",
		"all_rw",
		"failed"
	],
	"htsp_anonymize": false,
	"dvr_config": [
		"ccb63cf5ce165c9de9d967fa3d2320be"
	],
	"webui": true,
	"admin": true,
	"conn_limit_type": 0,
	"conn_limit": 0,
	"channel_min": 0,
	"channel_max": 0,
	"channel_tag_exclude": false,
	"channel_tag": [
	],
	"comment": "New entry",
	"wizard": false
}
EOF

#Creating epg config file
echo "Creating epg config file"
mkdir -p /home/hts/.hts/tvheadend/epggrab
cat > /home/hts/.hts/tvheadend/epggrab/config <<EOF
{
	"channel_rename": false,
	"channel_renumber": false,
	"channel_reicon": false,
	"epgdb_periodicsave": 1,
	"epgdb_saveafterimport": true,
	"cron": "5 6 * * *\n5 10 * * *\n5 18 * * *",
	"ota_initial": true,
	"ota_cron": "# Default config (02:04 and 14:04 everyday)\n4 2 * * *\n4 14 * * *",
	"ota_timeout": 30,
	"modules": {
		"/usr/bin/tv_grab_file": {
			"class": "epggrab_mod_int_xmltv",
			"dn_chnum": 0,
			"name": "XMLTV: tv_grab_file is a simple grabber that can be configured through the addon settings from Kodi",
			"type": "Internal",
			"enabled": false,
			"priority": 3
		},
		"/usr/bin/tv_grab_koala": {
			"class": "epggrab_mod_int_xmltv",
			"dn_chnum": 0,
			"name": "XMLTV: tv_grab_koala - Grabber koala--Movistar+ canales",
			"type": "Internal",
			"enabled": true,
			"priority": 3
		},
		"xmltv": {
			"class": "epggrab_mod_ext_xmltv",
			"dn_chnum": false,
			"name": "XMLTV",
			"type": "External",
			"enabled": false,
			"priority": 3
		},
		"pyepg": {
			"class": "epggrab_mod_ext_pyepg",
			"name": "PyEPG",
			"type": "External",
			"enabled": false,
			"priority": 4
		},
		"opentv-skynz": {
			"class": "epggrab_mod_ota",
			"name": "OpenTV: Sky NZ",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 2
		},
		"opentv-skyit": {
			"class": "epggrab_mod_ota",
			"name": "OpenTV: Sky Italia",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 2
		},
		"opentv-skyuk": {
			"class": "epggrab_mod_ota",
			"name": "OpenTV: Sky UK",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 2
		},
		"opentv-ausat": {
			"class": "epggrab_mod_ota",
			"name": "OpenTV: Ausat",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 2
		},
		"psip": {
			"class": "epggrab_mod_ota",
			"name": "PSIP: ATSC Grabber",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 1
		},
		"Bulsatcom_39E": {
			"class": "epggrab_mod_ota",
			"name": "Bulsatcom: Bula 39E",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 5
		},
		"viasat_baltic": {
			"class": "epggrab_mod_ota",
			"name": "VIASAT: Baltic",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 5
		},
		"nz_freeview": {
			"class": "epggrab_mod_ota",
			"name": "New Zealand: Freeview",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 5
		},
		"uk_freeview": {
			"class": "epggrab_mod_ota",
			"name": "UK: Freeview",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 5
		},
		"uk_freesat": {
			"class": "epggrab_mod_ota",
			"name": "UK: Freesat",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 5
		},
		"eit": {
			"class": "epggrab_mod_ota",
			"name": "EIT: DVB Grabber",
			"type": "Over-the-air",
			"enabled": false,
			"priority": 1
		}
	}
}
EOF

#Creating main config file
echo "Creating main config file"
cat > /home/hts/.hts/tvheadend/config <<EOF
{
	"server_name": "Tvheadend",
	"version": 24,
	"full_version": "4.3-1795~g771dfd6be~bionic",
	"theme_ui": "blue",
	"ui_quicktips": true,
	"uilevel": 0,
	"uilevel_nochange": false,
	"caclient_ui": false,
	"info_area": [
		"login",
		"storage",
		"time"
	],
	"chname_num": true,
	"chname_src": false,
	"date_mask": "",
	"label_formatting": false,
	"language": [
	],
	"epg_compress": true,
	"epg_cutwindow": 300,
	"epg_window": 86400,
	"prefer_picon": false,
	"chiconpath": "file:///home/hts/.hts/tvheadend/picons/vdr/%C.png",
	"chiconscheme": 2,
	"piconpath": "file:///home/hts/.hts/tvheadend/picons/vdr/",
	"piconscheme": 0,
	"http_server_name": "HTS/tvheadend",
	"http_realm_name": "tvheadend",
	"digest": 2,
	"digest_algo": 0,
	"cookie_expires": 7,
	"ticket_expires": 300,
	"proxy": false,
	"hdhomerun_ip": "",
	"local_ip": "",
	"local_port": 0,
	"http_user_agent": "TVHeadend/4.3-1795~g771dfd6be~bionic",
	"iptv_tpool": 2,
	"dscp": -1,
	"descrambler_buffer": 9000,
	"parser_backlog": false,
	"hbbtv": false,
	"tvhtime_update_enabled": false,
	"tvhtime_ntp_enabled": false,
	"tvhtime_tolerance": 5000,
	"satip_rtsp": 0,
	"satip_anonymize": false,
	"satip_noupnp": false,
	"satip_weight": 100,
	"satip_remote_weight": true,
	"satip_descramble": 1,
	"satip_muxcnf": 0,
	"satip_rtptcpsize": 42,
	"satip_nat_rtsp": 0,
	"satip_nat_name_force": false,
	"satip_iptv_sig_level": 220,
	"force_sig_level": 0,
	"satip_dvbs": 0,
	"satip_dvbs2": 0,
	"satip_dvbt": 0,
	"satip_dvbt2": 0,
	"satip_dvbc": 0,
	"satip_dvbc2": 0,
	"satip_atsct": 0,
	"satip_atscc": 0,
	"satip_max_sessions": 0,
	"satip_max_user_connections": 0,
	"satip_rewrite_pmt": false,
	"satip_nom3u": false,
	"satip_notcp_mode": false,
	"satip_restrict_pids_all": false,
	"satip_drop_fe": false
}
EOF

#Fixing folders and files permissions
echo "Fixing folders and files permissions"
chown -R hts:video /home/hts/.hts/tvheadend
find /home/hts/.hts/tvheadend/ -type d -exec chmod 755 {} \;
find /home/hts/.hts/tvheadend/ -type f -exec chmod 600 {} \;



#Starting Tvheadend
echo "Starting Tvheadend, wait for seconds and try ip:9981"
systemctl start tvheadend.service

echo -e "\e[34mYou only have to check in configuration-->dvb inputs for tv adapters and enable tuners and enable and select networks for positition"

else
    echo "You are NOT root, please run script like root. Please use 'sudo ./install-tvheadend-ubuntu.sh'"
fi
