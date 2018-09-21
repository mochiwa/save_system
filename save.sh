#!/bin/bash

##############################################################
#			Describe										 #
# Script Bash which make an incremantal save every day , and #
# when we are on first days of new month, it make a complet  #
# save of /home and sys										 #
#															 #
#															 #
# Author : Chiappelloni nicolas.							 #
# Date : September 2018.									 #
##############################################################


##############################################################
#						Functions							 #
##############################################################
main_print()
{
	clear
	echo "#################################################"
	echo "#		Save Manager	 		#"		
	echo "#################################################"
	echo  " "`date +%A" "%d-%B-%Y`"              "`date +%r`
	echo "-------------------------------------------------"
}

write_log()
{
	log_file=$extern_media/save_manager.log
	arguments=""
	for arg in "$@"
	do
		arguments=$arguments" "$arg
	done 
	echo `date +%d-%B-%Y-%r`": " $arguments >> $log_file
}

##############################################################
#						Variables							 #
##############################################################
extern_media=/media/backup_media
sys_backup=$extern_media/system
home_backup=$extern_media/users

to_save_sys="/etc /usr/local /opt"
to_save_user=/home

exclude=$extern_media/.exclude

actual_month=`date +%Y`/`date +%B`
completed_month=`date --date="1 month ago" +%Y`/`date --date="1 month ago" +%B`
count=0
##############################################################
#						Main								 #
##############################################################

write_log "-------SCRIPT_LAUNCHED--------"

#--procedure d'initialisation--#
if mountpoint -q $extern_media ; then
	###--USERS_DIR--###
	if ! [[ -d $home_backup ]]; then
		mkdir $home_backup
		write_log "dir" $home_backup "CREATED"
	fi

	if ! [[ -d $home_backup/`date +%Y` ]]; then
		mkdir $home_backup/`date +%Y`	
		write_log "dir" $home_backup/`date +%Y` "CREATED"
	fi

	if ! [[ -d $home_backup/$actual_month ]]; then
		mkdir $home_backup/$actual_month	
		write_log "dir" $home_backup/$actual_month "CREATED"
	fi

	if ! [[ -d $home_backup/`date --date="1 month ago" +%Y` ]]; then
		mkdir $home_backup/`date --date="1 month ago" +%Y`	
		write_log "dir" $home_backup/`date --date="1 month ago" +%Y` "CREATED"
	fi

	if ! [[ -d $home_backup/$completed_month ]]; then
		mkdir $home_backup/$completed_month	
		write_log "dir" $home_backup/$completed_month "CREATED"
	fi

	###--SYSTEM_DIR--###
	if ! [[ -d $sys_backup ]]; then
		mkdir $sys_backup
		write_log "dir" $sys_backup "CREATED"
	fi

	if ! [[ -d $sys_backup/`date +%Y` ]]; then
		mkdir $sys_backup/`date +%Y`	
		write_log "dir" $sys_backup/`date +%Y` "CREATED"
	fi

	if ! [[ -d $sys_backup/$actual_month ]]; then
		mkdir $sys_backup/$actual_month 	
		write_log "dir" $sys_backup//$actual_month  "CREATED"
	fi

	if ! [[ -d $sys_backup/`date --date="1 month ago" +%Y` ]]; then
		mkdir $sys_backup/`date --date="1 month ago" +%Y`	
		write_log "dir" $sys_backup/`date --date="1 month ago" +%Y` "CREATED"
	fi

	if ! [[ -d $sys_backup/$completed_month  ]]; then
		mkdir $sys_backup/$completed_month 	
		write_log "dir" $sys_backup/$completed_month  "CREATED"
	fi
else
	echo "No external media found"
	echo " -Media mounted ?"
	echo " -path :"$extern_media" is correct ?"
	exit -1
fi



