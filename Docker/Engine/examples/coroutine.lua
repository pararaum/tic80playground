--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"

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

function TIC()
   demo:run()
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
