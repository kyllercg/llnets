#!/bin/bash

if [ "$#" -ne "2" ]
then
	echo "usage: rrbb.sh n output_file"
	exit 1
fi

n=$1
outfile=$2

TEMPLATES="${HOME}/src/lsi.upc.edu/llnets/templates"

HEADER="${TEMPLATES}/RRBB.header"
PL="${TEMPLATES}/RRBB.pl"
TR="${TEMPLATES}/RRBB.tr"
TR2PL="${TEMPLATES}/RRBB.tr2pl"
PL2TR="${TEMPLATES}/RRBB.pl2tr"

tmp1="_tmp.1"
tmp2="_tmp.2"

cont=0
altura=320

rm -f ${tmp1} ${tmp2}

cat ${HEADER} > ${outfile}

echo "% Generated with '$0 $@' in `date`" >> ${outfile}
echo "% `uname -a`" >> ${outfile}

echo "% --------- Places ---------" >> ${outfile}
echo "PL" >> ${outfile}

while [ "$cont" -lt "$n" ]
do
	next=$(($cont + 1))

	if [ "$next" -eq "$n" ]
	then
		next=0
	fi

	sed "s/I/${cont}/g" ${PL} > ${tmp1}
	sed "s/J/${next}/g" ${tmp1} > ${tmp2}

	sed "s/+60/$(($cont * $altura + 60))/g" ${tmp2} > ${tmp1}
	sed "s/+220/$(($cont * $altura + 220))/g" ${tmp1} > ${tmp2}
	sed "s/+300/$(($cont * $altura + 300))/g" ${tmp2} > ${tmp1}
	sed "s/+380/$(($cont * $altura + 380))/g" ${tmp1} > ${tmp2}

	sed "s/\(\"w2\".*\)$/\1M1/g"  ${tmp2} > ${tmp1}
	sed "s/\(\"we2\".*\)$/\1M1/g"  ${tmp1} > ${tmp2}

	if [ "$cont" -ne "2" ]
	then
		cp  ${tmp2}  ${tmp1}
		sed "s/\(\"wne${cont}\".*\)$/\1M1/g"  ${tmp1} > ${tmp2}
	fi

	if [ "$cont" -ne "0" ]
	then
		cp  ${tmp2}  ${tmp1}
		sed "s/\(\"rne${cont}\".*\)$/\1M1/g"  ${tmp1} > ${tmp2}
	fi

	sed "s/\(\"PR0\".*\)$/\1M1/g"  ${tmp2} > ${tmp1}
	sed "s/\(\"re0\".*\)$/\1M1/g"  ${tmp1} > ${tmp2}


	cont=$(($cont + 1))

	cat ${tmp2} >> ${outfile}
done

rm -f ${tmp1} ${tmp2}
cont=0

echo "% --------- Transitions ---------" >> ${outfile}
echo "TR" >> ${outfile}

while [ "$cont" -lt "$n" ]
do
	next=$(($cont + 1))

	if [ "$next" -eq "$n" ]
	then
		next=0
	fi

	sed "s/I/${cont}/g" ${TR} > ${tmp1}
	sed "s/J/${next}/g" ${tmp1} > ${tmp2}

	sed "s/+140/$(($cont * $altura + 140))/g" ${tmp2} > ${tmp1}
	sed "s/+300/$(($cont * $altura + 300))/g" ${tmp1} > ${tmp2}

	cont=$(($cont + 1))

	cat ${tmp2} >> ${outfile}
done

rm -f ${tmp1} ${tmp2}
cont=0

echo "% --------- Transition -> Place Arcs ---------" >> ${outfile}
echo "TP" >> ${outfile}

while [ "$cont" -lt "$n" ]
do
	next=$(($cont + 1))

	if [ "$next" -eq "$n" ]
	then
		next=0
	fi

	sed "s/I/${cont}/g" ${TR2PL} > ${tmp1}
	sed "s/J/${next}/g" ${tmp1} >> ${tmp2}

	cont=$(($cont + 1))
done

cat ${tmp2} >> ${outfile}
rm -f ${tmp1} ${tmp2}
cont=0

echo "% --------- Place -> Transition Arcs ---------" >> ${outfile}
echo "PT" >> ${outfile}

while [ "$cont" -lt "$n" ]
do
	next=$(($cont + 1))

	if [ "$next" -eq "$n" ]
	then
		next=0
	fi

	sed "s/I/${cont}/g" ${PL2TR} > ${tmp1}
	sed "s/J/${next}/g" ${tmp1} >> ${tmp2}

	cont=$(($cont + 1))
done

cat ${tmp2} >> ${outfile}
rm -f ${tmp1} ${tmp2}
cont=0

exit 0
