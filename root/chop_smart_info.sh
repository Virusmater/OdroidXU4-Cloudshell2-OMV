#!/bin/bash

SRCPATH1="/usr/share/php/openmediavault/system/storage/smartinformation.inc"
SRCPATH2="/usr/share/openmediavault/engined/rpc/smart.inc"
SRCPATH3="/usr/share/php/openmediavault/system/storage/smarttrait.inc"

function chSrc() {
	
	local SRCPATH=$1;
	
	if [ ${SRCPATH} = ${SRCPATH1} ];
	then
		CMDRE="$(grep "\"-x %s\"" ${SRCPATH} | grep escapeshellarg | wc -l)"
		DIDIT="$(grep "\"-H -i -g all -c -A -f brief -l xerror,error -l xselftest,selftest -l selective -l directory -l devstat -l sataphy %s\"" ${SRCPATH} | grep escapeshellarg | wc -l)"
		OPTION="-x"
	else
		CMDRE="$(grep "\"--xall\"" ${SRCPATH} | wc -l)"
		DIDIT="$(grep "\"-H -i -g all -c -A -f brief -l xerror,error -l xselftest,selftest -l selective -l directory -l devstat -l sataphy\"" ${SRCPATH} | wc -l)"
		OPTION="--xall"

	fi

	if [ "${CMDRE}" -eq "1" ];
	then
		sed -i s/"${OPTION}"/"-H -i -g all -c -A -f brief -l xerror,error -l xselftest,selftest -l selective -l directory -l devstat -l sataphy"/g ${SRCPATH};
		echo "Okay"
	elif [ "${DIDIT}" -eq "1" ];
	then
		echo "Okay. You did it already. You don't need to try it"
	else
		GOTERROR=true
		echo "ERROR : This is a script to fix HDD disconnected from the system, "
		echo "        when you access S.M.A.R.T information."
		echo "        Read me using any text editor and fix it"
	fi
}

chSrc ${SRCPATH1}
chSrc ${SRCPATH2}
chSrc ${SRCPATH3}

if [ ${GOTERROR} ];
then
	echo "You have to see \"Okay\" two times"
	echo "If you got an ERROR even one time, please modify the files by hand"
	echo "1. ${SRCPATH1}"
	echo "2. ${SRCPATH2}"
fi
