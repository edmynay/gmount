# gmount
by edmynay

## FUNCTION
Automatically mounts provided CD/DVD image, runs given app/game and unmounts afterwards

## USAGE
1. Install DAEMON Tools or Alcohol
2. Copy this file to directory where DAEMON Tools or Alcohol installed
3. Create shortcut to this file on the desktop and modify its Properties-Target
field as following:
"Path\To\This\File\gmount.bat" "IMAGE" "APP" ["APP_WD"]\
where:\
IMAGE  - path (absolute or relative) to CD/DVD image\
APP    - path (absolute or relative) to application (.exe file)\
APP_WD - optional path (absolute or relative) to application working directory\
         (could be required sometimes if app/game crashes).\
         If omitted, directory with APP_EXE is used by default.\

Note: quotation marks ("") are necessary in case path contains space(s)!

EXAMPLE:\
"C:\Program Files\DAEMON Tools Lite\gmount.bat" "D:\Virtual CDs\My Game\NoCD\My Game.iso" "D:\Games\My Game\bin\My Game.exe" "D:\Games\My Game\"
