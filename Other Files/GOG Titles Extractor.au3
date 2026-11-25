#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli

 Script Function:   Extract GOG game titles from web page JSON data
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <File.au3>
#include <GuiListBox.au3>
#include <Array.au3>
#include <EditConstants.au3>

_Singleton("gog-titles-extractor-timboli")

; FUNCTIONS
;

Global $Button_clip, $Button_exit, $Button_fold, $Button_info, $Button_ontop, $Button_save
Global $Group_titles, $List_titles

Global $a, $ans, $array, $cnt, $data, $icoD, $i, $icoI, $icoX, $ind, $inifle, $left, $ontop, $pth, $right, $savfile, $shell, $title
Global $titles, $TitlesGUI, $top, $updated, $user32, $val, $version, $winpos

$inifle = @ScriptDir & "\Settings.ini"

$updated = "(created November 2026)"
$version = "(v1.0)"

$right = @DesktopWidth - (510 + 25)
$left = IniRead($inifle, "Program Window", "left", $right)
$top = IniRead($inifle, "Program Window", "top", 27)
$TitlesGUI = GuiCreate("GOG Titles Extractor", 510, 590, $left, $top, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU + $WS_MINIMIZEBOX _
																					+ $WS_VISIBLE + $WS_CLIPSIBLINGS, $WS_EX_TOPMOST)
GUISetBkColor($COLOR_SKYBLUE, $TitlesGUI)
;
; CONTROLS
$Button_ontop = GUICtrlCreateCheckbox("On" & @LF & "Top", 10, 10, 50, 50, $BS_PUSHLIKE + $BS_MULTILINE)
GUICtrlSetFont($Button_ontop, 9, 600)
GUICtrlSetTip($Button_ontop, "Toggle program window on top status!")
;
$Button_clip = GuiCtrlCreateButton("GET FROM CLIPBOARD", 70, 10, 180, 50)
GUICtrlSetFont($Button_clip, 9, 600)
GUICtrlSetTip($Button_clip, "Get JSON data from clipboard & process!")
;
$Button_save = GuiCtrlCreateButton("SAVE", 260, 10, 60, 50)
GUICtrlSetFont($Button_save, 9, 600)
GUICtrlSetTip($Button_save, "Save titles to a text file!")
;
$Button_fold = GuiCtrlCreateButton("D", 330, 10, 50, 50, $BS_ICON)
GUICtrlSetTip($Button_fold, "Open the program folder!")
;
$Button_info = GuiCtrlCreateButton("Info", 390, 10, 50, 50, $BS_ICON)
GUICtrlSetTip($Button_info, "Program Information!")
;
$Button_exit = GuiCtrlCreateButton("EXIT", 450, 10, 50, 50, $BS_ICON)
GUICtrlSetTip($Button_exit, "Exit / Close / Quit the window!")
;
$Group_titles = GuiCtrlCreateGroup("Discovered Game Titles", 10, 70, 490, 510)
$List_titles = GUICtrlCreateList("", 20, 90, 470, 480)
GUICtrlSetTip($List_titles, "Game Titles discovered in JSON data!")
;
; OS SETTINGS
$user32 = @SystemDir & "\user32.dll"
$shell = @SystemDir & "\shell32.dll"
$icoD = -4
$icoI = -5
$icoX = -4
;
; SETTINGS
GUICtrlSetImage($Button_fold, $shell, $icoD, 1)
GUICtrlSetImage($Button_info, $user32, $icoI, 1)
GUICtrlSetImage($Button_exit, $user32, $icoX, 1)
;
$ontop = 1
GUICtrlSetState($Button_ontop, $ontop)

