-- Home

os.loadAPI("SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")
os.loadAPI(Config.rootDir().."/utils/FileHandler")
os.loadAPI(Config.rootDir().."/utils/TextUtils")

local rtConf = FileHandler.readVariableFile(Config.runtimeFile())

local options = 1

-- get no. of unread emails
local function getUnreadCount()
  rednet.send(Config.emailServer(),"COUNT:"..rtConf.user)
  s,m = rednet.receive(3)
  if m == nil then
    return "?"
  else
    ms = TextUtils.split(m,":")
    if ms[1] == "COUNT" then
      return ms[2]
    end
  end
end

local unreadCount = getUnreadCount()

-- main loop
while true do
  ScreenUtils.drawHF("Home >> Email")
  ScreenUtils.drawHomeOptions(1,true)

  term.setCursorPos(19,4)
  term.write("    Inbox ("..unreadCount..")")
  term.setCursorPos(19,6)
  term.write("     Compose")
  term.setCursorPos(19,8)
  term.write("    Sent Mail")
  term.setCursorPos(19,10)
  term.write("     Friends")
  
  term.setCursorPos(19,(options*2)+2)
  term.write("[")
  term.setCursorPos(35,(options*2)+2)
  term.write("]")

  -- tracks the users option and enters each option
  e, k = os.pullEvent("key")
  if k == 208 then  
    if options == 4 then
      -- no change
    else
      options = options + 1
    end
  elseif k == 200 then
    if options == 1 then
      -- no change
    else
      options = options - 1
    end
  elseif k == 28 then  
    if options == 1 then
      shell.run(Config.rootDir().."/os/email/Inbox")
    elseif options == 2 then
      shell.run(Config.rootDir().."/os/email/New")
    elseif options == 3 then
      shell.run(Config.rootDir().."/os/email/Sent")
    --elseif options == 4 then  -- unfinished
    --  shell.run(Config.rootDir().."/os/email/Friends")
    end
    unreadCount = getUnreadCount()
  elseif k == 14 then
    break
  end
end
