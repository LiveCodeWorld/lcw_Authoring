script "Global | HkeyArray | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Line | Menu
type: controller
version: 0.1


--> Menu | Props
-
local LocalArray

private command _AddGraphHeader
   -- put graphHeader into dotText
   line_Insert nodeSection, dotText
   
end _AddGraphHeader

private command _SetArrays dView, @hkeyArray, @depKey
   put the displayed_HkeyArray of dView into hkeyArray
   get the selected_path of dView
   if item 1 of it is "Missing" then breakpoint
   put item 3 of it into depKey
   --
   hkey_Deconstruct depKey, hName, hType, hObject, hNum
   return hObject
end _SetArrays


--> Global | HkeyArray | Line | Menu
-
on menu_CreateSvgGraph dView
   _SetArrays dView, hkeyArray, depKey
   put the result into scriptObject
   --
   put adata_GetMarkovArray (depKey, hkeyArray) into markovArray
   
   graph_CreateScriptObjectHkeyArray markovArray, scriptObject, "fast undirected spring"
   put the result into imageFile
   
   display_SVG imageFile, scriptObject
   put the result into displayView
end menu_CreateSvgGraph

on _
end _

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


--> Deev | Menu
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
