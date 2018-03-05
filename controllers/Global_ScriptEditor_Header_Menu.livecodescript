script "Global_ScriptEditor_Header_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Header_Menu
type: controller
version: 0.4

local LocalArray


--> Menu | Props
-
on menu_Init
   put stack_ListEditedNames() into editedStackNames
   repeat for each line stackName in editedStackNames
      switch
         case exists (stack stackName) is false
         case word 1 of stackName = "Untitled"
            next repeat
         default
            put stackName & CR after goodEditedStackNames
      end switch
   end repeat
   delete char -1 of goodEditedStackNames
   put goodEditedStackNames into LocalArray ["editedStackNames"]
   
   put scriptEditor_ListEditingObjects() into historyObjects
   objects_MakeFriendly historyObjects, orderedFriendlyObjects, friendlyArray
   put friendlyArray into LocalArray ["friendlyArray"]
   put keys (friendlyArray) into LocalArray ["recentObjects"]
end menu_Init


--> Global | ScriptEditor | Header | Menu
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

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "Recent", mTitle
end menu_SetMenu

on submenu_Dev
   return "ScriptEditor | Dev | Menu"
end submenu_Dev


--> ScriptEditor | Dev | Menu
-
on menu_SaveScriptTabs scriptObject
   put empty into pPrefKey
   --
   put scriptEditor_ListEditingObjects() into historyObjects
   pref_SaveValue "historyObjects", historyObjects, pPrefKey
   
   put scriptEditor_ListTabScriptObjects() into tabScriptObjects
   pref_SaveValue "tabScriptObjects", tabScriptObjects, pPrefKey
   
   put line 1 of tabScriptObjects into scriptObject
   save scriptObject
   repeat with lineNum = 2 to the number of lines of tabScriptObjects
      put line lineNum of tabScriptObjects into scriptObject
      save scriptObject
      scriptEditor_CloseTab scriptObject
   end repeat
end menu_SaveScriptTabs

on menu_RestoreScriptTabs
   put empty into pPrefKey
   --
   put pref_FetchValue ("tabScriptObjects", pPrefKey)into tabScriptObjects
   repeat for each line scriptObject in tabScriptObjects
      -- scriptEditor_CreateNewTab scriptObject
      edit the script of scriptObject
   end repeat
end menu_RestoreScriptTabs

on _
end _

on menu_GatherStacks
   screen_GatherStacks
end menu_GatherStacks

on menu_SaveRecentStacks
   put scriptEditor_ListEditingObjects() into historyObjects
   repeat for each line someObject in historyObjects
      put the stack_Object of someObject into stackObject
      put the mainstack of stackObject into mainStackName
      put stackObject into stackObjectArray [mainStackName]
   end repeat
   
   repeat for each key mainStackName in stackObjectArray
      if exists (stack mainStackName) is false then 
         next repeat
      end if
      save stack mainStackName
      lcw_Notify ("Saved stack" && mainStackName)
   end repeat
end menu_SaveRecentStacks

on menu_SaveAppStacks
   put revLoadedStacks ("application") into appStackNames
   repeat for each line appStackName in appStackNames
      if the filename of stack appStackName is empty then
         next repeat
      end if
      
      /*
      if the destroywindow of stack appStackName is true then
         next repeat
      end if
      */
      
      save stack appStackName
      lcw_Notify ("Saved stack" && appStackName)
   end repeat
end menu_SaveAppStacks

on menu_SaveToIpfs scriptObject
   put the stack_Name of scriptObject into stackName
   put the mainstack of stack stackName into mStackName
   ipfs_SaveStack mStackName
   put the result
end menu_SaveToIpfs


--> Global | ScriptEditor | Header | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("Recent")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
end m_Titles

getprop recent_Objects
   put LocalArray ["recentObjects"] into recentObjects
   return recentObjects
end recent_Objects

getprop edited_StackNames
   put LocalArray ["editedStackNames"] into editedStackNames
   if editedStackNames is empty then
      return empty
   else
      return editedStackNames & ",-,Save All"
   end if
end edited_StackNames


--> Global | ScriptEditor | Header | Menu | Disabled
-
getprop disabled_RecentScripts
   put LocalArray ["recentObjects"] into recentObjects
   if recentObjects is empty then
      return true
   else
      return false
   end if
end disabled_RecentScripts
   
getprop disabled_SaveRecentStacks
   put LocalArray ["editedStackNames"] into editedStackNames
   put LocalArray ["friendlyArray"] into friendlyArray
   --
   repeat for each line editedStackName in editedStackNames
      repeat for each key recentObject in friendlyArray
         if the short name of recentObject = editedStackName then
            put editedStackName & CR after editedRecentStackNames
         end if
      end repeat
   end repeat
   delete char -1 of editedRecentStackNames
   if editedRecentStackNames is empty then
      return true
   else
      return false
   end if
end disabled_SaveRecentStacks
   
getprop disabled_SaveEditedStacks
   put LocalArray ["editedStackNames"] into editedStackNames
   return editedStackNames is empty
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
