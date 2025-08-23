script "Global | Stack | Menu"
--> MetaData
-
license: GPLv3
name: Global | Stack | Menu
type: controller
version: 0.3


--> Variables
-
local LocalArray

/*
Some basic tools for manipulating stacks, and windows. 
*/

--> Menu | Props
-
getprop menu_Target [tObject]
   put the displayed_Object of tObject into sObject
   put the stack_Object of sObject into stackObject
   return stackObject
end menu_Target

getprop menu_CheckTarget [stackObject]
   return exists (stackObject)
end menu_CheckTarget

getprop editOpenStack_Param [stackObject]
   put the stack_Name of stackObject into openStackName
   return openStackName
end editOpenStack_Param

getprop editOpenStack_Params
   put the openstacks into stackNames
   -- filter stackNames without "rev*"
   sort stackNames
   return stackNames
end editOpenStack_Params


--> Old
-
getprop disabled_Shrink [sObject]
   put the stack_Name of sObject into stackName
   put the scaleFactor of stack stackName into someFactor
   if someFactor = 1 then
      return false
   else
      return "delete"
   end if
end disabled_Shrink

getprop disabled_UnShrink [sObject]
   put the stack_Name of sObject into stackName
   put the scaleFactor of stack stackName into someFactor
   if someFactor = 1 then
      return "delete"
   else
      return false
   end if
end disabled_UnShrink


--> Global | Stack | Menu
-
on menu_SaveStack stackObject
   put the stack_Name of stackObject into sName
   --
   ide_SaveStack sName
end menu_SaveStack

on menu_StackProperties stackObject
   revIDEInspectObjects stackObject
end menu_StackProperties

private command _
end _

on menu_EditOpenStack stackObject, openStackName
   put the name of stack openStackName into oStackObject
   --
   display_ObjectProperties oStackObject
   edit the script of stack openStackName
end menu_EditOpenStack

on menu_StackIsUsed stackObject
   if _IsUsed (stackObject) is false then
      start using stackObject 
   else
      stop using stackObject
   end if
end menu_StackIsUsed

getprop checked_StackIsUsed [stackObject]
   return _IsUsed (stackObject)
end checked_StackIsUsed

private function _IsUsed stackObject
   put the stack_Name of stackObject into stackName
   set the wholematches to true 
   return stackName is among the lines of the stacksinuse 
end _IsUsed

private command __
end __

on menu_GatherStacks
   screen_GatherStacks
end menu_GatherStacks

on menu_PlaceOnScreen stackObject, whichScreen
   put the stack_Name of stackObject into stackName
   put system_GetScreenRect (whichScreen) into pScreenRect
   stack_SetToMainScreen stackName, pScreenRect
end menu_PlaceOnScreen

getprop placeOnScreen_Params
   put system_ListScreenNames() into screenNames
   return screenNames
end placeOnScreen_Params

private command ___
end ___

on menu_RevealStack stackObject
   put the stack_Name of stackObject into stackName
   stack_RevealInFinder stackName
end menu_RevealStack

on menu_StackStyle stackObject, stackStyle
   set the style of stackObject to stackStyle
end menu_StackStyle

getprop stackStyle_Param [stackObject]
   if exists (stackObject) is false then return empty
   return the style of stackObject
end stackStyle_Param

getprop stackStyle_Params
   return "topLevel,modeless,modal,palette"
end stackStyle_Params

on menu_StackTitleStyle stackObject, stackTitleStyle
   set the stack_TitleStyle of stackObject to stackTitleStyle
end menu_StackTitleStyle

getprop stackTitleStyle_Param [stackObject]
   return the stack_TitleStyle of stackObject
end stackTitleStyle_Param

getprop stackTitleStyle_Params [stackObject]
   return the stack_TitleStyles of stackObject
end stackTitleStyle_Params

on menu_StackResizable stackObject
   put the resizable of stackObject into sBoolean
   set the resizable of stackObject to (sBoolean is false)
end menu_StackResizable

getprop checked_StackResizable [stackObject]
   put the resizable of stackObject into sBoolean
   return sBoolean
end checked_StackResizable

private on ____
end ____

on submenu_Dev
   return menu_DevTitle ("Global | Stack | Menu")
end submenu_Dev

-- on submenu_Tidy
return "Global | Stack | Tidy | Menu"
end submenu_Tidy
