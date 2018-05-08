@ECHO OFF
REM Instructions:- Set the below 2 variables 
         SET desktop=C:\Users\sqa\Desktop\
REM SET productName=Kiwiplan Business Solutions
REM SET productName=Kiwiplan ESP

REM SET InstallerPath=\\calypso\Releases\ESP_9.10_180401
REM SET FileNameFormat=ESP_test_9.10_??????.???????.msi
         SET InstallerPath=\\calypso\Releases\ESP_8.62_180101
         SET FileNameFormat=ESP_test_8.62_??????.???????.msi


REM ********************************
REM ****Program begins from here****
REM ********************************

SET /p runDroid="Run database restore droid script?[Y/N]" 

IF %runDroid%==y (
	Echo ****** Free up connections on Vterm close all connection to the database.
	Pause
) 

SET currentlyInstalledMSIName="garbage"

ECHO ****** Querying currently installed 'Kiwiplan Business Solutions'...
FOR /f "delims=" %%a IN ('
    wmic product where "Name='Kiwiplan Business Solutions'" get packagename ^| find "msi"
') DO SET currentlyInstalledMSIName=%%a
SET currentlyInstalledMSIName=%currentlyInstalledMSIName: =%

if %currentlyInstalledMSIName%=="garbage" (
ECHO ****** Querying currently installed 'Kiwiplan ESP'...
FOR /f "delims=" %%a IN ('
    wmic product where "Name='Kiwiplan ESP'" get packagename ^| find "msi"
') DO SET currentlyInstalledMSIName=%%a
SET currentlyInstalledMSIName=%currentlyInstalledMSIName: =%
)

if %currentlyInstalledMSIName%=="garbage" (
	ECHO ****** No ESP MSI found installed. 
) else (
	ECHO ****** Currently Installed MSI is %currentlyInstalledMSIName% .
)

ECHO ****** Querying latest ESP MSI in folder %InstallerPath% ...
pushd %InstallerPath%
for /f "eol=: delims=" %%F in ('dir /b /a-d /o-d %FileNameFormat%') do set NewestFile="%%F" &goto :break
:break
popd

IF %NewestFile%=="%currentlyInstalledMSIName%" (
	Echo ****** Latest File is already installed...
) ELSE (

ECHO ****** Copying latest latest MSI %NewestFile% to the desktop...
	DEL %desktop%%FileNameFormat%
	copy "%InstallerPath%\%NewestFile%" %desktop%
	
ECHO ****** Installing latest MSI %NewestFile% ...
	taskkill /im KiwiXplor.exe /f
	wmic product where name="kiwiplan business solutions" call uninstall /nointeractive 
	%desktop%\%NewestFile%
		
	ECHO ****** Getting latest droid...
	taskkill /im logviewer.exe /f
	taskkill /im DCP.exe /f
	taskkill /im Droidplayer.exe /f

	echo. | C:\Users\sqa\Desktop\getLatestDroid6.bat.lnk
)

if %runDroid%==y (
	Echo ****** Restoring dataset; running script - restore_setupsheetplants.test...
	C:\Kiwiplan\Droid\DroidPlayer.exe -o C:\DroidTests_8.62.1\Sheetplant\Restores\restore_setupsheetplants\restore_setupsheetplants.test -U -G T:\ -L C:\DroidTests_8.62.1 -P -S
) 

pause




