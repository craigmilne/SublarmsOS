
os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/utils/FileHandler")
os.loadAPI(Config.rootDir().."/utils/TextUtils")

-- Note, config is runtime conf and Config is other one
config = {}
config = FileHandler.readVariableFile(Config.runtimeFile())

-- read input of length len and replace the characters with fill
-- eg. passwords fill can be '*'
local function readLen(len, fill)
  local input = ""
  local x,y = term.getCursorPos()
  
  term.setCursorBlink(true)

  repeat
    term.setCursorPos(x,y)
    term.write(string.rep(' ',len))
    term.setCursorPos(x,y)
    if fill == nil then
      term.write(input)
    else
      term.write(string.rep(fill, #input))
    end

    local event, key = os.pullEvent()

    if event == 'char' then
      if #input < len and key ~= ':' then
        input = input .. key
      end
    elseif event == 'key' then
      if key == 14 then
        input = input:sub(1, #input - 1)
      end
    end
  until event == 'key' and key == 28
  term.setCursorBlink(false)
  return input
end

-- if user not auth. and internet on then prompt login
if config.userAuth == 0 and config.rednet then
  term.clear()
  term.setCursorPos(1,1)
  print(" --------------- SublarmsOS Login ---------------")
  term.setCursorPos(14,6)
  print("[  CONTINUE AS GUEST  ]")
  term.setCursorPos(14,9)
  print("   LOGIN TO SUBLARMS   ")
  term.setCursorPos(1,17)
  print("     Use The Arrow Keys and Enter To Navigate    ")
  term.setCursorPos(1,18)
  i = 0
  write(" ")
  while i < 48 do
    i = i + 1
    write("-")
  end
  beGuest = true
  loginLoop = true
  -- screen render loop
  while loginLoop do
    event, key = os.pullEvent("key")
    if key == 208 then  -- down arrow
      beGuest = false
      term.setCursorPos(14,6)
      print("   CONTINUE AS GUEST   ")
      term.setCursorPos(14,9)
      print("[  LOGIN TO SUBLARMS  ]")
    elseif key == 200 then  -- up arrow
      beGuest = true
      term.setCursorPos(14,6)
      print("[  CONTINUE AS GUEST  ]") 
      term.setCursorPos(14,9)
      print("   LOGIN TO SUBLARMS   ")
    elseif key == 28 then -- enter
      loginLoop = false
    else
      -- Random key
    end
  end
  -- if user wants to login  
  if not beGuest then
    newAcc = true
    term.setCursorPos(14,6)
    print("[  CREATE AN ACCOUNT  ]")
    term.setCursorPos(14,9)
    print("   I HAVE AN ACCOUNT   ")
    newAccLoop = true
    while newAccLoop do -- same loop to get user input with same key bindings
      event, key = os.pullEvent("key")
      if key == 208 then
        term.setCursorPos(14,6)
        print("   CREATE AN ACCOUNT   ")
        term.setCursorPos(14,9)
        print("[  I HAVE AN ACCOUNT  ]")
        newAcc = false
      elseif key == 200 then
        term.setCursorPos(14,6)
        print("[  CREATE AN ACCOUNT  ]")
        term.setCursorPos(14,9)
        print("   I HAVE AN ACCOUNT   ")
        newAcc = true
      elseif key == 28 then
        newAccLoop = false
      else
        -- Random key
      end
    end
    if newAcc then  -- if the user wants to make a new account
     accountVerified = false
     term.setCursorPos(1,17)
     print("                                                 ")
     repeat
      term.setCursorPos(11,5)
      -- Username 12 chars
      print("[  Username:               ]")
      -- Password 12 chars
      term.setCursorPos(11,6)
      print("[  Password:               ]")
      term.setCursorPos(11,7)
      print("[   Confirm:               ]")
      -- Require password on new login
      term.setCursorPos(11,9)
      print("[    Remember Password?    ]")
      term.setCursorPos(11,10)
      print("   YES                 NO   ")
      term.setCursorPos(24,5)
      -- read username
      user = readLen(12)
      pass = ""
      pass2 = ""
      passMatch = false
      repeat -- read passwords until both match, only verified client side
        term.setCursorPos(24,6)
        pass = readLen(12,"*")
        term.setCursorPos(24,7)
        pass2 = readLen(12,"*")
        if pass ~= pass2 or pass == "" then
          term.setCursorPos(1,17)
          print("              Passwords do not match!            ")
          term.setCursorPos(24,6)
          sleep(0.5)
          print("            ")
          term.setCursorPos(24,7)
          print("            ")
        else
          passMatch = true
        end
      until passMatch
      term.setCursorPos(11,10)
      remember = true
      print("[  YES  ]              NO   ")
      term.setCursorPos(1,17)
      print("        Press Enter to create your account       ") 
      rememberLoop = true
      while rememberLoop do -- user can choose to save password or require on boot
        event, key = os.pullEvent("key")
        if key == 205 then
          term.setCursorPos(11,10)
          remember = false
          print("   YES              [  NO  ]")
        elseif key == 203 then
          term.setCursorPos(11,10)
          remember = true
          print("[  YES  ]              NO   ")
        elseif key == 28 then
          rememberLoop = false
        else
          -- Ignore
        end
      end
      remStr = "1"
      if remember then
        remStr = "1"
      else
        remStr = "0"
      end
      term.setCursorPos(1,17)
      print("         Waiting for server response...          ")
      -- send to server and wait for a response
      rednet.send(Config.userServer(), "CREATE:"..user..":"..pass..":"..remStr)
      s = 0
      msg = ""
      while s ~= Config.userServer() do
        s, msg = rednet.receive()
      end
      mParts = TextUtils.split(msg, ":")
      -- user created, get auth code
      if mParts[1] == "PASS" then
        accountVerified = true
        config.user = user
        config.userAuth = mParts[2]
      else
        term.setCursorPos(1,17)
        print("  Failed to create account! Is that name in use? ")
      end
     until accountVerified 
    else
      -- user wants to login, prompt login
      term.setCursorPos(1,17)
      print("                                                 ")
      loggedIn = false
      repeat
        term.setCursorPos(11,5)
        print("[  Username:               ]")
        term.setCursorPos(11,6)
        print("[  Password:               ]")
        term.setCursorPos(7,9)
        -- no password reset yet, just talk to me and we can sort something out
        print("     Forgot Password? Tell Carg   ")
        term.setCursorPos(24,5)
        user = readLen(12)
        term.setCursorPos(24,6)
        pass = readLen(12,"*")
        term.setCursorPos(1,17)
        print("         Waiting for server response.            ")
        rednet.send(Config.userServer(), "LOGIN:"..user..":"..pass)
        s = 0
        message = ""
        while s ~= Config.userServer() do
          s, message = rednet.receive()
        end
        messageParts = TextUtils.split(message,":")
        if messageParts[1] == "PASS" then
          loggedIn = true
          config.user = user
          config.userAuth = messageParts[2]
        else
          term.setCursorPos(1,17)
          print("                 Failed to login!                ")
        end
      until loggedIn  
    end
  end 
end
-- store the details the user is using, if guest then continue
FileHandler.writeVariableFile(Config.runtimeFile(), config)
