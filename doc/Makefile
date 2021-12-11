objects := $(patsubst %.md,%.lua,$(wildcard *.md))

all: $(objects)

$(objects): %.lua: %.md
	cat $< | lua generate.lua > $@

clean:
	rm $(objects)