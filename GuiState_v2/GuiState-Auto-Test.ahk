#Requires AutoHotkey v2.0

#Include GuiState.ahk 

; ===== SAMPLE GUI CONTROLS =====

myGui := Gui()

MyGui.OnEvent("Close", Gui_Close)

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

global guiManager := GuiState(myGui, "GuiState.ini", 1)
myGui.Show("AutoSize x5000 w5000")

guiManager.LoadState()

; ===== FUNCTIONS =====

Gui_Close(*){
    guimanager.SaveState()                
    ExitApp()
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