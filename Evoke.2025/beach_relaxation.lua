-- title:   Delayed Code
-- author:  Pararaum / T7D
-- desc:    Delayed Code Example
-- site:    https://pararaum.github.io/tic80playground/
-- license: GPLv2
-- version: 0.0
-- script:  lua

--|#include "animation.dog-02.tiles.lua"
--|#include "class.inc.lua"
--|#include "compression.inc.lua"
--|#include "engine.inc.lua"
--|#include "f1000017.960x128.image.lua"
--|#include "font.sto16x16.artist_made.palette.lua"
--|#include "font.sto16x16.artist_made.tiles.lua"
--|#include "Beachball.font.lua"
--|#include "animation.dolphin.tiles.lua"
--|#include "mokki.beach-seagulls.image.lua"
--|#include "mokki.beach-seagulls.1.image.lua"
--|#include "mokki.beach-seagulls.2.image.lua"
--|#include "mokki.beach-seagulls.3.image.lua"
--|#include "mokki.beach-background.image.lua"
--|#include "mokki.beach-foreground.image.lua"
--|#include "crab.tiles.lua"

-- Processing 'image.beach.png'
beachpalette = { { 44, 33, 17 }, { 88, 78, 68 }, { 43, 94, 145 }, { 100, 118, 49 }, { 161, 123, 91 }, { 91, 161, 167 }, { 203, 178, 52 }, { 222, 213, 152 }, { 62, 145, 227 }, { 0xff, 0xff, 0xff }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 255, 0, 0 }, }


mokki_beach_sprites={0,256,257,258,259,260,260,208,256,221,221,261,267,258,266,265,204,265,221,272,220,265,268,269,266,204,281,220,281,284,284,271,204,278,260,13,257,204,12,256,281,291,296,289,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,262,277,208,277,0,321,320,303,274,273,205,272,273,272,306,330,273,221,294,256,336,304,321,291,317,342,343,344,345,346,347,348,349,350,351,352,301,324,310,208,291,265,328,288,302,282,0,284,360,365,281,307,266,337,257,220,353,374,375,376,377,378,379,380,311,273,322,321,309,221,360,334,334,307,204,283,329,265,341,308,331,364,395,320,370,381,403,404,405,406,407,408,409,347,320,361,309,293,295,221,396,410,419,420,421,422,423,424,308,192,413,413,397,425,431,432,433,434,435,435,401,205,382,330,276,402,308,402,390,314,418,436,449,450,451,452,305,412,288,427,373,310,282,389,446,322,303,281,327,392,461,385,300,334,205,395,472,453,475,476,477,478,342,370,321,387,0,208,328,322,368,289,417,256,472,280,276,13,460,286,315,448,382,291,401,479,503,504,505,407,205,486,492,384,270,319,513,268,360,276,460,468,462,268,490,511,287,272,286,383,384,521,205,442,392,442,326,417,383,469,506,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,289} -- 317 tokens


