/////////////////////////////////////////////////////////////////////
//               TILER RUNTIME LIBRARY FUNCTIONS                   //
/////////////////////////////////////////////////////////////////////

void createGame()
==> makes a new game with the default properties

void setTitle(const char *title)
==> sets the title property for the game

void setWindow(int width, int height)
==> sets the game window size properties

void setBackgroundColor(int red, int green, int blue)
==> sets the rgb for the game background draw color

void setInit(void(*init)())
==> sets the init function pointer

void setTurn(void(*turn)())
==> sets the turn function pointer

void setEnd(int(*end)())
==> sets the end function pointer

void runGame()
==> opens an SDL window wiht the current game properties and executes
    the game loop logic

void setBackground(char *filepath)
==> sets the background texture to be the .bmp file at the given 
    filepath

void createGrid(int width, int height)
==> creates a new game grid with the given dimensions

int gridWidth()
==> returns the width of the game grid

int gridHeight()
==> returns the height of the game grid

void setGrid(void *object, int x, int y)
==> places the given object at the given grid coordinate

void clearGrid(int x, int y)
==> clears the object at the given grid coordinate

void *getGrid(int x, int y)
==> returns the object at the given grid coordinate

int isEmpty(int x, int y)
==> returns 1 if the given grid coordinate is the null object or 0 if
    it is not the null object

void *createObject(void *attr)
==> creates and returns a pointer to a new tiler object with the given
    attributes passed in as a void pointer to a struct

void *createNullObject()
==> creates and returns a new null object

void setSprite(void *object, char *sprite_filepath)
==> sets the sprite for the given object to be the image contianed in
    the .bmp file at the given filepath

void *getAttr(void *object)
==> gets the pointer to the attribute struct for the given object

int getX(void *object)
==> gets the x value of the object

int getY(void *object)
==> gets the y value of the object

void isNull(void *object)
==> returns 1 if the given object is the null object, 0 otherwise
    *note: tests for the tiler nullness property and not the nullness
	of the object pointer

void getMouseCoords(void *tuple_ptr)
==> waits for the user to click, then populates the pointer with the
    x,y coordinates of the grid coordinate which was clicked