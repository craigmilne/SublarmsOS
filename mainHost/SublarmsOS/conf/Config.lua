
-- System info --
conf_version = "v0.1"

-- Network Servers --
-- hard coded but would likely use a rednet broadcast to ask for ids to be sent on request in production
conf_mainHost = 25
conf_pingServer = 29
conf_userServer = 43
conf_emailServer = 31

-- Heirarchy --
conf_rootDir = "/SublarmsOS"
conf_runtimeFile = conf_rootDir.."/conf/RuntimeConfig"


-- API --
function version()
  return conf_version
end
function mainHost()
  return conf_mainHost
end
function pingServer()
  return conf_pingServer
end
function userServer()
  return conf_userServer
end
function emailServer()
  return conf_emailServer
end
function rootDir()
  return conf_rootDir
end
function runtimeFile()
  return conf_runtimeFile
end
