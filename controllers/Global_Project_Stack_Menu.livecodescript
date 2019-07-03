script "Global | Project | Stack | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Stack | Menu
type: controller
version: 0.4


--> Global | Project | Stack | Menu
-
/*
First section uses code from "lib_DisplayGraph"
This depends on "projectOverlay_File ["processedHkey.array"]" 
which is a complicated hArray based walk using "deps_SaveMainstackAndExportArrays"

The menu was originally designed to work with indexViews of project stacks,
but can equally be used directly in the ScriptEditor.
*/

on menu_GraphScript stackObject
   graph_Project stackObject
end menu_GraphScript

on _
end _

on menu_GoToStack stackObject
   object_GoTo stackObject
end menu_GoToStack

on menu_EditStackScript stackObject
   put the name of stackObject
   edit the script of stackObject
end menu_EditStackScript

on menu_UseStack stackObject, someBoolean
   if someBoolean is true then
      start using stackObject
      lcw_Notify merge ("Started using [[stackObject]]")
   else
      stop using stackObject
      lcw_Notify merge ("Stopped using [[stackObject]]")
   end if
end menu_UseStack

on _
end _

on menu_TrashStack stackObject
   put merge ("Are you sure you want to delete the file, and remove the [[stackObject]] from all projects?") into someQuestion
   answer someQuestion with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   put the filename of stackObject into longStackFile
   
   breakpoint
   /*
   -- lets not bother doing this automatically
   library_RemoveStackFromAllProjects stackObject
   */
   
   stop using stackObject
   set the stack_IsKnow of stackObject to false -- do this for all projects ?
   --
   delete stackObject
   delete file longStackFile
   --
   breakpoint
   put menu_GetTargetObject() into tObject
   put the index_View of tObject into indexView
   if exists (indexView) then
      dispatch "refresh" to _indexView()
   end if
end menu_TrashStack

on menu_DisplaySubstack stackObject, subStackName
   put the short name of stackObject into stackName
   go to stack subStackName of stack stackName
end menu_DisplaySubstack

on _
end _

on submenu_Index
   return "Global | Project | Stack | Tree | Menu"
end submenu_Index

on submenu_Deps
   return "Deps | Menu"
end submenu_Deps


--> Deps | Menu
-
on menu_StackDeps stackObject
   display_StackDeps stackObject
end menu_StackDeps

on _
end _

on menu_RevealProjectOverlayFolder stackObject
   put the project_OverlayFolder of stackObject into projectOverlayFolder
   put projectOverlayFolder
   finder_Reveal projectOverlayFolder
end menu_RevealProjectOverlayFolder

on menu_DisplayDependencyObjectArray stackObject
   put the textstack_HkeyObjectArray of stackObject into depObjectArray
   display_Array depObjectArray
end menu_DisplayDependencyObjectArray

on menu_ScriptLibraryDependencies stackObject
   -- in "lib_DisplayGraph" (depends on hArray based walk and "deps_SaveMainstackAndExportArrays")
   put the script_DepLibs of stackObject -- into dependencyStacks
end menu_ScriptLibraryDependencies


--> Global | Project | Stack | Menu | Props
-
getprop use_Stack [stackObject]
   set the wholematches to true
   put the short name of stackObject is among the lines of the stacksinuse into isUsed
   return isUsed
end use_Stack

getprop sub_StackNames [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames
end sub_StackNames


--> Global | Project | Stack | Menu | Disabled
-
getprop disabled_Index [scriptObject]
   put the index_View of the target into indexView
   return indexView is empty
end disabled_Index

getprop disabled_DisplayDependencyObjectArray [stackObject]
   put the projectOverlay_File ["processedHkey.array"] of stackObject into processedHkeyArrayFile
   put there is a file processedHkeyArrayFile into fileExists
   return fileExists is false
end disabled_DisplayDependencyObjectArray

getprop disabled_DependencyObjects [stackObject]
   put the projectOverlay_File ["processedHkey.array"] of stackObject into processedHkeyArrayFile
   put there is a file processedHkeyArrayFile into fileExists
   return fileExists is false
end disabled_DependencyObjects

getprop disabled_TrashStack [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames is not empty
end disabled_TrashStack

getprop disabled_DisplaySubstack [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames is empty
end disabled_DisplaySubstack
