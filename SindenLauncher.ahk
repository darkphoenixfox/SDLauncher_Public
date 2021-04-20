﻿;SDLauncher by Fox for the Sinden Lightgun
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetWinDelay, -1


;------------------- Preparations --------------------------
;Import external libraries
#Include, %A_ScriptDir%\lib\nonomousy.lib ; hidecursor() / showcursor()
#Include, %A_ScriptDir%\lib\emudownloader.lib ; HashFile(filepath, "MD5") || emudownloader(DMemuname,DMfullfilename,DMtotalFilesize,DMdocumentation)

showcursor()
; capture the parameters given to the program
numParams = %0% ;0 1 or 2
systemParam = %1% ;ps1 snes || ps2 mame or demul 
gameParam = %2% ; iso name with full path
systems := [] ; Init array
;.systems := [ps1,ps2,snes,demul,mame]
systems := {"ps1":0,"snes":0}

FileCreateDir, %a_scriptdir%\temp


; read the ini file sdlauncher.ini

;[general]
iniread, numberofguns, sdlauncher.ini, general, numberofguns, 1
iniread, p1sindenlocation, sdlauncher.ini, general, p1sindenlocation, 0
iniread, p2sindenlocation, sdlauncher.ini, general, p2sindenlocation, 0
iniread, latestsoftware, sdlauncher.ini, general, latestsoftware, https://www.sindenlightgun.com/software/SindenLightgunSoftwareReleaseV1.05b.zip
iniread, softwaresize, sdlauncher.ini, general, softwaresize, 23855276
iniread, softwarehash, sdlauncher.ini, general, softwarehash, 1672dc77d6cc505bd47cb85ffbf9b393

;[ps1]
IniRead, ps1emulocation, sdlauncher.ini, ps1, ps1emulocation, 0 
IniRead, ps1parameters, sdlauncher.ini, ps1, ps1parameters, 0
IniRead, ps1bezelslocation, sdlauncher.ini, ps1, ps1bezelsLocation, 0
IniRead, ps1gameslocation, sdlauncher.ini, ps1, ps1gameslocation, 0
IniRead, ps1hidemouse, sdlauncher.ini, ps1, ps1hidemouse, 0

;static
IniRead, ps1systemname, sdlauncher.ini, ps1, ps1systemname, PlayStation
IniRead, ps1name, sdlauncher.ini, ps1, ps1name, Duckstation
iniread, latestps1, sdlauncher.ini, ps1, latestps1, https://github.com/stenzek/duckstation/releases/download/latest/duckstation-windows-x64-release.zip
iniread, ps1manualdownload, launcher.ini, ps1, ps1manualdownload, https://github.com/stenzek/duckstation/releases/tag/latest
iniread, ps1size, sdlauncher.ini, ps1, ps1size, 21641575
iniread, ps1docs, sdlauncher.ini, ps1, ps1docs, https://github.com/stenzek/duckstation
IniRead, ps1wiki, sdlauncher.ini, ps1, ps1wiki, https://sindenlightgun.miraheze.org/wiki/Duckstation
IniRead, ps1video, sdlauncher.ini, ps1, ps1video, https://youtu.be/OvyUvxzBLOc


SplitPath, ps1emulocation ,, ps1emufolder


;[snes]
IniRead, snesemulocation, sdlauncher.ini, snes, snesemulocation, 0 
IniRead, snesparameters, sdlauncher.ini, snes, snesparameters, 0
IniRead, snesbezelslocation, sdlauncher.ini, snes, snesbezelsLocation, 0
IniRead, snesgameslocation, sdlauncher.ini, snes, snesgameslocation, 0
IniRead, sneshidemouse, sdlauncher.ini, snes, sneshidemouse, 0

;static
IniRead, snessystemname, sdlauncher.ini, snes, snessystemname, SuperNES
IniRead, snesname, sdlauncher.ini, snes, snesname, Snes9x
iniread, latestsnes, sdlauncher.ini, snes, latestsnes, https://github.com/ProfgLX/snes9xLightgun/releases/latest/download/Snes9x.Lightgun.Edition.zip
iniread, snesmanualdownload, launcher.ini, snes, snesmanualdownload, https://github.com/ProfgLX/snes9xLightgun/releases/latest
iniread, snessize, sdlauncher.ini, snes, snessize, 2116383
iniread, snesdocs, sdlauncher.ini, snes, snesdocs, https://www.snes9x.com/
IniRead, sneswiki, sdlauncher.ini, snes, sneswiki, https://sindenlightgun.miraheze.org/wiki/SNES9X
IniRead, snesvideo, sdlauncher.ini, snes, snesvideo, https://www.youtube.com/watch?v=yvP_-KLqLQE


; Sanity Checks

if (p1sindenlocation=0) ; set the default
	p1sindenlocation=%A_ScriptDir%\tools\SindenLightgun1
if (p2sindenlocation=0) ; set the default
		p2sindenlocation=%A_ScriptDir%\tools\SindenLightgun2


