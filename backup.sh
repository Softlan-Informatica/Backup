#!/bin/bash
clear
#===========================================================================+
#Autor      : Vitor e Erico                                                 |
#Data       : 08/03/2019                                                    |
#Versão     : 2.0                                                           |
#Licença    : GPLv2                                                         |
#Requisito  : GNU-bash                                                      |
#Finalidade : Backup                                                        |
#===========================================================================+
#
#================================ </ VARIAVEIS > ============================
#Diretorio de destino do Backup
DIRBKP="/backupext"
DIRBKP1="/backupext1"
# Arquivo de log do Backup
LOG="/opt/bkplog"
ARQLOG="log-backup.txt"
# Diretorios selecionados para Backup
DIRS="/dados "
#Email destino
DEST="backupmonitoringsoftlan@gmail.com"
#================================== </FUNCOES> ==============================
  function envia_email()
  {
  echo "$(tail -n 23 $LOG/$ARQLOG)" | mail -v -s "Alerta de Backup NOME-CLIENTE" $DEST;

  }
  function testedf()
  {       df -v
  }
  ESPACO=$(testedf)

#================================= </ INICIO > ==============================
echo $DIRS
echo $LOG
echo $DATA
#Localiza os HDDs
HD1=`blkid -U B781-11F8`
HD2=`blkid -U B0E3-1CA7`
#Busca o ponto de montagen dos HDDs
DHD1=`find /dev/disk/by-uuid/* |grep B781-11F8`
DHD2=`find /dev/disk/by-uuid/* |grep B0E3-1CA7`

echo $HD1
echo $HD2
echo $DHD1
echo $DHD2
echo SERVERNAME=$(hostname)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
if [ -d "$DIRBKP" ] ;
   then
   echo
else
   mkdir "$DIRBKP"
fi

if [ -d "$DIRBKP1" ] ;
     then
     echo
else
     mkdir "$DIRBKP1"
fi

if [ -d "$LOG" ] ;
     then
     echo "$LOG"
else
     mkdir "$LOG"
     chmod 777 "$LOG"
fi

#----------------------------------------------------------------------------

echo " -----------------BACKUP--------------------------" >> "$LOG/$ARQLOG"
echo SERVERNAME=$(hostname)>> "$LOG/$ARQLOG"
echo "INICIO BACKUP - $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "HD1 CONECTADO EM: $HD1  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "HD2 CONECTADO EM: $HD2  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "$DHD1  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "$DHD2  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "$LOG/$ARQLOG - $(date '+%F %T')" >> "$LOG/$ARQLOG"

#----------------------------------------------------------------------------

if test -z $DHD1
then
    echo "HD1 NAO ESTA NA USB - $(date '+%F %T')" >> "$LOG/$ARQLOG"
else
    mount $DHD1 $DIRBKP
    sleep 2
    MHD1=`mount|grep $DIRBKP `
    echo "HD1 MONTADO - $MHD1 - $(date '+%F %T')" >> "$LOG/$ARQLOG"
    echo "INICIO COMANDO RSYSC  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
    rsync -HEXAxuva $DIRS $DIRBKP 2>/dev/null
fi
if test -z $DHD2
then
    echo "HD2 NAO ESTA NA USB - $(date '+%F %T')" >> "$LOG/$ARQLOG"
else
     mount $DHD2 $DIRBKP1
    sleep 2
    MHD2=`mount|grep $DIRBKP1 `
    echo "HD2 MONTADO - $MHD2 - $(date '+%F %T')" >> "$LOG/$ARQLOG"
    echo "INICIO COMANDO RSYSC  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
    rsync -HEXAxuva $DIRS $DIRBKP 2>/dev/null
fi

#----------------------------------------------------------------------------
# FINALIZANDO SCRIPT

#
echo "ESPACO EM DISCO: $ESPACO" >> "$LOG/$ARQLOG"
umount /backupext
umount /backupext1
sleep 10
echo "DESMONTANDO VOLUME  - $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "FIM DE BACKUP -  $(date '+%F %T')" >> "$LOG/$ARQLOG"
echo "-----------------------------------------------" >> "$LOG/$ARQLOG"
sleep 10
envia_email
exit
