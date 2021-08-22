script "Global | HkeyArray | Script | Tree | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Script | Tree | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the tree_View of tObject into treeView
   put treeView into LocalArray ["treeView"]
   
   -- stack "model_GlobalMenu",F menu_GetGlobalArray,
   put the hilited_Element of treeView into sPath
   put the number of items of sPath into LocalArray ["treeLevel"]
   
   put item 1 of sPath into stackObject
   put item 2 of sPath into shortHkey  
   put hkeyLine_Construct (shortHkey, stackObject) into hKey
   
   put stackObject into LocalArray ["stackObject"]
   put shortHkey into LocalArray ["shortHkey"]
   put hKey into LocalArray ["hKey"]
end menu_Target


--> Global | HkeyArray | Script | Tree | Line | Menu
-
on menu_Test displayedObject
   put LocalArray ["hKey"] into hKey
   put LocalArray ["treeLevel"]
end menu_Test

on _
end _

on menu_DeleteHkeys displayedObject
   put LocalArray ["treeView"] into treeView
   put LocalArray ["stackObject"] into stackObject
   put the selected_Value of treeView into stackShortHkeys
   
   repeat for each key shortHkey in stackShortHkeys
      put the script_Handler [shortHkey] of stackObject into someHandler
      set the script_Handler [shortHkey] of stackObject to empty
      put the script_Handler [shortHkey] of stackObject into testHandler
      
      put hkeyLine_Construct (shortHkey, stackObject) into stackHkey
      put stackHkey & CR after deletedHkeys
   end repeat
   display_Index deletedHkeys
end menu_DeleteHkeys

getprop disabled_DeleteHkeys
   if LocalArray ["treeLevel"] = 1 then
      return false
   else
      return true
   end if
end disabled_DeleteHkeys
