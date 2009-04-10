#!/usr/bin/gnuplot
set title "Asymetry Penalty Illustration, assuming incoming TQ = 1.0"
set xlabel "receive quality (RQ)"
set ylabel "rebroadcasted TQ value"
set xrange [0:1]
set yrange [0:1]
set grid

set terminal png
set output "asym_penalty.png"

plot (1 - (1-x) ** 3) title "asymetry penalty 1 - (1-x)^3"

set terminal postscript eps enhanced color solid
set output "asym_penalty.eps"

plot (1 - (1-x) ** 3) title "asymetry penalty 1 - (1-x)^3"
