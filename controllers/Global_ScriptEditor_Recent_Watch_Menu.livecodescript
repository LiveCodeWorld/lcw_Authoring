script "Global_ScriptEditor_Recent_Watch_Menu"
--> MetaData
-
license: GPLv3
name: Gobal | ScriptEditor | Recent | Watch | Menu
type: controller
copyright: David Bovill
license: GPLv3
version: 0.91

/*
This is designed to be the main or the default menu for manipulating a script in an editor.
As such it is currently used in the Livecode IDE's script editor.
You can attach it anywhere you want. I personally add it to the Script Editors "watch" button on the top right bar of the editor.
*/

--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init
   -- a hack (we keep getting this reset by LIVecode)
   ide_AddRevEditScriptStack "LCW"
   rev_AddBehaviorHacks
   
   put stack_ListEditedNames() into editedStacks
   repeat for each line stackName in editedStacks
      switch
         case exists (stack stackName) is false
            next repeat
         case word 1 of stackName = "Untitled"
            next repeat
         default
            put stackName & CR after goodEditedStackNames
      end switch
   end repeat
   delete char -1 of goodEditedStackNames
   put goodEditedStackNames into LocalArray ["editedStacks"]
end menu_Init

getprop menu_Target [mTitlePath]
   put rev_ScriptObject() into scriptObject
   return scriptObject
end menu_Target

function stack_ListEditedNames pType
   global gREVStackStatus
   
   repeat for each key stackName in gREVStackStatus
      if exists (stack stackName) is false then next repeat
      switch pType
         case "saved"
            if gREVStackStatus [stackName] = empty then
               put "saved" into stackArray [stackName]
            end if
            break
         default
            if gREVStackStatus [stackName] = "edited" then
               put "edited" into stackArray [stackName]
            end if
      end switch
   end repeat
   return keys (stackArray)
end stack_ListEditedNames


--> Global | ScriptEditor | Recent | Watch | Menu
-
on menu_DisplayLocalChanges scriptObject
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on menu_RecentScripts scriptObject, recentObject
   put LocalArray ["friendlyArray"][recentObject] into someObject
   if exists (someObject) then
      edit the script of someObject
   else
      breakpoint
   end if
end menu_RecentScripts

on menu_SaveEditedStacks mTarget, editedStackName
   stack_SaveEdited editedStackName
end menu_SaveEditedStacks

on _
end _

on menu_ObjectProperties scriptObject
   object_Inspect scriptObject
end menu_ObjectProperties

on menu_Environment scriptObject
   display_ProjectList
end menu_Environment

on menu_GitStatus scriptObject
   display_GitStatus scriptObject
end menu_GitStatus

on menu_LoadGit   
   project_Start "lcw_Git"
end menu_LoadGit

on menu_ViewTools scriptObject
   -- put the module_Folder of scriptObject into moduleFolder
   -- display_Module moduleFolder
   display_View scriptObject   
end menu_ViewTools

getprop disabled_DisplayView [scriptObject]
   put the view_Name of scriptObject into vName
   put vName is empty into someBoolean
   if someBoolean is true then
      return "delete"
   else
      return false
   end if
end disabled_DisplayView

on _
end _

on submenu_Stack
   return "Global | Stack | Menu"
end submenu_Stack

on menu_Go scriptObject, whichStack
   -- bug: menu parsing of case statement is not working
   switch whichStack
      case "Go to Object"
         object_GoTo scriptObject
         break
      case "-"
      case "View Browser"
         go to stack "libOPN_ViewBrowser"
         break
      case "libOPN_GIT"
         go to stack "libOPN_GIT"
         break
      case "-"
      case "Properties"
         revIDEInspectObjects scriptObject
         break
   end switch
end menu_Go

on _
end _

on submenu_Create
   return "Global | ScriptEditor | Create | Menu"
end submenu_Create

on submenu_Template
   return "Global | Script | Template | Menu"
end submenu_Template

on submenu_Behavior
   return "Global | Behavior | Menu"
end submenu_Behavior

on submenu_Hacks
   return "Global | IDE | Menu"
end submenu_Hacks

on _
end _

on submenu_Custom
   return "Global | ScriptEditor | Recent | Custom | Menu"
end submenu_Custom

on _
end _

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "Recent", mTitle
end menu_SetMenu

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Recent | Watch | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("Recent")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end m_Titles

getprop project_StackNames
   put project_FetchValue ("openStacks") into stackNames
   return stackNames
