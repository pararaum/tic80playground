--|#include "t7d/class.inc.lua"
--|#include "t7d/engine.inc.lua"

Lissajous = Class:extend{phi1 = 4e-2, phi2 = 2e-2, omega = 0, tau1 = 0, tau2 = 0}
function Lissajous:run()
   local x = 120 + 50 * math.cos(self.phi1 *  self.omega + self.tau1)
   local y = 68 + 50 * math.sin(self.phi2 * self.omega + self.tau2)
   circ(x, y, 5, 2)
   self.omega = self.omega + 1
end

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

function TIC()
   demo:run()
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
