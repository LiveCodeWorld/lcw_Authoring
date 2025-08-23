script "Global | DepObjects | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | DepObjects | Tree | Menu
type: controller
version: 0.2


--> Menu | Init
-
command display_HkeySvg hKey
   put hkey_SvgFile (hKey) into svgFile
   put hkey into stackLabel
   display_SVG svgFile, stackLabel
end display_HkeySvg


--> Global | DepObjects | Tree | Menu
-
on menu_DisplayStoredDepArray indexView
   put the displayed_HkeyArray of indexView into hkeyArray
   put the displayed_ObjectHkeyArray of indexView into objectHkeyArray
   -- put the displayed_Object of treeView into hObject
   put the displayed_Hkey of indexView into hKey
   
   display_HkeyDepArray hKey
end menu_DisplayStoredDepArray

on menu_DisplayHkeySvg indexView
   put the displayed_Hkey of indexView into hKey
   display_HkeySvg hKey
end menu_DisplayHkeySvg

on _
end _

on menu_RedrawHkeyDepGraph indexView
   put the displayed_Hkey of indexView into hKey
   put the displayed_Index of indexView into searchHierarchy
   
   set the behavior of stack "Temp Revigniter Controllers" to empty
   hkey_RedrawAndDisplayDeps hkey, searchHierarchy, true
   
   display_HkeySvg hKey
   -- set the behavior of stack "Temp Revigniter Controllers" to the long id of stack "behavior_RigLocalOveride"
end menu_RedrawHkeyDepGraph

on menu_CreateHandlerObjectGraph indexView
   put the displayed_Hkey of indexView into hKey
   
   -- put empty into projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   
   set the behavior of stack "Temp Revigniter Controllers" to empty
   hkey_CreateAndDisplayDeps hkey, projectName
   put hkey_SvgFile (hKey) into svgFile
   finder_Reveal imageFile
   
   -- set the behavior of stack "Temp Revigniter Controllers" to the long id of stack "behavior_RigLocalOveride"
end menu_CreateHandlerObjectGraph
