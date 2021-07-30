script "Global_Project_Important_Menu"
--> MetaData
-
license: GPLv3
name: Global_Project_Important_Menu
type: controllers
version: 0.1


--> Global | Project | Important | Menu
-
on menu_SetWorkingProject mTarget, projectName
   env_SetProjectFocus projectName
end menu_SetWorkingProject

on menu_AddToImportantStacks scriptObject
   put the stack_Name of scriptObject into projectStackName
   project_AddImportantStack projectStackName
   lcw_Notify merge("Added stack '[[projectStackName]]' to the project array.")
   display_Environment
end menu_AddToImportantStacks

on menu_StoreOpenStacks scriptObject, projectName
   put the openstacks into stackNames
   filter stackNames without "rev*"
   stack_StripUnsaved stackNames
   project_StoreImportantStacks stackNames, projectName
   display_Environment
end menu_StoreOpenStacks

on menu_StoreLoadedStacks scriptObject, projectName
   put revLoadedStacks() into stackNames
   stack_StripUnsaved stackNames
   project_StoreImportantStacks stackNames, projectName
   display_Environment
end menu_StoreLoadedStacks

on menu_DisplayProject mTarget
   put the index_View of mTarget into indexView
   if exists (indexView) is false then
      display_Environment
      exit to top
   end if
   
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   set the view_Index of indexView to stackNames
end menu_DisplayProject

on menu_DisplayProjectArray mTarget, projectName
   put library_FetchProjectArray (projectName) into projectArray
   put merge ("library_FetchProjectArray (projectName),[[projectName]]") into someTitle
   display_Array projectArray, someTitle
   display_SetInteractions the result, "Project"
end menu_DisplayProjectArray

on _
end _

on menu_SelectProjectStacks mTarget
   set the multiple_Hilites of mTarget to true
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   set the selected_Index of mTarget to stackNames
end menu_SelectProjectStacks

on menu_AddStacksToProject indexView
   put the selected_Index of indexView into projectStackNames
   project_AddImportantStack projectStackNames
   replace CR with comma in projectStackNames
   lcw_Notify merge ("Added stacks '[[projectStackNames]]' to the project array.")
end menu_AddStacksToProject

on menu_StoreSelectedProjectStacks indexView
   put the selected_Index of indexView into projectStackNames
   project_SaveValue "openStacks", projectStackNames
   
   lcw_Notify "Stored the selected project stack names, to the project array."
end menu_StoreSelectedProjectStacks

on menu_ProjectOnlyStacks mTarget
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   set the view_Index of mTarget to stackNames
   set the multiple_Hilites of mTarget to false
end menu_ProjectOnlyStacks

on _
end _

on menu_DisplayOpenStacks
   put the openstacks into stackNames
   display_Index stackNames, "Project", "Global | Project | Menu", "Global | Project | Line | Menu", empty, "project_GoToStack"
   put the result into displayView
   set the multiple_Hilites of displayView to false
end menu_DisplayOpenStacks

on menu_DisplayLoadedStacks
   display_LoadedStacks
end menu_DisplayLoadedStacks


--> Global | Project | Important | Menu | Props
-
--> Global | Project | Important | Menu | Disabled
-
