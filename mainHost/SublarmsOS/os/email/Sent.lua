-- Sent

os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")
os.loadAPI(Config.rootDir().."/utils/TextUtils")
os.loadAPI(Config.rootDir().."/utils/FileHandler")

rtConf = FileHandler.readVariableFile(Config.runtimeFile())
error = false
emails = FileHandler.readVariableFile(Config.rootDir().."/os/email/sentmail/"..rtConf.user)
-- {id,to,subj,body}

-- for testing
-- emails = {{1,"Adroon","Hello, Carg",true},{2,"Mart","Fwd> Fwd> Re> Memes",false},{10,"Extra","pls scroll",false},{3,"a","b",true},{4,"b","isred",false},{5,"Kappa","new emotes",false},{6,"Keepo","Re> pls no kappa",true},{7,"b1g_d4ddY_com","WIN FR33 £1000 GIFT CARD",true},{8,"y","fak",false},{9,"Carg","I fucked up",false}}

local obj = 1
local offset = 0

-- mainloop
while true do

  ScreenUtils.drawHF("Email >> Sent")

  term.setCursorPos(1,4)
  term.write("     To             Subject                      ") 
    
  -- print based on email numbers
  if #emails == 0 then
    term.setCursorPos(1,8)
    term.write("                No Messages Found                ")
  elseif error then
    term.setCursorPos(1,8)
    term.write("                 An Error Occured                ")
  else
    baseRow = 5
    for i=1,9 do  -- print first 9 emails, rest won't fit on page
      if i + offset > #emails then
        break
      end
      writeMail = emails[i + offset]
      term.setCursorPos(1,baseRow + i)
      term.write("                                                ")
      term.setCursorPos(4,baseRow + i)
      term.setCursorPos(6,baseRow + i)
      term.write(writeMail[2])
      subj = writeMail[3]
      if #subj > 27 then
        subj = string.sub(subj,1,24).."..."
      end
      term.setCursorPos(21,baseRow + i)
      term.write(subj)
    end
    if offset + 9 < #emails then
      term.setCursorPos(1,baseRow+11)
      term.write("               Scroll down for more              ")
    end
  end
  
  -- email selector
  if #emails > 0 then
    term.setCursorPos(2, 5 + obj)
    term.write("[")
    term.setCursorPos(49, 5 + obj)
    term.write("]")
  end

  -- get user input
  e,k = os.pullEvent("key")
  if k == 208 then
    if obj == 9 then
      if obj+offset < #emails then
        offset = offset + 1
      end
    else
      if obj < #emails then
        obj = obj + 1
      end
    end
  elseif k == 200 then
    if obj == 1 then
      if offset > 0 then
        offset = offset - 1
      end
    else
      obj = obj - 1
    end
  elseif k == 28 then
    selectedMail = emails[obj + offset]
    emailID = tostring(selectedMail[1])
    shell.run(Config.rootDir().."/os/email/ReadSent",emailID)
  elseif k == 14 then
    break
  end

end
