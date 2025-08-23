script "Global | Project | Stack | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Stack | Menu
type: controller
target: stackObject
version: 0.4

/*
First section uses code from "lib_DisplayGraph"
This depends on "projectOverlay_File ["processedHkey.array"]" 
which is a complicated hArray based walk using "deps_SaveMainstackAndExportArrays"

The menu was originally designed to work with indexViews of project stacks,
but can equally be used directly in the ScriptEditor.
*/


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   -- 
   switch
      case exists (displayView) is false
         put the stack_Object of tObject into stackObject
         return stackObject
         break
      case word 1 of tObject = "widget"
         put the displayed_Object of displayView into stackObject
         if exists (stackObject) is false then
            put the selected_Line of tObject into stackName
            if exists (stack stackName) then
               put the name of stack stackName into stackObject
               return stackObject
            else
               return empty
            end if
         else
            return stackObject
         end if
      default
         put the selected_Line of displayView into projectName
         put the name of stack projectName into stackObject
         return stackObject
   end switch
end menu_Target

getprop useStack_Param [stackObject]
   set the wholematches to true
   put the short name of stackObject is among the lines of the stacksinuse into isUsed
   return isUsed
end useStack_Param

getprop useStack_Params [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames
end useStack_Params

getprop disabled_Index [stackObject]
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


--> Global | Project | Stack | Menu
-
on menu_GraphProject stackObject
   graph_Project stackObject
end menu_GraphProject

on menu_GraphScript stackObject
   breakpoint
   graph_Project stackObject
end menu_GraphScript

on submenu_Index
   return "Global | Project | Stack | Tree | Menu"
end submenu_Index

on _
end _

on menu_GoToStack stackObject
   object_GoTo stackObject
end menu_GoToStack

on menu_EditStackScript stackObject
   edit the script of stackObject
end menu_EditStackScript

on menu_UseStack stackObject
   if the stack_IsUsed of  stackObject is false then
      start using stackObject
      lcw_Notify merge ("Started using [[stackObject]]")
   else
      stop using stackObject
      lcw_Notify merge ("Stopped using [[stackObject]]")
   end if
end menu_UseStack

getprop checked_UseStack [stackObject]
   return the stack_IsUsed of  stackObject
end checked_UseStack

on _
end _

on menu_DisplaySubstack stackObject, subStackName
   put the short name of stackObject into stackName
   go to stack subStackName of stack stackName
end menu_DisplaySubstack

on menu_TrashStack stackObject
   ask_TrashProjectStack stackObject
end menu_TrashStack

on _
end _

on menu_DisplayStackDeps stackObject
   display_StackDeps stackObject
end menu_DisplayStackDeps

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
*/
