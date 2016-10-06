function split(s, regex)
  if regex == nil then
    regex = "%s"
  end
  local t = {}; i = 1
  for str in string.gmatch(s, "([^"..regex.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function convert( chars, dist, inv )
  return string.char( ( string.byte( chars ) - 32 + ( inv and -dist or dist ) ) % 95 + 32 )
end

function encrypt(str,k)
  local inv = false
  local enc= ""
  for i=1,#str do
    if #str-k[5] >= i or not inv then
      for inc=0,3 do
        if(i%4 == inc)then
          enc = enc .. convert(string.sub(str,i,i),k[inc+1],inv)
          break
        end
      end
    end
  end
  if not inv then
    for i=1,k[5] do
      enc = enc .. string.char(46 + (#str % 9))
    end
  end
  return enc:gsub(":","cc")
end

a = "Hello"
