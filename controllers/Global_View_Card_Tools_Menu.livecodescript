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
getprop menu_IsSimple
   return true
end menu_IsSimple

getprop menu_Target [tObject]
   if the stack_IsDisplay of tObject then
      put the display_View of tObject into displayView
      put the displayed_Object of displayView into templateView
      return templateView     
   end if
   
   put the card_Object of tObject into cardObject
   put cardObject into LocalArray ["cardObject"]
   --
   if exists (control 1 of cardObject) is false then
      return cardObject
   end if
   
   put the long id of control 1 of cardObject into templateView
   return templateView
end menu_Target

getprop disabled_EditBehavior [someView]
   put the behavior of someView into bObject
   put exists (bObject) into bExists
   return bExists is false
end disabled_EditBehavior

getprop disabled_SetViewCardBehavior [someView]
   put the card_Object of someView into cardObject
   put the behavior of cardObject into bObject
   put exists (bObject) into bExists
   return bExists is true
end disabled_SetViewCardBehavior

getprop disabled_EditViewCardBehavior [someView]
   put the card_Object of someView into cardObject
   put the behavior of cardObject into bObject
   put exists (bObject) into bExists
   return bExists is false
end disabled_EditViewCardBehavior

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

on menu_ModuleTools templateView
   put the view_Name of templateView into moduleName
   put the stack_Name of templateView into moduleName
   --
   display_ModuleTools moduleName
end menu_ModuleTools

on menu_DisplayViewTools templateView
   put the module_Name of templateView into moduleName
   put the project_Name of templateView into projectName
   --
   display_ModuleFromShortModuleFolder shortModuleFolder, projectName
end menu_DisplayViewTools

on menu_ReIndexMenus templateView
   module_ReIndexMenus templateView
end menu_ReIndexMenus

on menu_OpenSubstack someView, substackName
   go to stack substackName
end menu_OpenSubstack
