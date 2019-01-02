# Makefile for libghttp test
CC = gcc
CFLAGS = -g
OBJS = $(patsubst %c, %o, $(wildcard *.c))

PATH_REPO=$(shell git rev-parse --show-toplevel)
PATH_PWD=$(shell pwd)
PATH_LIBGHTTP=$(PATH_PWD)/libghttp

CFLAGS += -I$(PATH_LIBGHTTP)/include
LDFLAGS += -L$(PATH_LIBGHTTP)/lib -l:libghttp.a

Target = test_all.out

all: $(Target)

DEPS := $(OBJS:.o=.d)
-include $(DEPS)
CFLAGS += -MMD -MP
CXXFLAGS += -MMD -MP


%.o:%.c $(HEADER)
	$(CC) $(CFLAGS) -c $< -o $@

$(Target):$(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

.PHONY:clean
clean:
	rm -rf *.o *.out $(Target) $(DEPS)

.PHONY:distclean
distclean:
	rm -rf *.o *.out $(Target) $(DEPS) libghttp/
