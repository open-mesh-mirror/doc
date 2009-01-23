default:	all
all:		batman_doc
.PHONY:	clean images
batman_doc:	Makefile *.docbook images
	xmlto html batman.docbook
	xmlto fo batman.docbook
	fop batman.fo -ps batman.ps
	ps2pdf batman.ps

batman_iv_only_doc:	Makefile *.docbook images
	xmlto html batman_iv_only.docbook
	xmlto fo batman_iv_only.docbook
	fop batman_iv_only.fo -ps batman_iv_only.ps
	ps2pdf batman_iv_only.ps

images:
	make -C images/
clean:
	rm -f *.html *.pdf *.fo *.ps
	make -C images clean
