script "Global_Project_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Line | Menu
type: controller
version: 0.2

--> Variables
-
local LocalArray


--> Display
-
private command refreshDisplay projectName
   lock screen
   put LocalArray ["indexView"] into indexView   
   put project_ListUsedStackNames (projectName) into usedStackNames
   set the view_Index of indexView to usedStackNames
   set the title_Text of indexView to projectName
   unlock screen
end refreshDisplay


--> Global | Project | Line | Menu
-
on menu_GoToWiki stackObject
   put the short name of stackObject into scriptName
   put "https://github.com/Himalayan-Academy/Siva-Siva-App/wiki/" & scriptName into someURL
   launch url someURL
end menu_GoToWiki

on menu_CreateWikiPage stackObject
   put the project_Name of stackObject & ".wiki" into wikiProjectName
   put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put the stack_Name of stackObject into stackName
   put wikiFolder & stackName & ".md" into wikiPageFile
   
   put the github_WikiPage of stackObject into wikiMarkDown
   put "file:" & wikiPageFile into someURL
   put wikiMarkdown into url someURL
end menu_CreateWikiPage

on _
end _

on submenu_ProjectStack
   return "Global | Project | Stack | Menu"
end submenu_ProjectStack

on _
end _

on menu_MoveUsed stackObject, newProjectName
   put the project_Name of stackObject into oProjectName
   if oProjectName = newProjectName then
      answer warning merge ("Stack is already in project '[[newProjectName]]'. Choose a new project to move this library to!")
      exit to top
   end if
   
   put the short name of stackObject into stackName
   project_MoveLibrary stackName, newProjectName
   
   lcw_Notify merge ("Moved library to new project '[[newProjectName]]'!")
   refreshDisplay newProjectName
end menu_MoveUsed

on menu_StackIsUsed stackObject, someBoolean
   if someBoolean is true then
      start using stackObject 
   else
      stop using stackObject
   end if
end menu_StackIsUsed

on _
end _

on menu_DisplayScriptObject stackObject
   display_ScriptObject stackObject
end menu_DisplayScriptObject
   
on menu_DisplayStackDeps stackObject
   display_StackDeps stackObject
end menu_DisplayStackDeps

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Project | Line | Menu | Props
-
getprop multiple_Hilites [indexView]
   put the multiple_Hilites of indexView into someBoolean
   return someBoolean
end multiple_Hilites

getprop new_ProjectName [stackObject]
   put the project_Name of stackObject into projectName
   return projectName
end new_ProjectName

getprop new_ProjectNames
   return library_ListProjectNames()
end new_ProjectNames

getprop stack_IsUsed [stackObject]
   put the short name of stackObject into stackName
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_IsUsed

getprop model_ShortFiles [stackObject]
   put the model_Names of stackObject into shortFiles
   return shortFiles
end model_ShortFiles


--> Global | Project | Line | Menu | Disabled
-
getprop disabled_DisplayModelData [stackObject]
   put the short name of stackObject into modelName
   set the itemdelimiter to "_"
   if item 1 of modelName is "model" then
      return false
   else
      return "delete"
   end if
end disabled_DisplayModelData


--> Dev | Menu
-
on menu_DisplayModelData stackObject, modelShortFile
   put the short name of stackObject into modelName
   put the model_Array [modelShortFile] of stackObject into modelArray
   
   put "model_Array" & comma & modelName into someTitle
   display_Array modelArray, someTitle
end menu_DisplayModelData

on menu_ModelDataFolder stackObject
   put the model_DataFolder of stackObject into modelDataFolder
   finder_Reveal modelDataFolder
end menu_ModelDataFolder

on _
end _
   
on menu_ShortCallArray stackObject
   display_ScriptCallArray stackObject
end menu_ShortCallArray

on menu_ScriptCalls stackObject
   put the script_Calls of stackObject into scriptCalls
   put merge ("the script_Calls,[[stackObject]]") into someTitle
   display_Index scriptCalls, someTitle, "Global | Handler | Calls | Menu"
   put the result into displayView
   set the multiple_Hilites of displayView to true
end menu_ScriptCalls

on _
end _

on menu_ExportHandlersAndCalls stackObject
   script_ExportHandlersAndCalls stackObject, true
   
   menu_ShortHkeyArray stackObject
end menu_ExportHandlersAndCalls

on menu_MultipleHilites indexView, someBoolean
   set the multiple_Hilites of indexView to someBoolean
end menu_MultipleHilites


--> Display | ScriptCall
-
private command display_ScriptCallArray stackObject
   put the script_CallArray [true] of stackObject into scriptCallArray
   put merge ("the script_CallArray,[[stackObject]]") into someTitle
   
   put "Global | HkeyArray | Tree | Deps | Menu" into mTitle
   put "Global | HkeyArray | Menu" into mLineTitle
   display_Array scriptCallArray, someTitle, mTitle, mLineTitle, "checkCall", "checkCall"
   put the result into treeView
   set the displayed_Object of treeView to stackObject
   return treeView
end display_ScriptCallArray

command checkCall treeView, hObject, treePath
   if the optionKey is "Down" then breakpoint
   
   set the itemdelimiter to slash
   put item 1 of treePath into shortCall
   put item 2 of treePath into shortParent
   put the selected_Value of treeView into parentObject
   put shortParent & CR & shortCall & comma & parentObject
end checkCall


--> Menu | Props
-
on menu_Init
   put menu_GetTargetObject() into tObject
   put the index_View of tObject into LocalArray ["indexView"]
end menu_Init

getprop menu_Target [mTitle]
   put menu_GetTargetObject() into tObject
   put the selected_Index of tObject into stackName
   put the name of stack stackName into stackObject
   return stackObject
end menu_Target
