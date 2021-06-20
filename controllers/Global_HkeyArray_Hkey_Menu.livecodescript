script "Global | HkeyArray | Hkey | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Hkey | Menu
type: controller
version: 0.6

/*For trees displaying HkeyArrays of object scripts.*/


--> Variables
-
local LocalArray


--> Global | HkeyArray | Hkey | Menu
-
on menu_Test hObject
   put LocalArray ["tree_View"] into treeView
   put the displayed_Array of treeView into displayedArray
   put the displayed_Hkey of displayView into hkey
   -- put the title_Text of treeView into hName
end menu_Test

on _
end _

on submenu_Hkey
   return "Global | Tree | HkeyArray | Menu"
end submenu_Hkey

on submenu_CreateGraph
   return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph
