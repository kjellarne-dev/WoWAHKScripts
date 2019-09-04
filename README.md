# WoWAHKScripts
World of Warcraft Autohotkey scripts

To start using the script:
1. Install Autohotkey
2. Download WoW_AntiAFKScript.ahk, delete_character.png and Gehennas_realm.png to the same folder
3. Read through the variables section of the script. Make sure that the location of the World of Warcraft Launcher is correct.
4. Double click on the script to send it to the system tray

Then you should be all set and ready to use the shortcuts listed below


# Shortcuts
 

   Toggle Auto jump
   
   Shift + CTRL + F8
   
       Jumps (presses space) once every 200-280 seconds



   Toggle Auto Logout Manipulation
   
   Shift + CTRL + F9
   
       Logs off to character select screen (30m timeout)
       Then logs back in after waiting 20-25 minutes
       Then log backs off after 2-3 minutes
       Rinse & Repeat
       
       NOTE: This function assumes that you are logged in to your character



   Toggle Auto Detect Queue Pop
   
   Shift + CTRL + F10
   
       Tired of having to wait in front of your computer for the queue to pop?
       This function automatically detects when the queue wait is over
       (Aka when the client is in the character select screen)
       It then logs in to your character and enable the auto logout manipulation
       
       TO DISABLE BEFORE QUEUE IS OVER: Use shortcut for Auto Detect Queue Pop
       TO DISABLE AFTER QUEUE IS OVER: Use shortcut for Auto Logout Manipulation
       
       NOTE: This function assumes that you are in a server queue already
       NOTE: The PNG files must be included and stored in the same folder as the script



   Launch WoW with queuedetection
   
   Shift + CTRL + F11
   
       Launches World of Warcraft, connects to a realm of your choice
       And starts Auto Detect Queue Pop function
