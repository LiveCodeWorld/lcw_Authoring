script "Global | Stack | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Stack | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Stack | Dev | Menu
-
on menu_PlaceOnMainScreen mTarget, openStackName
   switch openStackName
      case "LiveCode Dictionary"
         stack_SetToMainScreen "revDictionary"
         go to stack "revDictionary"
         break
      case "Script Editors"
         put the openstacks into stackNames
         filter stackNames with "revNewScriptEditor *"
         repeat for each line stackName in stackNames
            stack_SetToMainScreen stackName
         end repeat
         break
      case "All open stacks"
         put the openstacks into stackNames
         stack_SetToMainScreen stackNames
         break
      default
         stack_SetToMainScreen openStackName
         show stack openStackName
   end switch
end menu_PlaceOnMainScreen

private on _
end _

on menu_Shrink sObject
   if the shiftKey is down then
      put lcw_Ask ("What scalefactor do you want to use?", 0.75) into someFactor
   else
      put 0.75 into someFactor
   end if
   stack_Shrink sObject, someFactor
end menu_Shrink

on menu_Unshrink sObject
   if the shiftKey is down then
      put the stack_Name of sObject into stackName
      put the scalefactor of stack stackName into oFactor
      put lcw_Ask ("What scalefactor do you want to use?", oFactor) into someFactor
   else
      put 1 into someFactor
   end if
   stack_Shrink sObject, someFactor
end menu_Unshrink

private on __
end __

on menu_TextstackHkeyObjectArray sObject
   put the stack_Object of sObject into stackObject
   put the textstack_HkeyObjectArray of stackObject into depObjectArray
   display_Array depObjectArray
end menu_TextstackHkeyObjectArray

on menu_ScriptLibraryDependencies sObject
   put the stack_Object of sObject into stackObject
   put the script_DepLibs of stackObject -- into dependencyStacks
end menu_ScriptLibraryDependencies

private on ___
end ___

on submenu_ViewSnapshot
   return "Global | View | Wireframe | Menu"
end submenu_ViewSnapshot

on submenu_Snapshot
   return "Global | Stack | Snapshot | Menu"
end submenu_Snapshot
