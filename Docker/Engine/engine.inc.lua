--===========================================================================
-- Engine
--===========================================================================

-----------------------------------------------------------------------------
-- Constants.
-----------------------------------------------------------------------------

REMOVE=true -- Constant to return when an effect should be removed.
CONTINUE=false -- Continue effect in next frame, nil is also ok.
QUIT="quit" -- Quit the current part and go to next.

PALETTE_BLACK={{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}} -- A completely black palette.
PALETTE_DEFAULT={{26,28,44},{93,39,93},{177,62,83},{239,125,87},{255,205,117},{167,240,112},{56,183,100},{37,113,121},{41,54,111},{59,93,201},{65,166,246},{115,239,247},{244,244,244},{148,176,194},{86,108,134},{51,60,87}} -- The default Tic80 palette.

-----------------------------------------------------------------------------
-- Functions to change the Tic80 state with convenience.
-----------------------------------------------------------------------------

-- A function to set the palette a list of (r,g,b) tuples is expected.
function setPalette(palette)
   for i,col in ipairs(palette) do
      local iz=i-1
      local r,g,b=table.unpack(col)
      poke(0x3fc0+3*iz, r)
      poke(0x3fc0+3*iz+1, g)
      poke(0x3fc0+3*iz+2, b)
   end
end


-- A function to get the current palette values as (r,g,b) tuples.
function getPalette()
   local pal={}
   for iz=0,15 do
      local r,g,b=peek(0x3fc0+3*iz),peek(0x3fc0+3*iz+1),peek(0x3fc0+3*iz+2)
      table.insert(pal,{r,g,b})
   end
   return pal
end


-- Mix frompalette to topalette and factor is between [0..1].
function mixPalette(frompalette,topalette,factor)
   for colidx=1,16 do
      local colidxz=colidx-1
      local fromr,fromg,fromb=table.unpack(frompalette[colidx])
      local tor,tog,tob=table.unpack(topalette[colidx])
      poke(0x3fc0+3*colidxz  , math.floor(fromr+(tor-fromr)*factor))
      poke(0x3fc0+3*colidxz+1, math.floor(fromg+(tog-fromg)*factor))
      poke(0x3fc0+3*colidxz+2, math.floor(fromb+(tob-fromb)*factor))
   end
end


-----------------------------------------------------------------------------
-- Functions which create functions that can be directly used in the effects.
-----------------------------------------------------------------------------

-- The returned function will clear the screen with the given colour.
function mkBackground(col)
   return function() cls(col) end
end

-- Return a function for fading a palette.
--
-- frompalette: Palette with r,g,b colour-information or nil if current palette
-- topalette: Palette with r,g,b to fade to
-- speed: [0.0 .. 1.0]
-- remove: remove this effect after destination palette was reached otherwise palette is set on each call
function fadePalette(frompalette,topalette,speed,remove)
   local factor=0
   if frompalette==nil then
      frompalette=getPalette()
   end
   return function()
      while factor<1 do
	 mixPalette(frompalette,topalette,factor)
	 factor=factor+speed
	 return
      end
      setPalette(topalette)
      if remove then return REMOVE end
   end
end


-- Create a function which sets the palette to the given functions. If oneshot is set to true then the palette function is removed after it has been called once.
function mkPalette(palette,oneshot)
   if palette==nil then return end
   return function() setPalette(palette) end
end


function mkDefaultPalette()
   local palette={{26,28,44},{93,39,93},{177,62,83},{239,125,87},{255,205,117},{167,240,112},{56,183,100},{37,113,121},{41,54,111},{59,93,201},{65,166,246},{115,239,247},{244,244,244},{148,176,194},{86,108,134},{51,60,87}}
   return mkPalette(palette)
end


-- Create a function which will draw an image from LZ77-compressed data.
--
-- data: LZ77-compressed data, either as a table of tables or a string
-- palette: a palette, may be nil
-- colkey: if not nil, then this color is not draw
-- destination: destination address in memory, defaults to 0, which is VRAM screen
function mkLZ77Image(data, palette, colkey, destination)
   local uncompressed,pfun=uncompressLZ77(data),mkPalette(palette)
   return function()
      if pfun ~= nil then
	 pfun()
      end
      destination=destination or 0
      for i,d in ipairs(uncompressed) do
	 if colkey==nil or d~=colkey then
	    poke4(destination+i-1,d)
	 end
      end
   end
end



-----------------------------------------------------------------------------
-- Engine control functions.
-----------------------------------------------------------------------------

-- Wait the number of frames and then replace the waiting function
-- with the effect. Can be used for delayed effects.
function delay_frames(frames,effect)
   return function()
      while frames>0 do
	 frames=frames-1
	 return
      end
      return effect
   end
end


