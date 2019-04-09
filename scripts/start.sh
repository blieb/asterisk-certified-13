#!/bin/sh -x
if [ -f '/var/run/fail2ban/fail2ban.sock' ]; then
	rm /var/run/fail2ban/fail2ban.sock
fi
service fail2ban restart
/usr/sbin/asterisk -cvvvvvvv
