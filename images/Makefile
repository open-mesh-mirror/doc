DIA_IMAGES=asymetry.dia
PNG_IMAGES=$(DIA_IMAGES:.dia=.png)
EPS_IMAGES=$(DIA_IMAGES:.dia=.eps)

.PHONY:		clean
.SUFFIXES:	.dia	.png	.eps

default:	all
all:	$(EPS_IMAGES) $(PNG_IMAGES)

.dia.png:
	/usr/bin/dia -e $@ $<
.dia.eps:
	/usr/bin/dia -e $@ $<

clean:
	rm *.png *.eps
