--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"

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

function BOOT()
   demo = Engine:new{
      parts = {
         {
            code = {
               function()
                  cls(8)
               end,
               Coclass:new{}
            },
            name = "coroutine class"
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
