#include <stdbool.h>
#include <stdlib.h>
#include "tiler-functs.h"

extern struct Blocks *blocks;

void setInit(void(*init)()) {
	blocks->init_ptr = init;
}

void setTurn(void(*turn)()) {
	blocks->turn_ptr = turn;
}

void setEnd(int(*end)()) {
	blocks->end_ptr = end;
}
