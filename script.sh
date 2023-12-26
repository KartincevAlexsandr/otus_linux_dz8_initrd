#! /usr/bin/env bash

cat << EOF > /etc/sysconfig/watchlog
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF

cat << EOF > /opt/watchlog.sh
#!/bin/bash

WORD=\$1
LOG=\$2
DATE=`date`

if grep \$WORD \$LOG &> /dev/null
then
logger "$\DATE: I found word, Master!"
else
exit 0
fi
EOF

chmod +x /opt/watchlog.sh

cat << EOF > /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG

EOF

cat << EOF > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target

EOF

systemctl start watchlog.timer

yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y


cat << EOF > /etc/sysconfig/spawn-fcgi
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s \$SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
EOF

cat << EOF > /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl start spawn-fcgi

sed '/Environment=LANG=C/a\EnvironmentFile=/etc/sysconfig/httpd-%I'  /usr/lib/systemd/system/httpd.service > /usr/lib/systemd/system/httpd.service

echo 'OPTIONS=-f conf/first.conf'  > /etc/sysconfig/httpd-first
echo 'OPTIONS=-f conf/second.conf'  > /etc/sysconfig/httpd-second

cat /etc/httpd/conf/httpd.conf > /etc/httpd/conf/first.conf
cat /etc/httpd/conf/httpd.conf > /etc/httpd/conf/second.conf

sed '/Listen 80/a\PidFile /var/run/httpd-second.pid'  /etc/httpd/conf/second.conf > /etc/httpd/conf/second.conf2
sed 's/Listen 80/Listen 8080/'  /etc/httpd/conf/second.conf2 > /etc/httpd/conf/second.conf


systemctl start httpd@first
systemctl start httpd@second