GuiSetState()
While 1
	$msg = GuiGetMsg()
	Select
	Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_exit
		; Close the program window
		$winpos = WinGetPos($TitlesGUI, "")
		$left = $winpos[0]
		If $left < 0 Then
			$left = 2
		ElseIf $left > @DesktopWidth - $winpos[2] Then
			$left = @DesktopWidth - $winpos[2]
		EndIf
		IniWrite($inifle, "Program Window", "left", $left)
		$top = $winpos[1]
		If $top < 0 Then
			$top = 2
		ElseIf $top > @DesktopHeight - $winpos[3] Then
			$top = @DesktopHeight - $winpos[3]
		EndIf
		IniWrite($inifle, "Program Window", "top", $top)
		;
		GUIDelete($TitlesGUI)
		ExitLoop
	Case $msg = $Button_save
		; Save titles to a text file
		If $cnt > 0 Then
			$titles = ""
			For $i = 0 To ($cnt - 1)
				$title = _GUICtrlListBox_GetText($List_titles, $i)
				$titles &= $title & @CRLF
			Next
			If $titles <> "" Then
				$savfile = @ScriptDir & "\GOG Game Titles.txt"
				FileWrite($savfile, $titles)
				ShellExecute($savfile)
			EndIf
		Else
			MsgBox(262144 + 48, "List Error", "No entries found.", 0, $TitlesGUI)
		EndIf
	Case $msg = $Button_ontop
		; Toggle program window on top status
		If GUICtrlRead($Button_ontop) = $GUI_CHECKED Then
			$ontop = 1
			WinSetOnTop($TitlesGUI, "", 1)
		Else
			$ontop = 4
			WinSetOnTop($TitlesGUI, "", 0)
		EndIf
		GUICtrlSetState($Button_ontop, $ontop)
	Case $msg = $Button_info
		; About the program
		MsgBox(262208, "About The Program", _
			"A program to get a customer's game titles at GOG." & @LF & @LF & _
			"The program works via web page JSON data copied" & @LF & _
			"to the clipboard by a customer, per page of games." & @LF & @LF & _
			"That data is processed to extract the game titles." & @LF & @LF & _
			"The resulting list can be saved to a text file." & @LF & @LF & _
			"BIG THANKS to Jon & team at the AutoIt Forum." & @LF & @LF & _
			"© November 2026 by Timboli - GOG Titles Extractor " & @LF & _
			$version & " " & $updated, 0, $TitlesGUI)
	Case $msg = $Button_fold
		; Open the program folder
		ShellExecute(@ScriptDir)
	Case $msg = $Button_clip
		; Get JSON data from clipboard & process
		If _IsPressed("11") Then
			If $cnt > 0 Then
				$ind = _GUICtrlListBox_GetCurSel($List_titles)
				For $i = $ind To ($cnt - 1)
					_GUICtrlListBox_SetCurSel($List_titles, $i)
					$title = _GUICtrlListBox_GetText($List_titles, $i)
					If StringInStr($title, "\u") > 0 Then
						MsgBox(262208, "Unicode Check", $title & " found.", 0, $TitlesGUI)
						ExitLoop
					EndIf
				Next
			EndIf
		Else
			$data = ClipGet()
			If $data = "" Then
				MsgBox(262144 + 48, "Clipboard Error", "No data found.", 0, $TitlesGUI)
			Else
				If StringInStr($data, '"title":"') < 1 Then
					MsgBox(262144 + 48, "Text Error", "Unsuitable data found.", 0, $TitlesGUI)
				Else
					$titles = StringSplit($data, '"title":"', 1)
					For $t = 2 To $titles[0]
						$title = $titles[$t]
						If $title <> "" Then
							$title = StringSplit($title, '",', 1)
							$title = $title[1]
							$title = StringReplace($title, "\u00ae", "")
							$title = StringReplace($title, "\u2122", "")
							$title = StringReplace($title, "\u0026", "&")
							$title = StringReplace($title, "\u0027", "'")
							$title = StringReplace($title, "\u2019", "'")
							$title = StringReplace($title, "\u2013", "-")
							$title = StringReplace($title, "\u00f6", "o")
							GUICtrlSetData($List_titles, $title)
						EndIf
					Next
					$cnt = _GUICtrlListBox_GetCount($List_titles)
					GUICtrlSetData($Group_titles, "Discovered Game Titles (" & $cnt & ")")
					$titles = $titles[0] - 1
					MsgBox(262208, "Get Result", $titles & " titles found.", 0, $TitlesGUI)
				EndIf
			EndIf
		EndIf
	Case $msg = $List_titles
		; Game Titles discovered in JSON data
		$title = GUICtrlRead($List_titles)
		If StringInStr($title, "\u") > 0 Then
			MsgBox(262208, "Unicode Check", $title & " found.", 0, $TitlesGUI)
		;ElseIf StringInStr($title, "&") > 0 Then
		;	MsgBox(262208, "Ampersand Check", $title & " found.", 0, $TitlesGUI)
		EndIf
	Case Else
		;;;
	EndSelect
WEnd

Exit
