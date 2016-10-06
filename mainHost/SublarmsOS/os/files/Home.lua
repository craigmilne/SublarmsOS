os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")
os.loadAPI(Config.rootDir().."/utils/TextUtils")

dir = "/"
local function drawInfo()
  term.setCursorPos(30,4)
  term.write("+----------------+")
  term.setCursorPos(30,5)
  term.write("|                |")
  term.setCursorPos(30,6)
  term.write("| L/R/U/D arrow  |")
  term.setCursorPos(30,7)
  term.write("| keys to go in  |")
  term.setCursorPos(30,8)
  term.write("| and out of     |")
  term.setCursorPos(30,9)
  term.write("| folders, Del   |")
  term.setCursorPos(30,10)
  term.write("| to delete and  |")
  term.setCursorPos(30,11)
  term.write("| Enter to open  |")
  term.setCursorPos(30,12)
  term.write("| the selected   |")
  term.setCursorPos(30,13)
  term.write("| file/folder in |")
  term.setCursorPos(30,14)
  term.write("| the shell.     |")
  term.setCursorPos(30,15)
  term.write("|                |")
  term.setCursorPos(30,16)
  term.write("+----------------+")
end

function clearPage()
  for i=4,17 do
    term.setCursorPos(2,i)
    term.write("                       ")
  end
end

local function parentDir(dir)  
  ds = TextUtils.split(dir, "/")
  parent = ""
  for i = 1, #ds - 1 do
    parent = parent.."/"..ds[i]
  end
  if parent == "" then
    parent = "/"
  end
  return parent
end

local function deleteFileBox(file)
  
  term.setCursorPos(10,5)  
  term.write("                            ")
  term.setCursorPos(10,6)
  term.write("  ########################  ")
  term.setCursorPos(10,7)
  term.write("  #                      #  ")
  term.setCursorPos(10,8)
  term.write("  # Delete               #  ")
  if #file > 12 then
    file = string.sub(file,1,9) .. "..."
  end
  term.setCursorPos(21,8)
  term.write(file.."?")
  term.setCursorPos(10,9)
  term.write("  #                      #  ")
  term.setCursorPos(10,10)
  term.write("  #  [ Yeah ]  [ Nope ]  #  ")
  term.setCursorPos(10,11)
  term.write("  #                      #  ")
  term.setCursorPos(10,12)
  term.write("  ########################  ")
  term.setCursorPos(10,13)
  term.write("                            ")
  del = true
  while true do
    if del then
      term.setCursorPos(12,10)
      term.write("#  [ Yeah ]    Nope    #")
    else
      term.setCursorPos(12,10)
      term.write("#    Yeah    [ Nope ]  #")
    end
    e,k = os.pullEvent("key")
    if k == 205 then
      del = false
    elseif k == 203 then
      del = true
    elseif k == 28 then
      return del
    elseif k == 14 then
      return false
    end
  end
end

local diroption = 1
local cpage = 1
local page = 1
breakoption = false

while true do
  
  if dir == "" then
    dir = "/"
  end
  ScreenUtils.drawHF("Files >> "..dir)
  drawInfo()

  local fileList = fs.list(dir)
  term.setCursorPos(2,3)
  term.write("|/ - "..dir)
  if dir == "/" then
    dir = ""
  end  

  row = 4
  page = 1
  folders = 0
  files = {}
  bork = false
  for _,file in ipairs(fileList) do
    if row % 16 == 0 then
      page = page + 1
      if page <= cpage then
        clearPage()
      else
        bork = true
        break
      end
      row = 5
    end
    if fs.isDir(dir.."/"..file) and (dir.."/"..file ~= "/SublarmsOS") then
      term.setCursorPos(2,row)
      files[row-3] = file
      if #file > 16 then
        file = string.sub(file,1,13).."..."
      end
      term.write("   : |/ - "..file)
      folders = folders + 1
      row = row + 1
    end
  end
  for _,file in ipairs(fileList) do
    if bork then
      break
    end
    if row % 16 == 0 then
      page = page + 1
      if page <= cpage then
        clearPage()
      else
        bork = true
        break
      end
      row = 5
    end
    if not fs.isDir(dir.."/"..file) then
      term.setCursorPos(2,row)
      files[row-3] = file
      if #file > 16 then
        file = string.sub(file,1,13).."..."
      end
      term.write("   : [] - "..file)
      row = row + 1
    end
  end
  
  if cpage > 1 then
    term.setCursorPos(2,4)
    term.write("   : << - Previous Page")
  end

  if page > cpage then
    term.setCursorPos(2,16)
    term.write("   : >> - Next Page")
  end

  term.setCursorPos(3,diroption+3)
  term.write("->")
  
  e, k = os.pullEvent("key")
  if k == 208 then
    if (diroption + 4 == row and page == cpage) or (diroption == 13 and page > cpage) then
      -- diroption unchanged
    else
      if page == 1 and row == 4 then
        -- No files
      else
        diroption = diroption + 1
      end
    end
  elseif k == 200 then
    if diroption == 1 then
      -- option unchanged
    else
      diroption = diroption - 1
    end
  elseif k == 203 then
    dir = parentDir(dir)
    diroption = 1
    page = 1
    cpage = 1
  elseif k == 205 then
    if (diroption+(cpage-1)*13) - folders <= 0 then
      dir = dir .."/"..files[diroption]
      diroption = 1
      page = 1
    end
    if cpage > 1 and diroption == 1 then
      diroption = 1
      cpage = cpage - 1
    elseif cpage < page and diroption == 13 then
      diroption = 1
      cpage = cpage + 1
    end
  elseif k == 28 then
    if diroption - folders <= 0 then
      breakoption = true
      shell.setDir(dir.."/"..files[diroption])
      term.clear()
      term.setCursorPos(1,1)
      break
    else
      shell.run(dir.."/"..files[diroption])
    end
  elseif k == 14 or k == 1 then
    break
  elseif k == 211 then
    if (diroption == 1 and cpage > 1) or (diroption == 13 and cpage < page) then
      -- do nothing
    else
      deleteFile = deleteFileBox(files[diroption])
      if deleteFile then
        fs.delete(dir.."/"..files[diroption])
        diroption = 1
      end
    end
  end
end
