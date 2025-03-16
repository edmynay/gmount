:: gmount
:: by edmynay

:: FUNCTION
:: Automatically mounts provided CD/DVD image, runs given app/game and unmounts afterwards

:: USAGE
:: 1. Install DAEMON Tools or Alcohol
:: 2. Copy this file to directory where DAEMON Tools or Alcohol installed
:: 3. Create shortcut to this file on the desktop and modify its Properties-Target
:: field as following:
:: "Path\To\This\File\gmount.bat" "IMAGE" "APP" ["APP_WD"]
:: where:
:: IMAGE  - path (absolute or relative) to CD/DVD image
:: APP    - path (absolute or relative) to application (.exe file)
:: APP_WD - optional path (absolute or relative) to application working directory
::          (could be required sometimes if app/game crashes).
::          If omitted, directory with APP_EXE is used by default.
:: Note: quotation marks ("") are necessary in case path contains space(s)!

:: EXAMPLE:
:: "C:\Program Files\DAEMON Tools Lite\gmount.bat" "D:\Virtual CDs\My Game\NoCD\My Game.iso" "D:\Games\My Game\bin\My Game.exe" "D:\Games\My Game\"



:: ****************
:: * INIT SECTION *
:: ****************

:: Turn off execution echo - needed for debugging purposes only
@ECHO OFF

:: Display error and help information in case of no obligatory parameters provided
IF (%1)==() GOTO PARAMETER_ERROR

:: ******************************
:: * HANDLE HELP/INFO PARAMETER *
:: ******************************

IF (%1)==(/?) GOTO HELP
IF (%1)==(-?) GOTO HELP
IF (%1)==(?) GOTO HELP

IF (%1)==(/h) GOTO HELP
IF (%1)==(/H) GOTO HELP
IF (%1)==(/Help) GOTO HELP
IF (%1)==(/help) GOTO HELP
IF (%1)==(/HELP) GOTO HELP

IF (%1)==(-h) GOTO HELP
IF (%1)==(-H) GOTO HELP
IF (%1)==(-Help) GOTO HELP
IF (%1)==(-help) GOTO HELP
IF (%1)==(-HELP) GOTO HELP

IF (%1)==(h) GOTO HELP
IF (%1)==(H) GOTO HELP
IF (%1)==(Help) GOTO HELP
IF (%1)==(help) GOTO HELP
IF (%1)==(HELP) GOTO HELP

IF (%1)==(/i) GOTO HELP
IF (%1)==(/I) GOTO HELP
IF (%1)==(/Info) GOTO HELP
IF (%1)==(/info) GOTO HELP
IF (%1)==(/INFO) GOTO HELP

IF (%1)==(-i) GOTO HELP
IF (%1)==(-I) GOTO HELP
IF (%1)==(-Info) GOTO HELP
IF (%1)==(-info) GOTO HELP
IF (%1)==(-INFO) GOTO HELP

IF (%1)==(i) GOTO HELP
IF (%1)==(I) GOTO HELP
IF (%1)==(Info) GOTO HELP
IF (%1)==(info) GOTO HELP
IF (%1)==(INFO) GOTO HELP

IF (%2)==() GOTO PARAMETER_ERROR


:: **************************
:: * HANDLE IMAGE FILE PATH *
:: **************************

:: Copy file path currently being precessed for error tracing purposes.
SET CURR_FILE_PATH=%1

:: Get Full path to virtual CD/DVD image from 2nd supplied parameter.
:: Note: quotation marks needs to be added due to extraction operand (~) removes
:: them from originally supplied parameter.
SET IMAGE="%~F1"
IF NOT ERRORLEVEL 0 GOTO INCORRECT_FILE_PATH

:: Checking files/folder existance
IF NOT EXIST %CURR_FILE_PATH% GOTO FILE_PATH_NOT_EXIST


:: ************************
:: * HANDLE EXE FILE PATH *
:: ************************

:: Copy file path currently being precessed for error tracing purposes.
SET CURR_FILE_PATH=%2

