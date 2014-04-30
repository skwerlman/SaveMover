@ECHO off
:: savemover-v0.2.0-alpha
:: Moves a save directory from it's default location to another drive, leaving a symlink in its wake.
:: Copyright (C) 2014 Skwerlman
:: 
:: 
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
:: 
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
:: 
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see http://www.gnu.org/licenses/
:: 
:: Compiled from batch script into executable by Bat to Exe Converter v1.6
:: http://www.f2ko.de/programs.php?lang=en&pid=b2e

:: VARS
:: %DRIVELETTER% is the drive letter of the target drive
:: %FOLDERNAME% is the name of the file to Symlink
:: %DATAPATH% is always AppData\skwerlman\savemover

:: Startup message
ECHO SaveMover 0.2.0-alpha  Copyright (C) 2014  Skwerlman
ECHO This program comes with ABSOLUTELY NO WARRANTY; see LICENSE for details.
ECHO This is free software, and you are welcome to redistribute it
ECHO under certain conditions; see LICENSE for details. You should have received a
ECHO copy of the GNU General Public License version 3 with this program. If not, see
ECHO http://www.gnu.org/licenses/ 
:: sleep for .5 sec (tyvm, stackexchange)
PING 192.0.2.2 -n 1 -w 500 >NUL
ECHO.

:: Save current directory
FOR /F %%i IN (' cd ') DO SET OLDDIRPATH=%%i

:: Set up DATAPATH and logger
IF NOT EXIST "%APPDATA%\skwerlman" MD "%APPDATA%\skwerlman"
IF NOT EXIST "%APPDATA%\skwerlman\savemover" MD "%APPDATA%\skwerlman\savemover"
SET DATAPATH=%APPDATA%\skwerlman\savemover
CD %DATAPATH%
:: Create logger if not exist
IF NOT EXIST %DATAPATH%\log.bat (
	ECHO @ECHO off >%DATAPATH%\log.bat
	ECHO ECHO [%%DATE%% %%TIME%%] %%* ^>^>%DATAPATH%\savemover.log >>%DATAPATH%\log.bat
	ECHO EXIT 0 >>%DATAPATH%\log.bat
)

START /B LOG Running as %0

:: Ensure we'll be able to use command extensions later; otherwise error
SETLOCAL ENABLEEXTENSIONS
IF %ERRORLEVEL% NEQ 0 (
	GOTO is95
)
ENDLOCAL

:: Check if they want to see the help BEFORE trying to get admin
IF "%1"=="help" GOTO show_help

:: Check for admin
AT >NUL
::ECHO %ERRORLEVEL%
IF %ERRORLEVEL% EQU 0 (
	SET ISADMIN=true
) ELSE (
	ECHO This program must be run as administrator!
	ECHO An issue where robocopy thinks it succeeds when it doesn't would lead to save
	ECHO folders being deleted ^(not moved to the recycle bin^).
	ECHO The only way around this is to run as an administrator. Sorry!
	ECHO.
	ECHO Don't believe me? See the 'Bugs' section here: http://ss64.com/nt/robocopy.html
	SET ISADMIN=false
	SET WHATFAILED=Tried to run without admin priviliges!
	GOTO command_failed
)

:: Check for cmdline args
IF NOT [%1]==[] (
	IF NOT [%2]==[] (
		SET DRIVELETTER=%1
		START /B LOG DRIVELETTER=%DRIVELETTER%
		SET FOLDERNAME=%2
		START /B LOG FOLDERNAME=%FOLDERNAME%
		GOTO have_2_inputs
	)
	:: User tried to use cmdline, but didn't provide both inputs, so we ask for the second one
	ECHO What is the name of the folder you'd like to perform this action on?
	SET /P FOLDERNAME="(Leave blank to apply to entire game folder) "
	START /B LOG FOLDERNAME=%FOLDERNAME%
	GOTO have_inputs
)
:: Get input
START /B LOG Prompting for inputs
ECHO What drive would you like to keep your saves on?
SET /P DRIVELETTER="(Letter only; no colon) "
START /B LOG DRIVELETTER=%DRIVELETTER%
ECHO.
ECHO What is the name of the folder you'd like to perform this action on?
SET /P FOLDERNAME="(Leave blank to apply to entire game folder) "
START /B LOG FOLDERNAME=%FOLDERNAME%

