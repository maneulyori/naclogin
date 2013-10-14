#!/bin/bash
#########################################
# Cisco Guest Access login script	#
# By zhongfu				#
# --------------------------------------#
# Logs in user to Cisco Guest Access	#
# protected wireless networks.		#
#########################################

## Configuration section
# username
username=""
# password
password=""

## Script
logger -t "ciscogalogin" -i -s "starting authentication"
# get address for authentication
authredurl=$(curl -k -s http://www.google.com | grep -o URL=.*\</HEAD | sed -e 's#URL=##' -e "s#'></HEAD##")
if [ "$authredurl" != "" ]; then
	domain=$(echo $authredurl | sed -e 's#https://##' -e 's#/login.*##')

	# hidden form values
	buttonClicked="4"
	err_flag="0"
	err_msg=""
	info_flag="0"
	info_msg=""
	redirect_url="http://www.google.com/"
	fullstring="username=$username&password=$password&buttonClicked=$buttonClicked&err_flag=$err_flag&info_flag=$info_flag&info_msg=$info_msg&redirect_url=$redirect_url"

	# sending authentication
	status=$(curl -k -s --max-time 60 --connect-timeout 30 -A "Mozilla/4.0" -d "$fullstring" https://$domain/login.html)
	if [[ $(echo $status | grep "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=http://www.google.com/\">") ]]; then
		logger -t "ciscogalogin'" -i -s "logged in"
		exit 0
	else
		logger -t "ciscogalogin'" -i -s "login failed, did you configure the settings correctly?"
		exit 2
	fi
else
	logger -t "ciscogalogin'" -i -s "could not complete, are you connected to WiFi or logged in already?"
	exit 1
fi
exit 0
