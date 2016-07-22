#!/bin/bash

while read DOMINIO; do
	whois $DOMINIO | grep -v ^% > /home/luiz/Dropbox/UFRJ/banco-de-dados_2016-1/dominiosGov/scripts/whois/whois-$DOMINIO
done < dominios.txt