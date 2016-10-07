-- Print the splash screen with version no.

os.loadAPI("SublarmsOS/conf/Config")

term.clear()
term.setCursorPos(1,1)
i = 0
write(" ")
while i < 48 do
  i = i + 1
  write("#")
end
term.setCursorPos(14,11)
print("Loading SublarmsOS "..Config.version())
term.setCursorPos(1,18)
i = 0
write(" ")
while i < 48 do
  i = i + 1
  write("#")
end
sleep(1)
term.clear()
term.setCursorPos(1,1)

