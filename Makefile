generate:
	lua ./doc/generate.lua

clean: $(OUTPUT_LUAS)
	rm -f $(OUTPUT_LUAS)