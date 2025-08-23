script "Global | View | Card | Tools | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | View | Card | Tools | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   if the stack_IsDisplay of tObject then
      put the display_View of tObject into displayView
      put the displayed_Object of displayView into templateView
      return templateView     
   end if
   
   put the card_Object of tObject into cardObject
   put cardObject into LocalArray ["cardObject"]
   --
   if exists (control 1 of cardObject) is true then
      put the long id of control 1 of cardObject into templateView
      return templateView
   else
      return cardObject
   end if
end menu_Target


--> Global | View | Card | Tools | Dev | Menu
-
on menu_DisplayModuleProject templateView
   put the project_Name of templateView into projectName
   --
   display_Project projectName
end menu_DisplayModuleProject

on menu_ReindexMenus templateView
   module_ReIndexMenus templateView
end menu_ReindexMenus

on menu_OpenSubstack someView, substackName
   go to stack substackName
end menu_OpenSubstack
