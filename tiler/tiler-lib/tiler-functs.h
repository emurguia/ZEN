#pragma once

#include "TileGame.h"

void setInit(void(*init)());

void setTurn(void(*turn)());

void setEnd(int(*end)());
