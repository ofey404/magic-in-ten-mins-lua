objects := $(patsubst %.md,%.lua,$(wildcard *.md))

all: $(objects)

md: sketch.md
lua: sketch.lua

%.lua: %.md
	cat $< | lua generate.lua > $@

sketch.md:
	cat sketch.lua | lua generate.lua --lua2md > $@

sketch.lua:
	cat sketch.md | lua generate.lua > $@

clean:
	rm -f $(objects)

.PHONY: sketch.lua sketch.md