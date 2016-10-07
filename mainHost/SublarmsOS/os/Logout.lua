-- Logs the user out or shuts PC down

os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")

-- topoption = logout, else shut down
topoption = true

while true do
  ScreenUtils.drawHF("Home >> Logout")
  ScreenUtils.drawHomeOptions(6,true)
  
  term.setCursorPos(19,4)
  term.write("     Log Out")
  term.setCursorPos(19,6)
  term.write("    Shut Down")

  if topoption then
    term.setCursorPos(19,4)
    term.write("[")
    term.setCursorPos(35,4)
    term.write("]")
  else
    term.setCursorPos(19,6)
    term.write("[")
    term.setCursorPos(35,6)
    term.write("]")
  end

  -- process key input
  e, k = os.pullEvent("key")
  if k == 208 then
    topoption = false
  elseif k == 200 then
    topoption = true
  elseif k == 28 then
    if topoption then
      fs.delete(Config.runtimeFile())
      os.reboot()
    else
      os.shutdown()
    end
  elseif k == 14 then
    break
  end
end
