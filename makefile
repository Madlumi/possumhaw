
# ############################
# #         MAKEFILE         #
# ############################

SHELL := /bin/bash

ODIN      ?= odin
EMCC      ?= emcc
PYTHON    ?= python3
PORT      ?= 8080
EMSDK_ENV ?= $(HOME)/emsdk/emsdk_env.sh

SRC_DIR := src
RES_DIR := res
OUT_DIR := out

ODIN_ROOT   := $(shell $(ODIN) root 2>/dev/null)
RAYLIB_WASM := $(ODIN_ROOT)/vendor/raylib/wasm/libraylib.a
RAYGUI_WASM := $(ODIN_ROOT)/vendor/raylib/wasm/libraygui.a
ODIN_JS     := $(ODIN_ROOT)/core/sys/wasm/js/odin.js

EMCC_FLAGS := \
	-sEXPORTED_RUNTIME_METHODS='["HEAPF32"]' \
	-sUSE_GLFW=3 \
	-sWASM_BIGINT \
	-sWARN_ON_UNDEFINED_SYMBOLS=0 \
	-sASSERTIONS=1 \
	-sASYNCIFY=1

.PHONY: help web run-web clean

help:
	@echo "make web      build browser version into out/"
	@echo "make run-web  build and serve out/ on port $(PORT)"
	@echo "make clean    remove out/"

web:
	set -eu; \
	export EMSDK_QUIET=1; \
	if ! command -v $(EMCC) >/dev/null 2>&1; then \
		test -f "$(EMSDK_ENV)" || { echo "emcc not found, set EMSDK_ENV=/path/to/emsdk_env.sh"; exit 1; }; \
		source "$(EMSDK_ENV)"; \
	fi; \
	test -n "$(ODIN_ROOT)" || { echo "odin root failed"; exit 1; }; \
	test -f "$(RAYLIB_WASM)" || { echo "missing $(RAYLIB_WASM)"; exit 1; }; \
	test -f "$(RAYGUI_WASM)" || { echo "missing $(RAYGUI_WASM)"; exit 1; }; \
	test -f "$(ODIN_JS)" || { echo "missing $(ODIN_JS)"; exit 1; }; \
	rm -rf "$(OUT_DIR)"; \
	mkdir -p "$(OUT_DIR)"; \
	$(ODIN) build "$(SRC_DIR)" \
		-target:js_wasm32 \
		-build-mode:obj \
		-define:RAYLIB_WASM_LIB=env.o \
		-define:RAYGUI_WASM_LIB=env.o \
		-out:"$(OUT_DIR)/game.wasm.o"; \
	cp "$(ODIN_JS)" "$(OUT_DIR)/odin.js"; \
	$(EMCC) -o "$(OUT_DIR)/index.html" \
		"$(OUT_DIR)/game.wasm.o" \
		"$(RAYLIB_WASM)" \
		"$(RAYGUI_WASM)" \
		$(EMCC_FLAGS) \
		--shell-file index.html \
		--preload-file "$(RES_DIR)@$(RES_DIR)"; \
	rm -f "$(OUT_DIR)/game.wasm.o"

run-web: web
	cd "$(OUT_DIR)" && $(PYTHON) -m http.server "$(PORT)"

clean:
	rm -rf "$(OUT_DIR)"

# ############################
# #         MAKEFILE         #
# ############################
