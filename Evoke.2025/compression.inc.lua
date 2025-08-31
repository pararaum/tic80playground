-- Serialisation and compression functions.
SER85CHARS="!~#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[|]^_`abcdefghijklmnopqrstu"
SER85CHARTABLE={}
for i=1,#SER85CHARS do SER85CHARTABLE[SER85CHARS:sub(i,i)]=i-1 end


-- Transform a stringified table of LZ77 tuples into plain tuples to
-- be used by the uncompressor.
function lz77str_to_tuple(tstr)
   local res={}
	-- Further hints can be seen here: http://lua-users.org/wiki/SplitJoin.
   tstr:gsub("([^;]+)", function(x)
	     local t={}
	     x:gsub("[^,]+", function(y) table.insert(t,tonumber(y,16)) end)
	     table.insert(res,t)
   end)
   return res
end


-- Get a memory block at addr of length len into a table for further
-- processing.
function mem2table(addr,len)
	local res={}
	for i=addr,addr+len-1 do
		table.insert(res,peek(i))
	end
	return res
end


-- Reverse function to mem2table().
function table2mem(addr,data)
	for i,v in ipairs(data) do
		poke(addr-1+i,v)
	end
end


-- Serialise a table (list) of values in an encoding similar to
-- ascii85.
function ser85enc(data)
	assert(#data%4==0)
	local result=""
	for i=1,#data,4 do
		local val=(data[i]<<24)+(data[i+1]<<16)+(data[i+2]<<8)+data[i+3]
		for j=4,0,-1 do
			local v85=1+math.floor(val/85^j)%85
			result=result..SER85CHARS:sub(v85,v85)
		end
	end
	return result
end


-- Deserialise a string in an encoding similar to ascii85 into a
-- table.
function ser85dec(cstr)
	assert(#cstr%5==0)
	local res={}
	for i=1,#cstr,5 do
		local val=0
		for j=0,4 do
			val=val*85+SER85CHARTABLE[cstr:sub(i+j,i+j)]
		end
		for j=3,0,-1 do
			table.insert(res,(val>>(j*8))%256)
		end
	end
	return res
end


-- Compress a table "data" of values [0..255] with LZW.
function lzwCompress(data,traceout)
   local dict_size = 256
   local dictionary = {}
   local w,wc
   local result = {}
   for i = 0, dict_size - 1 do
      dictionary[tostring(i)] = i
   end
   -- Build the dictionary and encode
   for _,c in ipairs(data) do
      c=tostring(c)
      if w==nil then
			wc=c
      else
			wc = w.."#"..c
      end
      if dictionary[wc] then
			w = wc
      else
			table.insert(result, dictionary[w])
			dictionary[wc] = dict_size
			dict_size = dict_size + 1
			w = c
      end
   end
   -- Add last sequence
   if #w ~= 0 then
      table.insert(result, dictionary[w])
   end
	if traceout then
		trace(string.format("{%s} -- %d tokens", table.concat(result,","), #result))
		--local hexes={}
		--for _,i in ipairs(result) do table.insert(hexes,string.format("%x",i)) end
		--trace(string.format("\"%s\" -- %d tokens", table.concat(hexes,","), #result))
	end
   return result
end


function lzwCompTiles()
	return lzwCompress(mem2table(0x4000,8192),true)
end


function lzwCompSprites()
	return lzwCompress(mem2table(0x6000,8192),true)
end


-- Uncompress LZW data.
function lzwUncompress(compressed)
   local dict_size = 256
   local dictionary = {}
    -- Initialize dictionary with 8-bit bytes.
   for i = 0, dict_size - 1 do
      dictionary[i] = {i}
   end
   local result = {compressed[1]}
   local w={compressed[1]}
   local entry
   for idx=2,#compressed do
      local tok=compressed[idx]
      if dictionary[tok] then
			entry = dictionary[tok]
      elseif tok == dict_size then
			entry = { table.unpack(w) }
			table.insert(entry,w[1])
      else
			return nil, "Invalid compressed data"
      end
      -- Add entry to output.
      for _,i in ipairs(entry) do table.insert(result,i) end
      -- Add pair to dictionary.
      local copy={table.unpack(w)}
      table.insert(copy,entry[1])
      dictionary[dict_size]=copy
      dict_size=dict_size+1
      --
      w = entry
    end
    return result
end


-- Uncompress LZ77 compressed data. Input are LZ77 tuples or a string
-- which is handled by the lz77str_to_tuple() function.
-- strEG is an Elias-Gamma encoded string
function uncompressLZ77(data, strEG)
	local function bytes2bits(seg)
		bits=""
		for _,v in ipairs(seg) do
			for i=7,0,-1 do
				if v&(1<<i)~=0 then
					bits=bits.."1"
				else
					bits=bits.."0"
				end
			end
		end
		return bits
	end
	function readbyte(str)
		local val=0
		for i=1,8 do
			val=val<<1
			if str:sub(i,i)~="0" then
				val=val|1
			end
		end
		return val,str:sub(9)
	end
	function readeg(str)
		-- 0001xxx
		-- 12345678
		--
		-- 1
		-- 12
		local val=0
		local initial=1
		while str:sub(initial,initial)=="0" do
			initial=initial+1 -- Count zeros.
			if initial>#str then return end -- We have been filled with zeros...
		end
		for i=0,initial-1 do
			val=val<<1
			if str:sub(initial+i,initial+i)~="0" then
				val=val|1
			end
		end
		return val,str:sub(2*initial)
	end
				
	if type(data)=="string" then
		data=lz77str_to_tuple(data)
	end
	if strEG~=nil then
		data={}
		strEG=ser85dec(strEG)
		strEG=bytes2bits(strEG)
		while #strEG>0 do
			local back1,s1=readeg(strEG)
			if s1==nil then break end
			local count1,s2=readeg(s1)
			if s2==nil then break end
			local byte,s3=readbyte(s2)
			local back,count=back1-1,count1-1
			strEG=s3
			table.insert(data,{back,count,byte})
		end
	end
	local dest,pos={},1
	for _,d in ipairs(data) do
		local off,len,c=table.unpack(d)
		if len>0 then
			for i=0,len-1 do
				dest[pos+i]=dest[pos-off+i]
			end
			pos=pos+len
		end
		if c>=0 then
			dest[pos]=c
			pos=pos+1
		end
	end
	return dest
end
