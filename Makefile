default:	all
all:		batman_doc
.PHONY:	clean images
batman_doc:	Makefile *.docbook images
	docbook2html batman.docbook
	docbook2pdf batman.docbook
images:
	make -C images/
clean:
	rm -rf *.html *.pdf
	make -C images clean