amiga_ball_sprites_lzw={0,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,297,192,257,204,256,16,322,0,204,17,0,192,327,326,331,326,28,324,28,193,327,17,338,17,340,17,204,204,28,344,346,348,28,339,193,17,1,256,345,328,357,348,342,342,339,360,348,357,325,264,12,321,257,354,256,342,373,17,369,265,320,356,256,192,28,256,347,329,385,346,193,356,17,330,351,347,344,394,204,338,327,398,340,357,396,372,334,358,347,338,407,401,353,408,401,393,17,383,265,377,326,371,355,0,340,373,193,418,263,379,419,386,375,329,374,399,384,391,337,352,438,345,347,440,350,361,341,377,339,326,362,339,327,359,452,451,342,416,368,370,373,377,344,373,204,426,262,428,325,330,431,192,433,374,422,17,16,364,453,341,476,339,441,397,377,351,322,396,396,400,488,402,362,266,418,367,376,462,462,460,344,470,499,362,470,450,504,449,506,438,342,478,353,442,512,349,513,484,506,364,517,453,519,345,204,355,357,332,328,491,362,12,529,531,344,369,401,475,338,536,204,16,193,407,349,412,544,349,486,362,487,357,489,399,550,366,542,555,343,545,556,558,346,524,387,385,401,422,338,1,401,568,567,569,422,345,475,574,348,540,509,508,401,579,361,581,584,398,514,587,481,589,344,521,362,479,592,360,327,524,423,434,395,573,28,568,561,395,604,603,573,539,577,348,330,582,585,580,595,522,505,594,364,547,395,362,551,401,552,627,591,598,389,600,397,602,607,635,606,619,452,324,344,324,327,642,358,331,591,580,510,352,591,511,588,350,520,620,451,638,627,357,1,660,662,646,461,528,495,344,355,559,543,204,382,338,392,391,349,405,422,347,622,349,623,344,341,397,553,628,671,670,407,437,690,413,349,12,695,697,564,338,566,322,340,534,608,590,513,382,345,613,676,471,358,583,649,614,398,437,515,443,658,519,516,594,400,399,696,703,726,632,383,601,533,679,669,720,587,575,672,339,710,448,527,394,656,504,366,655,359,681,750,341,625,725,728,755,425,327,731,346,602,573,704,421,575,496,0,324,371,257,16,266,654,716,395,652,335,440,424,258,340,441,751,628,700,463,260,345,356,446,257,421,272,540,416,700,329,494,770,266,400,681,685,400,330,333,461,371,541,715,581,541,683,760,523,787,325,786,429,0,792,271,640,766,768,373,799,265,442,716,440,586,347,675,256,796,835,346,682,839,691,558,0,608,259,333,818,367,821,270,540,325,796,468,826,323,772,363,615,552,623,336,328,0,836,864,490,813,437,626,626,843,849,448,356,421,848,284,771,384,381,416,423,536,843,423,473,851,784,345,812,868,455,586,460,760,830,831,719,509,456,263,418,456,425,837,837,464,261,879,422,381,863,461,765,491,566,470,812,515,648,650,440,818,666,453,747,619,593,266,792,863,326,446,817,815,265,910,863,540,906,851,566,882,610,411,687,415,548,949,684,366,460,700,413,694,680,689,557,633,265,931,321,446,416,561,266,938,323,389,332,767,788,601,866,794,736,744,810,832,668,462,702,520,721,647,960,264,962,875,390,390,421,408,851,335,408,382,955,558,999,870,551,840,950,1004,444,921,719,1009,546,372,407,885,389,809,866,603,408,1,1019,1019,526,644,1024,657,617,450,977,773,615,830,509,1027,748,985,342,534,665,461,525,663,354,1042,562,676,833,349,673,958,1000,338,753,867,1006,1055,999,689,1050,1059,409,905,565,565,677,698,376,1066,369,740,1070,342,708,653,1010,1010,978,921,1032,1035,591,745,519,733,732,814,599,756,727,757,703,1057,555,995,998,193,1095,1014,864,337,1002,947,832,717,1005,858,979,508,919,1074,1011,425,407,12,1113,337,383,408,1017,866,369,541,355,1082,503,391,502,925,448,657,706,588,451,351,1032,343,1082,596,617,744,533,532,463,491,1041,331,345,598,1121,1060,474,812,538,538,701,326,1052,1102,947,441,948,892,651,1150,408,812,1051,543,569,1169,571,785,563,406,524,905,1107,342,578,474,611,973,1182,522,1131,590,781,1007,1079,985,550,1139,593,605,1194,603,601,434,1198,372,482,381,760,334,381,970,864,270,1081,521,1026,339,640,863,788,321,388,1079,1185,422,873,385,872,880,256,873,268,613,991,432,458,329,266,922,1132,781,352,500,970,1203,356,869,753,782,949,1220,260,472,404,932,908,1227,337,435,323,932,367,428,263,549,628,1160,396,475,807,333,1241,1109,706,1242,550,422,908,1248,421,1250,274,503,1229,470,1231,1258,262,579,899,891,535,565,885,258,1061,1158,1116,999,864,1273,325,1249,257,1251,277,968,767,1214,322,642,609,356,739,595,481,521,478,844,353,328,625,750,624,525,961,769,990,874,448,1226,259,428,970,940,1204,392,1119,332,998,1162,718,1101,397,744,876,599,653,900,897,388,930,257,1206,844,1222,347,1326,318,1354,1355,309,1071,711,1180,1076,736,1080,361,1363,477,1158,758,1005,1318,647,534,896,1086,383,729,1088,726,1014,1095,1095,995,1092,1092,1055,1077,889,1387,1361,1135,1107,338,1149,1117,760,1116,1014,1114,703,1115,703,1356,1402,1403,306,1177,1359,738,738,1307,686,1365,858,363,1035,1053,784,1244,1162,1133,636,1194,631,1087,1423,1175,1069,693,1096,407,995,995,1119,1116,1385,950,1187,1338,449,1361,512,869,1031,410,561,1021,1445,1253,1013,1449,1012,905,1404,1453,1454,298,998,1254,1303,1281,1233,365,1343,514,401,918,325,1222,435,951,1417,1162,1295,1247,1297,460,1299,274,884,566,323,456,901,1461,618,517,1081,657,503,1297,932,473,541,1009,1443,631,908,796,1452,1206,1300,1455,1502,1503,299} -- 1250 tokens


function mkSepiaPalette()
	local palette={{41,36,24},{82,72,57},{115,101,74},{139,125,98},{164,141,106},{189,165,131},{205,186,148},{230,206,172},{200,135,129},{200,114,106},{200,92,82},{200,70,58},{103,150,111},{91,155,102},{77,160,90},{61,166,77}}
	return mkPalette(palette)
end


-- Image functions.

