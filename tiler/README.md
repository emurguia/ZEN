# tiler
tiler is a 2D turn-based gaming language.

## Prereqs
### OCaml LLVM library
Most easily installed through opam. Install LLVM and its development libraries, the m4 macro preprocessor, and opam, then use opam to install llvm.

### SDL
Download the source code:
https://www.libsdl.org/download-2.0.php
or ```brew install sdl2```

Run
```
mkdir mybuild
cd mybuild
CC=$PWD/../build-scripts/gcc-fat.sh CXX=$PWD/../build-scripts/g++-fat.sh ../configure
make
sudo make install 
```

## Compiling and running .tile
```shell
make all
make helloworld.game
./helloworld
 ```
 
## Running Tests
```./testall.sh```

## How to test the parser
``` menhir --interpret --interpret-show-cst parser.mly ```

## How to generate LLVM from C
``` clang -S -emit-llvm tiler-caller.c ```

