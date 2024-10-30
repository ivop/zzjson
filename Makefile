CC=gcc
ifeq ($(MAKECMDGOALS),debug)
	DEBUG = -Og -g3
else
	DEBUG = -O3
endif
WARN ?= -W -Wall -Wextra -pedantic
INCLUDES = -Iinclude
CFLAGS = $(WARN) $(DEBUG) -fsigned-char $(INCLUDES) $(EXTRA_CFLAGS)
LFLAGS = $(EXTRA_LFLAGS)
LIBS = -lm

FILES = zzjson_create.c zzjson_free.c zzjson_parse.c zzjson_print.c \
		zzjson_query.c
TEST_FILES = zzjson_test.c

SRC_FILES = $(FILES:%.c=src/%.c)
OBJ_FILES = $(SRC_FILES:%.c=%.o)

SRC_TEST = $(TEST_FILES:%.c=src/%.c)
OBJ_TEST = $(SRC_TEST:%.c=%.o)

STATIC_LIB = libzzjson.a
SHARED_LIB = libzzjson.so
TEST = zzjson_test

all: $(STATIC_LIB) $(SHARED_LIB)

test: $(TEST)

$(STATIC_LIB): $(OBJ_FILES)
	$(AR) rcs $@ $^

$(SHARED_LIB): $(OBJ_FILES)
	$(CC) -shared -o $@ $^

$(TEST): $(OBJ_TEST) $(STATIC_LIB)
	$(CC) $(LFLAGS) -o $@ $^ $(LIBS)

example1: examples/example1.c $(STATIC_LIB)
	$(CC) $(LFLAGS) $(CFLAGS) -o $@ $^

example2: examples/example2.c unicode/unicode_callbacks.c $(STATIC_LIB)
	$(CC) $(LFLAGS) $(CFLAGS) -Iunicode -o $@ $^ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJ_FILES) $(OBJ_TEST) *~ $(STATIC_LIB) $(SHARED_LIB) $(TEST) \
		example1 example2
