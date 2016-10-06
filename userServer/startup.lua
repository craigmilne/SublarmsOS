term.clear()
term.setCursorPos(1,1)

enc1 = {29, 58, 93, 28, 27}

os.loadAPI("TextUtils")
os.loadAPI("FileUtils")

rednet.open("back")

function genAuthCode(str, rem, s)
  enc = TextUtils.encrypt(str, enc1)
  encSub = string.sub(enc,1,15)
  authCode = rem..tostring(s)..encSub
  return authCode
end

users = {}
if fs.exists("Users") then
  users = FileUtils.readVariableFile("Users")
end

function getUserIndex(username)
  for i=1, #users do
    if users[i][1] == username then
      return i
    end
  end
  return 0
end

print("User Server (ID: " .. os.getComputerID() .. ")")

while true do
  redstone.setOutput("bottom", true)
  s, m = rednet.receive()
  redstone.setOutput("bottom", false)
  -- CAN ACCEPT CREATE, LOGIN or AUTH, VERFIY
  -- SENDS PASS OR FAIL
  ms = TextUtils.split(m, ":")
  action = ms[1]
  if action == "CREATE" then
    username = ms[2]
    password = TextUtils.encrypt(ms[3], enc1)
    remPas = ms[4]
    thisUser = getUserIndex(username)
    if thisUser == 0 then
      newUser = {username, password, remPas, s}
      table.insert(users, newUser)
      rednet.send(s, "PASS:"..genAuthCode(username, remPas, s))
      print("User "..username.." has been created!")
    else
      rednet.send(s, "FAIL:User already exists.")
    end
  elseif action == "LOGIN" then
    username = ms[2]
    password = TextUtils.encrypt(ms[3], enc1)
    thisUser = getUserIndex(username)
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