:have_inputs
:: Warn the user
START /B LOG Warning user of risks
ECHO.
ECHO Make sure you've entered the drive letter and folder name (NOT PATH) correctly
ECHO before hitting enter.
ECHO.
ECHO The actions to be performed are:
ECHO ROBOCOPY /E /MOV /COPY:DATSOU /NP /LOG:robocopy.log "%USERPROFILE%\Documents\My Games\%FOLDERNAME%" "%DRIVELETTER%:\Savegames\%FOLDERNAME%"
ECHO RD /S /Q "%USERPROFILE%\Documents\My Games\%FOLDERNAME%"
ECHO MKLINK /d "%USERPROFILE%\Documents\My Games\%FOLDERNAME%" "%DRIVELETTER%:\Savegames\%FOLDERNAME%"
ECHO.
ECHO If you've made a mistake, hit Control-C and try again.
:: Sleep for 3 sec by pinging a non-existant IP with a T/O of 3k ms
PING 192.0.2.2 -n 1 -w 3000 >NUL
PAUSE

:: Proceed
START /B LOG User accepted. We are proceeding.
START /B LOG Moving save data
ECHO Trying to move old save folder to new location...
ROBOCOPY /E /MOV /COPY:DATSOU /NP /LOG:robocopy.log "%USERPROFILE%\Documents\My Games\%FOLDERNAME%" "%DRIVELETTER%:\Savegames\%FOLDERNAME%"
IF %ERRORLEVEL% NEQ 0 (
	SET WHATFAILED=ROBOCOPY /E /MOV /COPY:DATSOU /NP /LOG:robocopy.log "%USERPROFILE%\Documents\My Games\%FOLDERNAME%" "%DRIVELETTER%:\Savegames\%FOLDERNAME%"
	GOTO command_failed
)
START /B LOG Done
START /B LOG Deleting original folder
ECHO Trying to remove old save directory...
RD /S /Q "%USERPROFILE%\Documents\My Games\%FOLDERNAME%"
IF %ERRORLEVEL% NEQ 0 (
	SET WHATFAILED=RD /S /Q "%USERPROFILE%\Documents\My Games\%FOLDERNAME%"
	GOTO command_failed
)
START /B LOG Done
START /B LOG Creating symlink
ECHO Trying to link old location to new location...
MKLINK /d "%USERPROFILE%\Documents\My Games\%FOLDERNAME%" "%DRIVELETTER%:\Savegames\%FOLDERNAME%"
IF %ERRORLEVEL% NEQ 0 (
	SET WHATFAILED=MKLINK /d "%USERPROFILE%\Documents\My Games\%FOLDERNAME%" "%DRIVELETTER%:\Savegames\%FOLDERNAME%"
	GOTO command_failed
)
START /B LOG Done
START /B LOG Success.
ECHO Done.
CD %OLDDIRPATH%
IF NOT DEFINED NOPAUSE PAUSE
EXIT 0

:is95
:: We're running under Win95 or earlier, so robocopy won't work.
:: We set WHATFAILED and proceed to command_failed
SET WHATFAILED=Tried to run under Win95 or earlier!

:command_failed
:: One of the above commands failed. Log an error report.
START /B LOG ERROR!
START /B LOG If this is not because of a typo or other mistake, send an email to skwerlman@gmail.com, and attach this log in its entirety.
START /B LOG All known info is included below.
START /B LOG Error Code: %ERRORLEVEL%
START /B LOG Command: %WHATFAILED%
START /B LOG IsAdmin: %ISADMIN%
FOR /F %%i IN (' set ') DO START /B LOG Environment: %%i
ECHO.
ECHO Something went wrong: Code %ERRORLEVEL%
ECHO See the log at: %DATAPATH%\savemover.log
ECHO.
ECHO If this is not because of a typo or other mistake, send an email to
ECHO skwerlman@gmail.com, and attach this log in its entirety.
ECHO Please note that this program can't run on Win95 or NT 3.5 or earlier.
CD %OLDDIRPATH%
PAUSE
EXIT %ERRORLEVEL%

:show_help
START /B LOG Showing help.
ECHO Usages:
ECHO savemover
ECHO Promts the user for the inputs at runtime.
ECHO.
ECHO savemover help
ECHO Shows this help message.
ECHO.
ECHO savemover ^<drive letter^> ^<folder^>
ECHO Runs the command without user interaction, using the drive letter
ECHO and folder specified.
CD %OLDDIRPATH%
PAUSE
EXIT 0

:have_2_inputs
SET NOPAUSE=1
GOTO have_inputs