:: Get Full path to application launcher (.exe file) from 2nd supplied parameter.
:: Note: quotation marks needs to be added due to extraction operand (~) removes
:: them from originally supplied parameter.
SET APP_EXE="%~F2"
IF NOT ERRORLEVEL 0 GOTO INCORRECT_FILE_PATH

:: Checking files/folder existance
IF NOT EXIST %CURR_FILE_PATH% GOTO FILE_PATH_NOT_EXIST




:: ****************************
:: * HANDLE WORKING DIRECTORY *
:: ****************************

:: Get application working directory as third provided optional parameter or
:: extract it from path to application launcher in case it's not provided explicitly.
:: Note: quotation marks needs to be added due to extraction operand (~) removes
:: them from originally supplied parameter.
IF (%3)==() (
	:: Parameter %1 already handled, no additional check needed here
	SET APP_WD="%~DP1"
) ELSE (
	:: Copy file path currently being precessed for error tracing purposes.
	SET CURR_FILE_PATH=%3
	
	SET APP_WD="%~F3"
	IF NOT ERRORLEVEL 0 GOTO INCORRECT_FILE_PATH
	
	:: Checking files/folder existance
	IF NOT EXIST %CURR_FILE_PATH% GOTO FILE_PATH_NOT_EXIST
)


:: ******************
:: * MOUNTING IMAGE *
:: ******************

:: Mount fixed image to virtual disk reader (DAEMON Tools).
@ECHO Mounting virtual drive...
IF EXIST DTAgent.exe (
	@ECHO DAEMON Tools found
	::DTLite.exe -mount 0,%IMAGE%
	DTAgent.exe -mount dt, %IMAGE%
) ELSE IF EXIST AxCmd.exe (
	@ECHO Alcohol found
	AxCmd.exe 1: /M:%IMAGE%	
) ELSE (
	@ECHO Neither DAEMON Tools nor Alcohol found!
	EXIT
)

IF NOT ERRORLEVEL 0 GOTO VIRTUAL_DRIVE_ERROR

@ECHO Done.


:: For stability, pause between mount and application launch for t sec (t x 1000 ms) by
:: pinging incorrect IP (1.1.1.1) once (-n 1) with timeout t x 1000 ms.
::PING -n 1 -w 2000 1.1.1.1>nul



:: ************************
:: * REMOVE Game Explorer *
:: ************************

:: Remove Game Explorer feature by renaming its dll file

:: x86 (32-bit) and x64 (64-bit) Windows
::IF EXIST       C:\Windows\System32\gameux.dll (
::	takeown /F C:\Windows\System32\gameux.dll
::	icacls     C:\Windows\System32\gameux.dll /setowner %USERNAME% /Q
::	icacls     C:\Windows\System32\gameux.dll /grant %USERNAME%:F /Q
::	REN        C:\Windows\System32\gameux.dll gameux.dll.bak
::)

:: x64 (64-bit) WindowsOnWindows 32bit subsystem
::IF EXIST       C:\Windows\SysWOW64\gameux.dll (
::	takeown /F C:\Windows\SysWOW64\gameux.dll
::	icacls     C:\Windows\SysWOW64\gameux.dll /setowner %USERNAME% /Q
::	icacls     C:\Windows\SysWOW64\gameux.dll /grant %USERNAME%:F /Q
::	REN        C:\Windows\SysWOW64\gameux.dll gameux.dll.bak
::)



:: *********************
:: * START APPLICATION *
:: *********************

:: Start application with working directory explicitly set to directory
:: where application executive file is located.
:: This is necessary to run some applications without errors.
@ECHO.
@ECHO Starting application...
START "Application launched" /WAIT /D %APP_WD% %APP_EXE%
IF NOT ERRORLEVEL 0 GOTO APPLICATION_ERROR


:: ********************
:: * UNMOUNTING IMAGE *
:: ********************

:UNMOUNTING
:: Unmount fixed image from virtual disk reader (DAEMON Tools).
@ECHO Unmounting virtual drive...

