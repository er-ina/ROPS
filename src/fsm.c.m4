include(gendir/script.m4)
fsm_comment_version
/* includes */

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>
#include <stdbool.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>

#include "parametri.h"
#include "arduino.h"

/* macro */

#define MAX_BUF 1000
#define USLEEP_TIME 100000
#define PROMPT "rops> "
#define OUT "out_fsm"
#define OUTDEBUG "out_debug_fsm"

/* definizione dei tipi */

typedef struct _item {
	char *cmd;
	bool (*f)(char *);
} item;

/* prima parte dichiarazione funzioni */

static bool start(char *);
static bool stop(char *);
static bool dump(char *);
static bool set_state(char *);
static bool set(char *);
static bool unset(char *);
static bool setblk(char *);
static bool unsetblk(char *);
static bool help(char *);
static bool quit(char *);

/* variabili globali */

extern char *nome_stato[];
int fsm_parameters;
bool alive;
pthread_t th;
FILE *out, *out_debug;
item comandi[] = {
			{"start", start},
			{"stop", stop},
			{"dump", dump},
			{"setstate", set_state},
			{"set", set},
			{"unset", unset},
			{"setblk", setblk},
			{"unsetblk", unsetblk},
			{"help", help},
			{"exit", quit},
			{"quit", quit},
			{NULL, NULL}
		};

/* seconda parte dichiarazione funzioni */

void setup();
void loop();
void emit_message(char *);
void emit_debug_message(char *);
int set_stato(int);
int get_stato(void);
unsigned long get_timer(void);

static void *rops_thread(void *);
static bool parse_command(char *cmd);

int main(int argc, char **argv)
{
	bool end;
	char *line;

	out = fopen(OUT, "w");
	out_debug = fopen(OUTDEBUG, "w");
	setvbuf(out, NULL, _IONBF, 0);
	setvbuf(out_debug, NULL, _IONBF, 0);
	alive = false;
	end = false;
	fsm_ingressi_inizializzazione
	printf(	"rops v1.0\n"
		"help per la lista dei comandi\n"
		"\n");
	while(!end) {
		line = readline(PROMPT);
		if (line && *line) {
			add_history(line);
			end = parse_command(line);
		}
		free(line);
	}
	fclose(out);
	fclose(out_debug);
}

void emit_message(char *msg)
{
	fprintf(out, "%s\n", msg);
	fflush(out);
}

void emit_debug_message(char *msg)
{
	fprintf(out_debug, "%s\n", msg);
	fflush(out_debug);
}

unsigned long millis(void)
{
	unsigned long r;
	struct timespec ts;
	timespec_get(&ts, TIME_UTC);
	r = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
	return r;
}

static bool parse_command(char *cmd)
{
	char *verb;
	char *arg;
	char *rest;
	item *it;

	rest = cmd;
	verb = strtok_r(rest, " ", &rest);
	arg = strtok_r(NULL, " ", &rest);
	if (verb == NULL) {
		return false;
	}
	it = comandi;
	while (it->f != NULL) {
		if (strcmp(it->cmd, verb) == 0) {
			return it->f(arg);
		}
		it++;
	}
	printf("comando sconosciuto: %s\n", verb);
	return false;
}

static void *rops_thread(void *data)
{
	setup();
	while(alive) {
		loop();
		usleep(USLEEP_TIME);
	}
	pthread_exit(0);
}

static bool start(char *)
{
	alive = true;
	pthread_create(&th, NULL, rops_thread, NULL);
	return false;
}

static bool stop(char *)
{
	alive = false;
	pthread_join(th, NULL);
	return false;
}

static bool dump(char *)
{
	printf(	"alive: %d -- stato: %s -- " fsm_ingressi_format " -- time: %ld\n", alive, nome_stato[get_stato()], fsm_parameters, get_timer());
	return false;
}

static bool set_state(char *arg)
{
	int n;

	for (n = 0; n < fsm_num_stati; n++) {
		if (strcmp(nome_stato[n], arg) == 0) {
			set_stato(n);
			break;
		}
	}
	return false;
}

static bool set(char *arg)
{
	fsm_set_ingressi
	} else {
		printf("argomento sconosciuto: %s\n", arg);
	}
	return false;
}

static bool unset(char *arg)
{
	fsm_unset_ingressi
	} else {
		printf("argomento sconosciuto: %s\n", arg);
	}
	return false;
}

static bool setblk(char *)
{
	sb1 = sb2 = 0;
	return false;
}

static bool unsetblk(char *)
{
	sb1 = sb2 = 1;
	return false;
}

static bool help(char *)
{
	printf(	"comandi:\n"
			"\tstart     - inizia il processo rops\n"
			"\tstop      - ferma il processo rops\n"
			"\tdump      - stato e ingressi\n"
			"\tsetstate  - imposta lo stato\n"
			"\tset       - imposta un ingresso a 1\n"
			"\tunset     - imposta un ingresso a 0\n"
			"\tsetblk    - imposta i blocchi\n"
			"\tunsetblk  - resetta i blocchi\n"
			"\thelp      - aiuto\n"
			"\texit/quit - esce\n"
			"\n");
	return false;
}

static bool quit(char *)
{
	return true;
}

void pinMode(int, int)
{
	// VOID
}

int digitalRead(int pin)
{
	switch(pin) {
fsm_digitalRead
	}
	return -1;
}

void digitalWrite(int, int)
{
	// VOID
}

void delay(int)
{
	// VOID
}
