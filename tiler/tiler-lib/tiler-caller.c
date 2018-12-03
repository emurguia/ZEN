/* tests the tiler library */
/* performs generated code functionality of tiler language */
#include <stdio.h>
#include "tiler.h"

//#define _CRTDBG_MAP_ALLOC
#include <stdlib.h> 
//#include <crtdbg.h>

struct edwards {
	int state;
};

void init() {
	createGrid(3, 3);
	setBackground("hello.bmp");

	// create object 1
	struct edwards *attr1 = malloc(sizeof(struct edwards));
	attr1->state = 0;
	void *obj1 = createObject(attr1);
	setSprite(obj1, "edwards.bmp");
	setGrid(obj1, 1, 0);

	// create object 2
	struct edwards *attr2 = malloc(sizeof(struct edwards));
	attr2->state = 0;
	void *obj2 = createObject(attr2);
	setSprite(obj2, "edwards.bmp");
	setGrid(obj2, 2, 1);
}

// turn
void turn() {
	// capture mouse
	struct Coord *c = malloc(sizeof(struct Coord));
	getMouseCoords((void *) c);

	// checking coordinates
	if (isEmpty(c->x, c->y)) {
		struct edwards *attr = malloc(sizeof(struct edwards));
		attr->state = 0;
		void *obj = createObject(attr);
		setSprite(obj, "edwards.bmp");
		setGrid(obj, c->x, c->y);
	}
	else {
		void *obj = getGrid(c->x, c->y);
		
		// access an attribute
		void *tmp = getAttr(obj);
		struct edwards *attr = (struct edwards *) tmp;
		int state = attr->state;

		// checking value
		if (state == 0) {
			// store an attribute
			void *tmp2 = getAttr(obj);
			struct edwards *attr2 = (struct edwards *) tmp2;
			attr2->state = 1;

			// set sprite again
			setSprite(obj, "evil_edwards.bmp");
		}
		else {
			void *nobj = createNullObject();
			setGrid(nobj, c->x, c->y);
		}
	}
	free(c);
}

// end
int end() {
	// enhanced for-loop
	int i,j;
	int w = gridWidth();
	int h = gridHeight();
	for (i = 0; i < w; i = i + 1) {
		for (j = 0; j < h; j = j + 1) {
			void *obj = getGrid(i,j);
			
			// checking for null object
			if (isNull(obj)) {
				return 0;
			}

			// access an attribute
			void *tmp = getAttr(obj);
			struct edwards *attr = (struct edwards *) tmp;
			int state = attr->state;
			
			if(state == 0) {
				return 0;
			}
		}
	}

	return 1;
}

int main(int argc, char **argv) {
	//_CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_DEBUG);

	createGame();

	// set function ptrs
	setInit(init);
	setTurn(turn);
	setEnd(end);

	// set other window properties
	setTitle("Hello World!");
	setWindow(800, 600);
	setBackgroundColor(0, 0, 255);

	//play game
	runGame();

	//_CrtDumpMemoryLeaks();
}
