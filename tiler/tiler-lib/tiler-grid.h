#pragma once

#include "TileGame.h"

void createGrid(int width, int height);

int gridWidth();

int gridHeight();

void setGrid(void *object, int x, int y);

void clearGrid(int x, int y);

void *getGrid(int x, int y);

int isEmpty(int x, int y);

void cleanGrid();

void destroyGameGrid();