if (numParams > 0) 
{
	if !FileExist(a_scriptdir "\sdlauncher.ini")
		{
		gosub showUI
		return
	}
	
	if !systems.Haskey(systemParam)  ; if the system provided is not one of the list
	{	
		MsgBox, 8208, System not recognized, I don't recognize system %systemParam%.
		ExitApp
	}
	if (numParams = 1)
	{
		MsgBox, 8208, Parameters missing, Please indicate the system and game iso with full path`n(e.g. ps1 "c:\games\time crisis.iso")
		ExitApp
	}
	if (numParams = 2)
	{
		If !FileExist(gameParam)
		{
			MsgBox, 8208, Game missing, Can't find the game in:'n'n%gameParam%
			ExitApp
		}
		if (systemParam="ps1")
		{
			SplitPath, gamePAram,ps1gamelist,ps1gameslocation
			Gosub Playps1
		}
		if (systemParam="snes")
		{
			SplitPath, gameParam,snesgamelist,snesgameslocation
			Gosub Playsnes
		}
		return
	}
}


; give the app a nice icon for the tray and the Windows
I_Icon = %A_ScriptDir%\lib\Lightgun_RED.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%


;-----------------------------------------------------------


if (numParams=0) ;if the program is run without parameters load the UI
	gosub showUI
return


;============================================================MAIN UI============================================================
showUI:
;Gui, main:Add, Tab3, W800 H600 Center, General||PS1|PS2|SNES|Demul|Tools|Run Game ; full version

Gui, main:Add, Tab3, w800 h600 Center, Sinden||Playstation | SNES | Credits ;lite version




;General TAB -----------   General TAB -----------   General TAB -----------   General TAB -----------   General TAB -----------   

Gui, main:Tab, 1, 
Gui, main:Add, Picture, x735 y545 vDiskIcon, %A_ScriptDir%\lib\disk.png
GuiControl, main:hide, DiskIcon
Gui, main:Add, Text, x30 y72 w150 h20 , Sinden Software

Gui, main:Add, Button, x150 y70 w100 h20, Installation Wizard
Gui, main:Add, Text, x260 y72 w150 h20 , - or - 
Gui, main:Add, Button, x290 y70 w100 h20 gDown1 , Manual Download
Gui, main:Add, Button, x430 y70 w100 h20, Visual guide - Wiki
Gui, main:Add, Button, x570 y70 w100 h20 gVideo1, Video guide
Gui, main:Add, Text, x710 y72 w150 h20, Guns
Gui, main:Add, DropDownList, x740 y70 w30 h20 r2 Choose1 gUpdateGUI vnumberofguns, 1|2
if (numberofguns=2)
{
	guicontrol, main:choose , numberofguns, 2
}


;gun 1 section

Gui, main:Add, Picture, x30 y125 w32 h32, %A_ScriptDir%\lib\Lightgun_RED.ico
gui, main:font, bold
Gui, main:Add, Button, x100 y130 w100 h20 gRUN1 vRUN1 Default, RUN 
gui, main:font
Gui, main:Add, Button, x220 y130 w100 h20 gCONFIG1 vCONFIG1, Configure 
Gui, main:Add, Text, x40 y155 w400 vWarning,  

If !FileExist(p1sindenlocation "\Lightgun.exe")
{
	GuiControl, main:Disable, RUN1
	GuiControl, main:Disable, CONFIG1
	GuiControl, main:Text, Warning , Please configure the correct folder or run the Installation Wizard
	gui, main:submit, NoHide
	
}

Gui, main:Add, Text, x370 y132 w150 h20 , Path:
Gui, main:Add, Edit, x400 y130 w290 h20 vp1sindenlocation gp1sindenlocation, %p1sindenlocation%
Gui, main:Add, Button, x700 y130 w100 h20 gp1sindenlocationBrowse , Browse



;gun 2 section

	Gui, main:Add, Picture, x30 y200 w32 h32 vSindenIcon2, %A_ScriptDir%\lib\Lightgun_BLUE.ico
	gui, main:font, bold
	Gui, main:Add, Button, x100 y205 w100 h20 gRUN2 Default vRUN2, RUN 
	gui, main:font
	Gui, main:Add, Button, x220 y205 w100 h20 gCONFIG2 vCONFIG2, Configure 
	Gui, main:Add, Text, x40 y230 w400 vWarning2,  

If !FileExist(p2sindenlocation "\Lightgun.exe")
{
	GuiControl, main:Disable, RUN2
	GuiControl, main:Disable, CONFIG2
	GuiControl, main:Text, Warning2 , Please configure the correct folder or run the Installation Wizard
	gui, main:submit, nohide
	
}
	Gui, main:Add, Text, x370 y207 w150 h20 vPathlabel, Path:
	Gui, main:Add, Edit, x400 y205 w290 h20 vp2sindenlocation gp2sindenlocation, %p2sindenlocation%
	Gui, main:Add, Button, x700 y205 w100 h20 vp2sindenlocationBrowse gp2sindenlocationBrowse , Browse

if (numberofguns=1)
{
	GuiControl, main:hide, SindenIcon2
	GuiControl, main:hide, RUN2
	GuiControl, main:hide, CONFIG2
	GuiControl, main:hide, Warning2
	GuiControl, main:hide, Pathlabel
	GuiControl, main:hide, p2sindenlocation
	GuiControl, main:hide, p2sindenlocationBrowse
	
}



;Playstation 1 TAB -----------   Playstation 1 TAB -----------   Playstation 1 TAB -----------   Playstation 1 TAB -----------   Playstation 1 TAB -----------   
Gui, main:Tab, 2 
Gui, main:Add, Picture, x735 y545 vDiskIconps1, %A_ScriptDir%\lib\disk.png
GuiControl, main:hide, DiskIconps1
Gui, main: font, bold
if FileExist(a_scriptdir "\lib\" ps1name ".ico")
{
	Gui, main:Add, picture, x40 y40 w64 h64 vps1ico, %a_Scriptdir%\lib\%ps1name%.ico
	
	Gui, main:Add, Text, x22 y110 w100 h20 center, %ps1name%
	
}
else
	Gui, main:Add, Text, x30 y72 w150 h20 , %ps1name%
Gui, main: font
Gui, main:Add, Button, x150 y70 w100 h20 gWizardps1, Installation Wizard
Gui, main:Add, Text, x260 y72 w150 h20 , - or - 
Gui, main:Add, Button, x290 y70 w100 h20 gDownps1 , Manual Download
Gui, main:Add, Button, x430 y70 w140 h20 gWikips1, %ps1name% Sinden Wiki
Gui, main:Add, Button, x610 y70 w140 h20 gVideops1, Video guide

Gui, main:Add, Text, x70 y132 w150 h20 , Emulator Location
if (ps1emulocation=0) ;set the default
	ps1emulocation=Path to emulator executable
Gui, main:Add, Edit, x180 y130 w490 h20 vps1emulocation gps1emulocation, %ps1emulocation%
Gui, main:Add, Button, x680 y130 w100 h20 gps1emulocationBrowse , Browse

Gui, main:Add, Text, x70 y162 w150 h20 , Emulator parameters
if (ps1parameters=0) ;set the default
	ps1parameters:="-fullscreen"
Gui, main:Add, Edit, x180 y160 w490 h20 vps1parameters gps1parameters, %ps1parameters%
Gui, main:Add, Button, x680 y160 w100 h20 gps1parametersDefault , Default

Gui, main:Add, Text, x70 y192 w150 h20 , Games Location
if (ps1gameslocation=0) ; set the default
	ps1gameslocation=Select your games folder
Gui, main:Add, Edit, x180 y190 w490 h20 vps1gameslocation gps1gameslocation, %ps1gameslocation%
Gui, main:Add, Button, x680 y190 w100 h20 gps1gameslocationBrowser , Browse

;game browser
Gui, main:Add, Text, x70 y222 w150 h20 , Game Launcher
Gui, main:Add, DropDownList, x180 y220 w490 r6 gps1gamelist vps1gamelist,
getFolderFilelistps1(ps1gameslocation,"ps1gamelist")
;selected game options


Gui, main:add, text, x115 y254 w150 h20, Hide Mouse
GuiControl, main:, ps1hidemouse, %ps1hidemouse% ; set the default/ ini value
Gui, main:add, CheckBox, x180 y255 vps1hidemouse gps1hidemouse,
Gui, main:add, Button, x220 y250 w100 h20 vps1configure gps1configure, Configure Emulator
If FileExist(ps1emulocation) &&	 Instr(ps1emulocation, ".exe")
{
	GuiControl, main:Enable, ps1configure
}
else
{
	GuiControl, main:Disable, ps1configure
}

Gui, main:Add, Button, x370 y250 w100 h20 gShortcutps1 vShortcutps1, Create Shortcut
If FileExist(ps1emulocation) &&	 Instr(ps1emulocation, ".exe")
{
	GuiControl, main:Enable, Shortcutps1
	GuiControl, main:Enable, Playps1
}
else
{
	GuiControl, main:Disable, Shortcutps1
	GuiControl, main:Disable, Playps1
}

Gui, main:Add, Button, x520 y250 w100 h20 gPlayps1 , Play




;bezel preview
Gui, main:Add, Text, x70 y302 w150 h20 , Bezels Location
if (ps1bezelslocation=0) ; set the default
	ps1bezelslocation=%A_ScriptDir%\SindenBezels\ps1
Gui, main:Add, Edit, x180 y300 w490 h20 vps1bezelslocation gps1bezelslocation, %ps1bezelslocation%
Gui, main:Add, Button, x680 y300 w100 h20 gps1bezelslocationBrowse , Browse

gui, main:submit, nohide
Gui, main:Add, Text, x70 y442 w150 h20 , Bezel Preview
Gui, main:add, text, x217 y570 w377 h20 center vps1bezelMessage, Game bezel not found - Using generic
SplitPath, ps1gamelist,,,,ps1gamenoext
if !FileExist(ps1bezelslocation "\" ps1gamenoext ".png")
{ 
	currentBezel = generic
	GuiControl, main:show, ps1bezelMessage
}
else
{
	currentBezel = %ps1gamenoext%
	GuiControl, main:hide, ps1bezelMessage
}
Gui, main:add, picture, x215 y343 w381 h216 vbackgroundps1, %A_ScriptDir%\lib\1px.png
Gui, main:add, picture, x217 y345 w377 h212 vbezelPreviewps1, %A_ScriptDir%\SindenBezels\ps1\%currentBezel%.png
Gui, main:Add, Button, x680 y440 w100 h20 gChangeBezelps1 vChangeBezelps1, Change Bezel







;SNES TAB -----------   SNES TAB -----------   SNES TAB -----------   SNES TAB -----------   SNES TAB -----------   
Gui, main:Tab, 3
Gui, main:Add, Picture, x735 y545 vDiskIconsnes, %A_ScriptDir%\lib\disk.png
GuiControl, main:hide, DiskIconsnes
Gui, main: font, bold
if FileExist(a_scriptdir "\lib\" snesname ".ico")
{
	Gui, main:Add, picture, x40 y40 w64 h64 vsnesico, %a_Scriptdir%\lib\%snesname%.ico
	
	Gui, main:Add, Text, x22 y110 w100 h20 center, %snesname%
	
}
else
	Gui, main:Add, Text, x30 y72 w150 h20 , %snesname%
Gui, main: font
Gui, main:Add, Button, x150 y70 w100 h20 gWizardsnes, Installation Wizard
Gui, main:Add, Text, x260 y72 w150 h20 , - or - 
Gui, main:Add, Button, x290 y70 w100 h20 gDownsnes , Manual Download
Gui, main:Add, Button, x430 y70 w140 h20 gWikisnes, %snesname% Sinden Wiki
Gui, main:Add, Button, x610 y70 w140 h20 gVideosnes, Video guide

Gui, main:Add, Text, x70 y132 w150 h20 , Emulator Location
if (snesemulocation=0) ;set the default
	snesemulocation=Path to emulator executable
Gui, main:Add, Edit, x180 y130 w490 h20 vsnesemulocation gsnesemulocation, %snesemulocation%
Gui, main:Add, Button, x680 y130 w100 h20 gsnesemulocationBrowse , Browse

Gui, main:Add, Text, x70 y162 w150 h20 , Emulator parameters
if (snesparameters=0) ;set the default
	snesparameters:="-fullscreen"
Gui, main:Add, Edit, x180 y160 w490 h20 vsnesparameters gsnesparameters, %snesparameters%
Gui, main:Add, Button, x680 y160 w100 h20 gsnesparametersDefault , Default

Gui, main:Add, Text, x70 y192 w150 h20 , Games Location
if (snesgameslocation=0) ; set the default
	snesgameslocation=Select your games folder
Gui, main:Add, Edit, x180 y190 w490 h20 vsnesgameslocation gsnesgameslocation, %snesgameslocation%
Gui, main:Add, Button, x680 y190 w100 h20 gsnesgameslocationBrowser , Browse

;game browser
Gui, main:Add, Text, x70 y222 w150 h20 , Game Launcher
Gui, main:Add, DropDownList, x180 y220 w490 r6 gsnesgamelist vsnesgamelist,
getFolderFilelistsnes(snesgameslocation,"snesgamelist")
;selected game options


Gui, main:add, text, x115 y254 w150 h20, Hide Mouse
GuiControl, main:, sneshidemouse, %sneshidemouse% ; set the default/ ini value
Gui, main:add, CheckBox, x180 y255 vsneshidemouse gsneshidemouse,
Gui, main:add, Button, x220 y250 w100 h20 vsnesconfigure gsnesconfigure, Configure Emulator
If FileExist(snesemulocation) &&	 Instr(snesemulocation, ".exe")
{
	GuiControl, main:Enable, snesconfigure
}
else
{
	GuiControl, main:Disable, snesconfigure
}

Gui, main:Add, Button, x370 y250 w100 h20 gShortcutsnes vShortcutsnes, Create Shortcut
If FileExist(snesemulocation) &&	 Instr(snesemulocation, ".exe")
{
	GuiControl, main:Enable, Shortcutsnes
	GuiControl, main:Enable, Playsnes
}
else
{
	GuiControl, main:Disable, Shortcutsnes
	GuiControl, main:Disable, Playsnes
}

Gui, main:Add, Button, x520 y250 w100 h20 gPlaysnes , Play




;bezel preview
Gui, main:Add, Text, x70 y302 w150 h20 , Bezels Location
if (snesbezelslocation=0) ; set the default
	snesbezelslocation=%A_ScriptDir%\SindenBezels\snes
Gui, main:Add, Edit, x180 y300 w490 h20 vsnesbezelslocation gsnesbezelslocation, %snesbezelslocation%
Gui, main:Add, Button, x680 y300 w100 h20 gsnesbezelslocationBrowse , Browse

gui, main:submit, nohide
Gui, main:Add, Text, x70 y442 w150 h20 , Bezel Preview
Gui, main:add, text, x217 y570 w377 h20 center vsnesbezelMessage, Game bezel not found - Using generic
SplitPath, snesgamelist,,,,snesgamenoext
if !FileExist(snesbezelslocation "\" snesgamenoext ".png")
{ 
	currentBezel = generic
	GuiControl, main:show, snesbezelMessage
}
else
{
	currentBezel = %snesgamenoext%
	GuiControl, main:hide, snesbezelMessage
}
Gui, main:add, picture, x215 y343 w381 h216 vbackgroundsnes, %A_ScriptDir%\lib\1px.png
Gui, main:add, picture, x217 y345 w377 h212 vbezelPreviewsnes, %A_ScriptDir%\SindenBezels\snes\%currentBezel%.png
Gui, main:Add, Button, x680 y440 w100 h20 gChangeBezelsnes vChangeBezelsnes, Change Bezel


; CREDITS TAB----------------------------------------------------------------------------------------------------------------------------------
Gui, main:Tab, 4
gui, main:font, s10
gui, main:font, bold
Gui, main:Add, Text, x40 y40 w800, Credits:
gui, main:font, norm
Gui, main:Add, Link,, Fox: Concept and code. <a href="https://twitter.com/akaJCT">@akaJCT</a>
Gui, main:add, text, , Pete: Code and Bezel design
Gui, main:add, text, , thatman84: Testing
Gui, main:add, text, , Prof_gLX: Code and Bezel Design
Gui, main:add, text, , Javice: Testing and Wiki tutorials
Gui, main:add, text, , Zerelito: Bezel design
Gui, main:Add, Link,, Titchgamer: Bezels and video tutorials. <a href="https://youtube.com/c/AndyJohnsonTRG">Titch's Youtube channel</a>
Gui, main:add, text, ,
Gui, main:Add, Link,, Sinden Software: <a href="https://www.sindenlightgun.com/">Titch's Sinden Technology Ltd.</a>
Gui, main:add, text, ,
Gui, main:Add, Link,, Duckstation: Stenzek. <a href="https://github.com/stenzek/duckstation">Duckstation github.</a>
Gui, main:add, text, ,
Gui, main:Add, Link,, Snes9x: Snes9x Team. <a href="https://www.snes9x.com/">Snes9x.com</a>

Gui, main:font




; add extra tabs before this-----------------------------------------------------------

Gui, main:Show,  Center h600, SindenLauncher
Return

LaunchGoogle:
Run www.google.com
return

; Playstation Buttons   ---------    Playstation Buttons   ---------    Playstation Buttons   ---------    Playstation Buttons   ---------    Playstation Buttons   ---------   

Wizardps1: ;-------  Duckstation wizard  -------  Duckstation wizard  -------  Duckstation wizard  -------  Duckstation wizard  -------  Duckstation wizard  -------  Duckstation wizard  
ps1emulocation := emudownloader(ps1name,latestps1,ps1size,ps1docs)"\duckstation-qt-x64-ReleaseLTCG.exe"
GuiControl, main:, ps1emulocation, %ps1emulocation%
sleep 200
SplitPath, ps1emulocation ,, ps1emufolder
FileAppend, , %ps1emufolder%\portable.txt
FileCopy, %A_scriptdir%\other\ps1\inputprofiles\*.*, %ps1emufolder%\inputprofiles,1
FileCopy, %A_scriptdir%\other\ps1\*.ini, %ps1emufolder% ,1
MsgBox, 8240, Playstation BIOS required, Duckstation requires a Playstation BIOS to run`, for example:`n`nscph5500.bin`nscph5501.bin`nscph5502.bin`n`nThese are not provided with the emulator`, you will need to source them using your own means.`n`nYou need to place then in the BIOS folder.`n`nLet me open the folder for you....
FileCreateDir %ps1emufolder%\bios\
FileAppend, , %ps1emufolder%\bios\place your bios files.txt
run, explorer.exe `"%ps1emufolder%\bios`" 
Gui, main:Submit, NoHide
;SendMessage, 0x1330, 2,, SysTabControl321, WinTitle ; 0x1330 is TCM_SETCURFOCUS.
iniwrite, %ps1emulocation%, sdlauncher.ini, ps1, ps1emulocation

return
;-------  Duckstation wizard END  -------  Duckstation wizard END -------  Duckstation wizard END -------  Duckstation wizard END  -------  Duckstation wizard END -------  Duckstation wizard  END 

Downps1: ;manual download
Gui, Submit, NoHide
MsgBox, 8257, Download from the official github, 1- On the browser window you will find the `"Latest Development Build`"`n`n2- Find where it says `" ▷ Assets`" and click it to expand the file list.`n`n3- Click on `"duckstation-windows-x64-release.zip`" to download the file
IfMsgBox, OK
	run, %ps1manualdownload%
return
Wikips1:
Gui, Submit, NoHide
	run, %ps1wiki%
return

Videops1:
Gui, Submit, NoHide
	run, %ps1video%
return



ps1emulocation:
Gui, main:Submit, NoHide
iniwrite, %ps1emulocation%, sdlauncher.ini, ps1, ps1emulocation
If FileExist(ps1emulocation) &&	 Instr(ps1emulocation, ".exe")
{
	GuiControl, main:Enable, Shortcut
	GuiControl, main:Enable, Play
	GuiControl, main:Enable, ps1configure
}
else
{
	GuiControl, main:Disable, Shortcut
	GuiControl, main:Disable, Play
	GuiControl, main:Disable, ps1configure
}
gosub Save
return
ps1emulocationBrowse: ; Browse for duckstation exe
FileSelectFile, ps1emulocation, S3,duckstation-qt-x64-ReleaseLTCG.exe, Select the emulator executable, duckstation-qt (duckstation-qt-x64-ReleaseLTCG.exe)
if (Errorlevel = 0)
	GuiControl, main:, ps1emulocation, %ps1emulocation%
If FileExist(ps1emulocation) &&	 Instr(ps1emulocation, ".exe")
{
	GuiControl, main:Enable, Shortcut
	GuiControl, main:Enable, Play
}
else
{
	GuiControl, main:Disable, Shortcut
	GuiControl, main:Disable, Play
}
Gui, main:Submit, NoHide
iniwrite, %ps1emulocation%, sdlauncher.ini, ps1, ps1emulocation
gosub Save
return


ps1parameters:
Gui, main:Submit, NoHide
iniwrite, %ps1parameters%, sdlauncher.ini, ps1, ps1parameters
gosub Save
return
ps1parametersDefault: ; Default parameters for Duckstation
GuiControl, main:, ps1parameters, -fullscreen
Gui, main:Submit, NoHide
iniwrite, %ps1parameters%, sdlauncher.ini, ps1, ps1parameters
gosub Save
return


ps1bezelslocation:
Gui, main:Submit, NoHide
iniwrite, %ps1bezelslocation%, sdlauncher.ini, ps1, ps1bezelslocation
gosub Save
return
ps1bezelslocationBrowse: ; Browse for ps1 bezel folder
FileSelectFolder, ps1bezelslocation, *%A_ScriptDir%\SindenBezels\ps1, 3, Select your %ps1systemname% bezel folder
if (Errorlevel = 0)
	GuiControl, main:, ps1bezelslocation, %ps1bezelslocation%
Gui, main:Submit, NoHide
iniwrite, %ps1bezelslocation%, sdlauncher.ini, ps1, ps1bezelslocation
gosub Save
return

ps1hidemouse: ; Default parameters for Duckstation
Gui, main:Submit, NoHide
iniwrite, %ps1hidemouse%, sdlauncher.ini, ps1, ps1hidemouse
gosub Save
return

ps1configure:
run, `"%ps1emulocation%`"
return
 
 
ps1gameslocation:
Gui, main:Submit, NoHide
getFolderFilelistps1(ps1gameslocation,"ps1gamelist")
Gui, main:Submit, NoHide
iniwrite, %ps1gameslocation%, sdlauncher.ini, ps1, ps1gameslocation
if FileExist(ps1emufolder "\settings.ini")
{
	iniwrite, %ps1gameslocation%, %ps1emufolder%\settings.ini, GameList, Paths
}
gosub Save
return
ps1gameslocationBrowser:
FileSelectFolder, ps1gameslocation, *%A_ScriptDir%\games\ps1, 3, Select your %ps1systemname% games folder
if (Errorlevel = 0)
{
	GuiControl, main:, ps1gameslocation, %ps1gameslocation%
	getFolderFilelistps1(ps1gameslocation,"ps1gamelist")
}
Gui, main:Submit, NoHide
iniwrite, %ps1gameslocation%, sdlauncher.ini, ps1, ps1gameslocation
if FileExist(ps1emufolder "\settings.ini")
{
	iniwrite, %ps1gameslocation%, %ps1emufolder%\settings.ini, GameList, Paths
}
gosub Save
return


Playps1:
Gui, main:submit, hide
playingps1 = 1
SplitPath, ps1gamelist,,,,ps1gamenoext
if !FileExist(ps1bezelslocation "\" ps1gamenoext ".png")
	currentBezel = generic
else
	currentBezel = %ps1gamenoext%
run, `"%ps1emulocation%`"  %ps1parameters% `"%ps1gameslocation%\%ps1gamelist%`"  , %ps1emufolder%
Sleep 1000
if(ps1hidemouse=1)
	hidecursor()
sleep 300
IfWinNotExist, frame
{
	SysGet, m1, Monitor, 1
	CustomColor = 000000f  ; Can be any RGB color (it will be made transparent below).
	Gui, 88:+Toolwindow
	Gui, 88:+0x94C80000
	Gui, 88:+E0x20 ; this makes this GUI clickthrough
	Gui, 88:-Toolwindow
	Gui, 88: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, 88: Color, %CustomColor%
	Gui, 88: Add, Picture, x0 y0 w%m1right% h%m1Bottom% BackGroundTrans, %ps1bezelslocation%\%currentBezel%.png
	WinSet, Style, -0xC40000, A
	WinSet, TransColor, %CustomColor% ;150	; Make all pixels of this color transparent and make the text itself translucent (150)
	Gui, 88: Show, x0 y0 w%m1right% h%m1Bottom%, NoActivate, frame ; NoActivate avoids deactivating the currently active window.
	Gui, 88: Show, x0 y0 w%m1right% h%m1Bottom%, NoActivate, frame ; NoActivate avoids deactivating the currently active window.
	WinHide, ahk_class Shell_TrayWnd
	WinHide, ahk_class Shell_SecondaryTrayWnd
}
return

ps1gamelist:
gui, main:submit, nohide
SplitPath, ps1gamelist,,,,ps1gamenoext
if !FileExist(ps1bezelslocation "\" ps1gamenoext ".png")
{
	currentBezel = generic
	GuiControl, main:show, ps1bezelMessage
}
else
{
	currentBezel = %ps1gamenoext%
	GuiControl, main:hide, ps1bezelMessage
}
GuiControl, main:, bezelPreviewps1, %A_ScriptDir%\SindenBezels\ps1\%currentBezel%.png
gosub Save
return

Shortcutps1:
FileSelectFolder, shortcutLocation, *%A_Desktop%, 3, Select a folder to save the game shortcut
SplitPath, ps1gamelist,,,,ps1gamenoext
FileCreateShortcut, %A_ScriptFullPath%, %shortcutLocation%\%ps1gamenoext%.lnk,  "%A_ScriptFullPath%", ps1 "%ps1gameslocation%\%ps1gamelist%", Run %ps1gamenoext% with Sinden Bezels, %A_ScriptDir%\lib\Lightgun_BLACK.ico
run, explorer.exe %shortcutLocation%
return

ChangeBezelps1:
SplitPath, ps1gamelist,,,,ps1gamenoext
Fileselectfile, newBezel, S3, %A_Scriptdir%\SindenBezels\ps1\%ps1gamenoext%.png, Select new bezel file for %ps1gamenoext%, Pictures (*.png)
if (Errorlevel = 0)
{
	if fileexist(ps1bezelslocation "\" ps1gamenoext ".png") ; make a backup of the existing bezel, if any
	{
		FormatTime, timestamp,, yyMMddHHmmss
		if !fileexist(ps1bezelslocation "\backup")
			filecreatedir, %ps1bezelslocation%\backup
		FileCopy, %ps1bezelslocation%\%ps1gamenoext%.png,  %ps1bezelslocation%\backup\backup_%timestamp%_%ps1gamenoext%.png
	}
	FileCopy, %newBezel%, %ps1bezelslocation%\%ps1gamenoext%.png, 1
	currentBezel = %ps1gamenoext%
	GuiControl, main:, bezelPreviewps1, %A_ScriptDir%\SindenBezels\ps1\%currentBezel%.png
	GuiControl, main:hide, bezelMessage

}
else
{ 
return
}
return




; SNES Buttons   ---------    SNES Buttons   ---------    SNES Buttons   ---------    SNES Buttons   ---------    SNES Buttons   ---------   

Wizardsnes: ;-------  SNES wizard  -------  SNES wizard  -------  SNES wizard  -------  SNES wizard  -------  SNES wizard  -------  SNES wizard  
snesemulocation := emudownloader(snesname,latestsnes,snessize,snesdocs)"\SNES9x.exe"
GuiControl, main:, snesemulocation, %snesemulocation%
sleep 200
SplitPath, snesemulocation ,, snesemufolder
FileAppend, , %snesemufolder%\portable.txt
FileCopy, %A_scriptdir%\other\snes\*.*, %snesemufolder%\
Gui, main:Submit, NoHide
;SendMessage, 0x1330, 2,, SysTabControl321, WinTitle ; 0x1330 is TCM_SETCURFOCUS.
iniwrite, %snesemulocation%, sdlauncher.ini, snes, snesemulocation

return
;-------  SNES wizard END  -------  SNES wizard END -------  SNES wizard END -------  SNES wizard END  -------  SNES wizard END -------  SNES wizard  END 

Downsnes: ;manual download
Gui, Submit, NoHide
MsgBox, 8257, Download from the official github, 1- On the browser window you will find the `"Latest release`"`n`n2- Find where it says `" ▷ Assets`" and click it to expand the file list.`n`n3- Click on `"Snes9x.Lightgun.Edition.zip`" to download the file
IfMsgBox, OK
	run, %snesmanualdownload%
return
Wikisnes:
Gui, Submit, NoHide
	run, %sneswiki%
return

Videosnes:
Gui, Submit, NoHide
	run, %snesvideo%
return



snesemulocation:
Gui, main:Submit, NoHide
iniwrite, %snesemulocation%, sdlauncher.ini, snes, snesemulocation
If FileExist(snesemulocation) &&	 Instr(snesemulocation, ".exe")
{
	GuiControl, main:Enable, Shortcut
	GuiControl, main:Enable, Playsnes
	GuiControl, main:Enable, snesconfigure
}
else
{
	GuiControl, main:Disable, Shortcutsnes
	GuiControl, main:Disable, Playsnes
	GuiControl, main:Disable, snesconfigure
}
gosub Save
return
snesemulocationBrowse: ; Browse for duckstation exe
FileSelectFile, snesemulocation, S3,SNES9x.exe, Select the emulator executable, SNEX9x(SNES9x.exe)
if (Errorlevel = 0)
	GuiControl, main:, snesemulocation, %snesemulocation%
If FileExist(snesemulocation) &&	 Instr(snesemulocation, ".exe")
{
	GuiControl, main:Enable, Shortcutsnes
	GuiControl, main:Enable, Playsnes
}
else
{
	GuiControl, main:Disable, Shortcut
	GuiControl, main:Disable, Playsnes
}
Gui, main:Submit, NoHide
iniwrite, %snesemulocation%, sdlauncher.ini, snes, snesemulocation
gosub Save
return


snesparameters:
Gui, main:Submit, NoHide
iniwrite, %snesparameters%, sdlauncher.ini, snes, snesparameters
gosub Save
return
snesparametersDefault: ; Default parameters for Duckstation
GuiControl, main:, snesparameters, -fullscreen -port2 superscope
Gui, main:Submit, NoHide
iniwrite, %snesparameters%, sdlauncher.ini, snes, snesparameters
gosub Save
return


snesbezelslocation:
Gui, main:Submit, NoHide
iniwrite, %snesbezelslocation%, sdlauncher.ini, snes, snesbezelslocation
gosub Save
return
snesbezelslocationBrowse: ; Browse for snes bezel folder
FileSelectFolder, snesbezelslocation, *%A_ScriptDir%\SindenBezels\snes, 3, Select your %snessystemname% bezel folder
if (Errorlevel = 0)
	GuiControl, main:, snesbezelslocation, %snesbezelslocation%
Gui, main:Submit, NoHide
iniwrite, %snesbezelslocation%, sdlauncher.ini, snes, snesbezelslocation
gosub Save
return

sneshidemouse: ; Default parameters for Duckstation
Gui, main:Submit, NoHide
iniwrite, %sneshidemouse%, sdlauncher.ini, snes, sneshidemouse
gosub Save
return

snesconfigure:
run, `"%snesemulocation%`"
return
 
 
snesgameslocation:
Gui, main:Submit, NoHide
getFolderFilelistsnes(snesgameslocation,"snesgamelist")
Gui, main:Submit, NoHide
gosub Save
return
snesgameslocationBrowser:
FileSelectFolder, snesgameslocation, *%A_ScriptDir%\games\snes, 3, Select your %snessystemname% games folder
if (Errorlevel = 0)
{
	GuiControl, main:, snesgameslocation, %snesgameslocation%
	getFolderFilelistsnes(snesgameslocation,"snesgamelist")
}
Gui, main:Submit, NoHide
iniwrite, %snesgameslocation%, sdlauncher.ini, snes, snesgameslocation
gosub Save
return


Playsnes:
Gui, main:submit, hide
playingsnes = 1
SysGet, m1, Monitor, 1
LeftPixel := Floor((m1right - ((m1bottom/7)*8))/2)
RightPixel := Floor(m1right - LeftPixel)
SplitPath, snesgamelist,,,,snesgamenoext
if !FileExist(snesbezelslocation "\" snesgamenoext ".png")
	currentBezel = generic
else
	currentBezel = %snesgamenoext%
run, `"%snesemulocation%`"  %snesparameters% `"%snesgameslocation%\%snesgamelist%`"  , %snesemufolder%
Sleep 1000
if(sneshidemouse=1)
	hidecursor()
sleep 300
IfWinNotExist, frame
{
	SysGet, m1, Monitor, 1
	CustomColor = 000000f  ; Can be any RGB color (it will be made transparent below).
	Gui, 88:+Toolwindow
	Gui, 88:+0x94C80000
	Gui, 88:+E0x20 ; this makes this GUI clickthrough
	Gui, 88:-Toolwindow
	Gui, 88: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, 88: Color, %CustomColor%
	Gui, 88: Add, Picture, x0 y0 w%m1right% h%m1Bottom% BackGroundTrans, %snesbezelslocation%\%currentBezel%.png
	WinSet, Style, -0xC40000, A
	WinSet, TransColor, %CustomColor% ;150	; Make all pixels of this color transparent and make the text itself translucent (150)
	Gui, 88: Show, x0 y0 w%m1right% h%m1Bottom%, NoActivate, frame ; NoActivate avoids deactivating the currently active window.
	Gui, 88: Show, x0 y0 w%m1right% h%m1Bottom%, NoActivate, frame ; NoActivate avoids deactivating the currently active window.
	WinHide, ahk_class Shell_TrayWnd
	WinHide, ahk_class Shell_SecondaryTrayWnd

}
sleep, 300
MouseClick , Left, 1000, 500, 1
return

snesgamelist:
gui, main:submit, nohide
SplitPath, snesgamelist,,,,snesgamenoext
if !FileExist(snesbezelslocation "\" snesgamenoext ".png")
{
	currentBezel = generic
	GuiControl, main:show, snesbezelMessage
}
else
{
	currentBezel = %snesgamenoext%
	GuiControl, main:hide, snesbezelMessage
}
GuiControl, main:, bezelPreviewsnes, %A_ScriptDir%\SindenBezels\snes\%currentBezel%.png
gosub Save
return

Shortcutsnes:
FileSelectFolder, shortcutLocation, *%A_Desktop%, 3, Select a folder to save the game shortcut
SplitPath, snesgamelist,,,,snesgamenoext
FileCreateShortcut, %A_ScriptFullPath%, %shortcutLocation%\%snesgamenoext%.lnk,  "%A_ScriptFullPath%", snes "%snesgameslocation%\%snesgamelist%", Run %snesgamenoext% with Sinden Bezels, %A_ScriptDir%\lib\Lightgun_BLACK.ico
run, explorer.exe %shortcutLocation%
return

ChangeBezelsnes:
SplitPath, snesgamelist,,,,snesgamenoext
Fileselectfile, newBezel, S3, %A_Scriptdir%\SindenBezels\snes\%snesgamenoext%.png, Select new bezel file for %snesgamenoext%, Pictures (*.png)
if (Errorlevel = 0)
{
	if fileexist(snesbezelslocation "\" snesgamenoext ".png") ; make a backup of the existing bezel, if any
	{
		FormatTime, timestamp,, yyMMddHHmmss
		if !fileexist(snesbezelslocation "\backup")
			filecreatedir, %snesbezelslocation%\backup
		FileCopy, %snesbezelslocation%\%snesgamenoext%.png,  %snesbezelslocation%\backup\backup_%timestamp%_%snesgamenoext%.png
	}
	FileCopy, %newBezel%, %snesbezelslocation%\%snesgamenoext%.png, 1
	currentBezel = %snesgamenoext%
	GuiControl, main:, bezelPreviewsnes, %A_ScriptDir%\SindenBezels\snes\%currentBezel%.png
	GuiControl, main:hide, bezelMessage

}
else
{ 
return
}
return




;----------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------------

Save: ;Settings saved tooltip
ToolTip, Settings saved, 640 , 575
GuiControl, main:show, DiskIcon
GuiControl, main:show, DiskIconps1
GuiControl, main:show, DiskIconsnes
SetTimer, RemoveToolTip, -3000
return

UpdateGUI:
gui, main: submit, nohide
If FileExist(p1sindenlocation "\Lightgun.exe")
{
	GuiControl, main:Enable, RUN1
	GuiControl, main:Enable, CONFIG1
	GuiControl, main:Text, Warning , 
}

If !FileExist(p1sindenlocation "\Lightgun.exe")
{
	GuiControl, main:Disable, RUN1
	GuiControl, main:Disable, CONFIG1
	GuiControl, main:Text, Warning , Please configure the correct folder or run the Installation Wizard
}

GuiControl, main:, vp1sindenlocation, %p1sindenlocation%

If FileExist(p2sindenlocation "\Lightgun.exe")
{
	GuiControl, main:Enable, RUN2
	GuiControl, main:Enable, CONFIG2
	GuiControl, main:Text, Warning2 , 
}

If !FileExist(p2sindenlocation "\Lightgun.exe")
{
	GuiControl, main:Disable, RUN2
	GuiControl, main:Disable, CONFIG2
	GuiControl, main:Text, Warning2 , Please configure the correct folder or run the Installation Wizard
}

GuiControl, main:, vp2sindenlocation, %p2sindenlocation%

if (numberofguns=1)
{
	GuiControl, main:hide, SindenIcon2
	GuiControl, main:hide, RUN2
	GuiControl, main:hide, CONFIG2
	GuiControl, main:hide, Warning2
	GuiControl, main:hide, Pathlabel
	GuiControl, main:hide, p2sindenlocation
	GuiControl, main:hide, p2sindenlocationBrowse
	
}

if (numberofguns=2)
{
	GuiControl, main:show, SindenIcon2
	GuiControl, main:show, RUN2
	GuiControl, main:show, CONFIG2
	GuiControl, main:show, Warning2
	GuiControl, main:show, Pathlabel
	GuiControl, main:show, p2sindenlocation
	GuiControl, main:show, p2sindenlocationBrowse
	
}
iniwrite, %p1sindenlocation%, sdlauncher.ini, general, p1sindenlocation
iniwrite, %p2sindenlocation%, sdlauncher.ini, general, p2sindenlocation
iniwrite, %numberofguns%, sdlauncher.ini, general, numberofguns
gosub Save
gui, main: submit, NoHide
;gui, main: destroy
;gosub, ShowUI
return


;General Buttons   ---------   General Buttons   ---------   General Buttons   ---------   General Buttons   ---------   General Buttons   ---------   

mainbuttonInstallationWizard:
MsgBox, 8257, Sinden drivers installation wizard, This wizard will guide you through the steps to download the latest Windows software, drivers (if required) and the initial set up steps.
IfMsgBox, OK
	gosub, driverwizard
return
Down1:
MsgBox, 8257, Download from the official page, Download the latest drivers package from the official page.
IfMsgBox, OK
	run, %latestsoftware% ;we need a static link that goes to the latest version
return

mainbuttonVisualguide-Wiki:
Gui,main:Submit, NoHide
	run, https://sindenlightgun.miraheze.org/wiki/Visual_Setup_Guide
return

Video1:
Gui,main:Submit, NoHide
	run, https://www.youtube.com/watch?v=RfUJHUjqXC8
return

p1sindenlocation:
gui, main:Submit, NoHide
iniwrite, %p1sindenlocation%, sdlauncher.ini, general, p1sindenlocation
gosub UpdateGUI
return
p1sindenlocationBrowse: ; Browse for SindenLightgun folder P1
FileSelectFolder, p1sindenlocation, *%A_ScriptDir%\tools\SindenLightgun1, 3, Select your Sinden Software folder for Player 1 gun
if (Errorlevel = 0)
	GuiControl, main:, p1sindenlocation, %p1sindenlocation%
gosub UpdateGUI
return

CONFIG1: ;Run from folder P1
If FileExist(p1sindenlocation "\Lightgun.exe")
	run, %p1sindenlocation%\Lightgun.exe , %p1sindenlocation%
else
	MsgBox, 48, Sinden Software not found, Can't find the Sinden Software in the selected path. Please double check the folder.
return

RUN1: ;Run autostart from folder P1
runError = 0
If FileExist(p1sindenlocation "\Lightgun.exe.config")
{
	
	licenseLine := isLicenseAccepted(p1sindenlocation "\Lightgun.exe.config")
	If (licenseLine=0) ;if license has been accepted
	{
		run, %p1sindenlocation%\Lightgun.exe -autostart , %p1sindenlocation%
		return
	}
	If (licenseLine>0)
	{
		MsgBox, 52, Running software before configuration, It looks like you are trying to run the Sinden Software without having configured it.`n`nThis will most likely prevent the lightgun from working properly. It's strongly suggested that you use the Configure option first and you follow the Wiki guide.`n`nAre you sure that you want to continue?
		IfMsgBox, No
			return
		
		MsgBox, 8244, Please accept the licensing and term conditions:, This software is fully owned by Sinden Technology Ltd.`nThis software may only be distributed by Sinden Technology Ltd.`nYou have no rights to copy or distribute this software.`nThis software may only be used in combination with Sinden Technology hardware.`nYou have no rights to modify this software.`nYou have no rights to decompile this software.`nYou have no rights to use any part of this software in another application.`nYou may only use this software for personal use on your own computer.`nYou may not use any copy of this software unless it was distributed by Sinden Technology Ltd.`nYou may only use this software for the purposes that it was intended.`nAll aspects of this software are copyrighted.
		IfMsgBox, No
		{
			runError+=1
			return	
		}
		IfMsgBox, Yes
		{
			Loop, Read, %p1sindenlocation%\Lightgun.exe.config
			{

				if (a_index!=licenseLine)
				{
					FileAppend, %A_LoopReadLine%`r`n, %A_scriptdir%\temp\temp.config
				}
				else
				{
					
					StringReplace, EditReadLine, A_LoopReadline, 0, 1
					FileAppend, %EditReadLine%`r`n, %A_scriptdir%\temp\temp.config
				}
			
			}
			FileCopy, %a_scriptdir%\temp\temp.config, %p1sindenlocation%\Lightgun.exe.config, 1
			sleep 500
			FileDelete, %a_scriptdir%\temp\temp.config
			run, %p1sindenlocation%\Lightgun.exe -autostart , %p1sindenlocation%
			return	
		}
	}

}
else
	runError:=runError+2
	
Switch (runError)
{
Case 1: MsgBox, 16, Can't run Sinden Software, You need to accept the license to use this software
Case 2: MsgBox, 16, Can't find Sinden Software, Can't find the Sinden Software in the selected path. Please double check the folder.
}

return

p2sindenlocation:
gui, main:Submit, NoHide
iniwrite, %p2sindenlocation%, sdlauncher.ini, general, p2sindenlocation
gosub UpdateGUI
return
p2sindenlocationBrowse: ; Browse for SindenLightgun folder P2
FileSelectFolder, p2sindenlocation, *%A_ScriptDir%\tools\SindenLightgun2, 3, Select your Sinden Software folder for Player 2 gun
if (Errorlevel = 0)
	GuiControl, main:, p2sindenlocation, %p2sindenlocation%
gosub UpdateGUI
return

CONFIG2: ;Run from folder P2
If FileExist(p2sindenlocation "\Lightgun.exe")
	run, %p2sindenlocation%\Lightgun.exe , %p2sindenlocation%
else
	MsgBox, 48, Sinden Software not found, Can't find the Sinden Software in the selected path. Please double check the folder.
return

RUN2: ;Run autostart from folder P2
runError = 0
If FileExist(p2sindenlocation "\Lightgun.exe.config")
{
	
	licenseLine := isLicenseAccepted(p2sindenlocation "\Lightgun.exe.config")
	If (licenseLine=0) ;if license has been accepted
	{
		run, %p2sindenlocation%\Lightgun.exe -autostart , %p1sindenlocation%
		return
	}
	If (licenseLine>0)
	{
		MsgBox, 52, Running software before configuration, It looks like you are trying to run the Sinden Software without having configured it.`n`nThis will most likely prevent the lightgun from working properly. It's strongly suggested that you use the Configure option first and you follow the Wiki guide.`n`nAre you sure that you want to continue?
			IfMsgBox, No
			return
			
		MsgBox, 8244, Please accept the licensing and term conditions:, This software is fully owned by Sinden Technology Ltd.`nThis software may only be distributed by Sinden Technology Ltd.`nYou have no rights to copy or distribute this software.`nThis software may only be used in combination with Sinden Technology hardware.`nYou have no rights to modify this software.`nYou have no rights to decompile this software.`nYou have no rights to use any part of this software in another application.`nYou may only use this software for personal use on your own computer.`nYou may not use any copy of this software unless it was distributed by Sinden Technology Ltd.`nYou may only use this software for the purposes that it was intended.`nAll aspects of this software are copyrighted.
		IfMsgBox, No
		{
			runError+=1
			return	
		}
		IfMsgBox, Yes
		{
			Loop, Read, %p2sindenlocation%\Lightgun.exe.config
			{

				if (a_index!=licenseLine)
				{
					FileAppend, %A_LoopReadLine%`r`n, %A_scriptdir%\temp\temp.config
				}
				else
				{
					
					StringReplace, EditReadLine, A_LoopReadline, 0, 1
					FileAppend, %EditReadLine%`r`n, %A_scriptdir%\temp\temp.config
				}
			
			}
			FileCopy, %a_scriptdir%\temp\temp.config, %p2sindenlocation%\Lightgun.exe.config, 1
			sleep 500
			FileDelete, %a_scriptdir%\temp\temp.config
			run, %p2sindenlocation%\Lightgun.exe -autostart , %p1sindenlocation%
			return	
		}
	}

}
else
	runError:=runError+2
	
Switch (runError)
{
Case 1: MsgBox, 16, Can't run Sinden Software, You need to accept the license to use this software
Case 2: MsgBox, 16, Can't find Sinden Software, Can't find the Sinden Software in the selected path. Please double check the folder.
}



S1: ; Save main config button

return




;Sinden Software Wizard   ---------   Sinden Software Wizard   ---------   Sinden Software Wizard   ---------   Sinden Software Wizard   ---------   Sinden Software Wizard   ---------   
driverwizard: ;this is a small helper to download the drivers and put the windows folder somewhere

SplitPath,latestsoftware,fileName
filenamepath = %a_scriptdir%\temp\%filename%
totalFilesize = %softwaresize%
desiredMD5Hash = %softwarehash%

; download the latest driver based on the filename we assigned above
if !(FileExist(filenamepath)) {
	MsgBox,65,Downloading Sinden Software, Press OK to download`n -- %fileName% --`n from the Sinden website.

	IfMsgBox, OK
	{
		If ConnectedToInternet() {
			msg := "Please wait while download is in progress"
			; Show splash bar
			Progress, 0 FM10 FS8 WM400 WS400 ,`n,%msg%, Downloading %fileName%, Tahoma
			; Now set the splash bar updating
			SetTimer, uProgress, 250
			; start the download
			UrlDownloadToFile, %latestsoftware%, %filenamepath%
			; download Finished turn off splashbar
			SetTimer, uProgress, off
			Progress, Off
		} else {
		   Msgbox, 48, Error, Your Internet seems to be down.`nI can't download %fileName%.
		}
	} 
	IfMsgBox, Cancel
	{
		return
	}

}


	msg := "Please wait while extraction is in progress"
	; Show splash bar
	Progress, 0 FM10 FS8 WM400 WS400 ,`n,%msg%, Extracting %fileName%, Tahoma
	; Now set the splash bar updating
		SetTimer, uProgress2, 250
	; extract the software folder
	run, `"%a_scriptdir%\lib\7z.exe`" e -y `"%filenamepath%`" SindenLightgunSoftwareReleaseV1.05b\SindenLightgunWindowsSoftwareV1.05\SindenLightgun\*.* -o`"%A_ScriptDir%\temp\SindenLightgun\`", `"%A_ScriptDir%\lib`"
	; download Finished turn off splashbar
	SetTimer, uProgress2, off
	Progress, Off
    	
	If !InStr(A_OSVersion,10)
	{
		run, `"%a_scriptdir%\lib\7z.exe`" e -y `"%filenamepath%`" SindenLightgunSoftwareReleaseV1.05b\SindenLightgunWindowsSoftwareV1.05\WindowsDrivers\*.* -o`"%A_ScriptDir%\tools\WindowsDrivers\`", `"%A_ScriptDir%\lib`" , Hide
		run, explorer.exe `"%A_ScriptDir%\tools\WindowsDrivers\`"
		MsgBox, 8260, Windows 7  Drivers, Follow the instructions in the Wiki to install the drivers for Windows 7 & 8.`n`nDo you want to check the Wiki now?
			IfMsgBox, Yes
				run, https://sindenlightgun.miraheze.org/wiki/Visual_Setup_Guide#Driver_Installation

	}
	; check if we need one or two copies of the software
	MsgBox, 8228, Number of Sinden Guns, Software extraction has finished.`nDo you have TWO Sinden Lightguns?
	
	IfMsgBox, Yes
	{
		numberofguns = 2
		FileCreateDir, %A_ScriptDir%\tools\SindenLightgun1\
		FileCopy, %A_ScriptDir%\temp\SindenLightgun\*.*, %A_ScriptDir%\tools\SindenLightgun1\*.*, 1
		FileCreateDir, %A_ScriptDir%\tools\SindenLightgun2\
		FileCopy, %A_ScriptDir%\temp\SindenLightgun\*.*, %A_ScriptDir%\tools\SindenLightgun2\*.*, 1
		iniwrite, %numberofguns%, sdlauncher.ini, general, numberofguns
		guicontrol, main:choose , numberofguns, 2
		gui, main: submit, NoHide
		gosub, UpdateGUI
		sleep 300
	}
	else
	{
		FileCreateDir, %A_ScriptDir%\tools\SindenLightgun1\
		FileCopy, %A_ScriptDir%\temp\SindenLightgun\*.*, %A_ScriptDir%\tools\SindenLightgun1\*.*, 1
		guicontrol, main:choose , numberofguns, 1
		gui, main: submit, NoHide
		gosub, UpdateGUI
	}
	
	MsgBox, 8256, Installation Complete, The Sinden software has been installed. Don't forget to check the Wiki to learn how to use it.
		
Return

;Progress Bars   ---------   Progress Bars   ---------   Progress Bars   ---------   Progress Bars   ---------   Progress Bars   ---------   Progress Bars   ---------   

uProgress:
	; get filesize
	FileGetSize, fs, %filenamepath%
	; calculate percent
	a := Floor(fs/totalFileSize * 100)
	; calculate percent with two 
	b := Floor(fs/totalFileSize * 10000)/100
	SetFormat, float, 0.2
	b += 0
	Progress, %a%, %b%`% done (%fs% Bytes of %totalFileSize% Bytes)
return

uProgress2:
	a += 20
	if (a > 100)
	{
		Sleep, 500
		a = 0
		
	}
	Progress, %a%, Extracting
return





; Functions   ---------   Functions   ---------   Functions   ---------   Functions   ---------   Functions   ---------   Functions   ---------   Functions   ---------   

isLicenseAccepted(FilePath) ;isLicenseAccepted(c:\Lightgun.exe.config)
{
	check =  "chkLicense" value="0"
    Loop, Read, %FilePath%
    {
        foundPos := Instr(A_LoopReadLine, check)
		if (foundPos > 0)
		{
			return %a_index%
		}
    }
    return 0
}

getFolderFilelistps1(FolderPath,guiVariable)
{

	List = 
	loop, Files, % FolderPath "\*.*"
		{
			SplitPath, A_LoopFileName, Filename,,FileExtension
			if(system=ps1)
			{
				if(FileExtension="CUE" or FileExtension="CHD")
					List .= FileName "|"
			}

		}
	List := RTrim(List, "|")
	List := StrReplace(List, "|", "||",, 1) ; make first item default
	GuiControl,main:, %guiVariable%, |
	GuiControl,main:, %guiVariable%, %List%
	SplitPath, ps1gamelist,,,,ps1gamenoext

}

getFolderFilelistsnes(FolderPath,guiVariable)
{

	List = 
	loop, Files, % FolderPath "\*.*"
		{
			SplitPath, A_LoopFileName, Filename,,FileExtension
			if(FileExtension="zip" or FileExtension="bin" or FileExtension="smc" or FileExtension="sfc")
				List .= FileName "|"
		}
	List := RTrim(List, "|")
	List := StrReplace(List, "|", "||",, 1) ; make first item default
	GuiControl,main:, %guiVariable%, |
	GuiControl,main:, %guiVariable%, %List%
	SplitPath, snesgamelist,,,,snesgamenoext

}


mainGuiClose:
FileRemoveDir, %A_ScriptDir%\temp, 1
;[general]

iniWrite, %numberofguns%, sdlauncher.ini, general, numberofguns
iniWrite, %p1sindenlocation%, sdlauncher.ini, general, p1sindenlocation
iniWrite, %p2sindenlocation%, sdlauncher.ini, general, p2sindenlocation

;[ps1]
iniWrite, %ps1emulocation%, sdlauncher.ini, ps1, ps1emulocation
iniWrite, %ps1parameters%, sdlauncher.ini, ps1, ps1parameters
iniWrite, %ps1bezelslocation%, sdlauncher.ini, ps1, ps1bezelsLocation
iniWrite, %ps1gameslocation%, sdlauncher.ini, ps1, ps1gameslocation
iniWrite, %ps1hidemouse%, sdlauncher.ini, ps1, ps1hidemouse


;[snes]
IniWrite, %snesemulocation%, sdlauncher.ini, snes, snesemulocation
IniWrite, %snesparameters%, sdlauncher.ini, snes, snesparameters
IniWrite, %snesbezelslocation%, sdlauncher.ini, snes, snesbezelsLocation
IniWrite, %snesgameslocation%, sdlauncher.ini, snes, snesgameslocation
IniWrite, %sneshidemouse%, sdlauncher.ini, snes, sneshidemouse


if FileExist(ps1emufolder "\settings.ini")
{
	iniwrite, %ps1gameslocation%, %ps1emufolder%\settings.ini, GameList, Paths
}

ExitApp

RemoveToolTip:
ToolTip
GuiControl, main:Hide, DiskIcon
GuiControl, main:hide, DiskIconps1
GuiControl, main:hide, DiskIconsnes
return


 ^!+n:: ; this is a debug feature, cleans up the environment back to initial installation status
FileRemoveDir, %A_ScriptDir%\temp\, 1
FileRemoveDir, %A_ScriptDir%\tools\SindenLightgun1\, 1
FileRemoveDir, %A_ScriptDir%\tools\SindenLightgun2\, 1
FileRemoveDir, %A_ScriptDir%\emulators\, 1
Filedelete, %A_ScriptDir%\sdlauncher.ini
Reload
return


#If (playingps1)
$Esc::
showcursor()
Process,Close,Duckstation PS1 Emulator
Run,taskkill /im "duckstation-qt-x64-ReleaseLTCG.exe" /F
WinShow, ahk_class Shell_TrayWnd
WinShow, ahk_class Shell_SecondaryTrayWnd
gui, 88:destroy
playingps1 = 0
if (numParams = 0)
	gui, main: show
else
	ExitApp
#If

#If (playingsnes)
$Esc::
showcursor()
Process,Close,SNES9x
Run,taskkill /im "snes9x.exe" /F
WinShow, ahk_class Shell_TrayWnd
WinShow, ahk_class Shell_SecondaryTrayWnd
gui, 88:destroy
playingsnes = 0
Run,taskkill /im "snes9x.exe" /F
if (numParams = 0)
	gui, main: show
else
	ExitApp
#If

return