script "Global_HkeyArray_Tree_Deps_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Tree_Deps_Menu
type: controller
version: 0.4

/*
This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
on menu_Init tObject
   put the tree_View of tObject into treeView
   put treeView into LocalArray ["tree_View"]
   -- put the displayed_Object of treeView into stackObject
   put the displayed_Array of treeView into displayedArray
   put displayedArray into LocalArray ["displayedArray"]
   put displayedArray ["Handlers"] into LocalArray ["hkeyShortArray"]
end menu_Init

function script_ListComponentObjects
   -- stub for now
   put the name of stack "View|Menu|Button" into componentObjects
   put CR & the behavior of stack "View|Menu|Button" after componentObjects
   return componentObjects
end script_ListComponentObjects

function stack_ListUsed
   put the stacksinuse into stackNames
   repeat for each line stackName in stackNames
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_ListUsed

command _DisplaySVG imageFile, scriptObject
   display_SVG imageFile, scriptObject
   put the result into displayView
   set the displayed_Object of displayView to scriptObject
end _DisplaySVG

getprop call_ProjectNames [treeView]
   put LocalArray ["tree_View"] into treeView
   
   put the displayed_Array of treeView into  displayedArray
   put displayedArray ["Calls"] into callProjectArray
   return keys (callProjectArray)
end call_ProjectNames

getprop new_ProjectName [treeView]
   put the displayed_Object of treeView into stackObject
   put the project_Name of stackObject into projectName
   return projectName
end new_ProjectName

getprop new_ProjectNames
   return library_ListProjectNames()
end new_ProjectNames

getprop active_Projects
   put env_ListProjects() into activeProjects
end active_Projects

getprop include_HandlersFrom
   lock messages
   put the include_HandlersFrom of me into includeHandlersFrom
   unlock messages
   if includeHandlersFrom is empty then return "stack"
   return includeHandlersFrom
end include_HandlersFrom

setprop include_HandlersFrom includeHandlersFrom
   lock messages
   set the include_HandlersFrom of me to includeHandlersFrom
   unlock messages
end include_HandlersFrom

getprop include_HandlersFroms
   get "none,-,stack,application,development,-,full"
   replace comma with CR in it
   return it
end include_HandlersFroms

getprop disabled_CreateLongHkeyArray [treeView]
   put the displayed_Hkey of treeView into hKey
   return hKey is empty
end disabled_CreateLongHkeyArray



--> Global | HkeyArray | Tree | Deps | Menu
-
on menu_ProjectDepStacks treeView, callProjectName
   put LocalArray ["tree_View"] into treeView
   
   put the displayed_Array of treeView into  displayedArray
   put displayedArray ["Calls"][callProjectName] into stackNameArray
   repeat for each key stackObject in stackNameArray
      put the short name of stackObject & CR after depStackNames
   end repeat
   delete char -1 of depStackNames
   replace CR with comma in depStackNames
   put depStackNames
end menu_ProjectDepStacks

on menu_MoveUsed treeView, newProjectName
   put the displayed_Object of treeView into stackObject
   
   put the project_Name of stackObject into oProjectName
   if oProjectName = newProjectName then
      answer warning "Choose a new project to move this library to!"
      exit to top
   end if
   
   put the short name of stackObject into stackName
   project_MoveStackRelative stackName, newProjectName
   put the result into newPath
   
   put the stack_Object of treeView into displayStackObject
   set the label of displayStackObject to newProjectName
   -- set the displayed_Object of treeView into stackObject
   
   lcw_Notify merge ("Moved library to new project '[[newProjectName]]'!")
end menu_MoveUsed

on menu_EditStackScript treeView
   put the displayed_Object of treeView into stackObject
   edit the script of stackObject
end menu_EditStackScript

on menu_DeleteStack treeView
   put the displayed_Object of treeView into stackObject
   put the mainstack of stackObject into stackName
   put the substacks of stack stackName into substackNames
   if substackNames is not empty then
      display_Index substackNames, "Substacks"
   end if
   lcw_Answer merge ("Are you sure you want to delete the stack '[[stackName]]' from disk?")
   
   put the effective filename of stack stackName into stackPath
   delete stack stackName
   delete file stackPath
end menu_DeleteStack

on _
end _

on menu_ExternalCallGraph scriptObject
   put LocalArray ["hkeyShortArray"] into hkeyShortArray
   --
   graph_CreateFromScriptHkeyArray hkeyShortArray, scriptObject, "fast undirected spring"
   put the result into imageFile
   _DisplaySVG imageFile, scriptObject
end menu_ExternalCallGraph

on menu_ObjectDependencyGraph scriptObject
   put LocalArray ["hkeyShortArray"] into hkeyShortArray
   put hkeyArray_ShortToLong (hkeyShortArray) into hKeyArray
   --
   graph_CreateFromScriptHkeyArray hKeyArray, scriptObject, "fast undirected spring"
   put the result into imageFile
   _DisplaySVG imageFile, scriptObject
end menu_ObjectDependencyGraph

on _
end _

on menu_DisplayHkeyArray stackObject
   -- put the displayed_Object of treeView into stackObject
   -- put the displayed_Array of treeView into displayedArray
   
   put LocalArray ["displayedArray"] into displayedArray
   put displayedArray ["Handlers"] into hkeyShortArray
   --
   display_Array hkeyShortArray, "Short"
   --
   put hkeyArray_ShortToLong (hkeyShortArray) into hKeyArray
   display_Array hkeyArray, "Long"
end menu_DisplayHkeyArray

on submenu_CreateGraph
   return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

on submenu_Export
   return "Global | Project | Export | Menu"
end submenu_Export

on submenu_Place
   return "Global | Place | Menu"
end submenu_Place

on _
end _

on _CollectDependencyScript treeView
   breakpoint
   local stripObjects, stripProps, stripComponents
   
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
    
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, stripObjects, stripProps, stripComponents
   put the result into someArray
   
   put someArray ["uniqueHkeys"] into uniqueHkeys
   put someArray ["duplicateHkeyArray"] into duplicateHkeyArray
   put someArray ["missingHkeys"] into missingHkeys
   
   display_Lines uniqueHkeys, "uniqueHkeys"
   if missingHkeys is not empty then display_Lines missingHkeys, "missingHkeys"
   display_Array duplicateHkeyArray, "duplicateHkeyArray"
end _CollectDependencyScript

on _
end _

on menu_StripHkeyProps scriptObject, someBoolean
   pref_SetValue "skip_HkeyProps", someBoolean
end menu_StripHkeyProps

on menu_StripHkeyComponents scriptObject, someBoolean
   pref_SetValue "skip_HkeyComponents", someBoolean
end menu_StripHkeyComponents

on menu_IncludeHandlersFrom scriptObject, includeHandlersFrom
   set the include_HandlersFrom of me to includeHandlersFrom
end menu_IncludeHandlersFrom

on _
end _

on menu_CreateAndExportHkeyGraphs treeView
   put the displayed_Array of treeView into hKeyArray
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   repeat for each key hKey in hKeyArray
      set the cursor to busy
      put hkeyArray_ExtractSubArray (hKey, hkeyArray) into hkeySubArray
      library_CreateHkeyGraph hKey, hKeyArray, "hierarchical"
   end repeat
end menu_CreateAndExportHkeyGraphs

on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | HkeyArray | Tree | Deps | Menu")
end submenu_Dev


--> Dev | Menu
-
on menu_SearchSetFirst scriptObject, setName
   lock messages
   set the set_Name of me to setName
   unlock messages
   return setName
end menu_SearchSetFirst

getprop set_Name
   lock messages
   put the set_Name of me into setName
   unlock messages
   return setName
end set_Name

getprop set_Names
   return library_ListProjectNames()
end set_Names

on menu_DisplayCollectedDependencies treeView
   put the displayed_DependencyWalkArray of treeView into dependencyWalkArray
   put dependencyWalkArray ["hKeyArray"] into dependencyHkeyArray
   put array_ListKeys (dependencyHkeyArray) into allDeps
   
   put the displayed_Object of treeView into mainStackObject
   put "Nested Deps for" && mainStackObject into someTitle
   set the tree_Display [someTitle] of treeView to allDeps
end menu_DisplayCollectedDependencies

on menu_ConstructMenuLibraryHandlers treeView
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put "menu_PopUp,c|menu_PullDown,c|menu_SendMessage,c" into shortHkeys
   set the itemdelimiter to "|"
   repeat for each item shortHkey in shortHkeys
      put the found_Call [shortHkey] of scriptObject & CR after hKeys
   end repeat
   delete char -1 of hKeys
   
   put hkey_DependencyArrayFromObjects (hKeys) into hkeyArray
   
   display_ObjectDepArray scriptObject, hkeyArray, "pop,pull,send"
   return empty
   
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put pref_GetValue ("skip_HkeyComponents") is not false into stripComponents
   put pref_GetValue ("skip_HkeyProps") is not false into stripProps
   
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, false, stripProps
   put the result into missingKeys
end menu_ConstructMenuLibraryHandlers
