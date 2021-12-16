articles := $(filter-out sketch.md,$(wildcard *.md))
objects := $(patsubst %.md,%.lua,$(articles))

all: $(objects)

$(objects): $(articles)
	cat $< | lua generate.lua > $@

sketch.md: sketch.lua
	cat sketch.lua | lua generate.lua --lua2md > $@

clean:
	rm -f $(objects)
