-- if the interface was exited safely
safeExit = false

-- run the Homepage
shell.run("/SublarmsOS/os/Home")

-- if the exit from the homepage was safe/intended
if safeExit then
  term.clear()
  term.setCursorPos(1,1)
  -- advise user how to return from the shell to the interface
  term.write("Use \"/SublarmsOS/Home\" or reboot to return to OS.")
  term.setCursorPos(1,3)
else
  os.reboot()
end
