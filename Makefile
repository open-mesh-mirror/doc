default:	all
all:		batman_doc
.PHONY:	clean images
batman_doc:	Makefile *.docbook images
	docbook2html batman.docbook
	docbook2pdf batman.docbook
batman_iv_only_doc:	Makefile *.docbook images
	docbook2html batman_iv_only.docbook
	docbook2pdf batman_iv_only.docbook

images:
	make -C images/
clean:
	rm -f *.html *.pdf *.log *.refs
	make -C images clean
