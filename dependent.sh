#!/bin/bash

validate()
{
	local k

	k=0

	if [ "$1" == "Нет" ]; then
		echo false
		return 0
	fi

	while [ "${pkg[$k]}" != "$1" -a $k -lt ${#pkg[*]} ]; 
	do
		(( k++ ))
	done

	if [ $k -eq ${#pkg[*]} ]; then
		echo true
	else
		echo false
	fi

}

check()
{
	local j t

	for j in ${buff[@]}
	do
		t=$(validate $j)
		if [ $t == true ]; then
			pkg=(${pkg[@]} $j)
		fi
	done

	buff=()
}

get_dependent()
{

	buff=(${buff[@]} $(pacman -Qi $1 | grep Зави* | cut -d':' -f2 | cut -d' ' --complement -f1) )
	check

}

get_set_group()
{
	local j t

	buff=(${pkg[@]} $(pacman -Sg $1 | cut -d' ' -f2) )
	check

	if [ $count -ne 0 ]; then
		file="$1_filter.txt"
	fi
}

set_dependent()
{
	local j

	for j in $@
	do
		buff=(${buff[@]} $(cat $j) )
		check
	done
}

count=0
file="no"

while getopts "g:p:m:lf" opt
do
	case $opt in
		g) get_set_group $OPTARG;;
		p) buff=(${buff[@]} $OPTARG)
		   check;;
		m) set_dependent $OPTARG
		   count=${#pkg[*]};;
		l) file="${pkg[0]}_full.txt";;
		f) set_dependent "*_filter.txt"
		   count=${#pkg[*]};;
	esac
done

i=0

while [ $i -lt ${#pkg[*]} ]
do
	get_dependent ${pkg[$i]}
	(( i++ ))

done


for (( i=$count; i <= ${#pkg[*]}; i=i+1 ))
do
	if [ "$file" == "" ]; then  
		echo ${pkg[$i]}
	else
		echo ${pkg[$i]} >> $file
	fi
done