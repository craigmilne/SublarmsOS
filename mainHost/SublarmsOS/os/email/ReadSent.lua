os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/utils/TextUtils")
os.loadAPI(Config.rootDir().."/utils/FileHandler")
os.loadAPI(Config.rootDir().."/os/utils/ScreenUtils")

rtConf = FileHandler.readVariableFile(Config.runtimeFile())

local id = ...
local readError = false

emails = FileHandler.readVariableFile(Config.rootDir().."/os/email/sentmail/"..rtConf.user)
email = {}
for i=1,#emails do
  if emails[i][1] == tonumber(id) then
    email = emails[i]
    break
  end
end

header = {email[1],rtConf.user,email[2],email[3]}
body = email[4]

offset = 0
isReply = true

--test case
--header = {10,"Carg","Adroon","Do You Have A Geiger Counter?"}
--body = "Hello Carg, \\n \\n I was wondering if you had a geiger counter. \\n You probably do. \\n \\n memes. \\n \\n more memes.  \\n \\n All the best, \\n Droon."

while true do
  
  ScreenUtils.drawHF("Email >> Inbox >> View Message")
  term.setCursorPos(1,4)
  term.write("  From    :                                          ")
  term.setCursorPos(1,5)
  term.write("  To      :                                          ")
  term.setCursorPos(1,6)
  term.write("  Subject :                                          ")
  term.setCursorPos(13,4)
  term.write(header[3])
  term.setCursorPos(13,5)
  term.write(header[2])
  term.setCursorPos(13,6)
  subj = header[4]
  if #subj > 38 then
    subj = string.sub(subj,1,35).."..."
  end
  term.write(subj)
  term.setCursorPos(1,16)
  term.write("                         Reply          Close     ")
  if isReply then
    term.setCursorPos(23,16)
    term.write("[  Reply  ]")
  else
    term.setCursorPos(38,16)
    term.write("[  Close  ]")
  end
  
  rowWidth = 47
  rows = {}
  row = ""
  bodyParts = TextUtils.split(body," ")
  for i=1,#bodyParts do
    if bodyParts[i] == "~d#" then
      rows[#rows + 1] = row
      row = ""
    else
      newRow = row .." ".. bodyParts[i]
      if #newRow > rowWidth then
        rows[#rows + 1] = row
        row = bodyParts[i]
      else
        row = newRow
      end
    end
  end 
  rows[#rows+1] = row 
  
  term.setCursorPos(3,16)
  calcScroll = #rows - 6
  if calcScroll < 1 then
    calcScroll = 1
  end
  term.write("("..tostring(offset + 1).."/"..tostring(calcScroll)..")")
 
  for j=1,7 do
    term.setCursorPos(2,7+j)
    term.write(rows[j+offset])
  end

  e,k = os.pullEvent("key")
  if k == 203 then
    isReply = true
  elseif k == 205 then
    isReply = false
  elseif k == 200 then
    if offset > 0 then
      offset = offset - 1
    end
  elseif k == 208 then
    if offset + 7 < #rows then
      offset = offset + 1
    end
  elseif k == 28 then
    if isReply then
      shell.run(Config.rootDir().."/os/email/new",header[3],"Re> "..header[4])
    else
      break
    end
  elseif k == 14 then
    break
  end

end
