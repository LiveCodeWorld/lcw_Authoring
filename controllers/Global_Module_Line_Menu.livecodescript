script "Global | Module | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Module | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
on menu_Init tObject
   -- called only once for top menu
   pass menu_Init
end menu_Init

getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

private function _GetStackName displayView
   put the selected_Line of displayView into stackName
   return stackName
end _GetStackName

--  private function _GetControllerPath displayView
-- loads the stack into memory
put _GetStackName (displayView) into moduleName
put the title_Text of displayView into projectName
--
put the project_Folder of stack projectName into projectFolder
put project_ConstructStandardFile (gMenuTitle, projectFolder, "modules") into controllerPath
put there is a stack controllerPath into someBoolean
if someBoolean is false then return empty
return controllerPath
end _GetControllerPath


--> Global | Module | Line | Menu
-
on menu_DisplayModuleTools displayView
   put _GetStackName (displayView) into stackName
   display_ModuleTools stackName
end menu_DisplayModuleTools

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