IF EXIST DTAgent.exe (
	@ECHO DAEMON Tools found
	::DTLite.exe -unmount 0
	DTAgent.exe -unmount_all
) ELSE IF EXIST AxCmd.exe (
	@ECHO Alcohol found
	AxCmd.exe 1: /U
) ELSE (
	@ECHO Neither DAEMON Tools nor Alcohol found!
	EXIT
)

IF NOT ERRORLEVEL 0 GOTO VIRTUAL_DRIVE_ERROR

@ECHO Done.

:: Exit after application finish.
@ECHO Bye!
EXIT



:: *****************
:: * ERRORHANDLING *
:: *****************

:PARAMETER_ERROR
@ECHO ERROR: MISSING 2 REQUIRED PARAMETERS! PRESS ANY KEY TO DISPLAY HELP
PAUSE
CLS
GOTO HELP



:INCORRECT_FILE_PATH
@ECHO ERROR: FILE PATH
@ECHO %CURR_FILE_PATH%
@ECHO IS INCORRECTLY SPECIFIED!
PAUSE
EXIT


:FILE_PATH_NOT_EXIST
@ECHO ERROR: FILE PATH
@ECHO %CURR_FILE_PATH%
@ECHO DOES NOT EXIST!
PAUSE
EXIT


:VIRTUAL_DRIVE_ERROR
@ECHO ERROR WHILE TRYING TO MOUNT/UNMOUNT VIRTUAL DRIVE
@ECHO %IMAGE%
@ECHO ERROR CODE RETURNED=%ERRORLEVEL%
@ECHO USE IT FOR FURTHER TROUBLESHOOTING!
@ECHO TRY GET HELP AT http://www.daemonpro-help.com/ OR http://forum.alcohol-soft.com/
@ECHO GOOD LUCK! :)
PAUSE
EXIT



:APPLICATION_ERROR
@ECHO ERROR WHILE TRYING TO LAUNCH APPLICATION
@ECHO %APP_EXE%
@ECHO WITH WORKING DIRECTORY
@ECHO %APP_WD%
@ECHO HINT: CHECK THAT CORRECT WORKING DIRECTORY WAS SET (SEE HELP TO THIS FILE)
@ECHO ERROR CODE RETURNED BY APPLICATION=%ERRORLEVEL%
@ECHO USE IT FOR FURTHER TROUBLESHOOTING!
@ECHO GOOD LUCK! :)
PAUSE
EXIT


:: ****************
:: * DISPLAY HELP *
:: ****************

:HELP
@ECHO gmount
@ECHO by edmynay
@ECHO.
@ECHO FUNCTION
@ECHO Automatically mounts provided CD/DVD image, runs given app/game and unmounts afterwards
@ECHO.

@ECHO USAGE
@ECHO 1. Install DAEMON Tools or Alcohol
@ECHO 2. Copy this file to directory where DAEMON Tools or Alcohol installed
@ECHO 3. Create shortcut to this file on the desktop and modify its Properties-Target
@ECHO field as following:
@ECHO "Path\To\This\File\gmount.bat" "IMAGE" "APP" ["APP_WD"]
@ECHO where:
@ECHO IMAGE  - path (absolute or relative) to CD/DVD image
@ECHO APP    - path (absolute or relative) to application (.exe file)
@ECHO APP_WD - optional path (absolute or relative) to application working directory
@ECHO          (could be required sometimes if app/game crashes).
@ECHO          If omitted, directory with APP_EXE is used by default.
@ECHO Note: quotation marks ("") are necessary in case path contains space(s)!
@ECHO.
@ECHO EXAMPLE:
@ECHO "C:\Program Files\DAEMON Tools Lite\gmount.bat" "D:\Virtual CDs\My Game\NoCD\My Game.iso" "D:\Games\My Game\bin\My Game.exe" "D:\Games\My Game\"
@ECHO.
PAUSE

:: Implicit exit here
