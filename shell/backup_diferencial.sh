#!/bin/bash

echo " "
# criação da pasta
criar_pasta () {
DATA=`date +%Y%m%d`
DIR_BACKUP=/backup
VERI_DIR_BACKUP=`ls -l $DIR_BACKUP/backup-dif-$DATA`

if [ $? = 2 ]; then

mkdir -p $DIR_BACKUP/backup-dif-$DATA
chmod 0777 $DIR_BACKUP/backup-dif-$DATA
echo "Criado diretótio $DIR_BACKUP/backup-dif-$DATA"

else

echo " Diretório $DIR_BACKUP/backup-dif-$DATA existe"

fi

}

dadosdif() {

SRCDIR="/home/s3b4h/teste" #diretórios que serão feitos backup

DSTDIR=$DIR_BACKUP/backup-dif-$DATA #diretório de destino do backup

DATA_BKP=`date +%Y%m%d`

TIME_FIND=-1440 #+xx busca arquivos criados existentes a xx minutos (arquivos que t                                                                                        enham mais de xx minutos)
#-xx arquivos que tenham sido criados nos últimos xx minutos
#12 horas = 720 minutos 8horas 480 minutos

TIME_DEL=+7 # dias em que permanecera o backup diferencial armazenado

#criar o arquivo dif-data.tar no diretório de destino

ARQ=$DSTDIR/$HOSTNAME-dif-$DATA_BKP.tar

#data de inicio backup

DATAIN=`date +%c`

echo " Data de inicio: $DATAIN"

}

backupdif(){

sync

find $SRCDIR -type f -cmin $TIME_FIND ! -path "/home/s3b4h/teste/regulacao/*" ! -path "/home/s3b4h/teste/vendor/*" -exec tar -rvf $ARQ {} ";" # adicionar
# ! -path os diretorios que não entrarão no backup

if [ $? -eq 0 ] ; then

echo "-------------------------------------"
echo "Backup Diferencial concluído com sucesso"

DATAFIN=`date +%c`

echo "Data de termino: $DATAFIN"
echo "Backup realizado com sucesso" >> /var/log/backup_diferencial.log
echo "Criado pelo usuário: $USER" >> /var/log/backup_diferencial.log
echo "INICIO: $DATAIN" >> /var/log/backup_diferencial.log
echo "FIM: $DATAFIN" >> /var/log/backup_diferencial.log
echo "------------------------------------------------" >> /var/log/backup_difer                                                                                        encial.log
echo " "
echo "Log gerado em /var/log/backup_diferencial.log"

else

echo "ERRO! Backup Diferencial $DATAIN" >> /var/log/backup_diferencial.log

fi

}

procuraedestroidif(){

#apagando arquivos mais antigos (a 7 dias que existe (-cmin +2)

find /backup/ -name "backup-dif-*" -ctime $TIME_DEL -exec rm -rf {} ";"

if [ $? -eq 0 ] ; then

echo "Arquivo de backup mais antigo eliminado com sucesso!"

else

echo "Erro durante a busca e destruição do backup antigo!"

fi

}

compactar () {

echo "Script de compactação"

DATAIN=`date +%c`

echo "Data de inicio: $DATAIN"

gzip -9 $DSTDIR/*.tar

echo "Compactação concluída"

DATAFIN=`date +%c`

echo "Data de termino: $DATAFIN"
echo "Compactação concluída"
echo "INICIO: $DATAIN" >> /var/log/backup_compactacao.log
echo "FIM: $DATAFIN" >> /var/log/backup_compactacao.log
echo "Realizado pelo usuário: $USER" >> /var/log/backup_compactacao.log
echo "-----------------------------------" >> /var/log/backup_compactacao.log
echo "Log gerado em /var/log/backup_compactacao.log"

}

criar_pasta

dadosdif

backupdif

procuraedestroidif

sleep 2

compactar

exit 0
