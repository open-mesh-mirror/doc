default:	all
all:		batman_doc
batman_doc:	Makefile *.docbook
	docbook2html batman.docbook
	docbook2pdf batman.docbook
clean:
	rm -rf *.html *.pdf