if ! [[ `ls $sys_backup/$actual_month` ]]; then #A new month begins ?

	if [[ -e $sys_backup/incremental.snar ]]; then # The incremental.snar exist ?
		mv $sys_backup/incremental.snar $sys_backup/incremental.snar.backup # then make a backup of it
		write_log "RENAME" $sys_backup/incremental.snar "to incremental.snar.backup" 
	fi

	tar_file=$sys_backup/$completed_month/complete-`date +%B-%Y`.tar.bz2
	while [[ -e $tar_file ]]; do # Don't erase a existing save !
		tar_file=$sys_backup/$completed_month/complete-$count-`date +%B-%Y`.tar.bz2
		count=$(($count+1))
	done

	tar --listed-incremental=$sys_backup/incremental.snar -X $exclude -cvjf $tar_file $to_save_sys #Make system save
	
	
	if ! tar -tjf $tar_file &> /dev/null ; then # The tar.bz contains some error ?
		write_log "SAV-COMP" $tar_file "ECHEC"
		mv $tar_file /root/.local/share/Trash/ # then move tar in trash 
		write_log "Trash" $tar_file " due to previous error"

		if [[ -e $sys_backup/incremental.snar ]]; then # The new incremental.snar exist ?
			rm $sys_backup/incremental.snar # then delete it
			write_log "DEL" $sys_backup/incremental.snar " due to previous error"
			mv $sys_backup/incremental.snar.backup $sys_backup/incremental.snar # replace the backup created previously
			write_log "RENAME" $sys_backup/incremental.snar.backup "to incremental.snar"
		fi
	else
		write_log "SAV-COMP" $tar_file "CREATED"
		if ls $sys_backup/$completed_month/incr-* > /dev/null 2>&1 ; then # Some incr save in dir ?
			rm $sys_backup/$completed_month/incr-* # then rm they
			write_log "DEL" $sys_backup/$completed_month/ "Incrementals"
		fi
		
		if [[ -e $sys_backup/incremental.snar.backup ]]; then # The old incremental.snar exist ?
			rm $sys_backup/incremental.snar.backup # del it
			write_log "DEL" $sys_backup/incremental.snar.backup
		fi
	fi
	

	
	if [[ -e $home_backup/incremental.snar ]]; then
		mv $home_backup/incremental.snar $home_backup/incremental.snar.backup
		write_log "RENAME" $home_backup/incremental.snar "to incremental.snar.backup"
	fi
	count=0
	tar_file=$home_backup/$completed_month/complete-`date +%B-%Y`.tar.bz2 
	while [[ -e $tar_file ]]; do # Don't erase a existing save !
		tar_file=$home_backup/$completed_month/complete-$count-`date +%B-%Y`.tar.bz2
		count=$(($count+1))
	done

	tar --listed-incremental=$home_backup/incremental.snar -X $exclude -cvjf $tar_file $to_save_user
	
	if ! tar -tjf $tar_file &> /dev/null ; then # The tar.bz contains some error ?
		write_log "SAV-COMP" $tar_file "ECHEC"
		mv $tar_file /root/.local/share/Trash/ # then move tar in trash 
		write_log "Trash" $tar_file " due to previous error"

		if [[ -e  $home_backup/incremental.snar ]]; then # The new incremental.snar exist ?
			rm $home_backup/incremental.snar # then delete it
			write_log "DEL" $home_backup/incremental.snar " due to previous error"
			mv $home_backup/incremental.snar.backup $home_backup/incremental.snar # replace the backup created previously
			write_log "RENAME" $home_backup/incremental.snar.backup "to incremental.snar"
		fi
	else
		write_log "SAV-COMP" $tar_file "CREATED"
		if ls $home_backup/$completed_month/incr-* > /dev/null 2>&1 ; then # Some incr save in dir ?
			rm $home_backup/$completed_month/incr-* # then rm they
			write_log "DEL" $home_backup/$completed_month/ "Incrementals"
		fi
		
		if [[ -e $home_backup/incremental.snar.backup ]]; then # The old incremental.snar exist ?
			rm $home_backup/incremental.snar.backup # del it
			write_log "DEL" $home_backup/incremental.snar.backup
		fi
	fi
fi

count=0
tar_file=$sys_backup/$actual_month/incr-`date +%B-%d-%Y`.tar.bz2 
#while [[ -e $tar_file ]]; do
#	tar_file=$sys_backup/$actual_month/incr-$count-`date +%B-%d-%Y`.tar.bz2
#	count=$(($count+1))
#done
if ! [[ -e $tar_file ]]; then
	tar --listed-incremental=$sys_backup/incremental.snar -X $exclude -cvjf $tar_file $to_save_sys
	write_log "SAV-INCR" $tar_file "CREATED"
fi


count=0
tar_file=$home_backup/$actual_month/incr-`date +%B-%d-%Y`.tar.bz2 
#while [[ -e $tar_file ]]; do
#	tar_file=$home_backup/$actual_month/incr-$count-`date +%B-%d-%Y`.$count.tar.bz2 
#	count=$(($count+1))
#done
if ! [[ -e $tar_file ]]; then
	tar --listed-incremental=$home_backup/incremental.snar -X $exclude -cvjf $tar_file $to_save_user
	write_log "SAV-INCR" $tar_file "CREATED"
fi
