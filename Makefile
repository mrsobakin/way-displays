include config.mk

INC_H = $(wildcard inc/*.h)

SRC_C = $(wildcard src/*.c)
SRC_CXX = $(wildcard src/*.cpp)
SRC_O = $(SRC_C:.c=.o) $(SRC_CXX:.cpp=.o)

PRO_X = $(wildcard pro/*.xml)
PRO_H = $(PRO_X:.xml=.h)
PRO_C = $(PRO_X:.xml=.c)
PRO_O = $(PRO_X:.xml=.o)

TST_C = $(wildcard tst/*.c)
TST_O = tst/test.o

TST_LDLIBS  = -lcmocka
TST_WRAPS = -Wl,--wrap=first,--wrap=second

# all: way-layout-displays test tags .copy
all: way-layout-displays tags .copy

$(SRC_O): $(INC_H) $(PRO_H)
$(PRO_O): $(PRO_H)
$(TST_O): $(INC_H) $(PRO_H) $(TST_C)

way-layout-displays: $(SRC_O) $(PRO_O)
	$(CXX) -o $(@) $(^) $(LDFLAGS) $(LDLIBS)

$(PRO_H): $(PRO_X)
	wayland-scanner client-header $(@:.h=.xml) $@

$(PRO_C): $(PRO_X)
	wayland-scanner private-code $(@:.c=.xml) $@

test: $(filter-out %main.o,$(SRC_O)) $(PRO_O) $(TST_O)
	$(CXX) -o $(@) $(^) $(LDFLAGS) $(LDLIBS) $(TST_LDLIBS) $(TST_WRAPS)
	./test

clean:
	rm -f way-layout-displays test $(SRC_O) $(PRO_O) $(PRO_H) $(PRO_C) $(TST_O) tags .copy

# https://github.com/alex-courtis/arch/blob/b530f331dacaaba27484593a87ca20a9f53ab73f/home/bin/ctags-something
tags: $(SRC_C) $(INC_H) $(PRO_H) $(TST_C)
	which ctags-c > /dev/null 2>&1 && \
		ctags-c $(CFLAGS) $(CPPFLAGS) --project-src $(^) || \
		true

.copy: way-layout-displays
	scp $(^) alw@gigantor:/home/alw/bin
	scp cfg.yaml alw@gigantor:.config/way-layout-displays/cfg.yaml
	@touch .copy

.PHONY: all clean

