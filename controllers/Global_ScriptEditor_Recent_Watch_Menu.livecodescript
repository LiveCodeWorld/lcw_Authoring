script "Global_ScriptEditor_Recent_Watch_Menu"
--> MetaData
-
name: Gobal | ScriptEditor | Recent | Watch | Menu
type: controller
copyright: David Bovill
license: GPLv3
version: 0.95

/*
This is designed to be the main or the default menu for manipulating a script in an editor.
As such it is currently used in the Livecode IDE's script editor.
You can attach it anywhere you want. I personally add it to the Script Editors "watch" button on the top right bar of the editor.

Modify to use "Global | ScriptEditor | Header | Menu"
*/

--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init
   -- a hack (we keep getting this reset by Livecode)
   ide_AddRevEditScriptStack "LCW"
   rev_AddBehaviorHacks
end menu_Init

getprop menu_Target [mTitlePath]
   put scriptEditor_Object() into scriptObject
   return scriptObject
end menu_Target


--> Global | ScriptEditor | Recent | Watch | Menu
-
on insert_HeaderMenu
   return "Global | ScriptEditor | Header | Menu"
end insert_HeaderMenu

on _
end _

on menu_ObjectProperties scriptObject
   object_Inspect scriptObject
end menu_ObjectProperties

on menu_Environment scriptObject
   display_LcwProjectList
end menu_Environment

on _
end _

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

-- on menu_ScriptDepArray scriptObject
-- can't find handler
display_ScriptDeps scriptObject
end menu_ScriptDepArray

on menu_StackDepArray scriptObject
   display_StackDeps scriptObject
end menu_StackDepArray

on menu_StackHistory scriptObject
   display_StackHistory scriptObject
end menu_StackHistory

on menu_GitStatus scriptObject
   display_GitStatus scriptObject
end menu_GitStatus

on menu_LoadGit   
   project_Start "lcw_Git"
end menu_LoadGit

on _
end _

on menu_DisplayRigControllers
   display_RigControllerArray
   ide_SetScriptEditorTitles "RevIgniter"
end menu_DisplayRigControllers

on menu_ViewTools scriptObject
   -- put the module_Folder of scriptObject into moduleFolder
   -- display_Module moduleFolder
   display_ViewIndex scriptObject   
end menu_ViewTools

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

-- on submenu_Dev
   return "ScriptEditor | Recent | Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Recent | Watch | Menu | Props
-
getprop which_Stacks
   return "Go to Object,-,View Browser,libOPN_GIT,Properties"
end which_Stacks

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


--> Global | ScriptEditor | Recent | Watch | Menu | Disabled
-
getprop disabled_DisplayView [scriptObject]
   put the view_Name of scriptObject into vName
   put vName is empty into someBoolean
   if someBoolean is true then
      return "delete"
   else
      return false
   end if
end disabled_DisplayView

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



on pushNotificationRegistered pSignature
   
end pushNotificationRegistered
