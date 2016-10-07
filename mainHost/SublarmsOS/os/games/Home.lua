-- currently only the default snake game that comes with the mod.
-- partially the inspiration for my Snake (in C)

os.loadAPI("SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")

while true do
  ScreenUtils.drawHF("Home >> Games")
  ScreenUtils.drawHomeOptions(3,true)

  term.setCursorPos(19,4)
  term.write("[     Snake     ]")

  e, k = os.pullEvent("key")
  if k == 28 then -- only one game so no checks
    shell.run("worm")
  elseif k == 14 then
    break
  end
end
