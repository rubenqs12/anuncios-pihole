#!/bin/bash

if [ $(id -u) = "0" ]; then
    echo "You are root, starting installation"

#install dependencys
apt-get install -y apt-utils dialog usbutils gcc g++ wget build-essential subversion libpcsclite1 libpcsclite-dev libssl-dev cmake make libusb-1.0-0-dev nano

#get oscam source
cd /usr/src/
svn checkout http://www.streamboard.tv/svn/oscam/trunk oscam-svn

# Configure, build and install oscam
cd oscam-svn

#Configure options
./config.sh --enable WEBIF

#Compile Oscam
make OSCAM_BIN=./build/oscam

#Copy Oscam to destination and set permissions
cp /usr/src/oscam-svn/build/oscam /usr/local/bin/oscam
chmod 755 /usr/local/bin/oscam

#Copy example config file 

cat > /usr/local/etc/oscam.conf <<EOF
[global]
logfile                       = /var/log/oscam.log
nice                          = -1
usrfile                       = /var/log/oscamuser.log
cwlogdir                      = /var/log/cw
lb_nbest_readers              = 4
lb_nfb_readers                = 8
lb_min_ecmcount               = 3
lb_max_ecmcount               = 250
lb_max_readers                = 9999
disablecrccws_only_for        = 0500:050F00;09C4:000000;098C:000000

[cache]

[dvbapi]
enabled                       = 1
au                            = 1
pmt_mode                      = 4
listen_port                   = 9000
user                          = tvheadend
boxtype                       = pc

[monitor]
port                          = 988
aulow                         = 120
monlevel                      = 1
hideclient_to                 = 15

[webif]
httpport                      = 8888
httpuser                      = oscam
httppwd                       = oscam
httpallowed                   = 0.0.0.0-255.255.255.255
aulow                         = 120
hideclient_to                 = 15
EOF

cat > /usr/local/etc/oscam.server <<EOF
[reader]
label                         = Linea1
protocol                      = cccam
device                        = DIRECCIONSERVIDOR,PUERTO
user                          = USUARIO
password                      = CONTRASEÑA
inactivitytimeout             = 30
group                         = 1
cccversion                    = 2.1.2
cccmaxhops                    = 1
ccckeepalive                  = 1

[reader]
label                         = Linea2
protocol                      = cccam
device                        = DIRECCIONSERVIDOR,PUERTO
user                          = USUARIO
password                      = CONTRASEÑA
inactivitytimeout             = 30
group                         = 1
cccversion                    = 2.1.2
cccmaxhops                    = 1
ccckeepalive                  = 1

[reader]
label                         = Linea3
protocol                      = cccam
device                        = DIRECCIONSERVIDOR,PUERTO
user                          = USUARIO
password                      = CONTRASEÑA
inactivitytimeout             = 30
group                         = 1
cccversion                    = 2.1.2
cccmaxhops                    = 1
ccckeepalive                  = 1

[reader]
label                         = Linea4
protocol                      = cccam
device                        = DIRECCIONSERVIDOR,PUERTO
user                          = USUARIO
password                      = CONTRASEÑA
inactivitytimeout             = 30
group                         = 1
cccversion                    = 2.1.2
cccmaxhops                    = 1
ccckeepalive                  = 1
EOF


cat > /usr/local/etc/oscam.user <<EOF
[account]
user                          = tvheadend
monlevel                      = 4
group                         = 1
max_connections               = 99
EOF


cat > /etc/systemd/system/oscam.service <<EOF
[Unit]
Description=OScam
After=network.target
Requires=network.target

[Service]
Type=forking
PIDFile=/var/run/oscam.pid
ExecStart=/usr/local/bin/oscam -b -B /var/run/oscam.pid
ExecStop=/usr/bin/rm /var/run/oscam.pid
TimeoutStopSec=1
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable oscam.service
systemctl start oscam.service

echo -e "\e[34mYou only have go to ip:8888 oscam:oscam and irrigate flowers, don't forget deactivate translate in web browser"

else
    echo "You are NOT root, please run script like root. Please use 'sudo ./install-oscam-ubuntu.sh'"
fi
