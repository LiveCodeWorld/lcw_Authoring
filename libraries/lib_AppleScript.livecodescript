script "lib_AppleScript"
--> MetaData
-
license: GPLv3
name: lib_AppleScript
type: library
version: 0.91
copyright: David Bovill

/*
A library for html and browser related stuff.

Browser links in Html:
Windows:  Registering an Application to a URL Protocol
<http://msdn.microsoft.com/en-us/library/aa767914(VS.85).aspx>

OS X:  HowToRegisterURLHandler
http://www.cocoadev.com/index.pl?HowToRegisterURLHandler

Apple Docs:
<http://developer.apple.com/documentation/MacOSX/Conceptual/BPRuntimeConfig/Articles/PListKeys.html#//apple_ref/doc/uid/20001431-102207>

I think you need to handle the 'GURL' apple event in your application.
*/


--> Photos
-
command photos_Import imageFile, albumName
   -- doe not seem to be working
   -- https://gist.github.com/natcl/7a5c98aae8b21475caf9
   -- launch imageFile with "/System/Applications/Photos.app"
   
   /*
   -- tell application "Photos"
   set DestinationAlbumName to "Inbox"			
   if not (exists container named DestinationAlbumName) then
      make new album named DestinationAlbumName
   end if				
   import ImageFile into container named DestinationAlbumName with skip check duplicates
   -- end tell
   */
   
   put "tell application 'Photos' to import '[[imageFile]]' into container named '[[albumName]]'" into tScript
   -- put space & "with skip check duplicates" after tScript
   replace "'" with quote in tScript
   put merge (tScript) into aScript
   --
   do aScript as AppleScript
   put the result
end photos_Import


--> Terminal
-
command launch_Terminal pFolder, pActivate
   if pFolder is empty then put the defaultfolder into pFolder
   put pActivate is not false into pActivate
   
   shell_BashParamEscape pFolder
   put "cd" && pFolder into someShell
   terminal_DoShell someShell, pActivate
   put the result
end launch_Terminal

command terminal_DoShell someShell, pActivate
   if pActivate is true then applescript_ActivateApp "Terminal"
   
   put "do script" && kwote(someShell) into appleScriptLine  -- this opens a terminal window using ApplesCript and then executes a shell command in the window.
   put appleScript_DoLine (appleScriptLine, "Terminal", false) into appleScriptResult
   return appleScriptResult
end terminal_DoShell


--> Applescripts
-
-- on appleEvent theClass, theID
put the params
pass appleEvent
end appleEvent

function appleScript_DoShell someShell, pStripQuotes
   put "do shell script" && kwote (someShell) into appleScriptLine
   put appleScript_DoLine (appleScriptLine, "Terminal", pStripQuotes) into appleScriptResult
   return appleScriptResult
end appleScript_DoShell

function finder_ListActive
   -- https://www.macscripter.net/viewtopic.php?id=43978 to do conversiotn in Applescript
   get "get the name of every process whose background only is false"
   put appleScript_DoLine (it, "System Events") into tResult
   
   delete char 1 of tResult
   delete char -1 of tResult
   replace quote with empty in tResult
   replace ", " with CR in tResult
   return tResult
end finder_ListActive


--> AppleScript | Browsers
-
/*
Here are a number of sources for Applescript and browsers:
- https://stackoverflow.com/questions/263741/using-applescript-to-grab-the-url-from-the-frontmost-window-in-web-browsers-the
*/

function chrome_GetURL
   -- https://stackoverflow.com/questions/2483033/get-the-url-of-the-frontmost-tab-from-chrome-on-os-x
   if "Google Chrome" is not among the lines of finder_ListActive() then return empty
   --
   get appleScript_DoLine ("get URL of active tab of first window", "Google Chrome")	
   return it
end chrome_GetURL

function firefox_GetUrl
   -- Firefox is not very scriptable
   -- see "http://www.macosxhints.com/article.php?story=20060325015454467"
   /*
   tell application "Firefox" to activate
   tell application "System Events"
   keystroke "l" using command down
   keystroke "c" using command down
   */
   
   -- get appleScript_DoLine ("set myURL to item 3 of properties of front window as list", "Firefox")
   -- get appleScript_DoLine ("set myURL to item 3 of properties of front window as list", "firefox-bin")
   -- get appleScript_DoLine ("set myURL to «class curl» of window 1", "Firefox")
   return it
end firefox_GetUrl

function safari_GetUrl
   -- see "http://www.macosxhints.com/article.php?story=20060325015454467"
   -- tell application "Safari" to return URL of front document
   -- get appleScript_DoLine ("set myURL to URL of document 1", "Safari")
   
   if "Safari" is not among the lines of finder_ListActive() then return empty
   --
   get appleScript_DoLine ("set myURL to name of front document", "Safari")
   return it
end safari_GetUrl

command firefox_PositionWindow someRect, windowName
   -- relative to top left corner
   if windowName is empty then
      put 1 into windowName
   else if windowName is not a number then
      put kwote(windowName) into windowName
   end if
   put merge("set the bounds of window [[windowName]] to {[[someRect]]}") into appleScriptLine
   get appleScript_DoLine(appleScriptLine, "firefox-bin")
   return it
end firefox_PositionWindow


