CRTGeomMOD 3.2 by Ducon2016 and Houb
Special version with launcher and auto settings for Demul (2020-04-25) by Houb


This "ready to use" config pack should give you a nice CRT effect and many enhanced features for Demul display.


How to install :
- First remove all the previous Reshade files including our full previous config files and presets (don't keep any old presets, dll, ini files nor launchers)
- Extract the full archive in your Demul's folder just next to your original "demul.exe" (original exe should be named demul.exe).
- Start the emulator exclusively with the launcher included (just click on it...)


How to use :
- You can use Demul as always but to get the effect you need to start the emu using the launcher included.
- You can still use Demul in command line : just send usual commands to the launcher directly and not to demul.exe anymore.
- You can set your emulator to any configuration (high resolution monitor will be requiered and so probably a good graphic card also...)
- Use "home" key to get the ReSahde's UI option ingame. You can check CRT-effect, dot mask, bloom, bezel, background, overlay, frame, manual rotation, aspect ratio correction, crop... (your settings will be saved for the current game)
- The best setting is with gpuDX11(new) plugin (works better than the old one) btw both are working (DX11old plug may crash the emu with ReShade when closing a game and CV1000 games won't look nice with this old plugin).
So by defaut gpuDX11(new) is somehow forced excepting when you launch a Gaelco game in commandline (the Demul ratio is also nearly broken with these games in 4/3 so you may have to use the "ratio resize adjustement" slider in the Reshade's UI with Gaelco games in 4/3).
- If fullscreen is set in Demul's config the games will be launched in fullscreen (all of them, even the ones who usually don't)
- If Stretch/4:3/16:9/AutoRotate or even RotationAngles are set in Demul's config the games will be launched according to your settings and hopefully most of the shader settings should follow at best.


FAQ :
Help, Demul now crashes when I launch a game!!
=> Try to increase SleepTime value (ms) in "\reshade-shaders\ReShade.ini" (default is 2000)


Help!! It's slow as hell...
=> A good computer is needed but you can try to disable bloom/frame/overlay in presets and also remove the these unused images in "reshade-shaders\textures" and "reshade-shaders" folders...
Also try to increase SleepTime value (ms) in "\reshade-shaders\ReShade.ini" (default is 2000)


Demul crashes when I quit my game!! / The shader effect works only the first time I launch a game but not for the next ones...
=> It seams to be an issue with ReShade dlls and Demul. Again gpuDX11(new) appears to have less issues but if not Quit and Relaunch Demul when it happens...


I just get nothing at all! A true shit: it doesn't work!!
=> Launch Demul "only using the launcher". It won't work if you launch Demul.exe directly.


I don't have CRT effect with Hikaru games
=> Yes it's disabled by default because the render is done only in 640x480 and unfortunately it's too low to get a good result.
But if you want to make a try with the effect just set "CRT_EFFECT=1" in presets (hikaru.ini and romname.ini) or check the same option ingame in Reshade's UI (home key).


I put the new config over my old one and now it doesn't work!
=> As said above, you need to do a clean new install. Don't keep any old presets from the previous version of the shader!


The effect is not pixel perfect, can I get better results??
=> Yes you can try to change the texture size and offsets. By defaut it's set to 320x240 but for some games it's not perfect. Try different values, offsets... (the setting made will be saved for the current game preset)
Also use "overscan" option in ReShade's UI to get your game display fullscreen and remove black bars in some games

Aspect ratio is not perfect with Gaelco games in fullscreen when set to 4:3!!
=>Yes and it's really worst without the shader! (Demul issue)
Try to use the "resize ratio adjustement" slider to match the game display (the value is unknow because it changes with your desktop resolution...)


I read the text above but I stil want to use gpuDX11old and the option is always reseted to gpuDX11(new) at start!!
=> Yes because unfortunately there is still some issues with this plugin so gpuDX11(new) is somehow forced at start (excepting for Gaelco games when launched in command line).
I you want really want gpudDX11old at start you can by editing AllowOld to "1" in "\reshade-shaders\ReSahde.ini" and it won't be reseted anymore next times


The render in not very good when using gpuDX11old. Any hope to get better results??
=> To get a good result with gpuDX11old for DC, Naomi, Atomiswave and Gaelco games in fullscreen you need "at least" internal resolution set to 2x (would be even better with 3x or more)
PS : High internal resolution scale coef will degrade performances (it won't work with CV1000 and Hikaru games because they will be still rendered in x1 unfortunately).


How to change the art files??
=> Just check the "\reshade-shader\Textures\" folder and you will understand quickly I think ;)
if "romname.png" exist it will be used as background, if not "sysname.png" will be used (or "sysname_v.png" for rotated games)
if "romname_bezel.png" exist it will be used as bezel, if not "sysname_bezel.png" will be used
if "romname_off.png" exist it will be used as bezel, if not "sysname_off.png" will be used
(if even sysname images are not found the arts in "\reshade-shader\" will be used instead)
These images should be sized in 16:9 ratio to work correctly


How to use with a FrontEnd??
=> just set your frontend to the launcher's exe using the very same commands than before (usual ones) but send them to the launcher directly!
Some examples :
-Naomi games:   Demul07_CRTGeomMOD.exe -run=naomi -rom=mvsc2
-Atomiswave games:   Demul07_CRTGeomMOD.exe -run=awave -rom=mslug6
-CV1000 games:   Demul07_CRTGeomMOD.exe -run=cave3rd -rom=akatana
-Gaelco games:   Demul07_CRTGeomMOD.exe -run=gaelco -rom=smashdrv
-Hikaru games:   Demul07_CRTGeomMOD.exe -run=hikaru -rom=swracer
-Dreamcast games:   Demul07_CRTGeomMOD.exe -run=dc -image="D:\DC Games\King of Fighters Evolution (NTSC-J).cdi"


When used with RocketLauncher I can't get fullscreen with CV1000, Gaelco and Hikaru : it goes back immediately to windowed  :(
=> Yes the launcher included send Alt+Enter for these systems when Demul is set to start in fullscreen because Demul doesn't. But it seems like RocketLauncher does the same so it's sent 2 times :D
In this case set "NoFullScreenFix" to "1" in "\reshade-shaders\ReShade.ini"


Info / Support :
http://www.emuline.org/topic/1420-shader-crt-multifonction-kick-ass-looking-games/


Credits :
-"Alex DC22" for most of the bezel arts used for Naomi and Atomiswave
-"AshuraX for most of the the bezel arts used for CV1000
-"Fire10" for its testings