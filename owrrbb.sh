#!/bin/bash

if [ "$#" -ne "2" ]
then
	echo "usage: owrrbb.sh n output_file"
	exit 1
fi

suffix1="ll_net"
suffix2="ctl"
suffix3="smv"

n=$1
outfile=$2.${suffix1}
props=$2.${suffix2}
smv=$2.${suffix3}

TEMPLATES="${HOME}/src/lsi.upc.edu/llnets/templates"

HEADER="${TEMPLATES}/OWRRBB.header"
PL="${TEMPLATES}/OWRRBB.pl"
TR="${TEMPLATES}/OWRRBB.tr"
TR2PL="${TEMPLATES}/OWRRBB.tr2pl"
PL2TR="${TEMPLATES}/OWRRBB.pl2tr"

tmp1="_tmp.1"
tmp2="_tmp.2"

cont=0
last=$(($n - 1))
altura=480

rm -f ${tmp1} ${tmp2}

echo "Generating Petri net model"
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

	sed "s/+20/$(($cont * $altura + 20))/g" ${tmp2} > ${tmp1}
	sed "s/+120/$(($cont * $altura + 120))/g" ${tmp1} > ${tmp2}
	sed "s/+140/$(($cont * $altura + 140))/g" ${tmp2} > ${tmp1}
	sed "s/+180/$(($cont * $altura + 180))/g" ${tmp1} > ${tmp2}
	sed "s/+260/$(($cont * $altura + 260))/g" ${tmp2} > ${tmp1}

	sed "s/\(\"w01\".*\)$/\1M1m1/g"  ${tmp1} > ${tmp2}
	sed "s/\(\"w0\".*\)$/\1M1m1/g"  ${tmp2} > ${tmp1}

	if [ "$cont" -ne "0" ]
	then
		cp  ${tmp1}  ${tmp2}
		sed "s/\(\"l${cont}1\".*\)$/\1M1m1/g"  ${tmp2} > ${tmp1}
	fi

	sed "s/\(\"ri${last}1\".*\)$/\1M1m1/g"  ${tmp1} > ${tmp2}
	sed "s/\(\"r${last}1\".*\)$/\1M1m1/g"  ${tmp2} > ${tmp1}
	sed "s/\(\"rn${last}0\".*\)$/\1M1m1/g"  ${tmp1} > ${tmp2}

	if [ "$cont" -ne "$last" ]
	then
		sed "s/\(\"rn${cont}0\".*\)$/\1M1m1/g"  ${tmp2} > ${tmp1}
		sed "s/\(\"rn${cont}1\".*\)$/\1M1m1/g"  ${tmp1} > ${tmp2}
	fi

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

	sed "s/+80/$(($cont * $altura + 80))/g" ${tmp2} > ${tmp1}
	sed "s/+140/$(($cont * $altura + 140))/g" ${tmp1} > ${tmp2}
	sed "s/+240/$(($cont * $altura + 240))/g" ${tmp2} > ${tmp1}
	sed "s/+260/$(($cont * $altura + 260))/g" ${tmp1} > ${tmp2}
	sed "s/+300/$(($cont * $altura + 300))/g" ${tmp2} > ${tmp1}
	sed "s/+400/$(($cont * $altura + 400))/g" ${tmp1} > ${tmp2}

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

echo "Generating CTL properties"
echo "" > ${props}
echo "-- CTL PROPERTIES" >> ${props}

while [ "$cont" -lt "$n" ]
do
	echo "SPEC AG(!((w${cont}0 | w${cont}0_) & r${cont}0))" >> ${props}
	echo "SPEC AG(!((w${cont}1 | w${cont}1_) & r${cont}1))" >> ${props}

	echo "SPEC AG((w${cont}0 | w${cont}0_) & !r${cont}1 ->
		E(!r${cont}1 U r${cont}0) &
		!E(!(w${cont}1 | w${cont}1_) U r${cont}1))" >> ${props}
	echo "SPEC AG((w${cont}1 | w${cont}1_) & !r${cont}0 ->
		E(!r${cont}0 U r${cont}1) &
		!E(!(w${cont}0 | w${cont}0_) U r${cont}0))" >> ${props}
	
	echo "SPEC AG((w${cont}0 | w${cont}0_) & r${cont}1 ->
		E(r${cont}1 U E(!r${cont}1 U r${cont}0)) &
		!E(r${cont}1 U (!r${cont}1 & E(!(w${cont}1 | w${cont}1_) U r${cont}1))) )" >> ${props}
	echo "SPEC AG((w${cont}1 | w${cont}1_) & r${cont}0 ->
		E(r${cont}0 U E(!r${cont}0 U r${cont}1)) &
		!E(r${cont}0 U (!r${cont}0 & E(!(w${cont}0 | w${cont}0_) U r${cont}0))) )" >> ${props}

	cont=$(($cont + 1))
done

echo "Executing pep2smv"
pep2smv ${outfile}
cat ${props} >> ${smv}

exit 0
