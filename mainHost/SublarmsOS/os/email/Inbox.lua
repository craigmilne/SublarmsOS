-- user inbox

os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")
os.loadAPI(Config.rootDir().."/utils/TextUtils")
os.loadAPI(Config.rootDir().."/utils/FileHandler")

rtConf = FileHandler.readVariableFile(Config.runtimeFile())

error = false

-- get all the email headers from the server
emailStrings = {}
rednet.send(Config.emailServer(),"FETCHHEAD:"..rtConf.user)
s,m = rednet.receive(3)
if m ~= nil then
  ms = TextUtils.split(m,":")
  for i=1,tonumber(ms[2]) do
    s1,m1 = rednet.receive(1)
    if m1 == nil then
      error = true
      break
    end
    table.insert(emailStrings,m1)
  end
else
  error = true
end

emails = {}

for i=1,#emailStrings do
  str = emailStrings[i]
  strs = TextUtils.split(str,":")
  id = tonumber(strs[2])
  unread = true
  if strs[6] == "false" then
    unread = false
  end
  mail = {id,strs[4],strs[5],unread}
  table.insert(emails,mail)
end

-- sort unread email to the top
local unreademails = {}
local reademails = {}
for i=1,#emails do
  lelelel = emails[i]
  if lelelel[4] then
    unreademails[#unreademails + 1] = lelelel
  else
    reademails[#reademails + 1] = lelelel
  end
end
for i=1,#reademails do
  unreademails[#unreademails + i] = reademails[i]
end
--uncomment this to sort by unread
--emails = unreademails -- actually sorted by unread

-- reverse emails
local emaTemp = {}
for i=#emails, 1, -1 do table.insert(emaTemp,emails[i]) end
emails = emaTemp

-- for testing
-- emails = {{1,"Adroon","Hello, Carg",true},{2,"Mart","Fwd> Fwd> Re> Memes",false},{10,"Extra","pls scroll",false},{3,"a","b",true},{4,"b","isred",false},{5,"Kappa","new emotes",false},{6,"Keepo","Re> pls no kappa",true},{7,"b1g_d4ddY_com","WIN FR33 £1000 GIFT CARD",true},{8,"y","fak",false},{9,"Carg","I fucked up",false}}

local obj = 1
local offset = 0

-- main loop
while true do

  ScreenUtils.drawHF("Email >> Inbox")

  term.setCursorPos(1,4)
  term.write("     Sender         Subject                      ") 
    
  -- print inbox contents
  if #emails == 0 then
    term.setCursorPos(1,8)
    term.write("                No Messages Found                ")
  elseif error then
    term.setCursorPos(1,8)
    term.write("                 An Error Occured                ")
  else
    baseRow = 5
    for i=1,9 do
      if i + offset > #emails then
        break
      end
      writeMail = emails[i + offset]
      term.setCursorPos(1,baseRow + i)
      term.write("                                                ")
      term.setCursorPos(4,baseRow + i)
      if writeMail[4] then
        term.write("!")
      end
      term.setCursorPos(6,baseRow + i)
      term.write(writeMail[2])
      subj = writeMail[3]
      if #subj > 27 then
        subj = string.sub(subj,1,24).."..."
      end
      term.setCursorPos(21,baseRow + i)
      term.write(subj)
    end
    -- deal with oveflow
    if offset + 9 < #emails then
      term.setCursorPos(1,baseRow+11)
      term.write("               Scroll down for more              ")
    end
  end
  
  -- track selected email
  if #emails > 0 then
    term.setCursorPos(2, 5 + obj)
    term.write("[")
    term.setCursorPos(49, 5 + obj)
    term.write("]")
  end

  -- handle input for whichever email user selects/if they exit
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
    shell.run(Config.rootDir().."/os/email/Read",emailID)
  elseif k == 14 then
    break
  end

end
