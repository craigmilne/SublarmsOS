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

The files also reside in a directory named with the hosting computer's ID instead of a named directory.

##Screenshots
I'll give you a walkthrough of the setup and interface quickly; it saves you having to organise the code and install the mod.

* The server setup

  This is how the servers were setup, so when you're going through the code for those you understand the references to the lights. They each had a rednet modem on the back.
  ![servers](https://github.com/enlim/SublarmsOS/blob/master/screenshots/servers.png)
  
* Splashscreen and Landing

  Simply printed the name and version:
  
  ![splashscreen](https://github.com/enlim/SublarmsOS/blob/master/screenshots/splashscreen.png)
  
  You then landed on this page:
  
  ![landing](https://github.com/enlim/SublarmsOS/blob/master/screenshots/user-main.png)
  
* Create Account

  I'll skip over the login as it's similar.
  
  ![createAcc](https://github.com/enlim/SublarmsOS/blob/master/screenshots/create-account.png)
  
* Homepage

  Once logged in (or viewing as guest) you landed on the homepage:
  
  ![homepage](https://github.com/enlim/SublarmsOS/blob/master/screenshots/home.png)
  
  The options for Email and Files will be covered in more depth.
  Games simply listed the built in game (1), Items (which was non-functional) was to allow you to send and organise your items with the ComputerCraft turtles, Shell simply returned you to the default shell, and Log Out allowed you to either log out (destroying your session) or shut down your computer.
  
* Email

  Users could view their inbox, sent mail or send a new message. Composing a message looked like:
  
  ![compose](https://github.com/enlim/SublarmsOS/blob/master/screenshots/email.png)
  
  The compose and read email functions allowed scrolling to support overflow from long messages.
  
  The inbox looked like:
  
  ![inbox](https://github.com/enlim/SublarmsOS/blob/master/screenshots/inbox.png)
  
  The inbox could sort by unread if required and always sorted with the newest first. The inbox, too, supported overflow.
  
* Files

  For users with little command line experience the thought of not being able to use an explorer was a big turn-off. I attempted to add a basic file system explorer, which of course excluded my interface to stop users from destroying it.
  
  I used the `|/` symbol to indicate that the file listed as a directory and `[]` to indicate that it was a file.
  
  The interface when in use look like:
  
  ![files](https://github.com/enlim/SublarmsOS/blob/master/screenshots/files.png)
  
  The navigation on this page was sub-par and took a bit of getting used to so I would likely re-do it.
