CC = gcc
CFLAGS = -Wall -Werror -Wextra -std=c11 -O2

SRC_DIR = ./src
BUILD_DIR = ./build

Program_OUT = $(BUILD_DIR)/tlp-app
Program_SRC = $(SRC_DIR)/main.c

all: main

main: $(BUILD_DIR) $(Program_SRC)
	$(CC) $(CFLAGS) $(Program_SRC) -o $(Program_OUT)

run: $(BUILD_DIR) $(Program_OUT)
	sudo $(Program_OUT)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

rebuild: clean all

clean:
	rm -rf $(BUILD_DIR)/*
