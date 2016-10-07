-- startup (runs on boot)

-- load the APIs
os.loadAPI("/utils/TextUtils")
os.loadAPI("/utils/FileUtils")

-- variables
userServerID = 43
-- fin

-- clear the terminal
term.clear()
term.setCursorPos(1,1)
-- print the servers ID to allow it to be run on any server
print("Email Server (ID: "..os.getComputerID()..")")

-- open networking if a modem is attached on the back
rednet.open("back")

-- email is {id,recipient,sender,subj,body,read}

-- main loop, don't exit (but Ctrl + T causes interupt)
while true do
  -- enable light on the bottom to show that server is idle
  redstone.setOutput("bottom",true)
  -- wait for network message
  s,m = rednet.receive()
  -- disable light to show that server is processing request
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

  -- user requested just the number of unread emails
  if TextUtils.startsWith(m, "COUNT") then
    ms = TextUtils.split(m,":")
    user = ms[2]
    -- ask user to verify they are logged in
    rednet.send(userServerID, "VERIFY:"..user..":"..tostring(s))
    -- wait 5 seconds for response, if none then timeout
    s1, m1 = rednet.receive(5)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s, "ERROR:Failed to verify user")
    else -- verified, process the request
      if not fs.exists("/mailto/"..user) then
        rednet.send(s, "COUNT:0")
      else
        usersMail = FileUtils.readVariableFile("/mailto/"..user)
        unread = 0
        for i=1,#usersMail do
          TOPKEK = usersMail[i]
          if TOPKEK[6] == true then
            unread = unread + 1
          end
        end
        -- send the size of the users email inbox back
        rednet.send(s, "COUNT:"..tostring(unread))
      end
    end
  -- get the headers for the emails, to show on the inbox
  elseif TextUtils.startsWith(m, "FETCHHEAD") then
    ms = TextUtils.split(m,":")
    user = ms[2]
    -- standard user verification
    rednet.send(userServerID, "VERIFY:"..user..":"..s)
    s1,m1 = rednet.receive(3)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s,"ERROR:Failed to verify user")
    else -- send the email count then sent that many email headers
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
  -- user requests an email so send the header seperate then the body
  elseif TextUtils.startsWith(m, "FETCH") then
    -- fetch:user:id
    ms = TextUtils.split(m,":")
    user = ms[2]
    id = tonumber(ms[3])
    -- standard verification
    rednet.send(userServerID,"VERIFY:"..user..":"..s)
    s1,m1 = rednet.receive(3)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s,"ERROR:Failed to verify user")
    else
      if not fs.exists("/mailto/"..user) then
        rednet.send(s,"ERROR:No mail found.")
      else -- find the email then send the header as before then send the whole body
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
  -- user wants to send new email
  elseif TextUtils.startsWith(m, "SEND") then
    -- SEND:sender,recipient,subj
    ms = TextUtils.split(m,":")
    user = ms[2]
    recip = ms[3]
    subj = ms[4]
    -- standard verification
    rednet.send(userServerID, "VERIFY:"..user..":"..s)
    s1,m1 = rednet.receive(3)
    if m1 == nil or TextUtils.startsWith(m1,"FAIL") then
      rednet.send(s,"ERROR:Failed to verify user")
    else -- save new mail to user file
      recipMail = {}
      if fs.exists("/mailto/"..recip) then
        recipMail = FileUtils.readVariableFile("/mailto/"..recip)
      end
      id = #recipMail + 1
      rednet.send(s,"READY")
      s2,m2 = rednet.receive()
      if m2 == nil or not TextUtils.startsWith(m2,"BODY:") then -- email body not received after header
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
