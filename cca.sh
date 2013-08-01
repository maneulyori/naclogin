#!/bin/bash
#########################################
# Cisco NAC login script		#
# By zhongfu				#
# --------------------------------------#
# Logs in user to Cisco NAC protected   #
# wireless networks.			#
#########################################

## Configuration section
# NAC username
username=""
# NAC password
password=""
# NAC auth provider
provider="LDAP"

## Script
logger -t "naclogin" -i -s "starting authentication"
# get address for authentication
authredurl=$(curl -k -s http://www.google.com | grep -o URL=.*\</head | sed -e 's#URL=##' -e "s#'></head##")
if [ "$authredurl" != "" ]; then
	domain=$(echo $authredurl | sed -e 's#https://##' -e 's#/auth.*##')
	cm=$(echo $authredurl | sed -e 's#https://[A-Za-z0-9./%_]*##' -e 's#?cm=##' -e 's#&uri=[A-Za-z0-9./%]*##')
	s3=$(curl -k -s $authredurl | grep s3 -A 1 | tail -n 1 | sed -e 's| *value="||' -e 's|" />||')

	# hidden form values
	guestusernamelabel="Guest ID"
	guestpasswordlabel="Password"
	passwordlabel="Password"
	usernamelabel="Computing ID"
	registerguest="NO"
	compact="false"
	pageid="-1"
	index="7"
	pm=""
	session=$s3
	uri="http://www.google.com/"
	reqfrom="perfigo_login.jsp"
	cm=""
	remove_old="1"

	fullstring="username=$username&password=$password&provider=$provider&guestUserNameLabel=$guestusernamelabel&guestPasswordLabel=$guestpasswordlabel&passwordLabel=$passwordlabel&userNameLabel=$usernamelabel&registerGuest=$registerguest&compact=$compact&pageid=$pageid&index=$index&pm=$pm&session=$session&userip=&cm=$cm&uri=$uri&reqFrom=$reqfrom&remove_old=$remove_old"

	# sending authentication
	status=$(curl -k -s --max-time 60 --connect-timeout 30 -A "Mozilla/4.0" -d "$fullstring" https://$domain/auth/perfigo_cm_validate.jsp)
	if [[ $(echo $status | grep "<META http-equiv='refresh' content='4;URL=http://www.google.com/'>") ]]; then
		logger -t "naclogin" -i -s "logged in"
		exit 0
	else
		logger -t "naclogin" -i -s "login failed, did you configure the settings correctly?"
		exit 2
	fi
else
	logger -t "naclogin" -i -s "could not complete, are you connected to WiFi or logged in already?"
	exit 1
fi
exit 0
