script "Global | Project | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Line | Menu
type: controller
target: stackObject
version: 0.2


--> Menu | Init
-
local LocalArray

on menu_Init tObject
   -- only happens once due to magic of _AddScriptMenu recursion checking
   put the title_Text of tObject into oProjectName
   put oProjectName into LocalArray ["oProjectName"]
   --
   put the top_Line of tObject into LocalArray ["shortFolder"]
   --
   put _GetStackName (tObject) into stackName
   put _GetStackObject (stackName) into stackObject
   put stackObject into LocalArray ["stackObject"]
end menu_Init

getprop menu_Target [tObject]
   get mArray_GetActiveTitle()
   return LocalArray ["stackObject"]
end menu_Target

getprop menu_CheckTarget [stackObject]
   get mArray_GetActiveTitle()
   if exists (stackObject) then
      return true
   else
      return false
   end if
end menu_CheckTarget

private function _GetStackName tObject
   put the selected_Line of tObject into stackName
   return stackName
end _GetStackName

private function _GetStackObject stackName
   put stackName into LocalArray ["stackName"]
   if exists (stack stackName) is false then return empty
   
   put the name of stack stackName into stackObject
   return stackObject
end _GetStackObject

private function _GetLibraryStack tObject
   put _GetStackName (tObject) into shortFolder
   --
   switch shortFolder
      case "Libraries"
      case "Models"
         return stackObject
      default
         delete variable LocalArray ["stackName"]
         delete variable LocalArray ["stackObject"]
         return empty
   end switch
end _GetLibraryStack

private function _GetMenu gMenuTitle
   put the long id of me into myController
   display_CreateMenuIfNeeded gMenuTitle, myController
   return gMenuTitle
end _GetMenu

getprop disabled_Library
   return LocalArray ["shortFolder"] is not "Libraries"
end disabled_Library

getprop disabled_Controller
   return LocalArray ["shortFolder"] is not "Controllers"
end disabled_Controller

getprop disabled_Module
   return LocalArray ["shortFolder"] is not "Modules"
end disabled_Module

getprop disabled_Model
   return LocalArray ["shortFolder"] is not "Models"
end disabled_Model

getprop disabled_View
   return LocalArray ["shortFolder"] is not "Views"
end disabled_View


--> Global | Project | Line | Menu
-
on insert_Controller
   return "Global | Controllers | Tree | Line | Menu"
end insert_Controller

on submenu_Library
   return _GetMenu ("Global | Lib | Line | Menu")
end submenu_Library

on submenu_Model
   return _GetMenu ("Global | Model | Line | Menu")
end submenu_Model

on submenu_Module
   return _GetMenu ("Global | Module | Line | Menu")
end submenu_Module

on submenu_View
   return _GetMenu ("Global | View | Line | Menu")
end submenu_View

on _
end _

-- on submenu_Stack
return "Global | Project | Stack | Menu"
end submenu_Stack

on menu_Go stackObject
   put the stack_Name of stackObject into stackName
   go to stack stackName
end menu_Go