-- Wait ms milliseconds and then replace the waiting function with the
-- effect. Can be used for delayed effects.
function delay_ms(ms,effect)
   -- Use a wrapper function to start the timer at the first call of
   -- the function.
   return function()
      local untiltime=time()+ms
      return function()
	 if time()>=untiltime then
	    return effect
	 end
      end
   end
end


-- Wait until a signal is sent and then replace the waiting function
-- with the effect.
function wait_signal(signal2wait,effect)
   return function(signals)
      if signals[signal2wait] then
	 return effect
      end
   end
end


-----------------------------------------------------------------------------
-- The Engine™ class
-----------------------------------------------------------------------------
--[[
   Every part has the following information:

   - append (optional): if set to true then the current code is appended to the list of running effects
   - *TODO*: background (optional): function called before any effects
   - *TODO*: bdr (optional): this function is set as BDR()
   - code: array of effects that are played simultaneously, see TIC
   - duration: duration in milliseconds
   - name: a name for this part, only used for debugging
   --
]]
Engine=Class:extend(
   {
      --finished=nil, -- This gives the point in time when the current part is finished, if it is nil then the part has no time limit.
      partidx=0, -- Initialise with index *before* first part.
      running={}, -- The currently running effects, starts empty.
      signals={}, -- A parameter passed to effect functions, is a simple set implemented by a table in which element is set to true (signals["value"]=true), set to nil to remove entry from set.
      -- parts={} -- Must be defined later or nothing will happen!
   }
)
function Engine:init()
   trace("--------------------------------- Engine:init()")
   self:next_part()
end
function Engine:next_part()
   self.partidx=self.partidx+1
   if self.partidx>#self.parts then
      self.partidx=1
   end
   local curr=self.parts[self.partidx]
   --|#ifndef NDEBUG
   trace(string.format('-------------------------------------------- Engine:next part #%d("%s")',self.partidx,curr.name))
   trace(time())
   --|#endif
   local newruns={} -- New table as tables are handled by reference! And append otherwise makes it bigger and bigger!
   if curr.append then -- We append, so copy existings effects.
      for _,i in ipairs(self.running) do
	 table.insert(newruns, i)
      end
   end
   for _,i in ipairs(curr.code) do -- Always copy new effects.
      table.insert(newruns, i)
   end
   self.running=newruns
   BDR=curr.bdr
   if curr.duration==nil then
      self.finished=nil
   else
      self.finished=curr.duration+time()
   end
   -- Next part has started, clear all signals.
   self.signals={}
   --|#ifndef NDEBUG
   for k,v in pairs(self) do trace(tostring(k) .. " -- " .. tostring(v)) end
   trace(string.format("#DEMO.running=%d", #self.running))
   --|#endif
end
-- Function to execute an effect, handles all the different types.
function Engine:execute(effect)
   if type(effect)=="function" then
      return effect(self.signals)
   elseif type(effect)=="table" then
      return effect:run(self.signals)
   elseif type(effect)=="thread" then
      return coroutine.resume(effect)
   else
      trace(string.format("Unknown effect type '%s': %s",type(effect),effect))
   end
   return CONTINUE
end
-- Function to be called each frame, this keeps the demo running.
function Engine:run()
   -- Check if demo has an end point in time!
   if self.finished~=nil then
      if time()>=self.finished then
	 local cleanup=self.parts[self.partidx].cleanup -- Get current cleanup function, if any.
	 self:next_part()
	 if cleanup~=nil then self:execute(cleanup) end
      end
   end
   --[[
      Each function/object is called with the signal set. The signal set is cleared at the start of each part.

      Two return values are returned:
      
      First return values are:
      - nil, false, CONTINUE: continue normally, no change
      - true, REMOVE: remove current item in next frame
      - "function", "table": replace(!) current item with the returned item
      - QUIT : quit processing and go to next part

      Second return value is a list of newly spawned objects.
   ]]--
   local ret,spawned
   local nextrun={}
   local finish_now_p=false
   for k,v in ipairs(self.running) do
      -- Run the function/effect.
      ret,spawned=self:execute(v)
      -- Handle the return value.
      if ret==QUIT then
	 finish_now_p=true
      elseif ret==REMOVE then
	 -- Do nothing, therefore remove entry.
      elseif type(ret)=="function" or type(ret)=="table" or type(ret)=="thread" then
	 -- Replace current effect with new one.
	 table.insert(nextrun,ret)
      else
	 -- Keep current effect.
	 table.insert(nextrun,v)
      end
      -- Handle spawned objects, if any.
      if spawned~=nil then
	 for _,v in ipairs(spawned) do
	    table.insert(nextrun,v)
	 end
      end
   end
   self.running=nextrun
   if finish_now_p then
      self:next_part()
   end
end
