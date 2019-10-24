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

get_dependent()
{
	local j t

	buff=(${buff[@]} $(pacman -Qi $1 | grep Зави* | cut -d':' -f2 | cut -d' ' --complement -f1) )

	for j in ${buff[@]}
	do
		t=$(validate $j)
		if [ $t == true ]; then
			pkg=(${pkg[@]} $j)
		fi
	done
}

pkg=($1)
buff=()
i=0

while [ $i -lt ${#pkg[*]} ]
do
	echo ${pkg[$i]}
	get_dependent ${pkg[$i]}
	buff=()
	(( i++ ))

done