-------------------------------------------------------
-- TODO: Check feasibility!
--
--   An engine for creating animation scenes.
--
-------------------------------------------------------

SceneClass=Class:extend{}
function SceneClass:update(tab)
   for k,v in pairs(tab) do
      self[k]=v
   end
end

Sprite=SceneClass:extend({colorkey=-1,scale=1,flip=0,rotate=0,w=1,h=1})
function Sprite:draw()
   spr(self.id,self.x,self.y,self.colorkey,self.scale,self.flip,self.rotate,self.w,self.h)
end

Container=Class:extend{contains={}}
function Container:update(tab)
	local ncontains={}
	local nspawned={}
	local nevents={}
	for _,v in ipairs(self.contains) do
		destroy,spawned,events=v:update(tab)
		if destroy~=true then
			table.insert(ncontains,v)
		end
		-- The spawned items are added immediately to self.contains but are returned if the superclass needs to do something with it.
		if spawned~=nil then
			for _,v in ipairs(spawned) do
				table.insert(nspawned,v)
			end
		end
		if events~=nil then
			for _,v in ipairs(events) do
				table.insert(nevents,v)
			end
		end
	end
	self.contains=ncontains
	if #self.contains==0 then
		return true,nspawned,nevents
	else
		return false,nspawned,nevents
	end
end
function Container:handle(eventset)
	for _,i in ipairs(self.contains) do
		if i.handle~=nil then
			i:handle(eventset)
		end
	end
end
function Container:draw()
   for _,v in ipairs(self.contains) do
      v:draw()
   end
end
   

Animation=Container:extend{timer=0,speed=1}
function Animation:new(init)
	self.inherits:new(init)
	-- Update to initialise all Sprites with position, etc.
	self:update(init)
end
function Animation:update(tab)
	self.inherits:update(tab)
	self.timer=self.timer+self.speed
	if self.timer>=#self.contains then
		self.timer=self.timer-#self.contains
	end
end
function Animation:draw()
	local frame=math.floor(self.timer)%#self.contains+1
	self.contains[frame]:draw()
end


Moving=Class:extend{}

Scene=Container:extend{}
function Scene:update()
	local finished,spawned,events=self.extends:update()
	if events~=nil then
		local eventset={}
		for _,i in ipairs(events) do
			events[i]=true
		end
		for _,i in ipairs(self.contains) do
			if i.handle~=nil then
				i:handle(eventset)
			end
		end
		if events["QUIT"] then
			return true
		end
	end
	return finished
end

testscene=Scene:new{
	contains={
		{comment="background", draw=function() cls(0) end},
		Sprite:new{id=407,x=80,y=80}
	}
}
