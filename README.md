SaveMover-v0.2.0-alpha
======
Moves a save directory from it's default location to another drive, leaving a symlink in its wake.

Copyright (C) 2014 Skwerlman

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/

##Intro
Let's say you have a 128GB SSD. You put your OS there, and put your games on another drive, because they're big, and you don't want to fill your OS drive. But, alas! The games you moved to the other drive are storing all their save data on your OS drive, and you're almost out of room! Sure, some games support changing their save location, but in many cases, like Skyrim for example, it's hard and doesn't always work. That very problem inspired me to find a solution to the issue, and automate it. And here it is!

##Usage
####Requirements
* Windows newer than Windows 95 (but, seriously, whose isn't?)
* 2 or more hard drives
* At least 80 KB of disk space for this program
* 3 MB RAM
* ROBOCOPY.EXE (Included in basically every copy of Windows since 2003)

####Instructions
**THIS IS STILL IN ALPHA! BACK UP YOUR SAVES BEFORE RUNNING THIS!**

1. Download either savemover_32.exe or savemover_64.exe, depending on your OS version (32- or 64-bit).
2. Run savemover as an administrator.
3. When prompted, enter the letter of the drive where you'd like to move the save files, then press enter. _(If you wanted to move them to your S: drive, you'd enter S)_
4. When prompted, enter the name of the save folder to move, then press enter. _(For C:/Users/name/Documents/My Games/Skyrim/, you'd enter Skyrim)_
5. After confirming that you entered the correct info, press enter again.
6. That's it!

Your saves will be located at DRIVELETTER:\Savegames
