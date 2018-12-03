#include <stdio.h>
#include <stdlib.h>
#include "SDL.h"
#include "tiler-object.h"
#include "tiler-grid.h"

extern struct TileGame *game;
extern struct GameGrid *grid;

void createNullObjectOnGrid(int x, int y) {
	// create space for object
	struct Object *obj = (struct Object *) malloc(sizeof(struct Object));
	if (!obj) {
		fprintf(stderr, "malloc returned NULL");
		return;
	}

	// set to be null
	obj->classCode = 0;

	// set sprite to NULL
	obj->sprite = NULL;

	// set the attribute pointer to NULL
	obj->attr = NULL;

	// init to be on grid
	obj->x = x;
	obj->y = y;
	obj->isOnGrid = 1;

	// place on the grid
	int i = x + y * grid->width;
	grid->objs[i] = obj;
}

void createGrid(int width, int height) {
	// allocate space for grid struct
	grid = (struct GameGrid *) malloc(sizeof(struct GameGrid));
	if (!grid) {
		fprintf(stderr, "malloc returned NULL");
		return;
	}

	// initialize width and height
	grid->width = width;
	grid->height = height;

	// allocate space for object ptrs in grid
	int n = width * height;
	grid->objs = (struct Object **) malloc(n * sizeof(struct Object *));
	if (!grid->objs) {
		fprintf(stderr, "malloc returned NULL");
		return;
	}

	// initialize obj ptrs to NULL objects
	for (int i = 0; i < width; i++) {
		for (int j = 0; j < height; j++) {
			createNullObjectOnGrid(i, j);
		}
	}

	// add display rectangles
	grid->disp_rects = (struct SDL_Rect *) malloc(n * sizeof(struct SDL_Rect));
	int w, h;
	w = game->width / width;
	h = game->height / height;
	struct SDL_Rect *cur;
	for (int i = 0; i < width; i++) {
		for (int j = 0; j < height; j++) {
			cur = &(grid->disp_rects[i + j*width]);
			cur->x = i*w;
			cur->y = j*h;
			cur->w = w;
			cur->h = h;
		}
	}
}


int gridWidth() {
	return grid->width;
}

int gridHeight() {
	return grid->height;
}

struct Object *removeGrid(int x, int y) {
	// get the object
	int i = x + y*grid->width;
	struct Object *obj = grid->objs[i];

	// remove from grid
	grid->objs[i] = NULL;
	
	if (obj->classCode) {
		// add back to list
		obj->isOnGrid = 0;
		addObject(obj);
	}
	else {
		// clean NULL object
		freeObject(obj);
	}

	return obj;
}

void setGrid(void *object, int x, int y) {
	struct Object *obj = (struct Object *) object;

	// get the object to place
	struct Object *target;
	if (obj->isOnGrid) {target = removeGrid(obj->x, obj->y);}
	else {target = removeObject(obj);}
	if (!target) {
		fprintf(stderr, "Untracked Object!");
		return;
	}
	
	// replace
	removeGrid(x, y);
	int i = x + y*grid->width;
	grid->objs[i] = target;

	// change members
	target->isOnGrid = 1;
	target->x = x;
	target->y = y;
}

void clearGrid(int x, int y) {
	// take off
	removeGrid(x, y);

	// replace with NULL object
	createNullObjectOnGrid(x, y);
}

void cleanGrid() {
	int n = grid->width*grid->height;
	for (int i = 0; i < n; i++) {
		freeObject(grid->objs[i]);
	}
}

void *getGrid(int x, int y) {
	int i = x + y*grid->width;
	return (void *) grid->objs[i];
}

int isEmpty(int x, int y) {
	struct Object *obj = (struct Object *) getGrid(x, y);
	return !obj->classCode;
}

void destroyGameGrid() {
	cleanGrid();
	free(grid->objs);
	free(grid->disp_rects);
	free(grid);
}
