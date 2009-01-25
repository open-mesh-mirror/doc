#! /usr/bin/make -f
# -*- makefile -*-

default:	all
all:		batman_doc
.PHONY:	clean images batman_doc batman_iv_only_doc
.SUFFIXES: .docbook	.fo	.ps	.pdf	.html
batman_doc:  batman.pdf batman.html
batman_iv_only_doc: batman_iv_only.pdf batman_iv_only.html

batman_iv_only.html: Makefile *.docbook images
batman_iv_only.pdf: Makefile *.docbook images
batman.html: Makefile *.docbook images
batman.pdf: Makefile *.docbook images

.docbook.fo:
	xmlto fo $<

.docbook.html:
	xmlto xhtml-nochunks $<

.fo.ps:
	fop $< -ps $@

.ps.pdf:
	ps2pdf $<

images:
	make -C images/
clean:
	rm -f *.html *.pdf *.fo *.ps
	make -C images clean
