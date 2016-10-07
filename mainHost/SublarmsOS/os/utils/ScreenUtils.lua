-- screen utils

os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/utils/FileHandler")

rtConf = FileHandler.readVariableFile(Config.runtimeFile())

-- draw the interface header and footer with 'dir' as the current path
function drawHF(dir)
  if dir == nil then
    dir = ""
  end
  if #dir > 31 then
    dir = string.sub(dir,1,28).."..."
  end
  term.clear()
  term.setCursorPos(1,1)
  term.write(" ------------------ SublarmsOS ------------------")
  term.setCursorPos(1,2)
  term.write(" ---[                                        ]---")
  term.setCursorPos(7,2)
  term.write("#"..os.getComputerID().." >> "..dir)
  term.setCursorPos(1,18)
  term.write(" ---[ User:              ]-----------------------")
  idStr = tostring(os.getComputerID())
  if #idStr == 1 then
    idStr = "00"..idStr
  elseif #idStr == 2 then
    idStr = "0"..idStr
  end
  term.setCursorPos(13,18)
  term.write(rtConf.user)
  term.setCursorPos(42,18)
  --term.write(idStr) disabled since new mail
end

-- draw the options as seen on the homepage
function drawHomeOptions(option, submenu)
  if submenu == nil then
    submenu = false
  end
  term.setCursorPos(1,4)
  term.write("     Email")
  term.setCursorPos(1,6)
  term.write("     Files")
  term.setCursorPos(1,8)
  term.write("     Games")
  term.setCursorPos(1,10)
  term.write("     Items")
  term.setCursorPos(1,12)
  term.write("     Shell")
  term.setCursorPos(1,14)
  term.write("    Log Out")
  term.setCursorPos(2,(option * 2)+2)
  term.write("[")
  term.setCursorPos(14,(option * 2)+2)
  term.write("]")
  if submenu then
    term.setCursorPos(16,(option * 2)+2)
    term.write("->")
  end
end