end project_StackNames

getprop edited_StackNames
   put LocalArray ["editedStacks"] into editedStacks
   if editedStacks is empty then
      return empty
   else
      return editedStacks & ",-,Save All"
   end if
end edited_StackNames

getprop recent_Objects
   put rev_GetScriptEditorHistoryObjects() into historyObjects
   objects_MakeFriendly historyObjects, orderedFriendlyObjects, friendlyArray
   put friendlyArray into LocalArray ["friendlyArray"]
   return orderedFriendlyObjects
end recent_Objects


--> Global | ScriptEditor | Recent | Watch | Menu | Disabled
-
getprop disabled_GitStatus [scriptObject]
   if project_IsActive ("lcw_GIT") is true then
      return false
   else
      return "delete"
   end if 
end disabled_GitStatus

getprop disabled_LoadGit
   if project_IsActive ("lcw_GIT") is true then
      return "delete"
   else
      return false
   end if 
end disabled_LoadGit

getprop disabled_ObjectProperties [scriptObject]
   put the stack_Name of scriptObject into stackName
   if the scriptonly of stack stackName is true then
      return "delete"
   else
      return false
   end if
end disabled_ObjectProperties

getprop disabled_Dev
   if the optionKey is "Down" then
      return false
   else
      return "delete"
   end if
end disabled_Dev

getprop disabled_SaveEditedStacks
   put LocalArray ["editedStacks"] into editedStacks
   return editedStacks is empty
end disabled_SaveEditedStacks

getprop disabled_DisplayLocalChanges [scriptObject]
   if the script_IsDifferent of scriptObject is true then
      return false
   else
      return true
      return "delete"
   end if
end disabled_DisplayLocalChanges


--> Deps
-
private command _safeGoProjectStack projectStackName
   if exists (stack projectStackName) then
      go to stack projectStackName
      show stack projectStackName
   else
      answer merge ("Cannot locate stack '[[projectStackName]]'")
      put projectStackName
   end if
end _safeGoProjectStack

command terminal_Diff thisText, lastText, pThisShortFile, pLastShortFile
   -- from "libOPN_PatchAndDiff"
   
   if pThisShortFile is empty then put "this.txt" into pThisShortFile
   if pLastShortFile is empty then put "last.txt" into pLastShortFile
   
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & pThisShortFile into thisFile
   put compareFolder & pLastShortFile into lastFile
   
   diff_CreateTempFile thisText, pThisShortFile
   put the result into thisFile
   
   diff_CreateTempFile lastText, pLastShortFile
   put the result into lastFile
   
   diff_Files thisFile, lastFile
   return the result
end terminal_Diff

command diff_CreateTempFile someText, shortFile
   -- from "libOPN_PatchAndDiff"
   
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & shortFile into someFile
   put someText into url ("binfile:" & someFile)
   return someFile
end diff_CreateTempFile

command diff_Files thisFile, lastFile
   -- from "libOPN_PatchAndDiff"
   
   put "opendiff" into someShell
   -- put "sdiff" into someShell
   put space & kwote(thisFile) && kwote(lastFile) after someShell
   put shell (someShell) into shellResult
   return shellResult
end diff_Files

command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   repeat for each line someObject in someObjects
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly scriptObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of scriptObject & space into tFriendlyName
   
   if the name of scriptObject is the short name of scriptObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of scriptObject after tFriendlyName
   else
      put quote & the short name of scriptObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly


--> Dev | Menu
-
on menu_RevealDataFolder scriptObject
   put the data_Folder [true] of scriptObject into dataFolder
   finder_Reveal dataFolder
end menu_RevealDataFolder

on menu_RevealProjectFolder scriptObject
   put the project_Folder of scriptObject into projectFolder
   finder_Reveal projectFolder
end menu_RevealProjectFolder

on _
end _

-- on submenu_View
return "Global | View | Authoring | Menu"
end submenu_View

-- on submenu_Prefs
   return "Global | Pref | Menu"
end submenu_Prefs

-- on submenu_LivecodePrefs
   return "Global | Rev | Prefs | Menu"
end submenu_LivecodePrefs

-- on menu_FindFromKeywords
   put lcw_Ask ("Input some handler names or keywords seperated by commas...", "path,array") into keywordList
   put hArray_KeywordHkeys (keywordList) into hKeys
   display_HkeyIndex hKeys
end menu_FindFromKeywords



