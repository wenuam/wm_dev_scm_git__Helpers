@echo off && setlocal EnableDelayedExpansion EnableExtensions
if "%~dp0" neq "!guid!\" (set "guid=%tmp%\crlf.%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "!guid!\%~nx0" (mkdir "!guid!" 2>nul & find "" /v<"%~f0" >"!guid!\%~nx0")) & call "!guid!\%~nx0" %* & rmdir /s /q "!guid!" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Update git --chmod=+x on subfolder tree, by wenuam 2025

rem Set code page to utf-8 (/!\ this file MUST be in utf-8, BOM or not)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

rem Set "quiet" suffixes
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

rem Set look-up parameters
set "carg=/B /A:-D /ON"
set "clst=.clst.txt"

set "crel=%~f1"

if not "%crel%"=="" (
	if exist "%crel%\*" (
		if exist "%crel%\.git\*" (
			git -v
REM			echo From: %cd%
			echo Folder to chmod: %crel%
			del "%clst%" %fquiet%
			echo Scanning for executable files...
			for %%a in (bash bat bin cmd com cpl dll elf exe gadget hta inf1 ins inx isu job js jse lnk mbn msc msi msp mst paf pif ps1 reg rgs scr sct sh shb shs u3p vb vbe vbs vbscript vsix ws wsf wsh xpi) do (
				rem	"https://www.robvanderwoude.com/battech_wildcards.php"
				rem	"https://devblogs.microsoft.com/oldnewthing/20071217-00/?p=24143"
				rem	"https://learn.microsoft.com/fr-fr/archive/blogs/jeremykuhne/wildcards-in-windows"
				dir %carg% /S "%crel%\*.%%a" 2>nul|findstr /le ".%%a"|findstr /v "_OLD">>"%clst%" 2>nul
			)
			sort "%clst%">"%clst%.sorted"
REM			pause

			if exist "%clst%.sorted" (
				rem For all files found
				for /f "delims=" %%i in (%clst%.sorted) do (
					pushd "!crel!"
						set "vdir=%%i"
						if exist "!vdir!" (
							echo !vdir!
							git update-index --chmod=+x "!vdir!" 2>nul
						)
					popd
				)
				echo Done...

				rem Delete files list
				del "%clst%.sorted" %fquiet%
			) else (
				echo No file to update found...
			)
			del "%clst%" %fquiet%
		) else (
			echo Folder provided not a Git repository...
		)
	) else (
		echo Folder provided doesn't exist...
	)
) else (
	echo No input folder provided...
)

rem Restore code page
chcp %cp%>nul

:end
REM	pause
