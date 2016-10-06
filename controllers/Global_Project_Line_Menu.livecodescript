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
command display_ScriptCallArray stackObject
   put the script_CallArray [true] of stackObject into scriptCallArray
   put merge ("the script_CallArray,[[stackObject]]") into someTitle
   
   put "Global | HkeyArray | Tree | Deps | Menu" into mTitle
   put "Global | HkeyArray | Menu" into mLineTitle
   display_Array scriptCallArray, someTitle, mTitle, mLineTitle, "checkCall", "checkCall"
   put the result into treeView
   set the displayed_Object of treeView to stackObject
   return treeView
end display_ScriptCallArray


--> Display | Events
-
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
on menu_MoveUsed stackObject, newProjectName
   put the project_Name of stackObject into oProjectName
   if oProjectName = newProjectName then
      answer warning merge ("Stack is already in project '[[newProjectName]]'. Choose a new project to move this library to!")
      exit to top
   end if
   
   project_MoveLibrary stackObject, newProjectName
   
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

getprop stack_IsUsed [stackObject]
   put the short name of stackObject into stackName
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_IsUsed

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

on menu_RevealDataFolder stackObject
   put the data_Folder of stackObject into dataFolder
   finder_Reveal dataFolder
end menu_RevealDataFolder

on menu_MultipleHilites indexView, someBoolean
   set the multiple_Hilites of indexView to someBoolean
end menu_MultipleHilites


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


--> Global | Project | Line | Menu | Disabled
-
