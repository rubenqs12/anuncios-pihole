#!/bin/bash

################### NormandyEPG #####################
# 		Actualización de la EPG de TVH y Picons
##################################################### 

# Definición de variables
NOMBRE_APP="NormandyEPG"
CARPETA_TVH="/"
carpeta_channel="$CARPETA_TVH/channel/config/*"
carpeta_tag="$CARPETA_TVH/channel/tag/*"

	cd $CARPETA_TVH

	rm -f config
	rm -f /storage/.kodi/addons/service.tvheadend42/bin/tv_grab_NormandyEPG
	rm -f /storage/.kodi/addons/service.tvheadend42/bin/tv_grab_NormandyEPG2
	rm -f settings.xml

	rm -rf bouquet/
#		rm -rf channel/
#		rm -rf input/
	rm -rf epggrab/
	rm -rf input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8/
	
	rm -rf input/iptv/networks/e10769958a53c91a6217d66c755ee746/ # red iptv mega
	
	rm -rf service_mapper/
	rm -rf xmltv/

	rm -f "channel/config/06001a78f3cd3eb64fc85eb707266a99" #canal 85 mega hd
	
	rm -f 
	
	if [ "$1" != "ALL" ];then
		# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca
		for fichero in $carpeta_channel $carpeta_tag
		do 
		   if [ -f "$fichero" ]; then  
			 ultima=$(tail -n 1 $fichero)
			 if [[ "$ultima" = $NOMBRE_APP ]]; then
			   rm -f $fichero 
			 fi
		   fi
		done
	else
		# Borramos todos los canales, tags y redes
		rm -rf $carpeta_channel
		rm -rf $carpeta_tag
		rm -rf input/
	fi
	
#	cd /storage/
#	
#	wget normandy.es/files/normandyepg.tar
#	
#	systemctl stop tvheadend.service
#	
#	tar xpf normandyepg.tar
#	
#	rm -rf normandyepg.tar
#	
#	systemctl start tvheadend.service
#
