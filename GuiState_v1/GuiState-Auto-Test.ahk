#SingleInstance force  
#NoEnv              
SetBatchLines -1    
ListLines Off       

#Include, GuiState.ahk

guiName := "GuiState"

Gui, +HwndhGui
Gui, Add, Text, xm, Enter Name:
Gui, Add, Edit, x+m w200 vName

Gui, Add, Checkbox, xm vRemember, Remember Me

Gui, Add, Text, xm, Select Gender:
Gui, Add, Radio, xm vGender, Male
Gui, Add, Radio, x+m vFemale, Female

Gui, Add, Text, xm, Choose Option:
Gui, Add, DropDownList, xm vOptions, Option 1||Option 2|Option 3

Gui, Add, Text, xm, Select Items:
Gui, Add, ListBox, xm w200 h80 vItems, Item 1|Item 2|Item 3|Item 4

Gui, Add, Button, xm gGuiClose, Close

Gui, Show,, %guiName%

GuiLoadState(guiName, "settings.ini")

return

GuiEscape:
GuiClose:
    GuiSaveState(guiName, "settings.ini")
    ExitApp
return
