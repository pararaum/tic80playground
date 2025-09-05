# Demo Engine #

This demo engine was used in the [Beach
Relaxation](https://demozoo.org/productions/376676/) demo. It provides
different parts which can be switched when they are finished or after
a time delay. Each part consists of effects which are shown at the
same time. The engine presented here is a variant which will be
improved over time.

It is separated into different include files, all named "….inc.lua"
which can be included into your demo, use the preprocessor of your
choice or the one in the [T7D's Docker
Image](https://hub.docker.com/r/vintagecomputingcarinthia/tic80build). All
examples in this manual will use the Docker image. Or just keep
everything in a single file and use copy-and-paste to put the code
into your demo.

## Class System ##

The file ["class.inc.lua"](class.inc.lua) contains a base class and some convenience
classes to used in the engine.

### Class ###

The base class "Class" has two methods: "extend" and "new".

Use "extend" to derive a new class from the base class. Multiple
inheritance is currently not supported. Use like this:

```lua
Myclass = Class:extend{data = "World"}
funcion Myclass:hello()
   print("Hello " .. self.data)
end
```

Use "new" to create a new object. Using the above class:

```lua
myobj = Myclass:new{}
myobj:hello()
```

This would print "Hello World".

## Engine ##

The engine consists of some constants, convenience function, and a
demo class. Effects are the core of the demo, grouped together in
parts. As parts may keep the current effects running, parts is used as
a loosly term here.

### Constants ###

Constants for the flow control are:

  * CONTINUE: an effect returns this value if it should continue in the next frame, returning `nil` is considered equivalent
  * REMOVE: if this value is returned the effect is removed from the queue and not executed on the next frame
  * QUIT: if this value is returned then current part quits and the next frame the next part will be executed.
  
Palettes:

  * PALETTE_BLACK: an all black palette for fading off
  * PALETTE_DEFAULT: the default Tic-80 palette

### Convenience functions ###

#### mkBackground(col) ####

This function returns a function which clears the background with the
given colour "col". It is best used at the beginning of a part to
clear the screen:

```lua
...
parts = {
	{
		code = {
			mkBackground(0), -- Black background.
			... -- Some more effects
		}
	}
}
```

🗈 Note, if the `mkBackground()` call would be replaced with `cls(0)`
this would not have the desired effect as the screen would only be
cleared once when the table is build and the return value (`nil`)
would be put into the list of effects. This would be an error when
running the demo.

#### delay_frames(frames, effect) ####

After "frames" frames the effect is moved into the list of effects.

#### delay_ms(ms, effect)  ####

After "ms" milliseconds the effect is moved into the list of effects.

#### wait\_signal(signal\_name, effect) ####

This function waits for the signal with the signal name "signal_name"
and if this signal is received the effect replaces the waiting
funciton.

### Engine class ###

The demo engine class should be instanciated in the `BOOT()` function
and set some global variable, probably "demo". We will use "demo" as
our engine object throughout this documentation. Every frame in the
`TIC()` function a call to `demo:run()` should be made.

When creating the demo object pass the demo parts in the table to the
`new()` call as "parts". If needed for debugging then setting "partidx" to the number of part one would like to start with *minus one*.

The [bare minimum](examples/minimum.lua), which does acually nothing, demo code is:

```lua
--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"

function BOOT()
   demo = Engine:new{
      parts = {
		  {
			  code = {
			  }
		  }
      }
   }
end

function TIC()
   demo:run()
end
```

Information on how to build and run your first demo are provided in
[Usage section](#usage).

The "parts" entry in the table given when initialising the Engine is a
table with parts which are played one after the other. Each part in
turn is a table with the following elements:

  * code: a table with functions, objects or coroutines to call (see below)
  * append: if set to true then the current code is *appended* to the list of running effects
  * duration: duration of this part in milliseconds (but see below), if not set then the part runs endlessly (or until a QUIT is sent)
  * name: a name for this part, this is only useful for debugging as the current part is outputted via `trace()`

When using the duration keep in mind that the check if the duration is
used up is only done once per frame with a ≥ check to the current
program clock, therefore the granularity is one frame (1/60s of a
second).

The code entries in the table are either

  * functions
  * objects
  * coroutines

and are executed in the order in which they are given in the code
table. This can be used to generate layers of effects.

⚠ Due the peculiarities how Lua handles tables be aware that due to
the call by reference nature a table initialisation in a class
definition may not give the desired result. It will be shared by all
instances! ⚠

### Effects ###

Effects are defined by the user of the engine. Each effect is called
with a single argument, a list to so-called signals. The signals is a
table stored in the game engine and can be used to transport
information between effects. Usually it would contain just keys "name"
in the table which are set to `true` to signal that the signale with
name "name" is set. This is used to start actions in other effects.

The effect should return either:

  * CONTINUE: continue the effect in the next frame
  * REMOVE: remove the effect from the list of effects, it will not be played next frame
  * QUIT: quit the current part and go to the next
  * an effect which will *replace* the effect which returned the value

Optionally the effect may return a table of new effects which are
appended to the list of effects after the current effect but before
the other effects not yet executed.

## Compression ##

tbd.

# Usage #

Two possible usage option are available, one is include everything
into a huge file and write your code there or use the includes
provided by the Docker image. In the latter case the demo must be
build before it can be load in the Tic-80 virtual console.

In this manual we will use the build option as this keeps the code
size small. Use whatever is more convenient fo you.

## Build ##

The build process described here uses the [Docker
Image](https://hub.docker.com/r/vintagecomputingcarinthia/tic80build)
to create a composited Lua file. In this image the necessary tools and
include files are available.

When a file "minimum.lua" should be converted into a file loadable by Tic-80 then use

```bash
docker run -u 1000:10 --rm -it -v $PWD:/host -w /host vintagecomputingcarinthia/tic80build gpp -U "" "" "(" "," ")" "(" ")" "#" "\\" -M '--|#' "\n" " " " " "\n" "(" ")" minimum.lua > cooked.lua
#If using Docker on Windows, replace "$PWD" by "%cd%" but leave the forward slashes!
```

to build your executable Lua file. Then start Tic-80 in the directory
the "cooked.lua" file is with `tic80 --fs=. --skip`. Then load it
(`load cooked.lua`) and `run` it.

## Glue everything together ##

Copy the content of [class.inc.lua](class.inc.lua) and
[engine.inc.lua](engine.inc.lua) into one file, call it whatever you
like, e.g. "demo.lua", and add the `BOOT()` and `TIC()` functions. In
Tic-80 use `load demo.lua` (or the name you gave your demo) to load
the file and then `run` to start your demo.

TODO: Add instructions to convert into a ".tic" file.

# Examples #

## Engine ##

### Call function ###

This [example with a function call](examples/call_function.lua) just
has a single function call to the clear screen function. As this is a
static function this is a prudent choice. Excerpt:

```lua
function BOOT()
   demo = Engine:new{
      parts = {
         {
            code = {
               function()
                  cls(7)
               end
            }
         }
      }
   }
end
```

When a dynamic approach is needed then using closures is a convenient
way to implement this. We will implement a "blind" [closing the screen
from left to right](examples/call_function.2.lua). Excerpt:

```lua
function mkBlinds()
   local width = 0
   return function()
      rect(0, 0, width, 136, 11)
      if width < 240 then
         width = width + 1
      end
   end
end

function BOOT()
   demo = Engine:new{
      parts = {
         {
            code = {
               function()
                  cls(7)
               end,
               mkBlinds()
            }
         }
      }
   }
end
```

The first part has two effects, the first effect clears the screen
with a dark green colour. The second effect is a function returned
from `mkblinds()` and uses the closure to access the local variable
width, which is incremented on each call until the whole screen is
covered.

In the "Beach Relaxation" demo the exploding text was implemented
using pixels flying off in every direction. The `mkPixel()` function
uses closures to keep track of the pixel position and velocity. The
closures accessed are the function parameters passed to `mkPixel()`
which allows to generated many pixels. When the pixel is off screen
then the value `REMOVE` is returned which removes the function from
the list of effects.

```lua
-- Example from Beach Relaxation.
function mkPixel(x,y,dx,dy,col,sig)
	return function()
		pix(x,y,col)
		x=x+dx
		y=y+dy
		if x<0 or x>=240 or y<0 or y>=136 then
			return REMOVE
		end
	end
end
```

### Object ###

A [class derived from the engine base class can be used as an
effect](examples/object.lua), it needs to implement the `run()` method
which will be called every frame. Actually any table with a `run()`
method will do.

Example class for Lissajous figures:

```lua
Lissajous = Class:extend{phi1 = 4e-2, phi2 = 2e-2, omega = 0, tau1 = 0, tau2 = 0}
function Lissajous:run()
   local x = 120 + 50 * math.cos(self.phi1 *  self.omega + self.tau1)
   local y = 68 + 50 * math.sin(self.phi2 * self.omega + self.tau2)
   circ(x, y, 5, 2)
   self.omega = self.omega + 1
end
```

The Lissajous class derives from the class and implements the `run()`
method. It is instanciated as one of the effects in the `BOOT()`
function.

```lua
function BOOT()
   demo = Engine:new{
      parts = {
         {
            code = {
               function()
                  cls(8)
               end,
               Lissajous:new{tau1 = math.pi / 2}
            },
            name = "Lissajous class"
         }
      }
   }
end
```

### Coroutine ###

Using [coroutines](examples/coroutine.lua) is a convenient way to
generate functions which can be called repeatedly. In the `BOOT()`
function

```lua
function BOOT()
   demo = Engine:new{
      parts = {
         {
            code = {
               function()
                  cls(8)
               end,
               coroutine.wrap(moving_circle)
            },
            name = "coroutine"
         }
      }
   }
end
```

one part is defined with two effects. The first effect cleans the
screen in a dark blue colour, the second is a coroutine which moves a
circle around the screen. The `while` loop is an endless loop and
after each circle drawing a call to `coroutine.yield()` to leave the
function and at the next frame the coroutine is resumed.

```lua
function moving_circle()
   local phi = 0
   while true do
      local x = 120 + 50 * math.cos(phi)
      local y = 68 + 50 * math.sin(phi)
      circ(x, y, 5, 2)
      phi = phi + 4e-2
      coroutine.yield()
   end
end
```

The angle φ is incremented at each frame and a circle of a radius of
five pixels is drawn moving on the screen.

An alternative option is to [use the Coclass class to call a coroutine
at each frame](examples/coroutine.2.lua). The class is defined as
follows:

```lua
Coclass = Coroutine:extend{phi = 0}
function Coclass:coroutine()
   while true do
      local x = 120 + 50 * math.cos(self.phi)
      local y = 68 + 50 * math.sin(self.phi)
      circ(x, y, 5, 2)
      self.phi = self.phi + 4e-2
      coroutine.yield()
   end
end
```

The class definition extends the Coroutine and implements the
`coroutine()` method. The framework calls the `run()` method at each
frame and the the Coroutine class resumes the `coroutine()` method in
turn. If a more sophisticated approach for an effect is needed this is
a possible way to implement it.

### Spawning effects ###

The [pixel spawning example](examples/pixelspawning.lua) shows how to
spawn effects. The effects in this part consist of clearing the screen
with black `mkBackground(0)`, please note that `cls(0)` will not
work. The next effect is delay by 2s and displays a scroller which
will appear *behind* the pixels as it is drawn earlier (remember that
effects are executed in order).

Then the coroutine wraps the following function

```lua
function()
	while true do
		local col = math.random(9, 13)
		for counter = 1, 400 do
			if math.random() < .8 then
				local phi = math.random(0, 359)
				local r = math.random() + .2
				local x = r * math.cos(phi / 360 * math.pi * 2)
				local y = r * math.sin(phi / 360 * math.pi * 2)
				coroutine.yield(CONTINUE, { mkPixel(120, 68, x, y, col) })
			end
		end
		for i = 1, 90 do coroutine.yield(CONTINUE) end
	end
end
```

and is used for creating/spawning moving pixel. In an endless loop a
random colour is selected and for 400 frames a moving pixel is spawned
with a probability of 80%. In the line with `coroutine.yield(CONTINUE,
{ mkPixel(120, 68, x, y, col) })` the function yields and returns two
values: the first value is "CONTINUE" which signals to the engine that
the coroutine should continue and be called next frame, the second
return value is a table of newly generated effects. The generated
effect uses `mkPixel()` to generated a single moving pixel which, in
turn, is a closure that draws and moves the pixel. Once the pixel
leaves the screen it will be removed from the list of effects.

After 400 frames of spawning pixels, 90 frames will do nothing to
create simulate waves of pixels. For the delay `coroutine.yield()`
could have been used as this returns nothing (`nil`) and this is
interpreted by the engine as "continue effect".

The last effect is delayed 2.5s and displays a scroller, again. But as
this scroller is drawn later, it appear *before* the moving pixels.

## Effects ##

### Scroller ###

A [scroller example](examples/scroller.lua) shows how to use the
scroller class. A simple left-to-right scroller is available in the
[ltor-scroller.inc.lua include
file](effects/ltor-scroller.inc.lua). In the example two effects are
running, the first effect clears the screen with white. The second
effect is the scroller object. Object instantiating:

```lua
LtoRScroller:new{
	foreground = 2,
	text = "One time scroller text..."
}
```

The scroller text is set (necessary data member) and the foreground is
set to red. Once the scroller is completed the object is removed from
	the list of effects (this is configurable, though, so other values may be returned).
