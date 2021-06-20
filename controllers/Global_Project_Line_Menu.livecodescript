script "Global_Project_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Line | Menu
type: controller
target: libraryStack
version: 0.2


--> Menu | Init
-
local LocalArray

on menu_Init tObject
   put the selected_Line of tObject into libStackName
   put the title_Text of tObject into oProjectName
   --
   put libStackName into LocalArray ["libStackName"]
   put oProjectName into LocalArray ["oProjectName"]
   --
   if exists (stack libStackName) then
      put the name of stack libStackName into libraryStack
      put libraryStack into LocalArray ["libraryStack"]
   end if
end menu_Init

getprop menu_Target [tObject]
   return LocalArray ["libraryStack"]
end menu_Target

getprop moveUsed_Param [libraryStack]
   put the project_Name of libraryStack into projectName
   return projectName
end moveUsed_Param

getprop moveUsed_Params [libraryStack]
   put LocalArray ["oProjectName"] into oProjectName
   put library_ListProjectNames() into projectNames
   
   -- don't move the library to the project it is already index_ConstructUnique(someIndex)
   line_Delete oProjectName, projectNames
   return projectNames
end moveUsed_Params

getprop stackIsUsed_Param [libraryStack]
   put the short name of libraryStack into stackName
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stackIsUsed_Param

getprop stackIsUsed_Params
   return "true,false"
end stackIsUsed_Params

getprop displayModelData_ShortFiles [libraryStack]
   put the model_Names of libraryStack into shortFiles
   return shortFiles
end displayModelData_ShortFiles

getprop disabled_DisplayModelData [libraryStack]
   put the short name of libraryStack into modelName
   set the itemdelimiter to "_"
   if item 1 of modelName is "model" then
      return false
   else
      return "delete"
   end if
end disabled_DisplayModelData


--> Global | Project | Line | Menu
-
on menu_DisplayProject libraryStack
   put the project_Name of libraryStack into projectName
   --
   display_ProjectLibs projectName
end menu_DisplayProject

on submenu_ProjectStack
   return "Global | Project | Stack | Menu"
end submenu_ProjectStack

on _
end _

on menu_MoveUsed libraryStack, newProjectName
   put the project_Name of libraryStack into oProjectName
   put the short name of libraryStack into libStackName
   --
   put LocalArray ["libStackName"] into libStackName
   put LocalArray ["oProjectName"] into oProjectName
   --
   switch
      case newProjectName is empty
         lcw_AnswerWarning "Something went wront with script. This menu item is supposed to list new project names?"
      case oProjectName = newProjectName
         lcw_AnswerWarning merge ("Stack is already in project '[[newProjectName]]'. Choose a new project to move this library to!")
   end switch
   
   project_MoveStackRelative libStackName, newProjectName
   --
   lcw_Notify merge ("Moved library to new project '[[newProjectName]]'!")
   --
   display_ProjectLibs oProjectName
   display_ProjectLibs newProjectName
end menu_MoveUsed

on menu_StackIsUsed libraryStack, someBoolean
   if someBoolean is true then
      start using libraryStack 
   else
      stop using libraryStack
   end if
end menu_StackIsUsed

on _
end _

on menu_TrashStack libraryStack
   display_AskProjectTrashStack libraryStack
end menu_TrashStack

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayScriptObject libraryStack
   display_ScriptObject libraryStack
end menu_DisplayScriptObject

on menu_DisplayStackDeps libraryStack
   display_StackDeps libraryStack
end menu_DisplayStackDeps

on _
end _

on menu_DisplayModelData libraryStack, modelShortFile
   put the short name of libraryStack into modelName
   put the model_Array [modelShortFile] of libraryStack into modelArray
   
   put "model_Array" & comma & modelName into someTitle
   display_Array modelArray, someTitle
end menu_DisplayModelData

on menu_ModelDataFolder libraryStack
   put the model_DataFolder of libraryStack into modelDataFolder
   finder_Reveal modelDataFolder
end menu_ModelDataFolder

on _
end _

on menu_ShortCallArray libraryStack
   display_ScriptCallArray libraryStack
end menu_ShortCallArray

on menu_ScriptCalls libraryStack
   put the script_Calls of libraryStack into scriptCalls
   put merge ("the script_Calls,[[libraryStack]]") into someTitle
   display_Index scriptCalls, someTitle, "Global | Handler | Calls | Menu"
   put the result into displayView
   set the multiple_Hilites of displayView to true
end menu_ScriptCalls

on _
end _

on menu_ExportHandlersAndCalls libraryStack
   script_ExportHandlersAndCalls libraryStack, true
   
   menu_ShortHkeyArray libraryStack
end menu_ExportHandlersAndCalls


--> Display | ScriptCall
-
private command display_ScriptCallArray libraryStack
   put the script_CallArray [true] of libraryStack into scriptCallArray
   put merge ("the script_CallArray,[[libraryStack]]") into someTitle
   
   put "Global | HkeyArray | Tree | Deps | Menu" into mTitle
   put "Global | HkeyArray | Menu" into mLineTitle
   display_Array scriptCallArray, someTitle, mTitle, mLineTitle, "checkCall", "checkCall"
   put the result into treeView
   set the displayed_Object of treeView to libraryStack
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

