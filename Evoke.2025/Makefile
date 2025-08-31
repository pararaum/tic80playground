#! /usr/bin/make -f

TARGET=beach_relaxation

VPATH=images
GPP=gpp -U "" "" "(" "," ")" "(" ")" "\#" "\\" -M '--|\#' "\n" " " " " "\n" "(" ")" $(GPPFLAGS)
#GPP=luapp

all: $(TARGET).cooked.lua

.PHONY: all clean
clean:
	rm -rf $(TARGET).cooked.lua
	rm -rf *.image.lua
	rm -rf *.tiles.lua
	rm -rf *.palette.lua
	rm -rf *.font.lua

%.tiles.lua: %.png
	./tools/imagetool.py -t -n $(basename $<) $< > $@

%.palette.lua: %.png
	./tools/imagetool.py -p -n $(basename $<) $< > $@

%.image.lua: %.png
	./tools/imagetool.py -p -7 -n $(basename $<) $< > $@

%.font.lua: %.ch8
	./tools/imagetool.py -f -n $(basename $<) $< > $@

$(TARGET).cooked.lua:	$(TARGET).lua \
	class.inc.lua compression.inc.lua engine.inc.lua \
	beach_relaxation.ticdata.lua \
	animation.dog-02.tiles.lua \
	crab.tiles.lua \
	f1000017.960x128.image.lua \
	class.inc.lua \
	font.sto16x16.artist_made.palette.lua font.sto16x16.artist_made.tiles.lua \
	Beachball.font.lua \
	animation.dolphin.tiles.lua \
	mokki.beach-seagulls.image.lua mokki.beach-seagulls.1.image.lua mokki.beach-seagulls.2.image.lua mokki.beach-seagulls.3.image.lua \
	mokki.beach-foreground.image.lua mokki.beach-background.image.lua
	$(GPP) -o $@ $<
