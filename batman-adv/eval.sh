#!/bin/sh

for i in $1/*/*; do
	tail -n 50 $i | head -n -3 | grep "TG" | tail -n1 | awk '{ print $2 }'
done | sort -n \
	| awk '{sum += $1; sumsq += ($1)^2; a[NR] = $1} END { s = sqrt((sumsq-sum^2/NR)/NR); if (NR % 2) {med=a[(NR+1) / 2]} else {med=(a[NR/2] + a[(NR/2)+1])/2.0}; printf "%f %f %f %f %i\n", sum/NR, med, s, s/sqrt(NR), NR }'
