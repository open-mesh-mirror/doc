#! /usr/bin/make -f
# -*- makefile -*-

SOURCE = batmand_howto.docbook copyright.docbook installing.docbook \
         references.docbook articleinfo.docbook troubleshooting.docbook \
         usage.docbook
INPUT = batmand_howto.docbook

all: $(INPUT:.docbook=.pdf) $(INPUT:.docbook=.html)

$(INPUT:.docbook=.pdf): $(SOURCE) img
$(INPUT:.docbook=.html): $(SOURCE) img

.docbook.fo:
	xmlto fo $<

.docbook.html:
	xmlto xhtml-nochunks $<

.fo.ps:
	fop $< -ps $@

.ps.pdf:
	ps2pdf $<

img:
	make -C img/

clean:
	rm -f $(INPUT:.docbook=.pdf) $(INPUT:.docbook=.html) $(INPUT:.docbook=.fo) $(INPUT:.docbook=.ps)
	make -C img clean

.PHONY:	all clean img
.SUFFIXES: .docbook .fo .ps .pdf .html