function mkImage(data, palette)
	local pfun=mkPalette(palette)
   return function()
		pfun()
		for i,d in ipairs(data) do
			local iz=i-1
			pix(iz%240, iz//240, d)
		end
	end
end


Seagulls=Class:extend{
	images={
		mkLZ77Image(images_mokki_beach_seagulls_imagelz77,nil,5),
		mkLZ77Image(images_mokki_beach_seagulls_1_imagelz77,nil,5),
		mkLZ77Image(images_mokki_beach_seagulls_2_imagelz77,nil,5),
		mkLZ77Image(images_mokki_beach_seagulls_3_imagelz77,nil,5),
	},
	starttime=time(),
	divisor=83
}
function Seagulls:run()
	local img=1+math.floor((time()-self.starttime)/self.divisor)%#self.images
	return self.images[img]()
end


-- Scroller class.
Scroller = Class:extend({
		foreground = 7,
		x = 240,
		y = 60,
		dx = 1,
		fixed = true
})
function Scroller:run()
	local width = print(self.text, self.x, self.y, self.foreground, self.fixed)
	self.x = self.x - self.dx
	if self.x < -width then
		return REMOVE
	end
end


-- Class to draw clouds, uses default palette.{256,288,320,352}
Cloud=Class:extend({x=242,finalx=-40,ids={0,32,64,96,128,160}})
function Cloud:init()
   self.y=math.random(2,40)
   self.dx=.1+.19*math.random()
   self.id=self.ids[math.random(1,#self.ids)]
end
function Cloud:run()
   while self.x>-40 do
      spr(self.id,self.x,self.y,0,1,0,0,4,2)
      self.x=self.x-self.dx
      return
   end
   return REMOVE
end


-- Class to draw a moving boat.
Boat=Class:extend{ids={10,74,138,202},x=242,y=75,waveids={85,69,53,37,21,5}}
function Boat:init()
	self.starttime=time()
end
function Boat:run()
	local boatid=1+math.floor((time()-self.starttime)/1100)%#self.ids
	local waveid=1+math.floor((time()-self.starttime)/35)%#self.waveids
	spr(self.ids[boatid],self.x,self.y,0,1,0,0,6,4)
	spr(self.waveids[waveid],self.x+8,self.y+24,0,1,0,0,4,1)
	self.x=self.x-.325
	if self.x<-50 then return REMOVE end
end


-- Class to draw a walking dog.
Dog=Class:extend{
	ids={256,259,262,288,291,294},
	ids_pee={299,301,331,333},
	id_wait=265,
	id_lifted_leg=268,
	palmx=27,
	waitframes=120,
	x=-26,
	y=108}
function Dog:init()
	self.starttime=time()
	self.run=self.run_to_palm
end
function Dog:run_to_palm()
	local id=1+math.floor((time()-self.starttime)/100)%#self.ids
	spr(self.ids[id],self.x,self.y,3,1,0,0,3,2)
	self.x=self.x+.4
	if self.x>=self.palmx then self.run=self.wait end
end
function Dog:wait()
	spr(self.id_wait,self.x,self.y,3,1,0,0,3,2)
	self.waitframes=self.waitframes-1
	if self.waitframes<=0 then
		self.waitframes=120
		self.run=self.pee
	end
end
function Dog:pee()
	local id=1+math.floor((time()-self.starttime)/100)%#self.ids_pee
	spr(self.ids_pee[id],self.x-6,self.y,3,1,0,0,2,2)
	spr(self.id_lifted_leg,self.x,self.y,3,1,0,0,3,2)
	self.waitframes=self.waitframes-1
	if self.waitframes<=0 then
		self.run=self.run_to_right
	end
end
function Dog:run_to_right()
	local id=1+math.floor((time()-self.starttime)/100)%#self.ids
	spr(self.ids[id],self.x,self.y,3,1,0,0,3,2)
	self.x=self.x+.4
	if self.x>242 then return true end
end


ReverseDog=Class:extend{
	ids={256,259,262,288,291,294},
	ids_pee={299,301,331,333},
	id_wait=265,
	id_lifted_leg=268,
	palmx=6,
	waitframes=120,
	x=242,
	y=107}
function ReverseDog:init()
	self.starttime=time()
	self.run=self.run_to_palm
end
function ReverseDog:run_to_palm()
	local id=1+math.floor((time()-self.starttime)/100)%#self.ids
	spr(self.ids[id],self.x,self.y,3,1,1,0,3,2)
	self.x=self.x-.45
	if self.x<self.palmx then self.run=self.wait end
end
function ReverseDog:wait()
	spr(self.id_wait,self.x,self.y,3,1,1,0,3,2)
	self.waitframes=self.waitframes-1
	if self.waitframes<=0 then
		self.waitframes=120
		self.run=self.pee
	end
end
function ReverseDog:pee()
	local id=1+math.floor((time()-self.starttime)/100)%#self.ids_pee
	spr(self.ids_pee[id],self.x+12,self.y,3,1,1,0,2,2)
	spr(self.id_lifted_leg,self.x,self.y,3,1,1,0,3,2)
	self.waitframes=self.waitframes-1
	if self.waitframes<=0 then
		self.run=self.run_to_left
	end
end
function ReverseDog:run_to_left()
	local id=1+math.floor((time()-self.starttime)/100)%#self.ids
	spr(self.ids[id],self.x,self.y,3,1,1,0,3,2)
	self.x=self.x-.45
	if self.x<-28 then return REMOVE end
end


-- A walking guy pressing the button.
WalkingGuy = Class:extend({
      x=200,
      finalx=40,
      y=60,
      frames={320,324,328,332},
      fcounter=0, -- frame counter
})
function WalkingGuy:init()
	self.anims={self.go_left,self.stand_still,self.press,self.stand_still2}
end
function WalkingGuy:draw_room()
   local y=self.y+26
   line(30,y,240,y,7)
   line(30,y,0,136,7)
   line(30,y,30,0,7)
end
function WalkingGuy:go_left()
   local x=self.x
   local fctrmodulus=(self.fcounter//6)%4+1
   self.x=self.x-.71
   spr(414,self.finalx-8,self.y+8,0,1,0,0)
   spr(self.frames[fctrmodulus],x,self.y,0,1,0,0,3,4)
   if fctrmodulus==1 then
      sfx(62,"F-3",-1,0,10)
   end
   if x<42 then return true end
end
function WalkingGuy:stand_still()
   spr(414,self.finalx-8,self.y+8,0,1,0,0)
   spr(384,self.x,self.y,0,1,0,0,3,4)
   if self.fcounter>150 then return true end
end
function WalkingGuy:press()
   spr(407,self.finalx-8,self.y+8,0,1,0,0)
   spr(392,self.x,self.y,0,1,0,0,3,4)
   if self.fcounter==0 then sfx(62,"A#8",-1,0,10) end
   if self.fcounter>75 then return true end
end
function WalkingGuy:stand_still2()
   spr(407,self.finalx-8,self.y+8,0,1,0,0)
   spr(384,self.x,self.y,0,1,0,0,3,4)
   if self.fcounter>125 then return true end
end
function WalkingGuy:run()
   cls(0)
   self:draw_room()
   if self.anims[1](self)==true then
      table.remove(self.anims,1)
      self.fcounter=0
   else
      self.fcounter=self.fcounter+1
   end
   if #self.anims==0 then return true end
end


function drawReel()
   local sprnums={256,258,260,262,264,266,268,270,288,290}
   local lile=138 -- line length
	local fffc=49 -- frames for full circle
	local bg=2 -- background
	local lbg=4 -- light background
	local lcol=6 -- line colours for cross and circle
	local fbrd=0 -- film border left and right colour
	local fbho=5 -- film border hole colour
	local fbwd=11 -- frame border width
	local fcounter=0 -- frame counter
	local function myfun()
		for counter=0,9 do
			sfx(63,"C-6",-1)
		   for frame=0,49 do
				cls(bg)
				for j=0,frame do
					tri(120,68,
						 120+lile*math.sin(math.pi*2*j/fffc),68-lile*math.cos(math.pi*2*j/fffc),
						 120+lile*math.sin(math.pi*2*(j+4)/fffc),68-lile*math.cos(math.pi*2*(j+4)/fffc),lbg)
				end
				line(0,68,239,68,lcol)
				line(120,0,120,135,lcol)
				circb(120,68,55,lcol)
				circb(120,68,45,lcol)
				spr(sprnums[counter+1],116,62,15,1,0,0,2,2)
				-- Draw the borders to create the illusion of a moving film.
				rect(0,0,fbwd,136,fbrd)
				rect(240-fbwd,0,240,136,fbrd)
				local y=-14+fcounter%13
				for j=0,18 do
					circ(fbwd//2,y+j*14,4,fbho)
					circ(240-fbwd//2,y+j*14,4,fbho)
				end
				for j=0,300 do
					local x=math.random(fbwd,240-fbwd)
					local y=math.random(0,136)
					if math.random() < .1 then
						circ(x,y,1,0)
					else
						pix(x,y,0)
					end
				end
				for j=0,13 do
					local x=math.random(fbwd,240-fbwd)
					line(x,0,x,240,1)
				end
				fcounter=fcounter+1
				coroutine.yield()
			end
		end
	end
	local co=coroutine.create(myfun)
	return function()
		local ret,err=coroutine.resume(co)
		if err then
			trace(err)
		end
		return not ret
	end
end


-- Flying Bird class
FlyingBird=Class:extend{frame=0,fspeed=.314,dx=1,dy=0,frames={448,450,452}}
function FlyingBird:run()
	self.frame=self.frame+self.fspeed
	local frameidx=math.floor(self.frame)
	if frameidx>=#self.frames then
		frameidx=0
		self.frame=0
	end
	spr(self.frames[frameidx+1],self.x,self.y,0,1,0,0,2,2)
	self.x=self.x+self.dx
	self.y=self.y+self.dy
	if self.x>240 or self.y<-16 or self.y>136 then
		return REMOVE
	end
end

PlaneWithText=Class:extend{
	frame=0,
	text="*Text*",
	x=-80,
	y=18,
	colkey=0
}
function PlaneWithText:init()
	self.textwidth=8+print(self.text,-8,-8,0,true) -- Print outside of screen
end
function PlaneWithText:run()
	local x=self.x+self.frame/1.5
	spr(292,x,self.y,self.colkey,1,0,0,6,2)
	spr(298+self.frame//2%3,x+6*8,self.y,self.colkey,1,0,0,1,2)
	spr(301,x-8,self.y,self.colkey,1,0,0,1,2)
	for i=0,self.textwidth,16 do
		spr(302,x-24-i,self.y,self.colkey,1,0,0,2,2)
	end
	print(self.text,x-8-self.textwidth,self.y+3,15,true)
	--
	self.frame=self.frame+1
	if self.x>self.textwidth+16 then
		return REMOVE
	end
end


function mkPixel(x,y,dx,dy,col,sig)
	return function()
		pix(x,y,col)
		x=x+dx
		y=y+dy
		if x<0 or x>=240 or y<0 or y>=136 then
			return REMOVE
		end
	end
end


ExplodingText=Class:extend{y=300,foreground=11,fg2=7,dy=2,showtime=2500,waittime=1500,topline=20,spacetile=256}
function ExplodingText:init()
	self.textidx=1
	local text=self.text[self.textidx]
	self.x=(240-#text*16)//2
	self.currenty=self.y
end
function ExplodingText:draw()
	local text=self.text[self.textidx]
	for i=1,15 do
		local char=text:sub(i,i)
		if #char>0 then
			local byte=string.byte(char)-32 -- Font starts with a space.
			local row=byte//8
			local column=byte%8
			local tile=column*2+row*32
			spr(self.spacetile+tile,self.x+(i-1)*16,self.currenty,0,1,0,0,2,2)
		end
	end
end
function ExplodingText:run()
	self.run=self.move_up
end
function ExplodingText:move_up()
	self:draw()
	self.currenty=self.currenty-self.dy
	if self.currenty<self.topline then
		self.run=self.wait
		self.starttime=time()
	end
end
function ExplodingText:wait()
	self:draw()
	if time()>=self.starttime+self.showtime then
		self.run=self.explode
	end
end
function ExplodingText:waitwodraw()
	if time()>=self.starttime+self.waittime then
		self.run=self.move_up
	end
end
function ExplodingText:explode(signals)
	self:draw()
	local t={}
	for x=0,239 do
		for y=self.topline,self.topline+8 do
			local col=pix(x,y)
			--trace(string.format("%d %d c=%d",x,y,col))
			if col~=0 then
				for i=1,5 do
					local phi=math.random(0,360)
					local r=1.5+2*math.random()
					local dx=r*math.cos(phi/180.0*math.pi)
					local dy=r*math.sin(phi/180.0*math.pi)
					t[#t+1]=mkPixel(x,y,dx,dy,col,signals)
				end
			end
		end
	end
	self.textidx=self.textidx+1
	if self.textidx<=#self.text then
		local text=self.text[self.textidx]
		self.x=(240-#text*16)//2
		self.run=self.waitwodraw
		self.currenty=self.y
		self.starttime=time()
		return false,t
	end
	signals.finished=true
	return REMOVE,t
end

NoiseText=ExplodingText:extend{
	y=60,
	dots=5760, -- (* 240 16 1.5)5760.0 (/ 5760 60)96
	waitframes=100
}
function NoiseText:run()
	self:draw()
	for i=0,self.dots do
		local x=math.random(0,240)
		local y=math.random(self.currenty,self.currenty+16)
		pix(x,y,0)
	end
	self.dots=self.dots-38
	if self.dots<=0 then
		self.dots=1
		self.run=self.wait
	end
end
function NoiseText:wait()
	self:draw()
	self.waitframes=self.waitframes-1
	if self.waitframes<0 then
		self.run=self.dissolve
	end
end
function NoiseText:dissolve()
	self:draw()
	for i=0,self.dots do
		local x=math.random(0,240)
		local y=math.random(self.currenty,self.currenty+16)
		pix(x,y,0)
	end
	self.dots=self.dots+38
	if self.dots>=5800 then
		return REMOVE
	end
end


-- Class to draw an appearing periscope animation.
Periscope=Coroutine:extend{
	--pixels={}, -- Pixel store for pixel exact appearing.
	appearspeed=5, -- Default speed of appearing.
	turnframes=40, -- Number of frames between next turn position.
	-- needed: x,y -- Position of periscope.
}
function Periscope:init()
	-- Can not be initialised above as this will be a class global
	-- variable and two periscopes at the same time would produce
	-- artifacts.
	self.pixels={}
end
function Periscope:restorepixels()
	for x=0,15 do
		for y=0,15 do
			pix(self.x+x,self.y+y+16,self.pixels[x..'|'..y])
		end
	end
end
function Periscope:storepixels()
	-- Save the background.
	for x=0,15 do
		for y=0,15 do
			self.pixels[x..'|'..y]=pix(self.x+x,self.y+y+16)
		end
	end
end
function Periscope:coroutine()
	self:waitframes(100)
	self:storepixels()
	-- Periscope appears, turns, and vanishes.
	for i=0,15*self.appearspeed do
		spr(494,self.x,self.y+16-i//self.appearspeed,0,1,0,0,2,2)
		self:restorepixels()
		coroutine.yield()
	end
	for _,i in ipairs{494,492,490,488,486,486,486,484,482,480,494} do
		for j=0,self.turnframes do
			spr(i,self.x,self.y,0,1,0,0,2,2)
			coroutine.yield()
		end
	end
	for i=15*self.appearspeed,0,-1 do
		spr(494,self.x,self.y+16-i//self.appearspeed,0,1,0,0,2,2)
		self:restorepixels()
		coroutine.yield()
	end
	self:waitframes(120)
	return true
end


-- Class to draw a jumping Dolphin.
Dolphin=Class:extend{
	ids={256,259,262,265,268,304,307,310,329,332,368,371},
	divisor=100,
	x=120,
	y=68,
	return_at_end=true
}
function Dolphin:run()
	self.starttime=time()
	self.run=self.jump
	self:jump()
end
function Dolphin:jump()
	local id=1+math.floor((time()-self.starttime)/self.divisor)
	if id<=#self.ids then
		spr(self.ids[id],self.x,self.y,5,1,0,0,3,3)
	else
		return self.return_at_end
	end
end


Fireworks=Class:extend{
	colramps={
		{5,6,7},
		{4,3,2},
		{12,13,14}
	},
	y=50,
	type="generator"
}
function Fireworks:run()
	local mytype=self[self.type]
	return mytype(self)
end
function Fireworks:generator()
	if math.random() < .14 then
		local x=math.random(50,180)
		local dx=2*(math.random()-.5)
		local dy=-(1.4+math.random())*1.1
		local y=self.y
		local r=math.random(1,#self.colramps)
		return false,{Fireworks:new{x=x,dx=dx,y=y,dy=dy,type="rocket",ramp=r}}
	end
end
function Fireworks:rocket()
	pix(self.x,self.y,self.colramps[self.ramp][1])
	self.x=self.x+self.dx
	self.y=self.y+self.dy
	self.dy=self.dy+.082
	if self.dy>.85 then -- explode
		local particles={}
		for i=0,47 do
			local phi=math.random(0,360)
			local r=.1+math.random()/10
			local dx=r*math.cos(phi/180.0*math.pi)
			local dy=r*math.sin(phi/180.0*math.pi)
			--trace(string.format("x=%e,y=%e,dx=%e,dy=%e",self.x,self.y,dx,dy))
			table.insert(particles,
							 Fireworks:new{x=self.x,y=self.y,ramp=self.ramp,dx=dx,dy=dy,type="particle"}
			)
		end
		return REMOVE,particles
	end
end
function Fireworks:particle()
	self.rampidx=(self.rampidx or 1)+.033
	local rampid=math.floor(self.rampidx)
	if rampid>3 or self.y<0 or self.y>60 or self.x<0 or self.x>240 then
		return REMOVE
	end
	pix(self.x,self.y,self.colramps[self.ramp][rampid])
	self.x=self.x+self.dx
	self.y=self.y+self.dy
end


-- ToDo: The Crab...
Crab=State:extend{
	ids_walking={288,292},
	ids_claws={256,260,264,268},
	starttime=time(),
	state="move_to", -- Start with "move_to" state.
	tox=math.random(30,220), -- X position to move to.
	x=242, -- Starting position and current position.
	speedx=1, -- Absolute value of speed.
}
function Crab:draw()
	local id
	if self.state:find("move") then
		id=self.ids_walking[1+math.floor(time()/5)%#self.ids_walking]
	elseif self.state:find("claw") then
		id=self.draw_claw
		assert(id~=nil)
	else
		id=self.ids_claws[1]
	end
	spr(id,self.x,self.y,0,1,0,0,4,2)
end
function Crab:move_to()
	local dx=self.speedx
	if self.x>self.tox then
		self.x=self.x-dx
	else
		self.x=self.x+dx
	end
	if math.abs(self.x-self.tox)<3 then
		self.state="choose"
	end
	self:draw()
end
function Crab:wait()
	if time()>self.endtime then
		self.state="choose"
	end
	self:draw()
end
function Crab:claws()
	local timeslice=math.floor((time()-self.starttime)/400)%4
	if timeslice==0 then
		self.draw_claw=self.ids_claws[1]
	elseif timeslice==1 then
		self.draw_claw=self.current_claw
	elseif timeslice==2 then
		self.draw_claw=self.ids_claws[1]
	elseif timeslice==3 then
		self.draw_claw=self.ids_claws[1]
	end
	if time()-self.starttime>4e3 then
		self.state="choose"
	end
	self:draw()
end
function Crab:choose()
	local states={"move_to","wait","move_to","wait","claws"}
	self.state=states[math.random(1,#states)]
	if self.state=="move_to" then
		self.tox=math.random(15,220)
		self.speedx=.4+math.random()*1.2
	elseif self.state=="wait" then
		self.endtime=time()+math.random()*3e3+.5
	elseif self.state=="claws" then
		self.current_claw=self.ids_claws[math.random(2,#self.ids_claws)]
		-- First time self:claws() has not been called yet!
		self.draw_claw=self.ids_claws[1]
	else
		assert(false)
	end
	self.starttime=time()
	self:draw()
end


-----------------------------------------------------------------------------
-- Engine
-----------------------------------------------------------------------------

function TIC()
	-- Disable mouse cursor. [https://github.com/nesbox/TIC-80/issues/1292]
	poke(0x3FFB,0)
	demo:run()
end


function BOOT()
	-- Seems to be broken:
	--local uncom=uncompressLZ77(nil,nzbeach_lz77_eg)
	----trace(#uncom.."\t"..table.concat(uncom,','))
	--for i,v in ipairs(uncom) do
	--	trace(string.format("%8d %s", i, v))
	--end

	-- Set up font.
	local font=lzwUncompress(Beachball_fontlzw)
	table2mem(0x14604+32*8,table.move(font,1,760,1,{}))
	-- According to https://github.com/nesbox/TIC-80/blob/ca3bb11f7d91b6f61c30b27e95958521e3432576/src/core/core.c#L294 only width and height are available.
	poke(0x149fc,8) -- Width
	poke(0x149fd,8) -- Height
	
   demo=Engine:new{
		--[[
			Parts to implement:
			- Fireworks
			- Planes with greetings
			- Sailing boat
		--
		--
		]]--
		partidx=0, -- Initialise with index *before* first part.
		--partidx=9,
		parts={
			------------------------------------------------------------------
			-- Finished
			------------------------------------------------------------------
			{ -- Guy walks to the switch.
				code={
					function() vbank(0) sync(1<<5,0,false) cls(0) return REMOVE end,
					WalkingGuy:new(),
				},
				name="guy"
			},
			{ -- Beginning of reel with beeps.
				code={
					mkSepiaPalette(),
					drawReel()
				},
				name="reel"
			},
			{ -- Clouds over the beach.
				code={
					function() vbank(0) end,
					delay_ms(1000,function() music(0) return REMOVE end),
					mkLZ77Image(images_mokki_beach_background_imagelz77),
					Seagulls:new{},
					-- Clouds are saved in the tiles.
				   function()
						local pf=mkDefaultPalette()
						vbank(1)
						pf()
						vbank(0)
						pf()
						local clouds={}
						for i=1,10 do
							clouds[#clouds+1]=Cloud:new({x=math.random(-1,235)})
						end
						return REMOVE,clouds
					end,
					function() -- Create clouds.
					   if math.random()<.00912 then
					      return false,{Cloud:new()}
					   end
					end,
					-- We generate these here and keep them waiting because
					-- they need to be behind the foreground layer.
					wait_signal("credit_music",PlaneWithText:new{text="Music: mAZE", y=30}),
					wait_signal("credit_graphics",PlaneWithText:new{text="Graphics: Logiker", y=40}),
					wait_signal("credit_graphics2",PlaneWithText:new{text="Graphics: Nerouine", y=35}),
					wait_signal("credit_code",PlaneWithText:new{text="Code: Pararaum", y=20}),
					wait_signal("credit_font",PlaneWithText:new{text="Font: DamienG", y=52}),
					wait_signal("periscope", Periscope:new{x=16,y=80}),
					mkLZ77Image(images_mokki_beach_foreground_imagelz77,nil,0)
				},
				duration=6.5e3,
				name="clouds & beach"
			},
			{ -- Exploding font effect.
				append=true,
				code={
					function()
						-- Use new sprites which contain a font.
						table2mem(0x6000,lzwUncompress(images_font_sto16x16_artist_made_tileslzw))
						vbank(1)
						setPalette(images_font_sto16x16_artist_made_palette)
						return REMOVE
					end,
					function() vbank(1) cls(0) end,
					ExplodingText:new{
						text={
							---------------(/ 240 16)15
							"BEACH",
							"RELAXATION",
							"A TIC80 DEMO",
							"FOR EVOKE 2025"
						},
						topline=69
					},
					coroutine.wrap(
						function(signals)
							while not signals.finished do coroutine.yield() end
							return true
						end
					),
					function() vbank(0) end,
				},
				name="exploding"
			},
			{ -- Wait 4 seconds before continuing.
				append=true,
				code={
					function()
						table2mem(0x6000,lzwUncompress(images_animation_dolphin_tileslzw))
						return REMOVE
					end,
					delay_frames(60, Dolphin:new{x=199,divisor=50,return_at_end=REMOVE}),
					delay_frames(60*4,function() return true end)
				},
				name="wait 4s"
			},
			{ -- Bouncing Amiga ball...
				append=true,
				code={
					function()
						local sprites=lzwUncompress(amiga_ball_sprites_lzw)
						table2mem(0x6000,sprites)
						return REMOVE
					end,
					coroutine.wrap(
						function()
							local ids={256+64,256+68,256+72,256+76,256+128,256+132,256+136,256+140,256+192,256+196}
							local stime=time()
							local y=60
							local dy=0
							for x=240,-36,-.75 do
								local id=1+math.floor((time()-stime)/50)%#ids
								spr(ids[id],x,y,0,1,0,0,4,4)
								y=y+dy
								dy=dy+.25
								if y>=100 then
									dy=-math.min(5.5,dy)
								end
								coroutine.yield()
							end
							return REMOVE
						end
					),
					delay_ms(8e3, function(signals) signals.credit_font=true return REMOVE end)
				},
				duration=9.5e3,
				name="Amiga"
			},
			{ -- Wait 6.5 seconds before continuing, display the two credits.
				append=true,
				code={
					function(signals)
						sync(2) -- Restore the plane sprites.
						signals.credit_music=true -- Signal the credits
						signals.periscope=true
						return REMOVE
					end,
					delay_frames(60*4,function(signals) signals.credit_graphics=true return REMOVE end)
				},
				duration=6.5e3,
				name="wait 6.5s"
			},
			{ -- Periscope of a submarine.
				append=true,
				code={
					Periscope:new{
						x=200,
						y=70,
						remove=false
					}
 				},
				name="periscope"
			},
			{
				append=true,
				code={
					fadePalette(nil,PALETTE_BLACK,1.0/140,true)
				},
				duration=75*60,
				name="fade to black"
			},
			{ -- Fade in the NZ beach, let the birds fly and display the greetings.
				name="NZ",
				code={
					function() vbank(1) cls(0) vbank(0) return REMOVE end,
					fadePalette(PALETTE_BLACK,images_f1000017_960x128_palette,1.0/132,true),
					--mkPalette(widebeachnz_palette),
					function() cls(0) end,
					function()
						-- Uncompressed colour information
						local img=uncompressLZ77(images_f1000017_960x128_imagelz77)
						return coroutine.wrap(
							function(signals)
								for fXX=0,960-240,.4 do
									local XX=math.floor(fXX)
									signals[XX]=true
									for x=0,239 do
										for y=0,127 do
											--trace(string.format("XX=%d,x=%d,Y=%d %d %d",XX,x,y,1+y*960+x,#img))
											pix(x,y,img[1+y*960+x+XX])
										end
									end
									coroutine.yield()
								end
								return true
							end
						)
					end,
					function(signals)
						-- Birds start to fly later.
						if signals[120] and not signals[960-240-100] then
							-- Create Bird
							if math.random() < .23 then
								return false,{
									FlyingBird:new{
										x=-math.random(17,25),
										y=math.random(80,145),
										dx=2.4*math.random()+1,
										dy=-(math.random()+1)
									}
												 }
							end
						end
					end,
					function(signals)
						if signals[80] then
							return Scroller:new{y=128,dx=3,foreground=13,text="Greetings fly to: Abyss Connection, Atlantis, Blazon, Commodore Treffen Graz, Cosmos Designs, CPC User Club, Delysid, Digital Talk Team, Excess, Quantum, Trex, Fairlight, Finnish Gold, Genesis Project, Haujobb, Hokuto Force, Laxity, Nerdy Family, Moods Plateau, Nodepond, Onslaught, Padua, Rabenauge, Rebels, The Solution, Triad, Gloegg, Harekiet, Joe, Phiwa, Sissim, Vintage Computing Carinthia, Wizball6502, XXX, Gorgh, and all we forgot..."}
						end
					end,
					function(signals)
						if signals[350] then
							local tox,toy,dx,dy=60,70,.5*240/136,.5
							local x,y=-10,50
							local r=9
							return function()
								circb(x,y,r-2,0)
								line(x-r,y,x+r,y,0)
								line(x,y-r,x,y+r,0)
								if tox<x then
									x=x-dx
								else
									x=x+dx
								end
								if toy<y then
									y=y-dy
								else
									y=y+dy
								end
								if math.abs(tox-x)<=1 and math.abs(toy-y)<=1 then
									tox=math.random(40,100)
									toy=math.random(30,75)
								end
							end
						end
					end,
					function(signals)
						if signals[620] then
							return fadePalette(widebeachnz_palette,PALETTE_BLACK,1.0/132,true)
						end
					end,
					-- We return true above which is easier...: function(signals) return signals[720] end
				},
			},
			{ -- Again: Clouds over the beach.
				code={
					function()
						vbank(0)
						return fadePalette(nil,PALETTE_DEFAULT,1.0/150,true)
					end,
					mkBackground(10),
					function(signals)
						if signals.fireworks then
							return Fireworks:new{}
						end
					end,
					mkLZ77Image(images_mokki_beach_background_imagelz77,nil,10),
					Seagulls:new{},
					function()
						-- Clouds are saved in the tiles.
						local clouds={}
						for i=1,10 do
							clouds[#clouds+1]=Cloud:new({x=math.random(-1,235)})
						end
						return REMOVE,clouds
					end,
					function() -- Create clouds randomly.
					   if math.random()<.00912 then
					      return false,{Cloud:new()}
					   end
					end,
					-- We generate these here and keep them waiting because
					-- they need to be behind the foreground layer.
					wait_signal("credit_graphics2",PlaneWithText:new{text="Graphics: Nerouine", y=35}),
					wait_signal("credit_code",PlaneWithText:new{text="Code: Pararaum", y=20}),
					wait_signal("credit_font2",PlaneWithText:new{text="Font: made", y=52}),
					delay_ms(3.3e3,Periscope:new{x=147,y=72}),
					wait_signal("boat",Boat:new{}),
					mkLZ77Image(images_mokki_beach_foreground_imagelz77,nil,0)
				},
				duration=6.5e3,
				name="beach again"
			},
			{ -- Boat... and signal graphics2 credits.
				append=true,
				code={
					function(signals) signals.boat=true return REMOVE end,
					delay_ms(5e3,function(signals) signals.credit_graphics2=true return REMOVE end),
					delay_ms(8e3,function(signals) signals.credit_code=true return REMOVE end),
					delay_ms(6e3,function(signals) signals.credit_font2=true return REMOVE end),
				},
				duration=2e4,
				name="boat & credits"
			},
			{ -- Dog animation
				append=true,
				code={
					function()
						table2mem(0x6000,lzwUncompress(images_animation_dog_02_tileslzw))
						return REMOVE
					end,
					Dog:new()
				},
				name="dog"
			},
			{
				append=true,
				code={
					function()
						table2mem(0x6000,lzwUncompress(images_animation_dolphin_tileslzw))
						return REMOVE
					end,
					delay_ms(1e3,Dolphin:new{divisor=50})
				},
				name="dolphin"
			},
			{
				append=true,
				code={
					function()
						sync(2) -- default sprites
						return REMOVE
					end,
					delay_frames(15,function()
										 local p=Periscope:new{x=200,y=70,appearspeed=3,turnframes=30}
										 return function() if p:run() then return REMOVE end end
					end
					),
					delay_ms(4e3, Scroller:new{foreground=1,y=120,text="That is all folks, enjoy and relax!"})
				},
				duration=1.3e4,
				name="end is near"
			},
			{
				append=true,
				code={
					function()
						table2mem(0x6000,lzwUncompress(images_animation_dog_02_tileslzw))
						return REMOVE
					end,
					ReverseDog:new(),
					delay_ms(12e3, Scroller:new{foreground=1,dx=2,y=120,text="Sorry, Sid, our mascot, needed to take another leak!"})
				},
				duration=1.8e4,
				name="final dog"
			},
			{
				append=true,
				code={
					function()
						-- Use new sprites which contain a font.
						table2mem(0x6000,lzwUncompress(images_font_sto16x16_artist_made_tileslzw))
						vbank(1)
						setPalette(images_font_sto16x16_artist_made_palette)
						return REMOVE
					end,
					function() vbank(1) cls(0) end,
					NoiseText:new{
						text={
							---------------(/ 240 16)15
							"THE END",
						},
						topline=69
					},
					function() vbank(0) end,
				},
				name="The End",
				duration=7e3
			},
			{
				append=true,
				code={
					function(signals) signals.fireworks=true end
				},
				duration=4e3,
				name="fireworks"
			},
			{
				append=true,
				code={
					function()
						table2mem(0x6000,lzwUncompress(images_crab_tileslzw))
						return REMOVE
					end,
					delay_ms(3.5e3, Crab:new{y=108}),
					delay_ms(1.6e4, Crab:new{y=110}),
					delay_ms(1.1e4, Crab:new{y=113}),
					delay_ms(7e3, Crab:new{y=116}),
					delay_ms(2e4, Crab:new{y=117}),
					Crab:new{y=119}
				},
				name="crab"
			},
			------------------------------------------------------------------
			-- Development
			------------------------------------------------------------------
			{code={}} -- End, do nothing anymore.
		}
	}
end
-- Must be last!
--|#include "beach_relaxation.ticdata.lua"
