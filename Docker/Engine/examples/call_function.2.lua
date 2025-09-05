--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"

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

function TIC()
   demo:run()
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
