# SublarmsOS
A user interface for the Tekkit version of ComputerCraft

##What is ComputerCraft?
ComputerCraft ([Link Here](http://www.computercraft.info/)) is a mod for Minecraft that adds computers and advanced logic to the game. The mod adds a terminal with access to a Lua API, disk drives, printers, and network capability.

My friends and I all played on a server with this mod and found that the default terminal interface was bland, and difficult for beginners to use, so I created SublarmsOS. It's not an OS, despite the name, but an interface for ComputerCraft terminals.

It's just that opening a terminal and seeing:
```
CraftOS v1.3
>
```
did not appeal to the others I was playing with so I tried to fix this with SublarmsOS.

##What does SublarmsOS do?
It is just a wrapper for the actual OS, but adds messaging functionality, a file browser, and a basic interface. The interface is written in Lua using the ComputerCraft API, the documentation for which is [here](http://www.computercraft.info/wiki/Main_Page).

I have annotated the code to try and help describe what is happening in each section and have added screenshots so you can see how the interface looks in use.

##Side note
ComputerCraft handles all files as Lua scripts by default and so in the real version there aren't file extensions. I have added them here to allow you to follow the syntax and flow of the scripts with less difficulty.

##Screenshots
