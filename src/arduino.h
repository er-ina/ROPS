#ifndef _ARDUINO_H
#define _ARDUINO_H

#define    LOW 0
#define   HIGH 1
#define  INPUT 0
#define OUTPUT 1

unsigned long millis(void);
void pinMode(int, int);
void digitalWrite(int, int);
int  digitalRead(int);
void delay(int);

#endif
