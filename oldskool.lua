-- title:   oldskool
-- author:  The 7th Division
-- desc:    Oldschool demo effects
-- site:    https://github.com/pararaum/tic80playground
-- license: GPLv2
-- script:  lua

Class={}
function Class:extend(classinit)
	return setmetatable(classinit or {},	{ __index=self})
end
function Class:new(init)
	
end


function BOOT()
	EFFECTLIST={}
end


function TIC()
	local	new={}
	for _,eff in ipairs(EFFECTLIST) do
		local ret=eff:run()
		if ret then
			table.insert(new,ret)
		else
			table.insert(new,eff)
		end
	end
	EFFECTLIST=new
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

