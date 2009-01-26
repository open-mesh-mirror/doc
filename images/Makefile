GP_IMAGES=asym_penalty.gp
DIA_IMAGES=asymetry.dia tq.dia eq.dia eq_alt1.dia eq_alt2.dia eq_alt3.dia rq.dia \
		   hop_penalty1.dia hop_penalty2.dia \
		   hop_penalty3.dia hop_penalty4.dia hop_penalty5.dia hop_penalty6.dia \
		   asym_link1.dia asym_link2.dia tq_prop.dia \
		   echo_cancel1.dia echo_cancel2.dia \
		   tq_prop_best1.dia tq_prop_best2.dia tq_prop_best3.dia \
		   announce_networks.dia multiple_announces.dia multiple_clients.dia
TEX_IMAGES=compute_tq.tex tq_prop_calc.tex
PNG_IMAGES= $(DIA_IMAGES:.dia=.png) 
PNG_IMAGES+=$(GP_IMAGES:.gp=.png) 
PNG_IMAGES+=$(TEX_IMAGES:.tex=.png) 
EPS_IMAGES= $(DIA_IMAGES:.dia=.eps)
EPS_IMAGES+=$(GP_IMAGES:.gp=.eps)
EPS_IMAGES+=$(TEX_IMAGES:.tex=.eps)

.PHONY:		clean
.SUFFIXES:	.dia	.png	.eps	.gp

default:	all
all: stamp

stamp: $(EPS_IMAGES) $(PNG_IMAGES)
	touch $@

.gp.png:
	gnuplot $<
.gp.eps:
	gnuplot $<

.dia.png:
	/usr/bin/dia -e $@ $<
.dia.eps:
	/usr/bin/dia -e $@ $<
.tex.eps:
	rm -f file_tmp.*
	cp $< file_tmp.tex
	latex file_tmp.tex
	dvips file_tmp.dvi
	ps2eps -l file_tmp.ps
	mv file_tmp.eps $@
	rm -f file_tmp.*

.tex.png:
	rm -f file_tmp.*
	cp $< file_tmp.tex
	latex file_tmp.tex
	dvips -x 3000 -y 3000  -E file_tmp.dvi
	convert file_tmp.ps $@
	rm -f file_tmp.*
clean:
	rm -f *.png *.eps stamp
