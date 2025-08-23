script "Global | Module | Authoring | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Module | Authoring | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [viewObject]
   put the module_Folder of viewObject into mFolder
   return there is a folder mFolder
end menu_CheckTarget


--> Global | Module | Authoring | Menu
-
on menu_ModuleTools moduleView
   put the stack_Name of moduleView into moduleName
   -- put the module_Name of moduleView into moduleName
   if moduleName is empty then
      breakpoint
   end if
   
   display_ModuleTools moduleName
end menu_ModuleTools

on menu_RenameModule viewObject
   put the view_Name of viewObject into oldModuleName
   --
   put the project_Folder of stack oldModuleName into projectFolder
   put the project_Name of stack oldModuleName into projectName
   put lcw_Ask ("Give this module a new name...", oldModuleName) into newModuleName
   --
   module_Rename oldModuleName, newModuleName, projectName
   --
   display_ProjectLibs projectName
   display_ProjectModules projectName
end menu_RenameModule

private on _
end _

on menu_CreateModuleStackfiles dView
   put the module_Folder of dView into moduleFolder
   if there is not a folder moduleFolder then
      breakpoint
   end if
   --
   put project_FetchStackFileArray (moduleFolder) into newStackFileArray
   --
   put the stackfile_Array of dView into stackfileArray
   union stackfileArray with newStackFileArray
   set the stackfile_Array of dView to stackfileArray
   --
   put the stack_Name of dView into stackName
   display_Data stackFileArray, stackName, "Stackfile Array"
end menu_CreateModuleStackfiles

on menu_ExportModuleJson viewObject
   put the module_Folder of viewObject into moduleFolder
   if there is not a folder moduleFolder then
      put the project_Folder of viewObject into projectFolder
      
      breakpoint
      project_ExportMenusAndStackFiles projectFolder
   else
      project_ExportMenusAndStackFiles moduleFolder
   end if
   put the result into projectArray
   --
   put the view_Name of viewObject into moduleName
   display_Data projectArray, moduleName, "Module Array"  
end menu_ExportModuleJson

on menu_RevealModuleFolder viewObject
   put the module_Folder of viewObject into moduleFolder
   if there is not a folder moduleFolder then
      breakpoint
   end if
   --
   finder_Reveal moduleFolder
end menu_RevealModuleFolder

private on __
end __

on subMenu_ModuleData
   return "Global | Module | Model | Menu"
end subMenu_ModuleData

on submenu_Assets
   return "Global | View | Assets | Menu"
end submenu_Assets

on subMenu_Frame
   return "Global | Frame | Menu"
end subMenu_Frame

private on ___
end ___

on menu_DisplayModuleProject moduleView
   put the project_Name of moduleView into projectName
   --
   display_Project projectName
end menu_DisplayModuleProject

on menu_ModuleObjectInspector moduleView
   display_ObjectProperties moduleView
end menu_ModuleObjectInspector
