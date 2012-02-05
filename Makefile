LESSC := ./node_modules/less/bin/lessc
COFFEE := ./node_modules/coffee-script/bin/coffee
SCRIPT := script
STYLE := style
STATIC := static

files = $(patsubst $(subst *,%,$(1)),$(2),$(wildcard $(1)))

all: dirs style script server.js
	

dirs:
	[ ! -d '$(STATIC)' ] && mkdir '$(STATIC)' || true
	[ ! -d '$(STATIC)/$(STYLE)' ] && mkdir '$(STATIC)/$(STYLE)' || true
	[ ! -d '$(STATIC)/$(SCRIPT)' ] && mkdir '$(STATIC)/$(SCRIPT)' || true
	[ ! -d '$(STYLE)' ] && mkdir '$(STYLE)' || true
	[ ! -d '$(SCRIPT)' ] && mkdir '$(SCRIPT)' || true

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

lessfiles = $(call files,$(STYLE)/*.less,$(STATIC)/$(STYLE)/%.css)
cssfiles = $(call files,$(STYLE)/*.css,$(STATIC)/$(STYLE)/%.css)
style: $(lessfiles) $(cssfiles)
	

$(STATIC)/$(STYLE)/%.css: %.less
	$(LESSC) -x $< > $@

$(STATIC)/$(STYLE)/%.css: %.css
	cp $< $@

coffeefiles = $(call files,$(SCRIPT)/*.coffee,$(STATIC)/$(SCRIPT)/%.js)
jsfiles = $(call files,$(SCRIPT)/*.js,$(STATIC)/$(SCRIPT)/%.js)
script: $(coffeefiles) $(jsfiles)
	

$(STATIC)/$(SCRIPT)/%.js: %.coffee
	$(COFFEE) -o $(dir $@) -c $<

$(STATIC)/$(SCRIPT)/%.js: %.js
	cp $< $@

clean:
	rm $(STATIC)/$(STYLE)/*.css || true
	rm $(STATIC)/$(SCRIPT)/*.js || true
	rm $(DIR)server.js || true
