### dc3314, Makefile, inspired from lab01 Makefile. ###

.SUFFIXES: .erl .beam

MODULES  = system1 process 

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

SYSTEM    = system1
L_ERL     = erl -noshell -pa ebin -setcookie pass

run1:	all
	$(L_ERL) -s $(SYSTEM) start