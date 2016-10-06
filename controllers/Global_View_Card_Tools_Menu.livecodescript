script "Global_View_Card_Tools_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Card_Tools_Menu
type: controller
version: 0.1

--> Variables
-
local LocalArray


--> Global | View | Card | Tools | Menu
-
on submenu_ViewAuthoring
   return "Global | View | Authoring | Menu"
end submenu_ViewAuthoring

on submenu_Geometry
   return "Global | View | Test | Geometry | Menu"
end submenu_Geometry

on submenu_ViewProperty
   return "Global | View | Property | Menu"
end submenu_ViewProperty

on submenu_ViewScript
   return "Global | View | Script | Menu"
end submenu_ViewScript

on _
end _

on menu_DisplayViewTools
   display_ModuleFromName moduleName, projectName
end menu_DisplayViewTools

on menu_OpenSubstack someView, substackName
   go to stack substackName
end menu_OpenSubstack


--> Global | View | Card | Tools | Menu | Disabled
-
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


--> Global | View | Card | Tools | Menu | Props
-
getprop substack_Names [someView]
   return LocalArray ["substackNames"]
end substack_Names
