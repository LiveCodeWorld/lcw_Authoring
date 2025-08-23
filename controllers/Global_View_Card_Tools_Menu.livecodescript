script "Global | View | Card | Tools | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | View | Card | Tools | Menu
type: controller
version: 0.2


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   /*
   if exists (the display_View of tObject) then
      -- if the stack_IsDisplay of tObject then -- recurses for some reason on card
      put the display_View of tObject into displayView
      put the displayed_Object of displayView into templateView
      return templateView     
   end if
   */
   put the current_Card of tObject into cardObject
   --
   if exists (control 1 of cardObject) is true then
      put the long id of control 1 of cardObject into templateView
      return templateView
   else
      return cardObject
   end if
end menu_Target

function stack_NameFromLongTarget longObject
   put stack_FromLongTarget (longObject) into longStack
   put the short name of longStack into stackName
   return stackName
end stack_NameFromLongTarget

function stack_FromLongTarget longObject
   # Get stack name
   put word -2 to -1 of longObject into stackObject
   return stackObject
end stack_FromLongTarget

getprop disabled_ModuleTools [templateView]
   put the module_Name of templateView into moduleName
   return moduleName is empty
end disabled_ModuleTools

getprop disabled_ViewTools [templateView]
   put the module_Name of templateView into moduleName
   return moduleName is not empty
end disabled_ViewTools

getprop disabled_OpenSubstack [someView]
   put the stack_Object of someView into stackObject
   put the mainstack of stackObject into stackName
   put the substacks of stack stackName into substackNames
   if substackNames is empty then
      return "delete"
   else
      put substackNames into LocalArray ["substackNames"]
      return false
   end if
end disabled_OpenSubstack

getprop substack_Names [someView]
   return LocalArray ["substackNames"]
end substack_Names


--> Global | View | Card | Tools | Menu
-
on submenu_View
   put LocalArray ["cardObject"] into cardObject
   if exists (control 1 of cardObject) is false then
      return "Global | View | Card | Create | Menu"
   end if
   
   put the long id of control 1 of cardObject into viewObject
   --
   put the view_MenuTitle [true] of viewObject into mTitle
   put menu_GetGlobalController (mTitle) into mController
   if exists (mController) is false then
      put "Global | View | Card | Tools | Menu" into mTitle
   end if
   return mTitle
end submenu_View

on submenu_ViewAuthoring
   return "Global | View | Authoring | Menu"
end submenu_ViewAuthoring

on submenu_ModuleAuthoring
   return "Global | Module | Authoring | Menu"
end submenu_ModuleAuthoring

on submenu_Geometry
   return "Global | View | Geometry | Menu"
   -- return "Global | View | Test | Geometry | Menu"
end submenu_Geometry

on submenu_ViewProperty
   return "Global | View | Property | Menu"
end submenu_ViewProperty

on submenu_ViewScript
   return "Global | View | Script | Menu"
end submenu_ViewScript

on _
end _

on menu_ViewTools templateView
   put the view_Name of templateView into viewName
   --
   display_ViewTools viewName
end menu_ViewTools

on menu_Refresh templateView
   put the card_Object of templateView into cardObject
   dispatch "refresh" to cardObject
end menu_Refresh

on __
end __

on menu_ModuleTools templateView
   put the stack_Name of templateView into moduleName
   -- put the module_Name of templateView into moduleName
   if moduleName is empty then
      breakpoint
   end if
   
   display_ModuleTools moduleName
end menu_ModuleTools

on submenu_CreateModule
   return "Global | View | Card | Create | Menu"
end submenu_CreateModule

on submenu_Dev
   return menu_DevTitle ("Global | View | Card | Tools | Menu")
end submenu_Dev
