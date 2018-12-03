#include <stdio.h>
#include "SDL.h"
#include "tiler-object.h"

// global variables
extern struct ObjRefList obj_refs;

void addObject(struct Object *obj) {
	// allocate space for new node
	struct ObjNode *node = (struct ObjNode *) malloc(sizeof(struct ObjNode));
	if (!node) {
		fprintf(stderr, "malloc returned NULL");
		return;
	}

	// set node values
	node->obj = obj;
	node->next = obj_refs.head;
	obj_refs.head = node;
}

int listIsEmpty() {
	return obj_refs.head == NULL;
}

struct Object* removeHead() {
	struct ObjNode *node = obj_refs.head;
	obj_refs.head = obj_refs.head->next;
	struct Object *obj = node->obj;
	free(node);
	return obj;
}

struct Object *removeObject(struct Object *obj) {
	// check for empty list
	if (listIsEmpty()) {
		return NULL;
	}

	// if object is head of list
	struct ObjNode *cur = obj_refs.head;
	if (cur->obj == obj) {
		return removeHead();
	}

	// object down list
	struct ObjNode *last = cur;
	cur = cur->next;
	while (cur != NULL && cur->obj != obj) {
		cur = cur->next;
		last = last->next;
	}

	
	if (cur != NULL) {
		struct Object *result = cur->obj;
		last->next = cur->next;
		free(cur);
		return result;
	}
	else { // not found
		return NULL;
	}
}

void* createObject(void *attr) {
	// create space for object
	struct Object *obj = (struct Object *) malloc(sizeof(struct Object));
	if (!obj) {
		fprintf(stderr, "malloc returned NULL");
		return NULL;
	}

	// set to be not null
	obj->classCode = 1;

	// set sprite to NULL
	obj->sprite = NULL;

	// init not on grid
	obj->isOnGrid = 0;
	addObject(obj);

	// set the pointer to attribute struct
	obj->attr = attr;

	return (void *) obj;
}

void *createNullObject() {
	// create space for object
	struct Object *obj = (struct Object *) malloc(sizeof(struct Object));
	if (!obj) {
		fprintf(stderr, "malloc returned NULL");
		return NULL;
	}

	// set to be null
	obj->classCode = 0;

	// set sprite to NULL
	obj->sprite = NULL;

	// init not on grid
	obj->isOnGrid = 0;
	addObject(obj);

	// set the attribute pointer to NULL
	obj->attr = NULL;

	return (void *) obj;
}

void setSprite(void *object, char *sprite_filepath) {
	struct Object *obj = (struct Object *) object;

	// set the sprite
	obj->sprite = SDL_LoadBMP(sprite_filepath);
	if (!obj->sprite) {
		fprintf(stderr, "SDL_LoadBMP Error: %s\n", SDL_GetError());
	}
}

int getX(void *object) {
	struct Object *obj = (struct Object *) object;
	return obj->x;
}

int getY(void *object) {
	struct Object *obj = (struct Object *) object;
	return obj->y;
}

void *getAttr(void *object) {
	struct Object *obj = (struct Object *) object;
	return obj->attr;
}

int isNull(void *object) {
	struct Object *obj = (struct Object *) object;
	return !obj->classCode;
}

int getType(void *object) {
	struct Object *obj = (struct Object *) object;
	return obj->classCode;
}

void freeObject(struct Object *obj) {
	if (obj->attr) { free(obj->attr); }
	SDL_FreeSurface(obj->sprite);
	free(obj);
}

void cleanObjects() {
	while (obj_refs.head) {
		freeObject(removeHead());
	}
}
