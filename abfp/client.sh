#!/bin/bash

PORT=2021
INPUT_PATH="entrada_cliente/"

IP_CLIENT="127.0.0.1"

if [ "$1" == "" ]; then
	IP_SERVER="127.0.0.1"
else
	IP_SERVER="$1"
fi

echo "Cliente de ABFP"

echo "(2) Sending Headers to $IP_SERVER"

echo "ABFP $IP_CLIENT" | nc -q 1 $IP_SERVER $PORT

echo "(3) Listening $PORT"

RESPONSE=`nc -l -p $PORT`
if [ "$RESPONSE" != "OK_CONN" ]; then
	echo "No se ha podido conectar con el servidor"
	exit 1
fi

echo "(6) HANDSHAKE"

sleep 1
echo "THIS_IS_MY_CLASSROOM" | nc -q 1 $IP_SERVER $PORT

echo "(7a) LISTEN"
RESPONSE=`nc -l -p $PORT`
if [ "$RESPONSE" != "YES_IT_IS" ]; then
	echo "ERROR: Handshake incorrecto"
	exit 1
fi

#ENVIAR NUM ARCHIVOS

echo "(7b) SENDING NUM_FILES"
sleep 1

NUM_FILES=`ls $INPUT_PATH | wc -w`

echo "NUM_FILES $NUM_FILES" | nc -q 1 $IP_SERVER $PORT

echo "(7c) LISTEN"
RESPONSE=`nc -l -p $PORT`

if [ "$RESPONSE" != "OK_NUM_FILES" ]; then
	echo "ERROR: Prefijo NUM_FILES incorrecto"
	exit 2
fi

#BUCLE


for FILE_NAME in `ls $INPUT_PATH`; do

	FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

	echo "(10) SENDING FILE_NAME"
	sleep 1
	echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc -q 1 $IP_SERVER $PORT

	echo "(11) LISTEN"
	RESPONSE=`nc -l -p $PORT`

	if [ "$RESPONSE" != "OK_FILE_NAME" ]; then
		echo "ERROR: envío de archivo fallido"

		exit 2
	fi

	sleep 1
	cat $INPUT_PATH$FILE_NAME | nc -q 1 $IP_SERVER $PORT
done




exit 0
