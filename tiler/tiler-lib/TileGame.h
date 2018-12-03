#pragma once

// object
struct Object {
	// tiler class type
	int classCode;

	// coordinates on grid
	int x, y;
	int isOnGrid;

	// sprite
	struct SDL_Surface *sprite;

	// attributes
	void *attr;
};

// grid
struct GameGrid {
	// dimensions of grid
	int width, height;

	// display rectangles
	struct SDL_Rect *disp_rects;

	// objects on grid
	struct Object **objs;
};

// game
struct TileGame {
	// window title
	char *title;

	// window dims
	int width, height;

	// background rgb
	int bg_r, bg_g, bg_b;

	// background surface
	struct SDL_Surface *bg;

	// is running
	int running, exit;
};

// game info
struct TileGame *game;

// grid
struct GameGrid *grid;

// function pointers
struct Blocks {
	// init block
	void(*init_ptr)();

	// turn block
	void(*turn_ptr)();

	// end block
	int(*end_ptr)();
};

// function pointers
struct Blocks *blocks;

// object reference node
struct ObjNode {
	struct Object *obj;
	struct ObjNode *next;
};

// object reference list
struct ObjRefList {
	struct ObjNode *head;
};
struct ObjRefList obj_refs;

// coordinate on grid
struct Coord {
	int x, y;
};

// mouse event info
struct MouseInfo {
	struct Coord coords;
	int pulled;
};
struct MouseInfo mouseInfo;