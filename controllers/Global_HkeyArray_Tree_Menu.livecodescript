script "Global_HkeyArray_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Tree_Menu
type: controller
version: 0.4


--> Global | HkeyArray | Tree | Menu
-
on menu_ProjectDepStacks treeView, callProjectName
   put the displayed_Array of treeView into  displayedArray
   put displayedArray ["Calls"][callProjectName] into stackNameArray
   repeat for each key stackObject in stackNameArray
      put the short name of stackObject & CR after depStackNames
   end repeat
   delete char -1 of depStackNames
   replace CR with (comma & space) in depStackNames
   put depStackNames
end menu_ProjectDepStacks

getprop call_ProjectNames [treeView]
   put the displayed_Array of treeView into  displayedArray
   put displayedArray ["Calls"] into callProjectArray
   return keys (callProjectArray)
end call_ProjectNames

on menu_CollectDeps treeView
   put the displayed_Array of treeView into hkeyArray
   put keys (hkeyArray)
end menu_CollectDeps

on _
end _

on menu_Display treeView, displayStyle
   put the view_Data of treeView into hkeyArray
   switch displayStyle
      case "Project Dependency Array"
         put hkeyArray_ToProjectDependencyArray (hkeyArray) into someArray
         break
      case "hKeyArray"
         put hkeyArray into someArray
         break
   end switch
   set the displayed_Array of treeView to someArray
   set the displayed_Style of treeView to displayStyle
end menu_Display

getprop display_Style [treeView]
   put the displayed_Style of treeView into displayStyle
   return displayStyle
end display_Style

on menu_DisplayDeps treeView
   put the displayed_Array of treeView into hkeyArray
   put hkeyArray_ToProjectDependencyArray (hkeyArray) into projectDependencyArray
   display_Array projectDependencyArray
end menu_DisplayDeps

on _
end _

on submenu_Create
   return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_Create

on submenu_Tree
   return "Global | Tree | HkeyArray | Menu"
end submenu_Tree
