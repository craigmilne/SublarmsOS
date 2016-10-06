safeExit = false

shell.run("/SublarmsOS/os/Home")

if safeExit then
  term.clear()
  term.setCursorPos(1,1)
  term.write("Use \"/SublarmsOS/Home\" or reboot to return to OS.")
  term.setCursorPos(1,3)
else
  os.reboot()
end
