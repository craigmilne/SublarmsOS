-- startup (run on boot)

-- clear terminal
term.clear()
term.setCursorPos(1,1)

-- password encoding stoof
enc1 = {29, 58, 93, 28, 27}

-- load my apis
os.loadAPI("TextUtils")
os.loadAPI("FileUtils")

-- open networking if a modem is location on the back face of the terminal
rednet.open("back")

-- generate auth code for each user
function genAuthCode(str, rem, s)
  enc = TextUtils.encrypt(str, enc1)
  encSub = string.sub(enc,1,15)
  authCode = rem..tostring(s)..encSub
  return authCode
end

-- load existing users into a file
users = {}
if fs.exists("Users") then
  users = FileUtils.readVariableFile("Users")
end

-- given a username, return the index of a user, returns zero if none as lua tables start at 1
function getUserIndex(username)
  for i=1, #users do
    if users[i][1] == username then
      return i
    end
  end
  return 0
end

-- print to the terminal the ID of the user server.
-- This allows the software to be copied elsewhere if needed, and reports the ID we must use
print("User Server (ID: " .. os.getComputerID() .. ")")

-- main loop, basically this should never end
-- Ctrl + T terminated programs in ComputerCraft
while true do
  -- Enable a light on the bottom to say server was ready to receive request
  redstone.setOutput("bottom", true)
  -- waits for a message
  s, m = rednet.receive()
  -- turns said light off when a message is received so we know the server is busy
  redstone.setOutput("bottom", false)
  -- CAN ACCEPT CREATE, LOGIN or AUTH, VERFIY
  -- SENDS PASS OR FAIL
  -- message format was 'ACTION:args(:..)'
  ms = TextUtils.split(m, ":")
  action = ms[1]
  -- User wants to create a new account
  if action == "CREATE" then
    username = ms[2]
    -- shoddily encrypt password
    password = TextUtils.encrypt(ms[3], enc1)
    remPas = ms[4]
    thisUser = getUserIndex(username)
    -- verify the user doesn't exist, then if not add them and send them a verification
    if thisUser == 0 then
      newUser = {username, password, remPas, s}
      table.insert(users, newUser)
      rednet.send(s, "PASS:"..genAuthCode(username, remPas, s))
      print("User "..username.." has been created!")
    else
      rednet.send(s, "FAIL:User already exists.")
    end
  -- user wants to login
  elseif action == "LOGIN" then
    username = ms[2]
    password = TextUtils.encrypt(ms[3], enc1)
    thisUser = getUserIndex(username)
    -- check if we have the user in the list of existing ones, then verify them
    if thisUser == 0 then
      rednet.send(s, "FAIL:User not found.")
    else
      if users[thisUser][2] == password then
        tempuser = users[thisUser]
        tempuser[4] = s
        rednet.send(s, "PASS:"..genAuthCode(username,tempuser[3],s))
        print("User "..username.." has logged in!")
        users[thisUser] = tempuser
      else
        rednet.send(s, "FAIL:Wrong password.")
      end
    end
  -- user's computer would like to login, provides auth code from before
  -- allow login if the user is on the same PC and allowed remember login
  elseif action == "AUTH" then
    username = ms[2]
    attemptedAuth = ms[3]
    rem = string.sub(attemptedAuth,1,1)
    if rem == "0" then
      rednet.send(s, "FAIL:User must reenter password.")
    else
      thisUser = getUserIndex(username)
      if thisUser == 0 then
        rednet.send(s, "FAIL:User could not be found")
      else
        actualAuth = genAuthCode(username, rem, users[thisUser][4])
        if actualAuth == attemptedAuth then
          print("User "..username.." has logged in!")
          rednet.send(s, "PASS:"..actualAuth)
        else
          rednet.send(s, "FAIL:Auth code not valid.")
        end
      end
    end
  -- verify user is on right PC
  elseif action == "VERIFY" then
    user = ms[2]
    id = ms[3]
    userIndex = getUserIndex(user)
    if userIndex > 0 then
      userObj = users[userIndex]
      if tonumber(userObj[4]) == tonumber(id) then
        rednet.send(s, "PASS:Users Latest ID")
      else
        rednet.send(s, "FAIL:Not Users Latest ID")
      end
    else
      rednet.send(s,"FAIL:User not found")
    end
  else
    rednet.send(s, "FAIL:No such protocol.")
  end
  FileUtils.writeVariableFile("Users", users)
end
