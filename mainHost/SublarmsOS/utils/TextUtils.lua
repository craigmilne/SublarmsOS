function split(s, regex)
  if regex == nil then
    regex = "%s"
  end
  local t = {} ; i = 1
  for str in string.gmatch(s, "([^"..regex.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function readLen(len,fill)
  local input = ""
  local x,y = term.getCursorPos()

  term.setCursorBlink(true)

  repeat
    term.setCursorPos(x,y)
    term.write(string.rep(' ',len))
    term.setCursorPos(x,y)
    if fill == nil then
      term.write(input)
    else
      term.write(string.rep(fill,#input))
    end
    
    local e, k = os.pullEvent()
    if e == 'char' then
      if #input < len and k ~= ':' then
        input = input .. k
      end
    elseif e == 'key' then
      if k == 14 then
        input = string.sub(input,1,#input - 1)
      end
    end
  until e == 'key' and k == 28
  term.setCursorBlink(false)
  return input   
end

function endWith(s,e)
  return e == '' or string.sub(s,-1 * #e) == e
end

function bodyText(w,h)
  if w == nil then
    w = 47
  end
  if h == nil then
    h = 10
  end

  local x,y = term.getCursorPos()
  local endInput = false
  local input = ""
  local preEnd = false

  term.setCursorBlink(true)
  repeat
    term.setCursorPos(x,y)
    for k=1,h do
      term.setCursorPos(x,y-1+k)
      term.write(string.rep(' ',w))
    end
    term.setCursorPos(x,y)
    rows = {}
    row = ""
    inputParts = split(input," ")
    for i=1,#inputParts do
      word = inputParts[i]
      newRow = row .. " " .. word
      if word == "~d#" then
        rows[#rows + 1] = row
        row = ""
      else
        if #newRow > w-1 then
          rows[#rows + 1] = row
          row = word
        else
          row = newRow
        end
      end
    end
    rows[#rows + 1] = row
    local index = 0
    for j=1,h do
      if #rows > h then
        index = #rows - h
      end
      sunset = -1
      if rows[index + j] == nil or string.sub(rows[index + j],1,1) ~= " " then
        sunset = 0
      end 
      term.setCursorPos(x + sunset,y - 1 + j)
      term.write(rows[index + j])
    end
    lex = rows[#rows]
    ley = y
    if index > 0 then
      ley = y + h - 1
    else
      ley = y + #rows - 1
    end
    extra = 0
    if endWith(input, " ") and not endWith(input," ~d# ") then
      extra = extra + 1
    end
    if string.sub(lex,1,1) == " " then
      extra = extra - 1
    end
    term.setCursorPos(#lex + x + extra, ley)
    if preEnd then
      endInput = true
      break
    end
    e, k = os.pullEvent()
    if e == 'char' then
      input = input .. k
    elseif e == 'key' then
      if k == 14 then
        if endWith(input," ~d# ") then
          input = string.sub(input, 1, #input - 5)
        else
          input = string.sub(input, 1, #input - 1)
        end
      elseif k == 28 then
        input = input .. " ~d# "
      elseif k == 54 then
        selYes = true
        while true do
          term.setCursorPos(9,7)
          term.write("                                  ")
          term.setCursorPos(9,8)
          term.write("  ##############################  ")
          term.setCursorPos(9,9)
          term.write("  #                            #  ")
          term.setCursorPos(9,10)
          term.write("  #        Confirm  Text?      #  ")
          term.setCursorPos(9,11)
          term.write("  #                            #  ")
          term.setCursorPos(9,12)
          term.write("  #   [  Yeah  ]  [  Nope  ]   #  ")
          term.setCursorPos(9,13)
          term.write("  #                            #  ")
          term.setCursorPos(9,14)
          term.write("  ##############################  ")
          if selYes then
            term.setCursorPos(9,12)
            term.write("  #   [  Yeah  ]     Nope      #  ")
          else
            term.setCursorPos(9,12)
            term.write("  #      Yeah     [  Nope  ]   #  ")
          end
          e1,k1 = os.pullEvent('key')
          if k1 == 28 then
            if selYes then
              preEnd = true
              break
            else
              break
            end
          elseif k1 == 203 then
            selYes = true
          elseif k1 == 205 then
            selYes = false
          end
        end
      end
    end
  until endInput
  term.setCursorBlink(false)
  return input
end


