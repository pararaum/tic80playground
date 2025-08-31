ArithBase={
   EOF="EOF",
}
function ArithBase:extend(init)
   init = init or {}
   init.extends = self
   return setmetatable(init, {__index=self})
end
function ArithBase:new(init)
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
function ArithBase:init()
   self.symbols={}
   self.symdict={}
   self.code=0
   self.low=0
   self.high=0xFFFFFFFF
   self.output={}
   self.underflow_count=0
   self.mask=self.high
   self.highest_bit=(self.high+1)>>1
   self.underflow_bit=self.highest_bit>>1
   -- Special symbol which is nonexistend...
   self.symbols[0]={sum=0}
   self:init_symbols()
end
function ArithBase:init_symbols()
   self:add_symbol(self.EOF)
end
function ArithBase:add_symbol(s)
   -- Symbol consists of:
   -- sym: the symbol itself
   -- count: number of occurences
   -- sum: total of counts running from last symbol to front of list
   -- idx: index of this symbol (trick to navigate within symbol list)
   local new={sym=s,count=1,sum=0,idx=#self.symbols+1}
   -- Add to list of symbols
   table.insert(self.symbols,new)
   -- For faster access add to dictionary.
   self.symdict[s]=new
   -- Renormalize...
   self:update_counts(new)
   return new
end
function ArithBase:find_symbol(byte)
   local sym=self.symdict[byte]
   if sym~=nil then
      return self.symbols[0].sum,sym.sum,self.symbols[sym.idx-1].sum,sym
   end
end
function ArithBase:encode(scale,lowrange,highrange,sym)
   --🧪 print(string.format("encode(%s): scale=%d,lowrange=%d,highrange=%d,symb=%s",symb.sym,scale,lowrange,highrange,symb))
   local range=self.high-self.low+1
   --🧪 print(string.format("[range=%08x,underflow=%s,low=%08X,high=%08X,lowrange=%e,highrange=%e,output=%s",range,underflow_count,low,high,lowrange,highrange,table.concat(output)))
   -- First change high as low is used here.
   self.high=self.low+math.floor(range*highrange/scale-1)
   self.low=self.low+math.floor(range*lowrange/scale)
   --🧪 print(string.format("|range=%08x,underflow=%s,low=%08X,high=%08X,lowrange=%e,highrange=%e,output=%s",range,underflow_count,low,high,lowrange,highrange,table.concat(output)))
   while true do
      -- Output the matching most significant bit.
      if (self.high&self.highest_bit)==(self.low&self.highest_bit) then
	 self:output_bit(self.high&self.highest_bit)
	 while self.underflow_count>0 do
	    self:output_bit((~self.high)&self.highest_bit)
	    self.underflow_count=self.underflow_count-1
	 end
      elseif (self.low&self.underflow_bit~=0) and (self.high&self.underflow_bit==0) then
	 self.underflow_count=self.underflow_count+1
	 self.low=self.low&(self.underflow_bit-1)
	 self.high=self.high|self.underflow_bit
      else
	 break
      end
      self.high=((self.high<<1)&self.mask)|1
      self.low=(self.low<<1)&self.mask
   end
end
function ArithBase:flush_encoder()
   self:output_bit(self.low&self.underflow_bit);
   self.underflow_count=self.underflow_count+1
   while self.underflow_count>0 do
      self:output_bit((~self.low)&self.underflow_bit)
      self.underflow_count=self.underflow_count-1
   end
end
function ArithBase:output_bit(val)
   if val~=0 then
      table.insert(self.output,1)
   else
      table.insert(self.output,0)
   end
end
function ArithBase:update_counts(symbol)
   for i=#self.symbols,1,-1 do
      -- This will write the total to symbols[0]!
      self.symbols[i-1].sum=self.symbols[i].sum+self.symbols[i].count
   end
end
function ArithBase:encode_token(token)
   local scale,lowr,highr,symbol=self:find_symbol(token)
   if symbol~=nil then
      self:encode(scale,lowr,highr,symbol)
      symbol.count=symbol.count+1
      self:update_counts(symbol)
   else
      return self:handle_unknown_token(token)
   end
   return symbol
end
function ArithBase:encode_message(message)
   for i=1,#message do
      local char=message:sub(i,i)
      local byte=string.byte(char)
      local symbol=self:encode_token(byte)
   end
   self:encode(self:find_symbol(self.EOF))
   self:flush_encoder()
   return self.output
end
function ArithBase:_print_symbols()
   for k,v in ipairs(self.symbols) do
      print(string.format("k=%d,sum=%d,sym=%02X,count=%d,idx=%d",k,v.sum,v.sym,v.count,v.idx))
   end
   print(string.format("\tsymbols[0].sum=%d",self.symbols[0].sum))
end
function ArithBase:get_current_count(scale,code)
   local range=self.high-self.low+1
   local count=(((code-self.low)+1)*scale-1)/range
   return math.floor(count)
end
function ArithBase:input_bit()
   self.messagepos=self.messagepos+1
   return self.message[self.messagepos] or 0
end
function ArithBase:remove_symbol_from_stream(scale,low_count,high_count)
   local range=self.high-self.low+1
   --🧪 print(string.format("[scale=%08x,lc=%d,hc=%d,low=%08x,high=%08x,code=%08X,range=%08x",scale,low_count,high_count,low,high,code,range))
   self.high=math.floor(self.low+range*high_count/scale-1)
   self.low=math.floor(self.low+range*low_count/scale)
   --🧪 print(string.format("|scale=%08x,low=%08x,high=%08x,code=%08X",scale,low,high,code))
   while true do
      -- Remove matching most significant bit.
      if (self.high&self.highest_bit)==(self.low&self.highest_bit) then
	 --🧪 print("<<")
      elseif (self.low&self.underflow_bit==self.underflow_bit) and (self.high&self.underflow_bit==0) then
	 self.code=self.code~self.underflow_bit
	 self.low=self.low&(self.underflow_bit-1)
	 self.high=self.high|self.underflow_bit
      else
	 break
      end
      self.high=((self.high<<1)&self.mask)|1
      self.low=(self.low<<1)&self.mask
      self.code=((self.code<<1)&self.mask)|self:input_bit()
   end
   --🧪 print(string.format("]scale=%08x,low=%08x,high=%08x,code=%08X",scale,low,high,code))
end
function ArithBase:find_symbol_by_count(count)
   local sum=0
   for i=#self.symbols,1,-1 do
      local s=self.symbols[i]
      sum=sum+s.count
      if count<sum then
	 return sum,s
      end
   end
end
function ArithBase:output_decoded_symbol(sym)
   if type(sym.sym)=="string" then
      table.insert(output,sym.sym)
   else
      table.insert(self.output,string.char(sym.sym))
   end
end
function ArithBase:decode_message(message)
   self.messagepos=0
   self.message=message
   -- Fill code with bits from input stream.
   for i=1,32 do
      self.code=self.code<<1
      self.code=self.code|self:input_bit()
   end
   -- Now decode!
   while true do
      local scale=self.symbols[0].sum -- Total sum of all counts.
      local count=self:get_current_count(scale,self.code)
      --print(string.format("D:scale=%08x,count=%08x,code=%08X %e,low=%08X,hight=%08X",scale,count,self.code,self.code/(self.high-self.low),self.low,self.high))
      local sum,sym=self:find_symbol_by_count(count)
      -- if sym.sym>=32 and sym.sym<128 then
      -- 	 print(string.format("sum=%d,symbol.count=%d,symbol=%s '%s'",sum,sym.count,sym.sym,string.char(sym.sym)))
      -- else
      -- 	 print(string.format("sum=%d,symbol.count=%d,symbol=%s ?",sum,sym.count,sym.sym))
      -- end
      --🧪 _output_table()
      if sym.sym==self.EOF then
	 break
      elseif type(sym.sym)=="boolean" then
	 raw_bits=raw_bits<<1
	 if sym.sym then
	    raw_bits=raw_bits|1
	 end
	 raw_bit_counter=raw_bit_counter+1
	 if raw_bit_counter==8 then
	    --table.insert(symbols,{sym=string.char(raw_bits),count=1})
	    table.insert(symbols,{sym=raw_bits,count=1})
	    table.insert(output,string.char(raw_bits))
	    raw_bits=0
	    raw_bit_counter=0
	 end
      else
	 self:output_decoded_symbol(sym)
      end
      self:remove_symbol_from_stream(scale,sum-sym.count,sum)
      sym.count=sym.count+1
      self:update_counts(sym)
   end
   return self.output
end

Arith=ArithBase:extend()
function Arith:init_symbols()
   self.extends.init_symbols(self)
   for i=0,255 do
      self:add_symbol(i)
   end
end

ArithEscape=ArithBase:extend()
function ArithEscape:init_symbols()
   self.extends.init_symbols(self)
   self:add_symbol(-2) --Escape Code!
end
function ArithEscape:handle_unknown_token(token)
   --print("TOKEN: "..token)
   for i=7,0,-1 do
      self:output_bit(token&(1<<i))
   end
   self:add_symbol(token)
   --self:_print_symbols()
end
function ArithEscape:output_decoded_symbol(sym)
   if sym.sym==-2 then
      local val=0
      for i=1,8 do
	 val=val<<1
	 val=val|self:input_bit()
      end
      sym=self:add_symbol(val)
   end
   self.extends.output_decoded_symbol(self,sym)
end

-- arith=Arith:new()
-- arith:encode_message("ABRACADABRA really,magic")
-- dearith=Arith:new()
-- dearith:_print_symbols()
-- print(table.concat(arith.output))
-- print("decoded '"..table.concat(dearith:decode_message(arith.output),"~").."'")
-- 
-- -- Fails due to mixing of arithmetic bits and raw bits for encoded symbol
-- print("ArithEscape encode")
-- arith=ArithEscape:new()
-- arith:encode_message("ABRACADABRA really,magic")
-- print("ArithEscape decode")
-- dearith=ArithEscape:new()
-- dearith:_print_symbols()
-- print(table.concat(arith.output))
-- print("decoded '"..table.concat(dearith:decode_message(arith.output),"~").."'")


-- Second version...
ArithEscape=ArithBase:extend()
function ArithEscape:init_symbols()
   self.extends.init_symbols(self)
   self:add_symbol(-2) --Escape Code!
end
function ArithEscape:handle_unknown_token(token)
   --print("TOKEN: "..token)
   local minsymbol=#self.symbols-2
   for i=minsymbol,token do
      assert(self:find_symbol(i)==nil)
      self:encode_token(-2)
      self:add_symbol(i)
   end
   --self:_print_symbols()
   --print(self:find_symbol(token))
   local _,_,_,symbol=self:find_symbol(token)
   --symbol.count=0 -- As it is increased later on!
   return self:encode_token(token)
end
function ArithEscape:output_decoded_symbol(sym)
   if sym.sym==-2 then
      self:add_symbol(#self.symbols-2)
      --self:_print_symbols()
      return
   end
   self.extends.output_decoded_symbol(self,sym)
end
print("ArithEscape2 encode")
message="                    ARA, ARA, says the Parrot!                    #"
print(message)
arith=ArithEscape:new()
arith:encode_message(message)
print(table.concat(arith.output).." "..#arith.output.." "..(#arith.output/8))
print("ArithEscape2 decode")
dearith=ArithEscape:new()
decoded=dearith:decode_message(arith.output)
print("decoded '"..table.concat(decoded).."' "..#decoded)



function compress(str)
   local symdict={}
   symdict[false]={sym=false, count=1}
   symdict[true]={sym=true, count=1}
   local symbols={
      symdict[false],
      symdict[true],
      {sym=-1, count=1}  -- EOF
   }
   for i=0,255 do table.insert(symbols,{sym=string.char(i),count=1}) end
   local low=0
   local mask=0xFFFFFFFF
   local high=0xFFFFFFFF
   local output={}
   local highest_bit=0x80000000
   local underflow_bit=highest_bit>>1
   local underflow_count=0

   function find_symbol(s)
      local sum=0
      local sum_low,sum_high
      local symbol
      for i,v in ipairs(symbols) do
	 if v.sym==s then
	    sum_low=sum
	    sum_high=sum+v.count
	    symbol=v
	 end
	 sum=sum+v.count
      end
      if symbol then
	 return sum,sum_low,sum_high,symbol
      end
   end
   function output_bit(val)
      if val~=0 then
	 table.insert(output,1)
      else
	 table.insert(output,0)
      end
   end
   function flush_encoder()
      output_bit(low&underflow_bit);
      underflow_count=underflow_count+1
      while underflow_count>0 do
	 output_bit((~low)&underflow_bit)
	 underflow_count=underflow_count-1
      end
   end
   function encode(scale,lowrange,highrange,symb)
      --🧪 print(string.format("encode(%s): scale=%d,lowrange=%d,highrange=%d,symb=%s",symb.sym,scale,lowrange,highrange,symb))
      local range=high-low+1
      --🧪 print(string.format("[range=%08x,underflow=%s,low=%08X,high=%08X,lowrange=%e,highrange=%e,output=%s",range,underflow_count,low,high,lowrange,highrange,table.concat(output)))
      -- First change high as low is used here.
      high=low+math.floor(range*highrange/scale-1)
      low=low+math.floor(range*lowrange/scale)
      --🧪 print(string.format("|range=%08x,underflow=%s,low=%08X,high=%08X,lowrange=%e,highrange=%e,output=%s",range,underflow_count,low,high,lowrange,highrange,table.concat(output)))
      while true do
	 -- Output the matching most significant bit.
	 if (high&highest_bit)==(low&highest_bit) then
	    output_bit(high&highest_bit)
	    while underflow_count>0 do
	       output_bit((~high)&highest_bit)
	       underflow_count=underflow_count-1
	    end
	 elseif (low&underflow_bit~=0) and (high&underflow_bit==0) then
	    underflow_count=underflow_count+1
	    low=low&(underflow_bit-1)
	    high=high|underflow_bit
	 else
	    break
	 end
	 high=((high<<1)&mask)|1
	 low=(low<<1)&mask
      end
      --🧪 print(string.format("]range=%08x,underflow=%s,low=%08X,hight=%08X,lowrange=%e,highrange=%e,output=%s",range,underflow_count,low,high,lowrange,highrange,table.concat(output)))
   end
   function add_symbol(s)
      local symval
      if type(s)=="string" then
	 symval=string.byte(s)
      end
      local bits=8 --math.floor(math.log(s)/math.log(2))+1
      for i=bits-1,0,-1 do
	 if symval&(1<<i)~=0 then
	    encode(find_symbol(true))
	    symdict[true].count=symdict[true].count+1
	 else
	    encode(find_symbol(false))
	    symdict[false].count=symdict[false].count+1
	 end
      end
      table.insert(symbols,{sym=s,count=1})
   end
   function _print_symbols()
      for k,v in ipairs(symbols) do print(k,v.sym,v.count) end
   end

   for i=1,#str do
      local char=str:sub(i,i)
      --🧪 print(string.format("idx=%d '%s'",i,char))
      local scale,lowr,highr,symbol=find_symbol(char)
      if symbol~=nil then
	 encode(scale,lowr,highr,symbol)
	 symbol.count=symbol.count+1
      else
	 -- New symbol
	 add_symbol(char)
	 --encode(char)
      end
   end
   encode(find_symbol(-1))
   flush_encoder()
   _print_symbols()
   return output
end


function uncompress(cdata)
   --🧪 print("cdata: "..table.concat(cdata))
   local symdict={}
   symdict[false]={sym=false, count=1}
   symdict[true]={sym=true, count=1}
   local symbols={
      symdict[false],
      symdict[true],
      {sym=-1, count=1}  -- EOF
   }
   for i=0,255 do table.insert(symbols,{sym=string.char(i),count=1}) end
   local low=0
   local high=0xFFFFFFFF
   local mask=high
   local output={}
   local highest_bit=0x80000000
   local underflow_bit=highest_bit>>1
   local underflow_count=0
   local output={}
   local code=0
   local cdata_pos=0
   local raw_bits=0
   local raw_bit_counter=0

   function input_bit()
      local oldpos=cdata_pos
      cdata_pos=cdata_pos+1
      return cdata[cdata_pos] or 0
   end
   function get_symbol_scale()
      local sum=0
      for _,v in ipairs(symbols) do
	 sum=sum+v.count
      end
      return sum
   end
   -- Scale is the sum of all counts, the code is between high and low
   -- with code=count/scale:
   function get_current_count(scale)
      local range=high-low+1
      local count=(((code-low)+1)*scale-1)/range
      return math.floor(count)
   end
   function find_symbol(count)
      local sum=0
      for i,s in ipairs(symbols) do
	 sum=sum+s.count
	 if count<sum then
	    return sum,s
	 end
      end
   end
   function remove_symbol_from_stream(scale,low_count,high_count)
      local range=high-low+1
      --🧪 print(string.format("[scale=%08x,lc=%d,hc=%d,low=%08x,high=%08x,code=%08X,range=%08x",scale,low_count,high_count,low,high,code,range))
      high=math.floor(low+range*high_count/scale-1)
      low=math.floor(low+range*low_count/scale)
      --🧪 print(string.format("|scale=%08x,low=%08x,high=%08x,code=%08X",scale,low,high,code))
      while true do
	 -- Remove matching most significant bit.
	 if (high&highest_bit)==(low&highest_bit) then
	    --🧪 print("<<")
	 elseif (low&underflow_bit==underflow_bit) and (high&underflow_bit==0) then
	    code=code~underflow_bit
	    low=low&(underflow_bit-1)
	    high=high|underflow_bit
	 else
	    break
	 end
	 high=((high<<1)&mask)|1
	 low=(low<<1)&mask
	 code=((code<<1)&mask)|input_bit()
      end
      --🧪 print(string.format("]scale=%08x,low=%08x,high=%08x,code=%08X",scale,low,high,code))
   end

   function _output_table()
      local sum=0
      local lowsum=0
      for _,v in ipairs(symbols) do sum=sum+v.count end
      for k,v in ipairs(symbols) do
	 print("\t",k,v.sym,v.count,lowsum,lowsum/sum)
	 lowsum=lowsum+v.count
      end
      print("\t","","","",lowsum,lowsum/sum)
   end

   -- Fill code with bits from input stream.
   for i=1,32 do
      code=code<<1
      code=code|input_bit()
   end
   -- Now decode!
   while true do
      local scale=get_symbol_scale()
      local count=get_current_count(scale)
      --🧪 print(string.format("D:scale=%08x,count=%08x,code=%08X %e,low=%08X,hight=%08X",scale,count,code,code/(high-low),low,high))
      local sum,sym=find_symbol(count)
      --🧪 print(string.format("sum=%d,symbol.count=%d,symbol=%s",sum,sym.count,sym.sym))
      --🧪 _output_table()
      if sym.sym==-1 then
	 break
      elseif type(sym.sym)=="boolean" then
	 raw_bits=raw_bits<<1
	 if sym.sym then
	    raw_bits=raw_bits|1
	 end
	 raw_bit_counter=raw_bit_counter+1
	 if raw_bit_counter==8 then
	    --table.insert(symbols,{sym=string.char(raw_bits),count=1})
	    table.insert(symbols,{sym=raw_bits,count=1})
	    table.insert(output,string.char(raw_bits))
	    raw_bits=0
	    raw_bit_counter=0
	 end
      else
	 if type(sym.sym)=="string" then
	    table.insert(output,sym.sym)
	 else
	    table.insert(output,string.char(sym.sym))
	 end
      end
      remove_symbol_from_stream(scale,sum-sym.count,sum)
      sym.count=sym.count+1
   end
   return output
end

SER85CHARS="!~#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[|]^_`abcdefghijklmnopqrstu"
SER85CHARTABLE={}
for i=1,#SER85CHARS do SER85CHARTABLE[SER85CHARS:sub(i,i)]=i-1 end
function ser85enc(data)
   --assert(#data%4==0)
   while #data%4~=0 do table.insert(data,0) end
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

function binstream2text(data)
   local bytes={}
   for i=1,#data,8 do
      local byte=0
      for j=0,7 do
	 byte=byte<<1
	 if data[i+j]==1 then
	    byte=byte|1
	 end
      end
      table.insert(bytes,byte)
   end
   return ser85enc(bytes)
end


--~ odata="abracadabraaaaaa"
--~ odata="Abracadabra with a very long Text and funny stuff '!$%/&%&/' inside it! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
--~ --odata="a"
--~ --odata="abcdefghijkl"
--~ print(string.format("Original data #%d: %s",#odata,odata))
--~ cdata=compress(odata)
--~ print(string.format("#cdata=%d,bytes=%f: %s",#cdata,#cdata/8,table.concat(cdata):gsub("........", function(x) return x..':' end)))
--~ print(binstream2text(cdata))
--~ udata=uncompress(cdata)
--~ print(string.format("#udata=%d: %s",#udata,table.concat(udata)))

