@echo off

set /a stepTotal = 5
set /a stepCount = 0

:hardReboot
set /p isHard="Run Hard Reboot? (This Will Automatically Restart Your Computer Once Complete): (Y/[N])"
if /i "%isHard%" == "" set "isHard=N"
if /i "%isHard%" == "Y" (
	set /a stepTotal= %stepTotal%+2
) else (
	if /i not "%isHard%" == "N" (
		cls
		echo Please Enter Y, N or Press Enter for Default
		goto hardReboot
	)
)

:coreCommands

echo [[[Internet Fix Start]]] 1>InternetFixLog.txt 2>>&1
ipconfig /all 1>>InternetFixLog.txt 2>>&1

cls
set /a stepCount=%stepCount%+1
echo Executing %stepCount%/%stepTotal%
echo Releasing IP Addess
echo/ 1>>InternetFixLog.txt
echo [[[Releasing IP Addess]]] 1>>InternetFixLog.txt 2>>&1
ipconfig /release 1>>InternetFixLog.txt 2>>&1

cls
set /a stepCount=%stepCount%+1
echo Executing %stepCount%/%stepTotal%
echo Flushing DNS Cache
echo/ 1>>InternetFixLog.txt
echo [[[Flushing DNS Cache]]] 1>>InternetFixLog.txt 2>>&1
ipconfig /flushdns 1>>InternetFixLog.txt 2>>&1

cls
set /a stepCount=%stepCount%+1
echo Executing %stepCount%/%stepTotal%
echo Renewing IP Address
echo/ 1>>InternetFixLog.txt
echo [[[Renewing IP Address]]] 1>>InternetFixLog.txt 2>>&1
ipconfig /renew 1>>InternetFixLog.txt 2>>&1

echo/ 1>>InternetFixLog.txt
echo [[[Re-Enabling Adapters]]] 1>>InternetFixLog.txt 2>>&1
netsh interface show interface 1>>InternetFixLog.txt 2>>&1

cls
set /a stepCount=%stepCount%+1
setlocal enabledelayedexpansion
set "names="
(set \n=^
%=DONT REMOVE THIS=%
)
for /f "tokens=1,2,3,* delims= " %%a in ('findstr /R /C:"Dedicated" InternetFixLog.txt') do (
	cls
	echo Executing %stepCount%/%stepTotal%
	echo Disabling Adapters
	set names=!names!%%d!\n!
	echo !names!
	netsh interface set interface "%%d" disable
)
endlocal

cls
set /a stepCount=%stepCount%+1
setlocal enabledelayedexpansion
set "names="
(set \n=^
%=DONT REMOVE THIS=%
)
for /f "tokens=1,2,3,* delims= " %%a in ('findstr /R /C:"Dedicated" InternetFixLog.txt') do (
	cls
	echo Executing %stepCount%/%stepTotal%
	echo Enabling Adapters
	set names=!names!%%d!\n!
	echo !names!
	netsh interface set interface "%%d" enable
)
endlocal

if /i "%isHard%" == "Y" (
	cls
	set /a stepCount=%stepCount%+1
	echo "Executing %stepCount%/%stepTotal%"
	echo "Resetting TCP/IP"
	echo/ 1>>InternetFixLog.txt
	echo [[[Resetting TCP/IP]]] 1>>InternetFixLog.txt 2>>&1
	netsh int ip reset 1>>InternetFixLog.txt 2>>&1

	cls
	set /a stepCount=%stepCount%+1
	echo "Executing %stepCount%/%stepTotal%"
	echo "Resetting Winsock"
	echo/ 1>>InternetFixLog.txt
	echo [[[Resetting Winsock]]] 1>>InternetFixLog.txt 2>>&1
	netsh winsock reset 1>>InternetFixLog.txt 2>>&1

	echo "Restarting Computer In"
	timeout /t 10 /nobreak
	shutdown.exe /r /t 00
)

exit