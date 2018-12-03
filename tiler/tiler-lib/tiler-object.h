#pragma once

#include "TileGame.h"

void addObject(struct Object *obj);

struct Object* removeObject(struct Object *obj);

void *createObject(void *attr);

void *createNullObject();

void setSprite(void *object, char *sprite_filepath);

void *getAttr(void *object);

int getX(void *object);

int getY(void *object);

int isNull(void *object);

int getType(void *object);

void freeObject(struct Object *obj);

void cleanObjects();
