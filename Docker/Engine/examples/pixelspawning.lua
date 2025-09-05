--[[
   Spawning pixels
]]--
--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"
--|#include "t7d/effects/mkpixel.inc.lua"
--|#include "t7d/effects/ltor-scroller.inc.lua"

function BOOT()
   demo = Engine:new{
      parts = {
         {
            code = {
               mkBackground(0),
	       delay_ms(2000, LtoRScroller:new{ y = 50, dx = .5, foreground = 6, text = "### Scroller behind the moving pixels... ###" }),
	       coroutine.wrap(
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
	       ),
	       delay_ms(2500, LtoRScroller:new{ y = 78, dy = .75, foreground = 6, text = "Scroller in front of the moving pixels..." }),
	    },
	    name = "Spawn!"
         }
      }
   }
end

function TIC()
   demo:run()
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
