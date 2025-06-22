-- title:   Delayed Code
-- author:  Pararaum / T7D
-- desc:    Delayed Code Example
-- site:    https://pararaum.github.io/tic80playground/
-- license: GPLv2
-- version: 0.0
-- script:  lua


-- Functions to make functions.

function mkBackground(col)
	return function() cls(col) end
end


-- Classes

Class={}
function Class:extend(classinit)
	classinit.extends = self
	return setmetatable(classinit or {}, { __index=self})
end
function Class:new(init)
	local obj = {}
	for k,v in pairs(init or {}) do
		obj[k]=v
	end
	setmetatable(obj, { __index=self })
	local curr, lastinit = self
	while curr do
		if curr.init and curr.init ~= lastinit then
			lastinit = curr.init
			lastinit(obj)
		end
		curr = curr.extends
	end
	return obj
end
function Class:finish()
	return true
end


Scroller = Class:extend({
		background = 11,
		foreground = 7,
		x = 240,
		y = 60,
		delta = 1
})
function Scroller:run()
	cls(self.background)
	local width = print(self.text, self.x, self.y, self.foreground)
	self.x = self.x - self.delta
	if self.x < -width then
		return self:finish()
	end
end
function Scroller:finish()
	self.x = 240
	return self.extends:finish()
end


-- Engine

function BOOT()
	--[[
		Every part has the following information:

		- append (optional): if set to true then the current code is appended to the list of running effects
		- background (optional): function called before any effects
		- bdr (optional): this function is set as BDR()
		- code: array of effects that are played simultaneously
		- duration: duration in milliseconds
		
	]]
   DEMO={
		finished=0, -- When is the current part finished?
		partidx=0, -- Initialise with index *before* first part.
		running={}, -- The currently running effects, starts empty.
		parts={
-- 			{
-- 				code={
-- 					Scroller:new({delta=3, text="Quick!"})
-- 				}
-- 			},
			{
				code={
					(
						function()
							col=0
							return function()
								cls(col//10)
								col=col+1
								if col>=160 then
									col=0
									return true
								end
							end
						end
					)()
				}
			},
			{
				duration=500, code={ mkBackground(2) }
			},
			{
				append=true,
				duration=1500,
				code={
					function()
						print("Hello World!", 90, 64, 12)
					end
				}
			},
			{
				code={
					mkBackground(12),
					Scroller:new({text="And now we present a... wait for it... scroller!"})
				}
			},
			--{code={}} -- End, do nothing anymore.
		}
	}
	next_part()
end


function next_part()
	trace("--------------------------------- next part()")
	trace(time())
	DEMO.partidx=DEMO.partidx+1
	if DEMO.partidx>#DEMO.parts then
		DEMO.partidx=1
	end
	local curr=DEMO.parts[DEMO.partidx]
	if curr.append then
		for _,i in ipairs(curr.code) do
			table.insert(DEMO.running, i)
		end
	else
		DEMO.running=curr.code
	end
	BDR=curr.bdr
	if curr.duration==nil then
		DEMO.finished=nil
	else
		DEMO.finished=curr.duration+time()
	end
	for k,v in pairs(DEMO) do trace(tostring(k) .. " -- " .. tostring(v)) end
end


function TIC()
	if DEMO.finished~=nil then
		if time()>=DEMO.finished then
			next_part()
		end
	end
	local ret=false
   for k,v in ipairs(DEMO.running) do
		if type(v)=="function" then
			ret=ret or v()
		elseif type(v)=="table" then
			ret=ret or v:run()
		end
		if ret==true then
			next_part()
		end
   end
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

