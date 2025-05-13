BINDIR=$(OUTDIR)/bin
GENDIR=$(OUTDIR)/generated
ARDUINO=$(OUTDIR)/rops
TESTS=$(OUTDIR)/tests
SRC_DIR=src
VERSIONE=$(shell jq -j -r '.version' $(SPECS); echo -n -; date +%F)
GEN_FSM=$(SRC_DIR)/genera_fsm
M4=m4 -D gendir=$(GENDIR)

all:	binari data arduino grafici

binari:	$(BINDIR)/fsm $(BINDIR)/test

$(BINDIR)/fsm:	$(GENDIR)/fsm.c $(GENDIR)/codice.c $(GENDIR)/parametri.h $(SRC_DIR)/arduino.h
	if [ ! -d $(BINDIR) ]; then \
		mkdir -p $(BINDIR); \
	fi
	gcc -D_REENTRANT -o $(BINDIR)/fsm $(GENDIR)/fsm.c $(GENDIR)/codice.c -I$(SRC_DIR) -I$(GENDIR) -lpthread -lreadline

$(BINDIR)/test:	$(GENDIR)/test.c $(GENDIR)/codice.c $(GENDIR)/parametri.h $(SRC_DIR)/arduino.h
	if [ ! -d $(BINDIR) ]; then \
		mkdir -p $(BINDIR); \
	fi
	gcc -o $(BINDIR)/test $(GENDIR)/test.c $(GENDIR)/codice.c -lreadline -I$(SRC_DIR) -I$(GENDIR)

arduino: $(ARDUINO)/rops.ino

grafici: $(GENDIR)/fsm.pdf

$(GENDIR)/fsm.pdf:	$(GENDIR)/fsm.dot
	dot -Tpdf $(GENDIR)/fsm.dot -o $(GENDIR)/fsm.pdf

$(ARDUINO)/rops.ino:	$(SRC_DIR)/codice.c.m4 $(GENDIR)/script.m4 $(GENDIR)/parametri.h $(GENDIR)/fsm.pdf
	if [ ! -d $(ARDUINO) ]; then\
		mkdir -p $(ARDUINO); \
	fi
	$(M4) -D ARDUINO $(SRC_DIR)/codice.c.m4 > $(ARDUINO)/rops.ino
	cp $(GENDIR)/parametri.h $(GENDIR)/fsm.pdf $(ARDUINO)

$(GENDIR)/codice.c:	$(SRC_DIR)/codice.c.m4 $(GENDIR)/script.m4
	$(M4) $(SRC_DIR)/codice.c.m4 > $(GENDIR)/codice.c

$(GENDIR)/fsm.c:	$(SRC_DIR)/fsm.c.m4 $(GENDIR)/script.m4
	$(M4) $(SRC_DIR)/fsm.c.m4 > $(GENDIR)/fsm.c

$(GENDIR)/test.c:	$(SRC_DIR)/test.c.m4 $(GENDIR)/script.m4
	$(M4) $(SRC_DIR)/test.c.m4 > $(GENDIR)/test.c

$(GENDIR)/parametri.h:	$(SRC_DIR)/parametri.h.m4 $(GENDIR)/script.m4
	$(M4) $(SRC_DIR)/parametri.h.m4 > $(GENDIR)/parametri.h

data:	$(BINDIR)/test $(GENDIR)/ingressi $(BINDIR)/genera_dati
	if [ ! -d $(TESTS) ]; then \
		mkdir -p $(TESTS); \
	fi
	$(BINDIR)/genera_dati $(BINDIR) $(TESTS)

$(BINDIR)/genera_dati:	$(SRC_DIR)/genera_dati.m4 $(GENDIR)/script.m4
	if [ ! -d $(BINDIR) ]; then \
		mkdir -p $(BINDIR); \
	fi
	$(M4) $(SRC_DIR)/genera_dati.m4 > $(BINDIR)/genera_dati
	chmod 755 $(BINDIR)/genera_dati

$(GENDIR)/script.m4 $(GENDIR)/fsm.dot:	$(GEN_FSM) $(SPECS)
	if [ ! -d $(GENDIR) ]; then \
		mkdir -p $(GENDIR); \
	fi
	./$(GEN_FSM) $(GENDIR) $(SPECS)

clean:
	rm -rf $(TESTS) $(GENDIR) $(ARDUINO) $(BINDIR)
