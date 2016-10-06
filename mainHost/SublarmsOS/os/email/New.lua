os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/utils/TextUtils")
os.loadAPI(Config.rootDir().."/utils/FileHandler")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")

rtConf = FileHandler.readVariableFile(Config.runtimeFile())

local to, subj = ...

while true do
  
  ScreenUtils.drawHF("Email >> Write New")
  
  term.setCursorPos(1,4)
  term.write("  To      : ")
  term.setCursorPos(1,5)
  term.write("  Subject : ")

  if to == nil then
    term.setCursorPos(13,4)
    to = TextUtils.readLen(12)
  else
    term.setCursorPos(13,4)
    term.write(to)
  end

  if subj == nil then
    term.setCursorPos(13,5)
    subj = TextUtils.readLen(30)
  else
    term.setCursorPos(13,5)
    term.write(subj)
  end 
  
  term.setCursorPos(1,16)
  term.write("      Use R-Shift To Confirm Your Email Body     ")

  term.setCursorPos(3,7)
  body = TextUtils.bodyText(47,8)
  
  term.setCursorPos(1,16)
  term.write("    Use Enter to Send or Backspace to Cancel.    ")
  e,k = os.pullEvent("key")
  if k == 14 then
    break
  elseif k == 28 then
    bodyStr = "BODY:"..body
    headStr = "SEND:"..rtConf.user..":"..to..":"..subj
    rednet.send(Config.emailServer(),headStr)
    s,mess = rednet.receive(3)
    if mess == nil or mess ~= "READY" then
      ScreenUtils.drawHF("Email >> Write New")
      term.setCursorPos(1,8)
      term.write("                An Error Occured!                ")
      sleep(1)
      break
    else
      rednet.send(Config.emailServer(), bodyStr)
      s,merror = rednet.receive(1.5)
      if merror == nil then
        ScreenUtils.drawHF("Email >> Write New")
        term.setCursorPos(1,8)
        term.write("                  Message Sent!                  ")
        sleep(1)
        lemails = {}
        lemails = FileHandler.readVariableFile(Config.rootDir().."/os/email/sentmail/"..rtConf.user)
        newM = {#lemails + 1, to, subj, body}
        lemails[#lemails + 1] = newM
        FileHandler.writeVariableFile(Config.rootDir().."/os/email/sentmail/"..rtConf.user, lemails)
        break
      else
        ScreenUtils.drawHF("Email >> Write New")
        term.setCursorPos(1,8)
        term.write(merror)
        term.write("                An Error 0ccured!                ")
        sleep(1)
        break
      end
    end
  end
end
