script "Global_Stack_Menu"
--> MetaData
-
license: GPLv3
name: Global_Stack_Menu
type: controller
version: 0.3

--> Variables
-
local LocalArray

/*
Some basic tools for manipulating stacks, and windows. 
*/

--> Currently working On
-

--> Global | Stack | Menu
-
on menu_TextstackHkeyObjectArray scriptObject
   put the stack_Object of scriptObject into stackObject
   put the textstack_HkeyObjectArray of stackObject into depObjectArray
   display_Array depObjectArray
end menu_TextstackHkeyObjectArray

on menu_ScriptLibraryDependencies scriptObject
   put the stack_Object of scriptObject into stackObject
   put the script_DepLibs of stackObject -- into dependencyStacks
end menu_ScriptLibraryDependencies

on menu_StackProperties scriptObject
   revIDEInspectObjects scriptObject
end menu_StackProperties
         
on _
end _

on menu_EditOpenStack scriptObject, openStackName
   put the name of stack openStackName into stackObject
   object_Inspect stackObject
   edit the script of stack openStackName
end menu_EditOpenStack

on menu_StackIsUsed stackObject, someBoolean
   if someBoolean is true then
      start using stackObject 
   else
      stop using stackObject
   end if
end menu_StackIsUsed

on _
end _

on menu_GatherStacks
   screen_GatherStacks
end menu_GatherStacks

on menu_PlaceOnScreen scriptObject, whichScreen
   put the stack_Name of scriptObject into stackName
   put system_GetScreenRect (whichScreen) into pScreenRect
   stack_SetToMainScreen stackName, pScreenRect
end menu_PlaceOnScreen

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

on _
end _

on menu_RevealStack mTarget
   put the stack_Name of mTarget into stackName
   stack_RevealInFinder stackName
end menu_RevealStack

on menu_Shrink scriptObject
   if the shiftKey is down then
      put lcw_Ask ("What scalefactor do you want to use?", 0.75) into someFactor
   else
      put 0.75 into someFactor
   end if
   stack_Shrink scriptObject, someFactor
end menu_Shrink

on menu_Unshrink scriptObject
   if the shiftKey is down then
      put the stack_Name of scriptObject into stackName
      put the scalefactor of stack stackName into oFactor
      put lcw_Ask ("What scalefactor do you want to use?", oFactor) into someFactor
   else
      put 1 into someFactor
   end if
   stack_Shrink scriptObject, someFactor
end menu_Unshrink

on _
end _

on menu_StackStyle scriptObject, stackStyle
   put the stack_Object of scriptObject into stackObject
   set the style of stackObject to stackStyle
end menu_StackStyle

on menu_StackResizable scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
   set the resizable of stackObject to someBoolean
end menu_StackResizable

on menu_StackTitleStyle scriptObject, stackTitleStyle
   put the stack_Object of scriptObject into stackObject
   set the stack_TitleStyle of stackObject to stackTitleStyle
end menu_StackTitleStyle

on _
end _

on submenu_ViewSnapshot
   return "Global | View | Wireframe | Menu"
end submenu_ViewSnapshot

on submenu_Snapshot
   return "Global | Stack | Snapshot | Menu"
end submenu_Snapshot

on submenu_Tidy
   return "Global | Stack | Tidy | Menu"
end submenu_Tidy

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Stack | Menu | Props
-
getprop stack_IsUsed [stackObject]
   put the short name of stackObject into stackName
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_IsUsed

getprop which_Screens
   put system_ListScreenNames() into screenNames
   return screenNames
end which_Screens

getprop record_Card
   return LocalArray ["isRecoring"] is true
end record_Card

getprop stack_Resizable [scriptObject]
   put the stack_Object of scriptObject into stackObject
   put the resizable of stackObject into someBoolean
   return someBoolean
end stack_Resizable

getprop open_StackName [mTarget]
   put the stack_Name of mTarget into openStackName
   return openStackName
end open_StackName

getprop open_StackNames [mTarget]
   put the openstacks into stackNames
   -- filter stackNames without "rev*"
   sort stackNames
   return stackNames
end open_StackNames

getprop stack_Style [mTarget]
   if exists(mTarget) is false then return empty
   put the stack_Object of mTarget into stackObject
   return the style of stackObject
end stack_Style

getprop stack_Styles
   return "topLevel,modeless,modal,palette"
end stack_Styles


--> Global | Stack | Menu | Disabled
-
getprop disabled_Shrink [scriptObject]
   put the stack_Name of scriptObject into stackName
   put the scaleFactor of stack stackName into someFactor
   if someFactor = 1 then
      return false
   else
      return "delete"
   end if
end disabled_Shrink

getprop disabled_UnShrink [scriptObject]
   put the stack_Name of scriptObject into stackName
   put the scaleFactor of stack stackName into someFactor
     if someFactor = 1 then
      return "delete"
   else
      return false
   end if
end disabled_UnShrink


--> Dev | Menu
-
on menu_GoToStack scriptObject
   put the stack_Object of scriptObject into stackObject
   go to stackObject
   if the result is not empty then beep
end menu_GoToStack


--> Menu | Props
-
