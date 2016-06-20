#!/bin/bash

cmp1=kmalloc-01
cmp2=kmem-cache-aligned-01
cmp3=kmem-cache-unaligned-01

get_stats() {
	res=`./eval.sh $1`
	ave=`echo $res | awk '{print $1}'`
	med=`echo $res | awk '{print $2}'`
	sig=`echo $res | awk '{print $3}'`
	err=`echo $res | awk '{print $4}'`
}

cpy_stats() {
	ave_cpy="$ave"
	med_cpy="$med"
	sig_cpy="$sig"
	err_cpy="$err"
}

compare() {
	x=0
	for i in logs/$1/*; do
	#	echo $i
	#	echo ${i##*/};

		get_stats "$i"
		cpy_stats

	#	echo "logs/$cmp2/${i##*/}"
		get_stats "logs/$2/${i##*/}"

		da[$x]="`echo "$ave $ave_cpy" |awk '{print ($1/$2)-1}'`"
	#	echo ${da[$x]}

		dm[$x]="`echo "$med $med_cpy" |awk '{print ($1/$2)-1}'`"
	#	echo ${dm[$x]}

		x=$(($x+1))
	done

	sum=0
	for i in ${da[*]}; do
	#	echo "i: $i, sum: $sum"
		sum="`echo "$sum $i" | awk '{print ($1+$2)}'`"
	done

	ave_fin=`echo "$sum ${#da[*]}" | awk '{print 1+($1/$2)}'`


	sum=0
	for i in ${dm[*]}; do
	#	echo "i: $i, sum: $sum"
		sum="`echo "$sum $i" | awk '{print ($1+$2)}'`"
	done

	med_fin=`echo "$sum ${#dm[*]}" | awk '{print 1+($1/$2)}'`

	echo "ave: $ave_fin, med: $med_fin"
}

plot_data() {
	read -d '' GP <<-EOF
		set title '$cmp1 vs. ...'
		set style data histogram
		set boxwidth 0.75 absolute
		set style histogram
		set style fill solid 1.0 border lt -1
		set ylabel 'Size gain factor'
		set yrange [1.2:1.5]
		set terminal png size 800,640
		set output 'kmalloc_vs_kmem-cache.png'
		set grid ytics mytics
		set mytics
		plot '-' using 2 t 'average', '-' using 3:xtic(1) t 'median'
	EOF

	echo -e "$GP\n$1\ne\n$1\ne" | gnuplot
}


echo "Size gain factor $cmp1 vs $cmp2:"
echo -n "  "
compare "$cmp1" "$cmp2"

DATA="$cmp2 $ave_fin $med_fin"
echo

echo "Size gain factor $cmp1 vs $cmp3:"
echo -n "  "
compare "$cmp1" "$cmp3"

DATA="$DATA
$cmp3 $ave_fin $med_fin"

plot_data "$DATA"
