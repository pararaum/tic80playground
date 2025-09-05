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
