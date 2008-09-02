#!/usr/bin/gnuplot
set title "Asymetry Penalty illustration"
set xlabel "Receive Quality (RQ)"
set ylabel "applied Asymetry Penalty"
set xrange [0:1]
set yrange [0:1]
set grid

set terminal png
set output "asym_penalty.png"

plot (1 - (1-x) ** 3) title "asymetry penalty 1 - (1-x)^3",\
	x title "receive quality"

set terminal postscript eps enhanced color solid
set output "asym_penalty.eps"

plot (1 - (1-x) ** 3) title "asymetry penalty 1 - (1-x)^3",\
	x title "receive quality"
