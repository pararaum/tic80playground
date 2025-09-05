-- A (moving) pixel.

-- Make a pixel.
--
-- If the pixel leaves the screen, it is removed.
--
-- Parameters
--	x: starting X position
--	y: starting Y position
--	dx: delta X per frame
--	dy: delty Y per frame
--	col: pixel colour
function mkPixel(x, y, dx, dy, col)
   return function()
      pix(x, y, col)
      x = x + dx
      y = y + dy
      if x < 0 or x >= 240 or y < 0 or y >= 136 then
         return REMOVE
      end
   end
end
