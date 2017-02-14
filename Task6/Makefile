# dc3314, Makefile, inspired from lab01 Makefile. ###

.SUFFIXES: .erl .beam

MODULES  = system6 process pl app beb rb

# BUILD =======================================================

ERLC	= erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam} 

ebin:	
	mkdir ebin

debug:
	erl -s crashdump_viewer start 

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

# LOCAL RUN ===================================================

SYSTEM    = system6
L_ERL     = erl -noshell -pa ebin -setcookie pass

run:	all
	$(L_ERL) -s $(SYSTEM) start
