include(gendir/script.m4)
fsm_comment_version
/* includes */
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

ifdef(`ARDUINO', `', `#include "arduino.h"')
#include "parametri.h"

/* macro */

fsm_macro_check

#define CHECK_INPUT(x) if (a_ ## x != -1 && a_ ## x != x) return 0;

fsm_outputs

/* definizione tipi */

fsm_tipo_stato

/* prima parte dichiarazione funzioni */

fsm_dichiarazioni

/* variabili globali */

t_stato stato, vecchio_stato;
unsigned long s_timer;		/* primo valore assoluto del timer */
unsigned long t_timer;		/* primo valore del timer */
unsigned long max_timer;	/* intervallo massimo del timer */

fsm_outputs_strings

fsm_stati

/* seconda parte dichiarazione funzioni */

ifdef(`ARDUINO', `', `t_stato get_stato(void);
void set_stato(t_stato);
')dnl

unsigned long get_timer(void);

void emit_message(char *);
void emit_debug_message(char *);

static void set_outputs(int motore, int blocco_sblocco, int code);
static void set_timer(unsigned long m);  /* imposta il timer in secondi */
static char *create_message(const char *, va_list ap);
static void print_message(const char *, ...);
static void print_debug_message(const char *, ...);

static void motore_su(void);
static void motore_giu(void);
static void motore_spegni(void);
static void blocco_attiva(void);
static void sblocco_attiva(void);
static void blocco_sblocco_spegni(void);

/* definizione funzioni */

void setup()
{
	/* inizializzazione */
ifdef(`ARDUINO', `
	Serial.begin(9600);
')
	fsm_init_pin

	pinMode(PIN_RELE_ROPS_1,  OUTPUT);
	pinMode(PIN_RELE_ROPS_2,  OUTPUT);
	pinMode(PIN_RELE_SERR_11, OUTPUT);
	pinMode(PIN_RELE_SERR_12, OUTPUT);
	pinMode(PIN_RELE_SERR_21, OUTPUT);
	pinMode(PIN_RELE_SERR_22, OUTPUT);
	
	blocco_sblocco_spegni();
	motore_spegni();

	stato = S_START;
	vecchio_stato = S_END;
	s_timer = millis();

	print_message("versione: %s", fsm_version);
	print_message("OK");
}

void loop()
{
	/* valorizza gli ingressi */
	int fsm_parameters;

	fsm_leggi_pin

	timer = 0;
	if (millis() - t_timer >= max_timer) {
		timer = 1;
	}

	print_debug_message("stato: %11s, " fsm_ingressi_format ", absolute time: %ld, time: %ld", nome_stato[stato], fsm_parameters, millis() - s_timer, millis() - t_timer);

	if (vecchio_stato != stato) {
		print_message("stato: %s", nome_stato[stato]);
	}
	vecchio_stato = stato;

	stato = evolve(stato, fsm_parameters);
}
ifdef(`ARDUINO', `', `
void set_stato(t_stato s)
{
	stato = s;
}

t_stato get_stato(void)
{
	return stato;
}')
fsm_definizioni
static void set_timer(unsigned long m)
{
	max_timer = m * 1000;
	t_timer = millis();
}

static char *create_message(const char *fmt, va_list ap)
{
	char *buf;
	size_t size;
	int n;
	va_list copy;

	size = 0;
	buf = NULL;
	va_copy(copy, ap);
	n = vsnprintf(buf, size, fmt, ap);
	size = n + 1;
	buf = (char *)malloc(size);
	n = vsnprintf(buf, size, fmt, copy);
	va_end(copy);
	return buf;
}
ifdef(`ARDUINO', `
void emit_message(char *msg)
{
	Serial.println(msg);
}

void emit_debug_message(char *msg)
{
	/*Serial.println(msg);*/
}
')
static void print_message(const char *fmt, ...)
{
	char *buf;
	va_list ap;

	va_start(ap, fmt);
	buf = create_message(fmt, ap);
	va_end(ap);
	emit_message(buf);
	free(buf);
}

static void print_debug_message(const char *fmt, ...)
{
	char *buf;
	va_list ap;

	va_start(ap, fmt);
	buf = create_message(fmt, ap);
	va_end(ap);
	emit_debug_message(buf);
	free(buf);
}

unsigned long get_timer(void)
{
	return millis() - t_timer;
}

static void set_outputs(int motore, int blocco_sblocco, int errore)
{
	/*print_debug_message("output: %s, %s, %s", output_o1[motore], output_o2[blocco_sblocco], output_err[errore]);*/
	switch(motore) {
		case MOTORE_SU:
			motore_su();
			break;
		case MOTORE_GIU:
			motore_giu();
			break;
		case OFF:
			motore_spegni();
			break;
	}
	switch(blocco_sblocco) {
		case BLOCCO:
			blocco_attiva();
			break;
		case SBLOCCO:
			sblocco_attiva();
			break;
		case BSOFF:
			blocco_sblocco_spegni();
			break;
	}
	switch(errore) {
		fsm_case_errori
			print_message("%s", output_err[errore]);
			break;
	}
}

static void motore_su(void)
{
	digitalWrite(PIN_RELE_ROPS_1,  LOW);
	digitalWrite(PIN_RELE_ROPS_2,  LOW);
	delay(DELAY_FOR_RELAIS);
	digitalWrite(PIN_RELE_ROPS_2, HIGH);
	set_timer(TIMER_SALITA);
	print_message("pistone: su");
}

static void motore_giu(void)
{
	digitalWrite(PIN_RELE_ROPS_1,  LOW);
	digitalWrite(PIN_RELE_ROPS_2,  LOW);
	delay(DELAY_FOR_RELAIS);
	digitalWrite(PIN_RELE_ROPS_1, HIGH);
	set_timer(TIMER_DISCESA);
	print_message("pistone: giù");
}

static void motore_spegni(void)
{
	digitalWrite(PIN_RELE_ROPS_1,  LOW);
	digitalWrite(PIN_RELE_ROPS_2,  LOW);
	print_message("pistone: spegni");
}

static void blocco_attiva(void)
{
	digitalWrite(PIN_RELE_SERR_11,  LOW);
	digitalWrite(PIN_RELE_SERR_21,  LOW);
	digitalWrite(PIN_RELE_SERR_11, HIGH);
	digitalWrite(PIN_RELE_SERR_12,  LOW);
	digitalWrite(PIN_RELE_SERR_21, HIGH);
	digitalWrite(PIN_RELE_SERR_22,  LOW);
	set_timer(TIMER_BLOCCO);
	print_message("blocco: attiva");
}

static void sblocco_attiva(void)
{
	digitalWrite(PIN_RELE_SERR_12,  LOW);
	digitalWrite(PIN_RELE_SERR_22,  LOW);
	digitalWrite(PIN_RELE_SERR_11,  LOW);
	digitalWrite(PIN_RELE_SERR_12, HIGH);
	digitalWrite(PIN_RELE_SERR_21,  LOW);
	digitalWrite(PIN_RELE_SERR_22, HIGH);
	set_timer(TIMER_SBLOCCO);
	print_message("sblocco: attiva");
}

static void blocco_sblocco_spegni(void)
{
	digitalWrite(PIN_RELE_SERR_11,  LOW);
	digitalWrite(PIN_RELE_SERR_12,  LOW);
	digitalWrite(PIN_RELE_SERR_21,  LOW);
	digitalWrite(PIN_RELE_SERR_22,  LOW);
	print_message("blocco_sblocco: spegni");
}
