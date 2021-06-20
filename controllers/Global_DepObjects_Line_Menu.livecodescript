script "Global_DepObjects_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_DepObjects_Line_Menu
type: controller
version: 0.2


--> Global | DepObjects | Line | Menu
-
on menu_DeleteLine indexView
   put the hilited_Lines of indexView into lineNum
   put the displayed_Index of indexView into depObjects
   delete line lineNum of depObjects
   set the displayed_Index of indexView to depObjects
end menu_DeleteLine

on menu_DisplayObjectHkeys indexView
   put the selected_Line of indexView into depObject
   
   put the displayed_HkeyArray of indexView into hkeyArray
   put the displayed_ObjectHkeyArray of indexView into objectHkeyArray
   
   put objectHkeyArray [depObject] into depKeyArray
   put keys (depKeyArray) into shortObjectDepKeys
   --
   display_Lines shortObjectDepKeys, "shortObjectDepKeys"
end menu_DisplayObjectHkeys


--> Global | DepObjects | Line | Menu | Props
-

--> Global | DepObjects | Line | Menu | Disabled
-
