script "Global_Script_Dep_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Dep_Menu
type: controller
version: 0.1

/*
This menu is for processing whole scripts to extract their dependencies.
*/

--> Variables
-
local LocalArray


--> Global | Script | Dep | Menu
-
on menu_CreateProjectSvg scriptObject, projectName
   -- this indexes a "project" not a script
   local pGraphStyle, pProcessObject, pForceCreate
   
   display_IndexScriptAndDisplaySVG scriptObject, projectName, pGraphStyle, pProcessObject, true
   put the result into imageFile
   
   put the textStack_HkeyArray of scriptObject into processedHkeyArray
   -- display_HkeyArray processedHkeyArray, scriptObject
   display_ScriptHkeyArray processedHkeyArray, scriptObject
end menu_CreateProjectSvg

on menu_DisplayProjectSvg scriptObject
   put the project_SvgFile of scriptObject into svgFile
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      display_SVG svgFile
   end if
end menu_DisplayProjectSvg

on _
end _

-- on menu_CreateScriptSvg scriptObject
   display_ScriptObject scriptObject
end menu_CreateScriptSvg

-- on menu_DisplayScriptSvg scriptObject
   put the script_SvgFile of scriptObject into svgFile
   display_SVG svgFile
end menu_DisplayScriptSvg

-- on insert_UploadScriptOnlyLibrary
   return "Global | Rig | Files | Menu"
end insert_UploadScriptOnlyLibrary

on _
end _

on menu_DisplayTextStackHkeyArray scriptObject
   put the textStack_HkeyArray of scriptObject into processedHkeyArray
   display_HkeyArray processedHkeyArray, scriptObject
end menu_DisplayTextStackHkeyArray

on menu_DisplayScriptHkeyArray scriptObject
   put the textStack_HkeyArray of scriptObject into processedHkeyArray
   display_ScriptHkeyArray processedHkeyArray, scriptObject
end menu_DisplayScriptHkeyArray

on menu_DisplayTextstackHkeyObjectArray scriptObject
   put the textstack_HkeyObjectArray of scriptObject into depObjectArray
   display_Array depObjectArray, "the textstack_HkeyObjectArray"
end menu_DisplayTextstackHkeyObjectArray

on _
end _

on menu_ScriptLibraryDependencies scriptObject
   -- put the missing_HkeyArray of scriptObject into missingHkeyArray
   put the script_DepLibs of scriptObject into dependencyStacks
   display_Index dependencyStacks
end menu_ScriptLibraryDependencies

on menu_DisplayStackDepArray scriptObject
   put the stack_Object of scriptObject into stackObject
   display_StackDeps stackObject
end menu_DisplayStackDepArray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-


--> Global | Script | Dep | Menu | Props
-
getprop project_Name [scriptObject]
   put the project_Name of scriptObject into projectName
   return projectName
end project_Name

getprop project_Names
   put library_ListProjectNames() into projectNames
   return projectNames
end project_Names


--> Global | Script | Dep | Menu | Disabled
-
getprop disabled_DisplayProjectSvg [scriptObject]
   put the project_SvgFile of scriptObject into svgFile
   if there is a file svgFile then
      return false
   else
      return true
   end if
end disabled_DisplayProjectSvg
