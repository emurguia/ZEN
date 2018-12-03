#include <stdio.h>
#include <string.h>
#include <setjmp.h>
#include "SDL.h"
#include "tiler-object.h"
#include "tiler-grid.h"
#include "tiler-mouse.h"
#include "tiler-main.h"

#include <stdlib.h>
//#include <crtdbg.h>

// global values
extern struct TileGame *game;
extern struct GameGrid *grid;
extern struct Blocks *blocks;
extern struct ObjRefList obj_refs;
extern struct MouseInfo mouseInfo;

void createGame() {
	game = (struct TileGame *)malloc(sizeof(struct TileGame));
	if (!game) {
		fprintf(stderr, "malloc returned NULL");
		exit(0);
	}

	// init title
	char *def = "Game";
	size_t n = strlen(def) + 1;
	game->title = (char *)malloc(n);
	if (!game->title) {
		free(game);
		fprintf(stderr, "malloc returned NULL");
		exit(0);
	}
	memcpy(game->title, def, n);

	// init window size
	setWindow(640, 480);

	// init bg color
	setBackgroundColor(255, 255, 255); // white

	// set background to NULL
	game->bg = NULL;

	// set running to false
	game->running = 0;
	game->exit = 0;

	// create the function pointers
	blocks = (struct Blocks *) malloc(sizeof(struct Blocks));
	if (!blocks) {
		SDL_FreeSurface(game->bg);
		free(game->title);
		free(game);
		fprintf(stderr, "malloc returned NULL");
		exit(0);
	}
	blocks->init_ptr = NULL;
	blocks->turn_ptr = NULL;
	blocks->end_ptr = NULL;

	// initialize empty object reference list
	obj_refs.head = NULL;

	// initialize mouse info
	mouseInfo.pulled = 0;
}


void setTitle(const char *str) {
	// free old title
	if (game->title) {
		free(game->title);
	}

	// allocate memory for new title
	size_t n = strlen(str) + 1;
	game->title = (char *)malloc(n);
	if (!game->title) {
		fprintf(stderr, "malloc returned NULL");
		return;
	}

	// copy string
	memcpy(game->title, str, n);
}


void setWindow(int width, int height) {
	game->width = width;
	game->height = height;
}


void setBackgroundColor(int red, int green, int blue) {
	game->bg_r = red;
	game->bg_g = green;
	game->bg_b = blue;
}


void setBackground(char *filepath) {
	game->bg = SDL_LoadBMP(filepath);
	if (!game->bg) {
		fprintf(stderr, "SDL_LoadBMP Error: %s\n", SDL_GetError());
		return;
	}
}

void draw(SDL_Renderer *renderer) {
	// load background texture
	SDL_Texture *back_tex = NULL;
	if (game->bg) {
		back_tex = SDL_CreateTextureFromSurface(renderer, game->bg);
		if (!back_tex) {
			fprintf(stderr, "Background Texture Error: %s\n", SDL_GetError());
		}
	}

	// load object textures
	int n = grid->width*grid->height;
	SDL_Texture **obj_tex = (SDL_Texture **) malloc(n*sizeof(SDL_Texture *));
	for (int i = 0; i < n; i++) {
		obj_tex[i] = NULL;
		if (grid->objs[i]->sprite) {
			obj_tex[i] = SDL_CreateTextureFromSurface(renderer, grid->objs[i]->sprite);
			//printf("Loaded Object Sprite");
		}
	}

	// clear back buffer
	SDL_RenderClear(renderer);

	// draw to background img to buffer
	if (back_tex) { SDL_RenderCopy(renderer, back_tex, NULL, NULL); }

	// draw object imgs to buffer
	for (int i = 0; i < n; i++) {
		if (grid->objs[i] && obj_tex[i]) {
			SDL_RenderCopy(renderer, obj_tex[i], NULL, &(grid->disp_rects[i])); 
		}
	}

	// draw buffer to screen
	SDL_RenderPresent(renderer);

	// free draw resources
	if (back_tex) { SDL_DestroyTexture(back_tex); }
	for (int i = 0; i < n; i++) {
		if (obj_tex[i]) {SDL_DestroyTexture(obj_tex[i]);}
	}
	free(obj_tex);
}


jmp_buf funcBuf;

void exitFunction() {
	longjmp(funcBuf, 1);
}

static int gameLoop(void *vargp) {
	//_CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_DEBUG);

	SDL_Renderer *renderer = (SDL_Renderer *)vargp;
	
	// set background color
	SDL_SetRenderDrawColor(renderer, game->bg_r, game->bg_g, game->bg_b, 255);

	// run init
	if (!setjmp(funcBuf)) {
		blocks->init_ptr();
	}

	// game loop
	while (game->running && !game->exit) {
		// draw
		draw(renderer);

		// check if end condition already met
		if (blocks->end_ptr) {
			if (!setjmp(funcBuf)) {
				game->exit = blocks->end_ptr();
			}
		}
		else {
			game->exit = 0;
		}
		

		// perform turns
		while (game->running && !game->exit) {
			// call turn
			if (blocks->turn_ptr) {
				if (!setjmp(funcBuf)) {
					blocks->turn_ptr();
				}
			}
			cleanObjects();

			// update draw
			draw(renderer);

			// test end
			if (game->running && !game->exit) {
				if (blocks->end_ptr) {
					if (!setjmp(funcBuf)) {
						game->exit = blocks->end_ptr();
					}
				}
			}
		}
	}

	printf("Game over.\n");

	//destroyGame();
	//_CrtDumpMemoryLeaks();

	return 0;
}


void runGame() {
	// initialize SDL
	if (SDL_Init(SDL_INIT_VIDEO)) {
		fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
		return;
	}

	// create window
	SDL_Window *window = SDL_CreateWindow(game->title,
		SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		game->width, game->height, SDL_WINDOW_SHOWN | SDL_WINDOW_MOUSE_FOCUS);
	if (!window) {
		fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
		SDL_Quit();
		return;
	}

	// create renderer
	SDL_Renderer *renderer = SDL_CreateRenderer(window, -1,
		SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (!renderer) {
		SDL_DestroyWindow(window);
		fprintf(stderr, "SDL_CreateRenderer Error: %s\n", SDL_GetError());
		SDL_Quit();
		return;
	}

	// call game logic thread
	game->running = 1;
	SDL_Thread *thread;
	int trv;
	thread = SDL_CreateThread(gameLoop, "game loop", (void *)renderer);

	while (game->running) {
		// event processing
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			if (event.type == SDL_QUIT) {
				game->running = 0;
			}
			else if (event.type == SDL_MOUSEBUTTONDOWN) {
				// compute the coords on the grid
				int x, y;
				x = event.button.x/(game->width/grid->width);
				y = event.button.y/(game->height/grid->height);
				setMouseInfo(x, y);
			}
		}
	}
	
	// wait for game thread to complete
	SDL_WaitThread(thread, &trv);

	// release memory
	destroyGame();
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();
}


void closeGame() {
	printf("%s\n", "The game window was successfully launched ...");
	game->running = 0;
	printf("%s\n", "The game window has been exited. Program exited.");
}


void destroyGame() {
	// grid
	if(grid) {
		destroyGameGrid();
	}

	// blocks
	free(blocks);

	// game
	SDL_FreeSurface(game->bg);
	free(game->title);
	free(game);
}
