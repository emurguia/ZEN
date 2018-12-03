#include "tiler-main.h"
#include "tiler-mouse.h"

extern struct MouseInfo mouseinfo;
extern struct TileGame *game;

void setMouseInfo(int x, int y) {
	mouseInfo.coords.x = x;
	mouseInfo.coords.y = y;
	mouseInfo.pulled = 0;
}

void pullMouseInfo(struct Coord *tuple_ptr) {
	tuple_ptr->x = mouseInfo.coords.x;
	tuple_ptr->y = mouseInfo.coords.y;
	mouseInfo.pulled = 1;
}

void getMouseCoords(void *tuple_ptr) {
	mouseInfo.pulled = 1;
	while (mouseInfo.pulled) { 
		if (!game->running) {
			exitFunction();
		}
	}

	pullMouseInfo((struct Coord *) tuple_ptr);
}
