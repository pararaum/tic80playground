-- title:   oldskool
-- author:  The 7th Division
-- desc:    Oldschool demo effects
-- site:    https://github.com/pararaum/tic80playground
-- license: GPLv2
-- script:  lua

Class={}
function Class:extend(classinit)
	classinit.extends = self
	return setmetatable(classinit or {}, { __index=self})
end
function Class:new(init)
	local obj =  {}
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


Scroller = Class:extend({
		background = 11,
		foreground = 7,
		x = 240,
		y = 60,
		delta = 1
})
function Scroller:finish()
	if self.next then
		return self.next
	else
		return true
	end
end
function Scroller:run()
	cls(self.background)
	local width = print(self.text, self.x, self.y, self.foreground)
	self.x = self.x - self.delta
	if self.x < -width then
		return self:finish()
	end
end


DelayFrames = Class:extend({ delay = 60 }) -- Default delay is 1s.
function DelayFrames:run()
	self.delay = self.delay - 1
	if self.delay < 0 then
		return true
	end
end


function next_effect()
	trace(string.format("#EFFECTS = %d, #EFFECTLIST = %d", #EFFECTS, #EFFECTLIST))
	return table.remove(EFFECTLIST, 1)
end


function BOOT()
	local second = Scroller:new({text = "And now a little (s)lower...", foreground = 8, y = 76})
	local first = Scroller:new({text = "Some nice scroller text...", delta = 1.41})
	EFFECTLIST = {first, DelayFrames:new({delay = 30}), second}
	EFFECTS = {}
	table.insert(EFFECTS, next_effect())
end


function TIC()
	local new={}
	for _,eff in ipairs(EFFECTS) do
		local ret=eff:run()
		if ret then
			if ret ~= true then
				table.insert(new, ret)
			else
				table.insert(new, next_effect())
			end
		else
			table.insert(new, eff)
		end
	end
	EFFECTS=new
end


-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- 001:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>

