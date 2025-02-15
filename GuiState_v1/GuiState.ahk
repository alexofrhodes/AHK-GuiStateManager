;====================================================================
; GuiSaveState and GuiLoadState functions
; NOTE: only controls with vnames are handled
;
; Programmer: Alan Lilly 
; AutoHotkey: v1.1.03.00 (autohotkey_L ANSI version)
; https://www.autohotkey.com/board/topic/71205-functions-to-save-and-restore-gui-controlsfields/
;====================================================================
; 1. When this ahk program is compiled into an exe, fileinstall indicates which files should be embedded inside the exe.
; 2. When the program is run, fileinstall extracts the embedded file to the specified folder.
;============================================================
; Modified by Anastasiou Alex
; https://github.com/alexofrhodes
;
; #include this script
; use simplified functions 
; - GuiSaveState     
; - GuiLoadState  
;====================================================================

VERSION := 1.0

; dont use splitpath to get basename because it cant handle DeltaRush.1.3.exe
RegExMatch(A_ScriptName, "^(.*?)\.", basename)    
global WINTITLE := basename1 " " VERSION

#SingleInstance force  
#NoENV              ; Avoids checking empty variables to see if they are environment variables (recommended for all new scripts and increases performance).
SetBatchLines -1    ; have the script run at maximum speed and never sleep
ListLines Off       ; a debugging option


; if Not InStr(FileExist(A_AppData "\" basename1), "D")    ; create appdata folder if doesnt exist
;     FileCreateDir , % A_AppData "\" basename1

;============================================================
; save all gui control values for active gui to ini file
;============================================================
GuiSaveState(guiName="",inifile="", Preset=1, begin="",end="")   ;section = guiName
{
    Gui, %guiName%:Submit, NoHide      ; update control variables
    if (inifile=""){
        SplitPath, inifile, file, path, ext, base, drive     ; splitpath expects paths with \
        if (path = "") {   ; if no path given then use default path
            ; dont use splitpath to get basename because it cant handle DeltaRush.1.3.exe
            RegExMatch(A_ScriptName, "^(.*?)\.", basename)    
            ; inifile := A_AppData "\" basename1 "\" inifile
            inifile := A_ScriptDir "\" basename1 ".ini"
        }
    }
    if (guiName = "")
        return
    WinGet, List_controls, ControlList, %guiName% ;A    ; get list of all controls active gui
    if (begin = "")
        flag := 0
    else 
        flag := 1      
    Loop, Parse, List_controls, `n
    { 
        ;ControlGet, cid, hWnd,, %A_LoopField%        ; get the id of current control
        GuiControlGet, textvalue,,%A_Loopfield%,Text  ; get associated text
        GuiControlGet, vname, Name, %A_Loopfield%     ; get controls vname   
        If (vname = "")   ; only save controls which have a vname 
            continue
        if (begin = vname) {
            flag := 0
            continue
        }           
        if (flag) 
            continue           
        if (end = vname) 
            break           
        GuiControlGet, value ,, %A_Loopfield%   ; get controls value
        ; convert newlines to pipes (for multiline edit fields, because newlines are not valid for ini file)   
        value := RegExReplace(value, "`n", "|")          
        ; TODO  truncate edit values to not exceed ini fieldsize limit (1024?)  OR blank (all or nothing)
        IniWrite, % value, %inifile%, %guiName%-%Preset%, %vname%
    }    
    WinGet, winstate, MinMax, %guiName%
    ; do not save window position if minimized, winx and winy would be something like -32000
    if (winstate != -1) {      
        ; save window dimensions, location, and column widths!    
        WinGetPos , winx, winy, Width, Height, %guiName%
        IniWrite, %winx%,  %inifile%, %guiName%-%Preset%, winx
        IniWrite, %winy%,  %inifile%, %guiName%-%Preset%, winy
    }
}


;============================================================
; Update gui controls with values from ini file.
;============================================================
GuiLoadState(guiName="",inifile="", Preset=1)   
{
    SplitPath, inifile, file, path, ext, base, drive     ; splitpath expects paths with \  
    ; if no path given then use default path
    if (inifile = "") {   
        ; dont use splitpath to get basename because it cant handle DeltaRush.1.3.exe
        RegExMatch(A_ScriptName, "^(.*?)\.", basename)    
        ; inifile := A_AppData "\" basename1 "\" inifile
        inifile := A_ScriptDir "\" basename1 ".ini"
    }
    if (guiName = "")
        return
    WinGet, List_controls, ControlList, %guiName% 
    Loop, Parse, List_controls, `n
    { 
        ;ControlGet, cid, hWnd,, %A_LoopField%         ; get the id of current control
        ;GuiControlGet, textvalue,,%A_Loopfield%,Text  ; get controls associated text
        GuiControlGet, vname, Name, %A_Loopfield%     ; get controls vname
        ;GuiControlGet, value ,, %A_Loopfield%         ; get controls value      
        If (vname = "")   ; only process controls which have a vname 
            continue    
        IniRead, value, %inifile%, %guiName%-%Preset%, %vname%, ERROR
        if (value != "ERROR") {
            ; convert pipes to newlines (for multiline edit fields, because newlines are not valid for ini file)      
            value := RegExReplace(value, "\|", "`n")    
            ; dont use splitpath to get basename because it cant handle DeltaRush.1.3.exe 
            RegExMatch( A_Loopfield, "(.*?)\d+", name)   
            if (name1 = "ComboBox") || (name1 = "ListBox"){
                GuiControl, ChooseString, %A_Loopfield%, %value%   ; select item in dropdownlist
            } else {
                GuiControl,  ,%A_Loopfield%, %value%    ; update the control
            }
        }
    }

    IniRead, winx,  %inifile%, %guiName%-%Preset%, winx, 0
    IniRead, winy,  %inifile%, %guiName%-%Preset%, winy, 0
    ; get the width and height of the entire desktop (even if it spans multiple monitors)
    SysGet, VirtualWidth, 78
    SysGet, VirtualHeight, 79
    ; prevent display of gui off-screen (somehow this was still happening to jess, so I added this logic)
    if (winx < 0) OR (winx > VirtualWidth) 
        winx := 0
    if (winy < 0) OR (winy > VirtualHeight)     
        winy := 0  
    
    Gui, Show,x%winx% y%winy%,%guiName%
}

