#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; World of Warcraft anti disconnect script
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Written by Kjella
; Date: 29. August 2019
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Shortcuts
;
;   Toggle Auto jump
;   Shift + CTRL + F8
;       Jumps (presses space) once every 200-280 seconds
;
;   Toggle Auto Logout Manipulation
;   Shift + CTRL + F9
;       Logs off to character select screen (30m timeout)
;       Then logs back in after waiting 20-25 minutes
;       Then logs back off after 2-3 minutes
;       Rinse & Repeat
;       NOTE: This function assumes that you are logged in to your character
;
;   Toggle Auto Detect Queue Pop
;   Shift + CTRL + F10
;       Tired of having to wait in front of your computer for the queue to pop?
;       This function automatically detects when the queue wait is over
;       (Aka when the client is in the character select screen)
;       It then logs in to your character and enable the auto logout manipulation
;       NOTE: This function assumes that you are in a server queue already
;       TO DISABLE BEFORE QUEUE IS OVER: Use shortcut for Auto Detect Queue Pop
;       TO DISABLE AFTER QUEUE IS OVER: Use shortcut for Auto Logout Manipulation
;       NOTE: wow.png must be included and stored in the same folder as the script
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SYSTEM VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get window ID for World of Warcraft and make it global
WinGet, wowid, ID, World of Warcraft
Global wowid

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendChatCommand(command) {
    ; Sends a keypress and then sleeps a random amount of time
    ; Simulating a human typing on a keyboard

    ;Split command into array
    CommandArray := StrSplit(command)

    ;Opening chat box
    ControlSend,, {Enter}, ahk_id %wowid%

    ;Send forward slash "/"
    Send {Shift Down}
    Sleep 250
    Send {7}
    Sleep 250
    Send {Shift Up}

    ;Slight sleep so the system can catch up
    Random, r, 242, 675
    Sleep r

    ;For loop, sending each letter to the chat box with a slight delay between each letter
    for key, val in CommandArray {
        ControlSend,, %val%, ahk_id %wowid%
        Random, r, 136, 322
        Sleep r
    }

    ;Closing chat box
    ControlSend,, {Enter}, ahk_id %wowid%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SHORTCUTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Shift + CTRL + F8
$^+F8::
    EnableAutojump := !EnableAutojump
    SetTimer, Autojump, -1
return

; Shift + CTRL + F9
$^+F9::
    EnableLogOutManipulation := !EnableLogOutManipulation
    SetTimer, LogOutManipulation, -1
return

; Shift + CTRL + F10
$^+F10::
    EnableAutodetectQueuePop := !EnableAutodetectQueuePop
    SetTimer, AutodetectQueuePop, -1
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Autojump:
    ; 2 second sleep so the user has time to release shortcut keys before progressing
    Sleep 2000

    ; While loop keeps script running
    while (EnableAutojump) {
        ;Send jump
        ControlSend,, {Space}, ahk_id %wowid%

        ; AFK timeout is 5 minutes
        Random, r, 200000, 280000
        Sleep r
    }
Return ; End Autojump

LogOutManipulation:
    ; 2 second sleep so the user has time to release shortcut keys before progressing
    Sleep 2000

    ; While loop keeps script running
    while (EnableLogOutManipulation) {

        ; First log out from WoW
        SendChatCommand("logout")

        ; Timeout for character select is 30 minutes
        ; The script presses enter between 20 and 25 minutes after logging out, so you don't get DCd
        Random, r, 1200000, 1500000
        Sleep r

        ControlSend,, {Enter}, ahk_id %wowid%

        ; Wait for the world to finish loading. Randoms between 3-4 minutes so you don't get AFK status (5 minutes)
        Random, r, 180000, 240000
        Sleep r
    }
Return ; End LogOutManipulation

AutodetectQueuePop:
    ; 2 second sleep so the user has time to release shortcut keys before progressing
    Sleep 2000

    ; While loop keeps script running
    while (EnableAutodetectQueuePop) {
        ; Get World of Warcraft window location and size
        WinGetPos, xPos, yPos, WinWidth, WinHeight, ahk_id %wowid%

        CoordMode, Pixel, Screen
        endxPos := xPos + WinWidth
        endyPos := yPos + WinHeight

        ; Search for the image specified below
        ImageSearch, x, y, %xPos%, %yPos%, %endxPos%, %endyPos%, .\wow.png

        if (ErrorLevel = 2) {
            MsgBox AutodetectQueuePop failed miserably. For some reason it is unable to search the WoW window for character select screen
        }
        else if (ErrorLevel = 1) {
            ; Image was not found, assuming that client is still in queue. Sleep for 60 seconds before checking again
            Sleep 60000
        }
        else {
            ; Image was found. Client is currently at the character select screen.
            ; First enter the world, then start LogOutManipulation so the client doesn't disconnect
            ControlSend,, {Enter}, ahk_id %wowid%

            ; Wait for the world to finish loading.
            Random, r, 180000, 240000
            Sleep r

            EnableLogOutManipulation := !EnableLogOutManipulation
            SetTimer, LogOutManipulation, -1

            ; Disable AutodetectQueuePop so it doesn't keep running in the background
            EnableAutodetectQueuePop := !EnableAutodetectQueuePop
        }
    }
Return ; End AutodetectQueuePop
