# No uname.exe on MinGW!, but OS=Windows_NT on Windows!
# ifeq ($(UNAME),Msys) -> Windows
ifeq ($(OS),Windows_NT)
	PLATFORM_OS?=WINDOWS
else
	UNAMEOS=$(shell uname)
	ifeq ($(UNAMEOS),Linux)
		PLATFORM_OS?=LINUX
	endif
	ifeq ($(UNAMEOS),Darwin)
		PLATFORM_OS?=OSX
	endif
endif

CC = clang
COMMON_CFLAGS = -Wall -Wextra -std=c17 -g
COMMON_LDFLAGS =
BUILD = build

TARGET1_SRC = $(wildcard src/game/*.c)
TARGET1_OBJ = $(patsubst %.c,$(BUILD)/%.o,$(TARGET1_SRC))
TARGET1_DEP = $(patsubst %.c,$(BUILD)/%.d,$(TARGET1_SRC))

ifeq ($(PLATFORM_OS),WINDOWS)
	TARGET1_CFLAGS = \
		$(COMMON_CFLAGS) \
		-D PLATFORM_WINDOWS \
		-isystem./lib/raylib-3.7.0/win64_mingw-w64/include \
		-isystem./lib/raygui-2.6/src \
		-I./src/game \
		-MMD # Option to generate a .d file during compilation.

	TARGET1_LDFLAGS = \
		$(COMMON_LDFLAGS) \
		-L./lib/raylib-3.7.0/win64_mingw-w64/lib \
		-lraylib -lopengl32 -lgdi32 -lwinmm
endif
ifeq ($(PLATFORM_OS),OSX)
	TARGET1_CFLAGS = \
		$(COMMON_CFLAGS) \
		-D PLATFORM_MACOS \
		-isystem./lib/raylib-3.7.0/macos/include \
		-isystem./lib/raygui-2.6/src \
		-I./src/game \
		-MMD # Option to generate a .d file during compilation.

	TARGET1_LDFLAGS = \
		$(COMMON_LDFLAGS) \
		./lib/raylib-3.7.0/macos/lib/libraylib.a \
		-framework OpenGL \
		-framework Cocoa \
		-framework IOKit \
		-framework CoreAudio \
		-framework CoreVideo
endif
ifeq ($(PLATFORM_OS),LINUX)
	TARGET1_CFLAGS = \
		-D PLATFORM_LINUX \
		-isystem./lib/raylib-3.7.0/linux_amd64/include \
		-isystem./lib/raygui-2.6/src \
		-I./src/game \
		-MMD # Option to generate a .d file during compilation.

	TARGET1_LDFLAGS = \
		$(COMMON_LDFLAGS) \
		./lib/raylib-3.7.0/linux_amd64/lib/libraylib.a \
		-lGL -lm -lpthread -ldl -lrt -lX11
endif
ifeq ($(PLATFORM_OS),WEB)
	# HTML5 emscripten compiler
	# WARNING: To compile to HTML5, code must be redesigned
	# to use emscripten.h and emscripten_set_main_loop()

	CC = emcc

	TARGET1_CFLAGS = \
		-D PLATFORM_WEB \
		-Os \
		-isystem./lib/raylib-3.7.0/wasm/include \
		-isystem./lib/raygui-2.6/src \
		-I./src/game \
		-MMD # Option to generate a .d file during compilation.

	TARGET1_LDFLAGS = \
		./lib/raylib-3.7.0/wasm/lib/libraylib.a \
		-Os -s USE_GLFW=3 -s TOTAL_MEMORY=16777216 --preload-file assets --shell-file ./src/shell.html

	EXT = .html
endif

all: game

game: $(BUILD)/src/main.o $(TARGET1_OBJ)
	$(CC) -o $@$(EXT) $^ $(TARGET1_LDFLAGS)

game-web:
	docker run \
  --rm \
  -v $(shell pwd):/src \
  -u $(shell id -u):$(shell id -g) \
  emscripten/emsdk:2.0.29 \
  make PLATFORM_OS=WEB

test: $(BUILD)/src/test.o $(TARGET1_OBJ)
	$(CC) -o $@ $^ $(TARGET1_LDFLAGS)

# Include all dep files in the makefile, so if a .h change, the .c files are rebuilt.
-include $(TARGET1_DEP)

$(BUILD)/src/game/%.o: src/game/%.c
	$(CC) $(TARGET1_CFLAGS) -o $@ -c $<

$(BUILD)/src/main.o: src/main.c
	$(CC) $(TARGET1_CFLAGS) -o $@ -c $<

$(BUILD)/src/test.o: src/test.c
	$(CC) $(TARGET1_CFLAGS) -o $@ -c $<

clean:
	rm -fr $(BUILD) game* test

run: game
	./game

run-web:
	python3 ./wasm-serve.py

run-test: test
	./test

.PHONY: all clean run run-web test game-web

$(shell mkdir -p build/src/game)
