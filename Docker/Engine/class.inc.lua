-----------------------------------------------------------------------------
-- Classes and tools.
-----------------------------------------------------------------------------

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
	function call_inits(initcl)
		if initcl.extends~=nil then
			call_inits(initcl.extends)
			if initcl.init~=nil then initcl.init(obj) end
		end
	end
	call_inits(obj)
	return obj
end


-- Class to handle coroutines easier.
--
-- Overwrite the coroutine() method and run() will call it for you
-- each frame.
Coroutine=Class:extend{
	remove=true, -- return REMOVE at the end of the coroutine otherwise true for finishing the whole part.
}
function Coroutine:init()
   self.corovar=coroutine.create(self.coroutine)
end
function Coroutine:run()
	if not coroutine.resume(self.corovar,self) then
		if self.remove then
			return REMOVE
		end
		return true
	end
end
function Coroutine:waitframes(num)
	while num>0 do
		num=num-1
		coroutine.yield()
	end
end


-- Class to handle an object with a state.
--
-- The run() function calls an associated state function.
State=Class:extend{
	--state=... -- Set to first state!
	--laststate=... -- State on the last call to run(). Use it to detect state change.
	finalreturn=REMOVE -- This is returned if state is equal to nil.
}
function State:run(signals)
	if self.state==nil then
		return self.finalreturn
	end
	local statefun=self[self.state]
	local laststate=self.state
	ret={statefun(self,signales)}
	self.laststate=laststate
	return table.unpack(ret)
end
