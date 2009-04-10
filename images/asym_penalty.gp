#!/usr/bin/gnuplot
set title "asymetry penalty illustration, assuming incoming TQ = 100%"
set xlabel "receive quality (RQ) [%]"
set ylabel "rebroadcasted TQ value [%]"
set xrange [100:0]
set yrange [0:100]
set grid

set terminal png
set output "asym_penalty.png"

plot (1 - (1-x/100) ** 3)*100 title "rebroadcasted TQ value"

set terminal postscript eps enhanced color solid
set output "asym_penalty.eps"

plot (1 - (1-x/100) ** 3)*100 title "rebroadcasted TQ value"
