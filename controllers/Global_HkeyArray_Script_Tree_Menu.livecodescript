script "Global_HkeyArray_Script_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Script_Tree_Menu
type: controller
version: 0.1

--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init tObject
   put the tree_View of tObject into treeView
   
   put the displayed_Object of treeView into LocalArray ["scriptObject"]
   put the displayed_HkeyArray of treeView into LocalArray ["hKeyArray"]
   put the displayed_ObjectHKeyArray of treeView into LocalArray ["objectTreeArray"]
end menu_Init


--> Global | HkeyArray | Script | Tree | Menu
-
on menu_CollectDependencyScript treeView
   local stripObjects, stripProps, stripComponents
   
   put LocalArray ["scriptObject"] into scriptObject
   put LocalArray ["hKeyArray"] into hkeyArray
   -- put LocalArray ["objectTreeArray"] into objectTreeArray
   
   set the cursor to watch
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, stripObjects, stripProps, stripComponents
   put the result into someArray
   
   put someArray ["uniqueHkeys"] into uniqueHkeys
   put someArray ["duplicateHkeyArray"] into duplicateHkeyArray
   put someArray ["missingHkeys"] into missingHkeys
   
   display_Outline uniqueHkeys, "uniqueHkeys"
   if missingHkeys is not empty then display_Outline missingHkeys, "missingHkeys"
   display_Array duplicateHkeyArray, "duplicateHkeyArray"
end menu_CollectDependencyScript

on _
end _

on menu_DisplayObjectArray treeView
   put the displayed_HkeyArray of treeView into hkeyArray
   put LocalArray ["hKeyArray"] into hkeyArray
   
   put the displayed_Hkey of treeView into hKey
   if hKey is empty then
      put the displayed_Object of treeView into hObject
      display_ObjectDepArray hObject, hkeyArray
   else
      display_ObjectDepArray hKey, hkeyArray
   end if
end menu_DisplayObjectArray

on menu_ScriptProjectDependencyArray treeView
   put LocalArray ["scriptObject"] into scriptObject
   put LocalArray ["objectTreeArray"] into objectTreeArray
   
   delete variable objectTreeArray ["Missing"]
   put keys (objectTreeArray) into stackObjects
   repeat for each line stackObject in stackObjects
      put the project_Name of stackObject into projectName
      put objectTreeArray [stackObject] into scriptProjectDependencyArray [projectName][stackObject]
   end repeat
   
   put scriptObject & comma & "Script Project Dependency Array" into someTitle
   display_Array scriptProjectDependencyArray, someTitle
end menu_ScriptProjectDependencyArray

on _
end _

on submenu_Filter
   return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_Filter

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | HkeyArray | Script | Tree | Menu | Props
-

--> Global | HkeyArray | Script | Tree | Menu | Disabled
-

--> Dev | Menu
-
on submenu_CreateGraph
   return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

-- on submenu_Deps
-- has some error in it
return "Global | HkeyArray | Tree | Deps | Menu"
end submenu_Deps

