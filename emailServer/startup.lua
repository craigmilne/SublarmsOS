os.loadAPI("/utils/TextUtils")
os.loadAPI("/utils/FileUtils")

-- variables
userServerID = 43
-- fin

term.clear()
term.setCursorPos(1,1)
print("Email Server (ID: "..os.getComputerID()..")")

rednet.open("back")

-- email is {id,recipient,sender,subj,body,read}

while true do
  redstone.setOutput("bottom",true)
  s,m = rednet.receive()
  redstone.setOutput("bottom",false)

  -- can receive: 
  -- COUNT (unread count, send username too)
  -- FETCHHEAD (same as fetch but no message body after)
  -- FETCH (sends count then all mail one at a time?, 2 parts (header+body))
  -- SEND (Verifies recipient & sender, also takes subject then asks for message)
  -- can send:
  -- COUNT (number of unread)
  -- HEADER (sender, recipient, subject)
  -- BODY (message body after header)
  -- READY (if ready for response)
  -- ERROR (sends if an error occured)
  if TextUtils.startsWith(m, "COUNT") then
    ms = TextUtils.split(m,":")
    user = ms[2]
    rednet.send(userServerID, "VERIFY:"..user..":"..tostring(s))
    s1, m1 = rednet.receive(5)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s, "ERROR:Failed to verify user")
    else -- verified
      if not fs.exists("/mailto/"..user) then
        rednet.send(s, "COUNT:0")
      else
        usersMail = FileUtils.readVariableFile("/mailto/"..user)
        unread = 0
        for i=1,#usersMail do
          TOPFUCKINGKEK = usersMail[i]
          if TOPFUCKINGKEK[6] == true then
            unread = unread + 1
          end
        end
        rednet.send(s, "COUNT:"..tostring(unread))
      end
    end
  elseif TextUtils.startsWith(m, "FETCHHEAD") then
    ms = TextUtils.split(m,":")
    user = ms[2]
    rednet.send(userServerID, "VERIFY:"..user..":"..s)
    s1,m1 = rednet.receive(3)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s,"ERROR:Failed to verify user")
    else
      if not fs.exists("/mailto/"..user) then
        rednet.send(s,"COUNT:0")
      else
        usersMail = FileUtils.readVariableFile("/mailto/"..user)
        rednet.send(s,"COUNT:"..tostring(#usersMail))
        for i=1,#usersMail do
          thisMail = usersMail[i]
          headerStr = thisMail[1]..":"..thisMail[2]..":"..thisMail[3]..":"..thisMail[4]..":"..tostring(thisMail[6])
          rednet.send(s,"HEADER:"..headerStr)
        end
      end
    end
  elseif TextUtils.startsWith(m, "FETCH") then
    -- fetch:user:id
    ms = TextUtils.split(m,":")
    user = ms[2]
    id = tonumber(ms[3])
    rednet.send(userServerID,"VERIFY:"..user..":"..s)
    s1,m1 = rednet.receive(3)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s,"ERROR:Failed to verify user")
    else
      if not fs.exists("/mailto/"..user) then
        rednet.send(s,"ERROR:No mail found.")
      else
        userMail = FileUtils.readVariableFile("/mailto/"..user)
        sent = false
        for i=1,#userMail do
          thisMail = userMail[i]
          if id == tonumber(thisMail[1]) then
            rednet.send(s,"HEADER:"..thisMail[1]..":"..thisMail[2]..":"..thisMail[3]..":"..thisMail[4])
            thisMail[6] = false
            userMail[i] = thisMail
            sent = true
            FileUtils.writeVariableFile("/mailto/"..user, userMail)
            rednet.send(s,"BODY:"..thisMail[5])
          end
        end
        if not sent then
          rednet.send(s,"ERROR:Failed to find mail")
        end
      end
    end
  elseif TextUtils.startsWith(m, "SEND") then
    -- SEND:sender,recipient,subj
    ms = TextUtils.split(m,":")
    user = ms[2]
    recip = ms[3]
    subj = ms[4]
    rednet.send(userServerID, "VERIFY:"..user..":"..s)
    s1,m1 = rednet.receive(3)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s,"ERROR:Failed to verify user")
    else
      recipMail = {}
      if fs.exists("/mailto/"..recip) then
        recipMail = FileUtils.readVariableFile("/mailto/"..recip)
      end
      id = #recipMail + 1
      rednet.send(s,"READY")
      s2,m2 = rednet.receive()
      if m2 == nil or not TextUtils.startsWith(m2,"BODY:") then
        rednet.send(s,"ERROR:No Body received")
      else
        body = string.sub(m2,-1 * (#m2 - 5))
        email = {id,recip,user,subj,body,true}
        table.insert(recipMail,email)
      end
      FileUtils.writeVariableFile("/mailto/"..recip,recipMail)
    end
  else
    rednet.send(s, "ERROR:Unknown protocol")
  end


end
