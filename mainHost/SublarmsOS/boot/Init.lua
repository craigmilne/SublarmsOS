local vars = {}
local oldVars = {}


-- Load APIs --

os.loadAPI("/SublarmsOS/conf/Config")
os.loadAPI(Config.rootDir().."/utils/FileHandler")
os.loadAPI(Config.rootDir().."/utils/OpenRednet")
os.loadAPI(Config.rootDir().."/utils/TextUtils")

vars.version = Config.version()

-- Previous RuntimeVars --

if fs.exists(Config.runtimeFile()) then
  oldVars = FileHandler.readVariableFile(Config.runtimeFile())
  fs.delete(Config.runtimeFile())
  if oldVars.version ~= Config.version() then
    print("New SublarmsOS Version detected.")
    oldVars = {}
  end
end

-- Rednet --

modemSide = OpenRednet.openRednet()
if modemSide == nil then
  vars.rednet = false
  print("Modem: NULL (Offline)")
else
  vars.rednet = true
  print("Modem: "..modemSide.." (Online)")
end

-- Ping Servers --

if vars.rednet then
  rednet.send(Config.pingServer(), tostring(os.getComputerID()))
  sender,message = rednet.receive(5)
  if sender == nil then
    print("Ping: Timeout. Going offline.")
    vars.rednet = false
  else
    print("Ping: Server online, "..message.." blocks away.")
  end
else
  print("Ping: Cannot ping in offline mode")
end

-- Load Users --

if vars.rednet then
  validAuth = false
  if next(oldVars) ~= nil and oldVars.user ~= "Guest" then
    rednet.send(Config.userServer(), "AUTH:"..oldVars.user..":"..oldVars.userAuth)
    s, m = rednet.receive(5)
    if m ~= nil and s == Config.userServer() then
      ms = TextUtils.split(m,":")
      if ms[1] == "PASS" then
        vars.user = oldVars.user
        vars.userAuth = ms[2]
        validAuth = true
      end
    else
      print("Cannot connect to user auth server.")
    end
  end
  if validAuth then
    print("Authorized as "..vars.user..".")
  else
    vars.user = "Guest"
    vars.userAuth = 0
    print("No valid login found.")
  end
else
  print("Authorized as Guest. (Offline)")
  vars.user = "Guest"
  vars.userAuth = 0
end

-- Save To RuntimeConfig --

FileHandler.writeVariableFile(Config.runtimeFile(), vars)
