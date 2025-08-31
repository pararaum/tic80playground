
How to transform font images
============================

$ history |grep convert
 2008  convert ../STO16X16.GIF +gravity -crop 16x16 tiles-%02x.png
 2027  convert ../STO16X16.GIF +gravity -crop 16x16 tiles-%03d.png
 2066  history |grep convert
$ #Reorder by hand...
$ history |grep montage
 2035  montage font-0* -geometry +0+0 out.png
 2043  montage font-0* -geometry +0+0 out.png
 2067  history |grep montage


Divide
------

See:

 * http://www.imagemagick.org/Usage/crop/
 * http://www.imagemagick.org/Usage/crop/#crop_tile

Subdivide into eight times eight tiles: `convert 37148_sim1_font11_long_\(no_shadow\)_blue_-final.png +gravity -crop 8x8 tiles_%02x.png`.
Subdivide if number of tiles is known: `convert 37147_terminal_fonts_03.xpm -crop 80x1@ +repage +adjoin chars_%02x.png`.

Montage
-------

 * http://www.imagemagick.org/Usage/montage/

Montage all image into a large one without space and try to guess the final size: `montage tiles_* -geometry +0+0 /tmp/all.png`.
Use the tile operator to specify the tiling, here a single column: `montage tile.* -tile 1x -geometry +0+0 full.xpm`.
And a single row: `montage tile.* -tile x1 -geometry +0+0 full.xpm`.

Traps
-----

The XBM file format stores the first pixel in the LSB! This will
effectively mirror each character if copied vanilla into the graphics
hardware.