--> Events
-
command appleEvent theClass, theID
   -- put the params
   switch
      case theClass is "misc" and theID is "dosc"
         -- request appleEvent data
         -- do URL ("file:" & it)
         break
      case theClass is "aevt" and theID is "odoc"
         request appleEvent data
         -- put "the file opened is:" && it
         break
   end switch
   pass appleEvent
end appleEvent


--> AppleScript
-
function appleScript_DoShell someShell
   do "do shell script" && kwote (someShell) as AppleScript
   return the result
end appleScript_DoShell

command appleScript_Do appleScriptLine, appName
   get "tell application" && kwote (appName) && "to" && appleScriptLine
   do it as AppleScript
   put the result into someText
   return someText
end appleScript_Do

command applescript_ActivateApp appNameOrPath
   get "activate application" && kwote (appNameOrPath)
   do it as AppleScript
   get the result
   return it
end applescript_ActivateApp

function appleScript_DoLine appleScriptLine, appName, pStripQuotes
   appleScript_Do appleScriptLine, appName
   put the result into someText
   if pStripQuotes is not false then
      if char 1 of someText is quote then delete char 1 of someText
      if char -1 of someText is quote then delete char -1 of someText
   end if
   return someText	
end appleScript_DoLine

function applescript_ConstructIndex kwoteList
   repeat
      put word 1 of kwoteList into someValue
      applescript_StripRecord someValue
      put someValue & CR after someIndex
      delete word 1 of kwoteList
      delete item 1 of kwoteList
      if kwoteList is empty then exit repeat
   end repeat
   delete char -1 of someIndex
   return someIndex
end applescript_ConstructIndex

command applescript_StripRecord @someValue
   delete char 1 of someValue
   delete char -1 of someValue
end applescript_StripRecord

command applescript_CreateRecord @someValue
   put  "{" before someValue
   put  "}" after someValue
end applescript_CreateRecord

-- function appleScript_File filePath, convertOSX
-- old

breakpoint
return revMacFromUnixPath (filePath, convertOSX)

replace "/" with ":" in filePath
put line 1 of the volumes into systemVolume
set the itemdelimiter to ":"
put systemVolume into item 1 of filePath
return filePath
end appleScript_File

command applescript_ConvertPath @pFileOrFolder
   -- "Macintosh HD:Applications:Revolution 2.6.1:"
   put revMacFromUnixPath (pFileOrFolder) into pFileOrFolder
   put kwote(pFileOrFolder) into pFileOrFolder
   return empty
end applescript_ConvertPath


--> AppleScript | SnapZ
-
command snap_Invoke
   appleScript_DoLine "Snapz Pro X", "invoke"
end snap_Invoke


--> AppleScript | Open Mime
-
-- command appleEvent theClass, theID, someSender
put the params

/*
* The form request appleEvent class is equivalent to request appleEvent data
with keyword "evcl". It gets the four-character class the Apple event belongs to (for example, misc or aevt).
* The form request appleEvent id is equivalent to request appleEvent data 
with keyword "evid". It gets the four-character name of the specific Apple event (for example, dosc or eval).
* The form request appleEvent sender is equivalent to request appleEvent data
with keyword "addr". It gets the AppleTalk address of the program that sent the Apple event to Revolution.
* The form request appleEvent returnID is equivalent to request appleEvent data
with keyword "rtid". It gets the Apple event's return id number.

* The form request appleEvent data gets the data associated with the Apple event. 
The meaning of this data depends on which kind of Apple event is being handled. 
For example, the odoc (open document) event sends the file path of the document being opened as the Apple event data.
For more information about Apple events, see Apple Computer's technical documentation,
Inside Macintosh: Interapplication Communication, located at
http://developer.apple.com/techpubs/mac/IAC/IAC-2.html.
*/

switch theClass
   case "aevt"
      if theID is "odoc" then
         pass appleEvent
         
         -- appleEvent "aevt","odoc",""
         -- is what you get when the finder tries to ope a file
         pass appleEvent
         
         -- guess it coming from a browser?
         
         -- should be a mime type somewhere?
         
         -- this assumes it is from MediaWiki
         request appleEvent data -- get the content of the AppleEvent
         put it into someFile
         put url ("file:" & someFile) into someText
         put someText
         
         put lineoffset("[File]", someText) into lineNum
         delete line 1 to lineNum of someText
         split someText with CR and "="
         put someText ["Extension"] -- into someFileType
         put someText ["URL"] -- into someFile
      end if
      break
   case "misc"
      breakpoint
      if theID is "dosc" then
         request appleEvent data -- get the content of the AppleEvent
         put "dosc:" && it
         -- do URL ("file:" & it)
      end if
      break
   default
      breakpoint
end switch

pass appleEvent
end appleEvent


--> AppleScript | iChat
-
command iChat_PositionWindow someRect, windowName
    if windowName is empty then put 2 into windowName
    finder_PositionWindow "iChat", someRect, windowName
    return the result	
end iChat_PositionWindow


--> AppleScript | Skype
-
command skype_PositionWindow someRect, windowName
    if windowName is empty then put 5 into windowName
    finder_PositionWindow "Skype", someRect, windowName
    return the result	
end skype_PositionWindow

getprop skype_WindowNames
    return "Main User Window,Edit Contact Groups,Window,Audio,Skype Video,History"
end skype_WindowNames
