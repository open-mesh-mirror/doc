# -*- makefile -*-

DIA_IMAGES = announce_networks.dia multiple_announces.dia multiple_clients.dia
EPS_IMAGES = $(DIA_IMAGES:.dia=.eps)
PNG_IMAGES = $(DIA_IMAGES:.dia=.png)

all: $(EPS_IMAGES) $(PNG_IMAGES)

.SUFFIXES: .dia .eps .png

.dia.eps:
	/usr/bin/dia -e $@ $<

.dia.png:
	/usr/bin/dia -e $@ $<

clean:
	rm -f $(EPS_IMAGES) $(PNG_IMAGES)
