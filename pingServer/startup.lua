term.clear()
term.setCursorPos(1,1)
print("Ping Server (ID: "..os.getComputerID()..")")
rednet.open("back")
while true do
  redstone.setOutput("bottom",true)
  sender, message, dist = rednet.receive()
  redstone.setOutput("bottom",false)

  print("Ping from computer "..sender)
  rednet.send(sender, tostring(dist))
end
  
