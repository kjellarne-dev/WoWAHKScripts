#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; World of Warcraft anti disconnect script
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Written by Kjella
; Date: 2019-09-03
; Version: 1.4
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
;
;       NOTE: This function assumes that you are logged in to your character
;
;   Toggle Auto Detect Queue Pop
;   Shift + CTRL + F10
;       Tired of having to wait in front of your computer for the queue to pop?
;       This function automatically detects when the queue wait is over
;       (Aka when the client is in the character select screen)
;       It then logs in to your character and enable the auto logout manipulation
;       It can even send a message to your Discord channel of choice - see below
;
;       TO DISABLE BEFORE QUEUE IS OVER: Use shortcut for Auto Detect Queue Pop
;       TO DISABLE AFTER QUEUE IS OVER: Use shortcut for Auto Logout Manipulation
;       
;       NOTE: This function assumes that you are in a server queue already
;       NOTE: wow.png must be included and stored in the same folder as the script
;
;   Launch WoW with queuedetection
;   Shift + CTRL + F11
;       Launches World of Warcraft, connects to a realm of your choice
;       And starts Auto Detect Queue Pop function
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get window ID for World of Warcraft and make it global
WinGet, wowid, ID, World of Warcraft
Global wowid

; World of Warcraft Classic Launcher exe location
WoWLauncherExe := "C:\Program Files (x86)\World of Warcraft\World of Warcraft Launcher.exe"

; Print screen image of the realm name that you wish to connect to (required for F11 shortcut)
RealmOCRImage := ".\Gehennas_realm.png"

; Print screen image of something that only exist on the character select screen
CharacterSelectOCRImage := ".\delete_character.png"

; Automatically start WoW at a specific time. 0 = Disabled, 1 = Enabled
EnableAutoStartWoW := 0

; If EnableAutoStartWoW is enabled - specifiy when you want WoW to start here (format: HHmm. Eg 2359 for 23:59)
AutoStartWoWTime := 1155

; Discord Message - Enable if you would like to recieve a message to a discord channel when your queue pops. 0 = Disabled, 1 = Enabled
EnableDiscordMessage := 0
Global EnableDiscordMessage

; Type in your Discord API token if you enable DiscordMessage (How to get a webhook for Discord: https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks )
DiscordWebhook := "https://discordapp.com/api/webhooks/x/x"
Global DiscordWebhook

; Type in the message you would like to send to Discord
DiscordMessageContent := "Your World of Warcraft queue just popped!"

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

SendDiscordMessage(DiscordMessage) {
    If (EnableDiscordMessage) {
        Text := StrReplace(StrReplace(DiscordMessage, "\", "\\"), """", "\""")
        Http := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
        Http.Open("POST", DiscordWebhook, False)
        Http.SetRequestHeader("Content-Type", "application/json")
        Http.Send("{""content"": """ Text """}")
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STARTUP COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Start Chronos every 500 ms
If (EnableAutoStartWoW) {
    AutoStartWoW := !AutoStartWoW
    SetTimer, Chronos, -1
}
Return

Chronos:
    While (AutoStartWoW) {
        FormatTime, TimeToMeet,,HHmm
        ; If you want the script to start at 7 am put change 1006 to 700
        If (TimeToMeet = AutoStartWoWTime) {
            SendDiscordMessage("Starting World of Warcraft at "AutoStartWoWTime)

            ; Run the Start WoW function
            SetTimer, StartWoWAndAutodetectQueuePop, -1

            ; Turn off AutoStartWoW
            AutoStartWoW := !AutoStartWoW
        }
    }
Return

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
    MsgBox Auto detect queue pop enabled
    SetTimer, AutodetectQueuePop, -1
return

; Shift + CTRL + F11
$^+F11::
    SetTimer, StartWoWAndAutodetectQueuePop, -1
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
    SendDiscordMessage("Started AutodetectQueuePop")
    ; While loop keeps script running
    while (EnableAutodetectQueuePop) {      
        ; Get World of Warcraft window location and size
        WinGetPos, xPos, yPos, WinWidth, WinHeight, ahk_id %wowid%

        CoordMode, Pixel, Screen
        endxPos := xPos + WinWidth
        endyPos := yPos + WinHeight

        ; Search the WoW window for the image specified above
        ImageSearch, x, y, %xPos%, %yPos%, %endxPos%, %endyPos%, *5 %CharacterSelectOCRImage%

        if (ErrorLevel = 2) {
            MsgBox AutoDetectQueuePop image search failed miserably. Did you include %CharacterSelectOCRImage% in the root folder of this script?
        }
        else if (ErrorLevel = 1) {
            ; Image was not found, assuming that client is still in queue. Sleep for 60 seconds before checking again
            Sleep 60000
        }
        else {
            ; Image was found. Client is currently at the character select screen.
            ; Sending message to Discord if user has elected to do so
            SendDiscordMessage(DiscordMessageContent)

            ; Sleep for 30 seconds to make sure that all required assets are loaded
            Sleep 30000

            ; Press enter to enter the world
            ControlSend,, {Enter}, ahk_id %wowid%

            ; Wait for the world to finish loading.
            Random, r, 180000, 240000
            Sleep r

            ; Start the logoutmanipulation-function so the account stays signed in
            EnableLogOutManipulation := !EnableLogOutManipulation
            SetTimer, LogOutManipulation, -1

            ; Disable AutodetectQueuePop so it doesn't keep running in the background
            EnableAutodetectQueuePop := !EnableAutodetectQueuePop
            Sleep 2000
        }
    }
Return ; End AutodetectQueuePop

StartWoWAndAutodetectQueuePop:
    ; Start battle.net launcher
    Run %WoWLauncherExe%

    ; Sleep for 10 seconds to make sure that all required assets are loaded
    Sleep 10000

    ; Get window ID for Battle.net
    WinGet, battlenetid, ID, Blizzard Battle.net

    ; Press enter to start World of Warcraft
    ControlSend,, {Enter}, ahk_id %battlenetid%

    ; Sleep for 15 seconds so WoW can launch and log in
    Sleep 15000

    ; Get World of Warcraft window ID, so the other functions are able to use it
    WinGet, wowid, ID, World of Warcraft
    Global wowid
    Sleep 1000
    
    ; Get World of Warcraft window location and size
    WinGetPos, xPos, yPos, WinWidth, WinHeight, ahk_id %wowid%

    CoordMode, Pixel, Screen
    endxPos := xPos + WinWidth
    endyPos := yPos + WinHeight

    ; Search the WoW window for the image specified above
    ImageSearch, x, y, %xPos%, %yPos%, %endxPos%, %endyPos%, *5 %RealmOCRImage%

    if (ErrorLevel = 2) {
        MsgBox AutoDetectQueuePop image search failed miserably. Did you include %RealmOCRImage% in the root folder of this script?
    }
    else if (ErrorLevel = 1) {
        ; Image was not found, assuming that client is still in queue. Sleep for 60 seconds before checking again
        MsgBox Did not find %RealmOCRImage% on the screen
    }
    else {
        ; Doubleclick on the realm to log into it
        x := x + 20
        y := y + 20
        MouseClick, Left, x, y, 2, 45

        ; 10 second sleep
        Sleep 10000

        ; Enable AutodetectQueuePop
        EnableAutodetectQueuePop := !EnableAutodetectQueuePop
        SetTimer, AutodetectQueuePop, -1
    }

Return ; End StartWoWAndAutodetectQueuePop
