#!/bin/bash
# FTP User Manage
# Function: Add Remove List


set -e

FTPSERVICE="/etc/init.d/vsftpd"
FTPUSERFILE="/etc/vsftpd/virtual_user.txt"
FTPUSERDB="/etc/vsftpd/virtual_user.db"
FTPUSERCONF="/etc/vsftpd/vconf/"
FTPROOTDIR="/home/project/ftp/"
FTPMAINUSER="vsftpd"

test -x "${FTPSERVICE}" || exit 0

case "${1}" in 
	add)
		echo -n "AddUser: "
		if [ ! -n "${2}" ]; then
			echo "Error: Empty User"
			exit 0
		fi	
		if [ ! -n "${3}" ]; then
			echo "Error: Empty Password"
			exit 0
		fi	
		checkuser=`sed -n '/^'${2}'$/=' ${FTPUSERFILE}`
		checklist=($checkuser)
		if [ ${#checklist[*]} -gt 0 ]; then
			echo "${2} existed!"
			exit 0
		fi
		echo "${2}"

		echo "${2}" >> ${FTPUSERFILE}
		echo "${3}" >> ${FTPUSERFILE}
		
		## make dir
		if [ ! -n "${4}" ]; then
			userdir="${FTPROOTDIR}${2}"
		else
			userdir="${FTPROOTDIR}${4}"
		fi
		echo "${userdir}"
		if [ ! -d "${userdir}" ]; then
			mkdir -p ${userdir}
		fi
		chown ${FTPMAINUSER}.${FTPMAINUSER} ${userdir} 
		chmod 555 ${userdir}
		if [ ! -d "${userdir}/wwwroot" ]; then
			mkdir -m 755 ${userdir}/wwwroot
			chown  ${FTPMAINUSER}.${FTPMAINUSER} ${userdir}/wwwroot
		fi

		## user config
		userconf="${FTPUSERCONF}${2}"
		touch ${userconf}
		echo "local_root=${userdir}" >> ${userconf}
		echo "write_enable=YES" >> ${userconf}
		echo "anon_world_readable_only=NO" >> ${userconf}
		echo "anon_upload_enable=YES" >> ${userconf}
		echo "anon_mkdir_write_enable=YES" >> ${userconf}
		echo "anon_other_write_enable=YES" >> ${userconf}


		echo "Please check the dir permission; Remove write permission of the ftprootdir"
		echo ""
		echo "=Add End="
		;;
	remove)
		echo -n "RemoveUser: "
		if [ ! -n "${2}" ]; then
			echo "Error: Empty User"
			exit 0
		fi
		userline=`sed -n '/^'${2}'$/=' ${FTPUSERFILE}`
		linelist=($userline)
		if [ ${#linelist[*]} == 0 ]; then
			echo "${2} not found!"
			exit 0
		fi
		for itemline in ${linelist[*]}; do
			if [ `expr ${itemline} % 2` != 1 ]; then
				continue
			fi
			sed -n ''${itemline}'p' ${FTPUSERFILE}
			sed -i ''${itemline}'s/^.*$//' ${FTPUSERFILE}
			nextline=`expr ${itemline} + 1`
			sed -i ''${nextline}'s/^.*$//' ${FTPUSERFILE}
		done
		sed -i '/^$/d' ${FTPUSERFILE}
		rm -f ${FTPUSERCONF}${2}
		echo ""
		echo "=Delete End="
		;;
	list)
		userlist=`cat ${FTPUSERFILE}`
		userlist=(${userlist})
		if [ ${#userlist[*]} == 0 ]; then
			echo "Empty User!"
			exit 0
		fi
		i=0
		for useritem in ${userlist[*]}; do
			if [ `expr $i % 2` == 0 ]; then
				echo -n ${useritem}":"
				head -1 ${FTPUSERCONF}${useritem}|awk -F '=' '{print $2}'
			fi
			i=`expr $i + 1`
		done
		exit 0
		;;
	help)
		echo "Command: [add]"
		echo "Add User"
		echo ""
		echo "Command: [remove]"
		echo "Delete User"
		echo ""
		echo "Command: [list]"
		echo "List All Users"
		exit 0
		;;
	*)
		echo "error action"
		exit 0
		;;
esac

## generate auth db 
rm -f ${FTPUSERDB}
/usr/bin/db4.8_load -T -t hash -f ${FTPUSERFILE} ${FTPUSERDB} 

${FTPSERVICE} restart

exit 0
