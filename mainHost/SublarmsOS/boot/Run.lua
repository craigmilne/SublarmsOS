-- Run, starts everything interface related

safeExit = false

-- run the splash
shell.run("/SublarmsOS/boot/Splash")
-- run the initialisation
shell.run("/SublarmsOS/boot/Init")
-- run user auth
shell.run("/SublarmsOS/boot/User")
-- run the home page
shell.run("/SublarmsOS/os/Home")

-- if safe exit then exit to command line and advice user how to return to interface
if safeExit then
  term.clear()
  term.setCursorPos(1,1)
  term.write("Use \"/SublarmsOS/Home\" or reboot to return to OS.")
  term.setCursorPos(1,3)
else
  os.reboot()
end
