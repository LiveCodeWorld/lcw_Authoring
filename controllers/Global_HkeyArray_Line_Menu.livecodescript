script "Global | HkeyArray | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Line | Menu
type: controller
version: 0.2


--> Menu | Events
-
command mDoubleUp_HkeyArray dView, someValue, sPath
   if the optionKey is "Down" then breakpoint
   --
   switch 
      case line 1 of sPath = "Missing"
         --  put line 4 of sPath into hKey
         put someValue into hKey
         break
      default
         put line 3 of sPath into hKey
   end switch
   --
   hkey_Edit hKey
end mDoubleUp_HkeyArray


--> Menu | Props
-
local LocalArray

private command _SetArrays dView, @hkeyArray, @depKey
   put the displayed_HkeyArray of dView into hkeyArray
   get the selected_path of dView
   if item 1 of it is "Missing" then breakpoint
   put item 3 of it into depKey
   --
   hkey_Deconstruct depKey, hName, hType, hObject, hNum
   return hObject
end _SetArrays

private function _HkeyArray dView
   return the displayed_HkeyArray of dView
end _HkeyArray

private function  _SelectedStack treeView
   put the selected_Path of treeView into sPath
   put item 1 of sPath into stackObject
   return stackObject
end _SelectedStack

private function  _SelectedHkey treeView
   put the selected_Path of treeView into sPath
   put item 2 of sPath into hKey
   return stackObject
end _SelectedHkey

private function _ShowHow treeView
   put the data_View of treeView into dView
   put the show_How of dView into showHow
   return showHow
end _ShowHow


--> Global | HkeyArray | Line | Menu
-
on menu_DeleteStackKeys treeView
   put the displayed_Data of treeView into stackArray
   put _SelectedStack (treeView) into sObject
   delete variable stackArray [sObject]
   --
   set the displayed_Data of treeView to stackArray
end menu_DeleteStackKeys

getprop disabled_DeleteStackKeys [treeView]
   put _ShowHow (treeView) into showHow
   return showHow is not "stacks"
end disabled_DeleteStackKeys

on menu_CollectStackHandlers treeView
   put the top_Array of treeView into topArray
   put keys (topArray) into stackKeys
   --
   put _SelectedStack (treeView) into sObject
   display_CollectedHkeys stackKeys, sObject
end menu_CollectStackHandlers

on menu_CreateSvgGraph dView
   _SetArrays dView, hkeyArray, depKey
   put the result into scriptObject
   --
   put adata_GetMarkovArray (depKey, hkeyArray) into markovArray
   
   graph_CreateFromScriptHkeyArray markovArray, scriptObject, "fast undirected spring"
   put the result into imageFile
   
   display_SVG imageFile, scriptObject
   put the result into displayView
end menu_CreateSvgGraph

on _
end _

on submenu_Dev
   return "Global | HkeyArray | Line | Dev | Menu"
end submenu_Dev

on menu_MarkovArray dView
   _SetArrays dView, hkeyArray, depKey
   --
   put adata_GetMarkovArray (depKey, hkeyArray) into markovArray
   --
   display_HkeyArray depKey, markovArray, "Markov"
end menu_MarkovArray

on menu_SubArray dView
   _SetArrays dView, hkeyArray, depKey
   --
   put adata_GetChildArray (depKey, hKeyArray) into childArray
   display_HkeyArray depKey, childArray, "Sub-array"
end menu_SubArray

on menu_ParentAndChildArray dView
   _SetArrays dView, hkeyArray, depKey
   --
   put adata_GetParentAndChildArray (depKey, hKeyArray) into parentArray
   display_HkeyArray depKey, parentArray, "Parents"
end menu_ParentAndChildArray

on _
end _

on menu_SimpleGraph dView
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put dot_FromLinkArray (hkeyArray) into dotText
   dot_CreateGraph dotText
   put the result into svgFile
   --
   display_SVG svgFile
   --
   -- finder_Reveal svgFile
   -- display_Text dotText
end menu_SimpleGraph

on menu_CollectPrivateHandlers scriptObject
   breakpoint
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

-- getprop disabled_CollectPrivateHandlers [scriptObject]
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
