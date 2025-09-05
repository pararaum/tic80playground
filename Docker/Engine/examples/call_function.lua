--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"

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

function TIC()
   demo:run()
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
