LESSC := node_modules/less/bin/lessc
COFFEE := node_modules/coffee-script/bin/coffee
SCRIPT := script
STYLE := style
STATIC := static

files = $(patsubst $(subst *,%,$(1)),$(2),$(wildcard $(1)))

all: style script server.js
	

server.js: server.coffee
	$(COFFEE) -c $<
	sed -i '1i#!/usr/bin/node' $@
	chmod +x $@

vpath %.coffee $(SCRIPT)
vpath %.js $(SCRIPT)
%.js: %.coffee
	$(COFFEE) -c $<

vpath %.less $(STYLE)
vpath %.css $(STYLE)
%.css: %.less
	$(LESSC) -x $< > $@

lessfiles = $(call files,$(STYLE)/*.less,$(STATIC)/style/%.css)
cssfiles = $(call files,$(STYLE)/*.css,$(STATIC)/style/%.css)
style: $(lessfiles) $(cssfiles)
	

$(STATIC)/style/%.css: %.less
	$(LESSC) -x $< > $@

$(STATIC)/style/%.css: %.css
	cp $< $@

coffeefiles = $(call files,$(SCRIPT)/*.coffee,$(STATIC)/script/%.js)
jsfiles = $(call files,$(SCRIPT)/*.js,$(STATIC)/script/%.js)
script: $(coffeefiles) $(jsfiles)
	

$(STATIC)/script/%.js: %.coffee
	$(COFFEE) -o $(dir $@) -c $<

$(STATIC)/script/%.js: %.js
	cp $< $@

clean:
	rm $(STATIC)/style/*.css || true
	rm $(STATIC)/script/*.js || true
	rm $(DIR)server.js || true
