#Requires AutoHotkey v2.0

#Include GuiState.ahk 
iniFile := "Settings.ini"

; ----- GUI ------

myGui := Gui()
myGUi.Title := "GuiState"

MyGui.OnEvent("Close", Gui_Close)

; ----- Presets Save/Load/Delete ------
; by buttons, you could have only one and save/load that automatically

myGui.Add("Text", "w100", "Select Preset:")
Items := ["NEW"]
Sections := ""
try 
    Sections := StrSplit(IniRead("settings.ini"), "`n")
if (Sections){
for item in Sections 
    Items.Push(StrSplit(item, "-")[2])    
}

ddlPresets := myGui.Add("DropDownList", "ys w100", items)
ddlPresets.OnEvent("Change", LoadPreset)

btnDelete := myGui.Add("Button", "xs w100", "Delete Preset")
btnDelete.OnEvent("Click", DeletePreset)

btnSave := myGui.Add("Button", "x+m w100", "Save Preset")
btnSave.OnEvent("Click", SavePreset)


ddlPresets.Choose(1)    ; Select NEW preset

myGui.Add("Text", "xm h1 w300 0x10")

; ===== SAMPLE GUI CONTROLS =====


; ----- EDIT ------
myGui.Add("Text", "xm", "Enter Name:")
txtName := myGui.Add("Edit", "x+m w200 vName")

; ----- CHECKBOX ------
chkRemember := myGui.Add("Checkbox", "xm vRemember", "Remember Me")

; ----- RADIO ------
myGui.Add("Text", "xm", "Select Gender:")
radioMale := myGui.Add("Radio", "xm vGender", "Male")
radioFemale := myGui.Add("Radio", "x+m vFemale", "Female")

myGui.Add("Text", "xm", "Choose Option:")

; ----- DROPDOWN ------
ddlOptions := myGui.Add("DropDownList", "xm vOptions", ["Option 1", "Option 2", "Option 3"])

; ----- LISTBOX ------
myGui.Add("Text", "xm", "Select Items:")
lstItems := myGui.Add("ListBox", "xm w200 h80 vItems", ["Item 1", "Item 2", "Item 3", "Item 4"])

btnClose := myGui.Add("Button", "xm", "Close")
btnClose.OnEvent("Click", Gui_Close)

myGui.Show

; ===== FUNCTIONS =====

Gui_Close(*){
    if (ddlPresets.text != "NEW")   ;/===== SAVE/LOAD/DELETE =====
        SavePreset()                  
    ExitApp()
}

SavePreset(*) {
    preset := ddlPresets.Text
    if (preset = "NEW") {
        preset := InputBox("Enter new preset name:", "New Preset").value
        if (!preset) 
            return

        Items := ControlGetItems(ddlPresets)

        if (HasVal(Items,preset)) {
            MsgBox "Preset already exists!"
            return
        }

        Items.Push(preset)
        ddlPresets.Delete
        ddlPresets.Add(Items)
        ddlPresets.Choose(Items.Length) ; Select new preset
    }

    GuiSaveState(myGui.Title, iniFile, preset)
}

LoadPreset(*) {
    preset := ddlPresets.Text
    if (preset != "NEW") 
        GuiLoadState(myGui.Title, iniFile, preset)
    ; else
        ;GuiResetState(myGui.Title)
}

DeletePreset(*) {
    preset := ddlPresets.Text
    if (preset = "NEW") {
        return
    }
    GuiDeleteState(myGui.Title, iniFile preset)
 
    previous:= ddlPresets.Value
    ddlPresets.Delete(ddlPresets.Value)
    if (previous>1)
        ddlPresets.Choose(previous-1)
    else
        ddlPresets.Choose(1)
}

;;;; Automatically assign names if they don't have one
;
; AssignControlNames(*) {
;     index := 1
;     for ctrl in myGUI {
;         if (ctrl.name = "") 
;;;	  	if (ctrl.type = "CheckBox") || (ctrl.type = "Edit") { 		; etc...
;             		ctrl.Name := ctrl.type "_" index "_" StrReplace(ctrl.Text," ","-") ; Fallback if no text is present
;         		index++
;;;		}
;     }
; }