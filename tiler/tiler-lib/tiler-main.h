#pragma once

#include "TileGame.h"

/* init the game */
void createGame();

/* set title property of game */
void setTitle(const char *title);

/* set window dimension properties of game */
void setWindow(int width, int height);

/* set background color property of game */
void setBackgroundColor(int red, int green, int blue);

/* set the background image */
void setBackground(char *filepath);

/* exit a called function and return to game loop */
void exitFunction();

/* runs the SDL window */
void runGame();

/* force close the game window -- for testing */
void closeGame();

/* free memory of game structure */
void destroyGame();