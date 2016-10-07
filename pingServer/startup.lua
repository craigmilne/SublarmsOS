-- startup (runs on boot)
-- this server literally did nothing except allow pings and tell the user how far away the server was

-- clears terminal
term.clear()
term.setCursorPos(1,1)
-- print the server ID
print("Ping Server (ID: "..os.getComputerID()..")")
-- allow networking if modem attached on the back
rednet.open("back")
-- main loop
while true do
  -- set the light on the bottom to on if the server is idle
  redstone.setOutput("bottom",true)
  -- wait for network message receive
  sender, message, dist = rednet.receive()
  -- light off as server is busy
  redstone.setOutput("bottom",false)

  -- print that the server was pinged
  print("Ping from computer "..sender)
  -- reply to the sender
  rednet.send(sender, tostring(dist))
end
  
