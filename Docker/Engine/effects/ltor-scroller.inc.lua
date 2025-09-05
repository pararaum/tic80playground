-- Left to Right Scroller class.
LtoRScroller = Class:extend{
   foreground = 7, -- Foreground colour
   x = 240, -- Beginning X position
   y = 60, -- Y position
   dx = 1, -- Delta X per frame.
   final_return = REMOVE, -- Return this value once the scroller has run fully
   fixed = true -- Use a fixed width font
   -- text -- Set to the text to be displayed
}
function LtoRScroller:run()
   local width = print(self.text, self.x, self.y, self.foreground, self.fixed)
   self.x = self.x - self.dx
   if self.x < -width then
      return self.final_return
   end
end
