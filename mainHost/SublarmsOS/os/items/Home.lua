os.loadAPI("SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")

while true do
  ScreenUtils.drawHF("Home >> Items")
  ScreenUtils.drawHomeOptions(4,true)

  term.setCursorPos(19,4)
  term.write("Not finished. Use Bksp to exit")

  e, k = os.pullEvent("key")
  if k == 14 then
    break
  end
end
