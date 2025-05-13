include(gendir/script.m4)
fsm_comment_version
/* includes */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <errno.h>

#include "parametri.h"

/* macro */

#define PROMPT "test> "

/* definizione dei tipi */

typedef struct _item {
	char *cmd;
	bool (*f)(char *);
} item;

fsm_tipo_stato

/* dichiarazione funzioni */

void emit_message(char *msg);
void emit_debug_message(char *msg);
unsigned int millis(void);
void pinMode(int, int);
int  digitalRead(int);
void digitalWrite(int, int);
void set_stato(t_stato);
t_stato get_stato(void);
t_stato evolve(t_stato stato, fsm_signature);

static void parse_file(char *);
static bool parse_command(char *cmd);
static bool set_state(char *);
static bool get_state(char *);
static bool evl(char *);
static bool set(char *);
static bool get(char *);
static bool help(char *);
static bool quit(char *);

/* variabili globali */

extern char *nome_stato[];
int fsm_parameters;
fsm_test_ingressi
item comandi[] = {
			{"setstate", set_state},
			{"getstate", get_state},
			{"set", set},
			{"get", get},
			{"evolve", evl},
			{"help", help},
			{"exit", quit},
			{"quit", quit},
			{NULL, NULL}
		};

/* definizione funzioni */

int main(int argc, char **argv)
{
	bool end;
	char *line;

	if (argc > 1) {
		parse_file(argv[1]);
	} else {
		end = false;
		printf(	"test rops v1.0\n"
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
	}
}

void emit_message(char *msg)
{
	printf("%s\n", msg);
}

void emit_debug_message(char *msg)
{
	printf("%s\n", msg);
}

unsigned int millis(void)
{	
	return 0;
}

static void parse_file(char *filename)
{
	int c;
	FILE *f;
	t_stato stato_iniziale, stato_finale;
	char inputs[NUM_INPUTS+2];
	int riga;
	t_stato stato;

	riga = 1;
	f = fopen(filename, "r");
	if (NULL == f) {
		printf("errore \"%s\" nell'apertura del file %s\n", strerror(errno), filename);
		return;
	}
	while(!feof(f)) {
		c = fscanf(f, "%d %s %d", &stato_iniziale, inputs, &stato_finale);
		if (EOF != c) {
			set_stato(stato_iniziale);
			inputs[NUM_INPUTS+1] = '\0';
			set(inputs);
			stato = evolve(stato_iniziale, fsm_parameters);
			if (stato > (fsm_num_stati - 3)) {
				printf("- %s ko alla riga %3d: %s\n", nome_stato[stato], riga, inputs);
			} else {
				printf("+ %s ok alla riga %3d: %s\n", nome_stato[stato], riga, inputs);
			}
			/*
			if (stato_finale != stato) {
				printf("- stato differente (%d) alla riga %d: %s\n", stato, riga, inputs);
			} else {
				printf("+ ok: %s\n", inputs);
			}
			*/
		}
		riga++;
	}
	fclose(f);
}

static bool parse_command(char *cmd)
{
	char *verb;
	char *arg;
	item *it;

	verb = strtok(cmd, " ");
	arg = strtok(NULL, " ");
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

static bool get_state(char *arg)
{
	printf("stato: %s\n", nome_stato[get_stato()]);
	return false;
}

static bool set(char *arg)
{
	int i;
	for (i = 0; i < NUM_INPUTS+1; i++) {
		*(ingressi[i]) = arg[i] - '0';
	}
	return false;
}

static bool get(char *arg)
{
	int i;
	for (i = 0; i < NUM_INPUTS+1; i++) {
		printf("%d", *(ingressi[i]));
	}
	printf("\n");
	return false;
}

static bool evl(char *arg)
{
	t_stato stato;
	stato = evolve(get_stato(), fsm_parameters);
	set_stato(stato);
	return false;
}

static bool help(char *)
{
	printf(	"comandi:\n"
			"\tsetstate  - imposta lo stato\n"
			"\tgetstate  - ritorna lo stato\n"
			"\tevolve    - passo di evoluzione della FSM\n"
			"\tset       - imposta gli ingressi\n"
			"\tget       - ritorna gli ingressi\n"
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
	// VOID
}

void digitalWrite(int, int)
{
	// VOID
}

void delay(int)
{
	// VOID
}
