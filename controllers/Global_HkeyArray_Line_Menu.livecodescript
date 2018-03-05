script "Global_HkeyArray_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Line_Menu
type: controller
version: 0.1


--> Menu | Props
-
local LocalArray

on menu_Init tObject
   put the array_View of tObject into LocalArray ["arrayVew"]
end menu_Init


--> Global | HkeyArray | Line | Menu
-
on menu_CollectPrivateHandlers scriptObject
   put LocalArray ["arrayVew"] into arrayVew
   put the diplayed_Array of arrayVew into objectHkeyArray
   put the selected_Path of arrayVew into pathItems
   put item 1 of pathItems into stackObject
   if the number of items of pathItems = 1 then
      put the selected_Value of arrayVew into selectedValue
      put keys (selectedValue) into shortKeys
      put hkey_FromShort (shortKeys, stackObject) into depHkeys
      
      -- put hkey_ConstructDepArray (depHkeys) into depArray
      -- put depArray ["depSuite"] into depSuite
      
      put script_FromHkeys (depHkeys, true) into depScript
      put script_ConstructSuite ("Deps", depScript) into depSuite
      
      display_Text depSuite, stackObject
   else
      
   end if
end menu_CollectPrivateHandlers

getprop disabled_CollectPrivateHandlers [scriptObject]
   put LocalArray ["arrayVew"] into arrayVew
   put the selected_Path of arrayVew into pathItems
   put item 1 of pathItems into stackObject
   switch stackObject 
      case "midding"
         return true
      default
         return false
   end switch
end disabled_CollectPrivateHandlers


--> Global | HkeyArray | Line | Menu | Props
-

--> Global | HkeyArray | Line | Menu | Disabled
-
