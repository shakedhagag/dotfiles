; Caps Lock as Hyper on Windows: the AutoHotkey twin of the Karabiner rule in
; ~/.config/karabiner (create_private_karabiner.json.tmpl).
;   Hold Caps Lock  = Ctrl+Shift+Alt+Win, the same chord the ZSA Voyager's
;                     Hyper key sends, so Raycast/app shortcuts match.
;   Tap Caps Lock   = switch input language (English <-> Hebrew).
; Caps Lock itself never toggles. Started at login by a Startup-folder
; shortcut (run_onchange_after_autohotkey.ps1.tmpl).
#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook
SetCapsLockState "AlwaysOff"

; A tap shorter than this switches language; a longer lone hold does nothing
; (like Karabiner's to_if_alone timeout).
TAP_MS := 400

*CapsLock:: {
    Send "{Blind}{LCtrl down}{LShift down}{LAlt down}{LWin down}"
    KeyWait "CapsLock"
    tappedAlone := (A_PriorKey = "CapsLock") && (A_TimeSinceThisHotkey < TAP_MS)
    ; Mask the release: a bare Win (or Win+Ctrl+Shift+Alt) press/release would
    ; otherwise open Start or the Office hub.
    Send "{Blind}{vkE8}"
    Send "{Blind}{LWin up}{LAlt up}{LShift up}{LCtrl up}"
    if tappedAlone
        SwitchInputLanguage()
}

; Office key: Windows opens Microsoft 365 when Ctrl+Shift+Alt+Win is pressed
; and released alone. Whenever the 4th Hyper modifier goes down (in any order,
; e.g. from the Voyager's Hyper key), inject the unassigned vkE8 so Windows
; never sees a "lone" chord. `~` passes the key through, so Hyper+<key>
; shortcuts (Raycast etc.) keep working.
~^+!LWin::
~^+!RWin::
~#^+LAlt::
~#^+RAlt::
~#^!LShift::
~#^!RShift::
~#+!LCtrl::
~#+!RCtrl:: Send "{Blind}{vkE8}"

SwitchInputLanguage() {
    ; WM_INPUTLANGCHANGEREQUEST with INPUTLANGCHANGE_FORWARD: next installed
    ; layout for the focused window (a toggle with two languages).
    try PostMessage 0x50, 0x2, 0, , "A"
    catch
        Send "#{Space}"  ; e.g. elevated windows; fall back to Windows' own switch
}
