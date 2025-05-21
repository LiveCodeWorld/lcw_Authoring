script "Global | Behavior | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Behavior | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   _SetBehaviorMenu
   return the display_View of tObject
end menu_Target

private command _SetBehaviorMenu
   put env_ListBehaviorStackNames() into bNames
   put "None,-" & CR before bNames
   put bNames into LocalArray ["sBehaviorNames"]
   
   put the behavior of sObject into bObject
   switch
      case bObject is empty
         put "None" into LocalArray ["sBehaviorName"]
      case exists (bObject) is false
      case word 1 of bObject is not "stack"
         put empty into LocalArray ["sBehaviorName"]
      default
         put the short name of bObject into stackName
         put stackName into LocalArray ["sBehaviorName"]
   end switch
end _SetBehaviorMenu

getprop layoutBehaviorName_Params [scriptObject]
   put env_ListBehaviorStackNames() into behaviorStackNames
   put behaviorStackNames into layoutBehaviorNames
   filter layoutBehaviorNames with "behavior_Layout*"
   filter behaviorStackNames with "behavior_ViewLayout*"
   put CR & behaviorStackNames after layoutBehaviorNames
   sort layoutBehaviorNames
   return layoutBehaviorNames
end layoutBehaviorName_Params

getprop behavior_StackNames [scriptObject]
   put the behavior_Objects of scriptObject into bObjects
   repeat for each line bObject in bObjects
      if word 1 of bObject is not "stack" then
         -- it's a button not a stack behavior
         next repeat
      end if
      
      put the short name of bObject into behaviorStackName
      put behaviorStackName & CR after behaviorStackNames
   end repeat
   delete char -1 of behaviorStackNames
   return behaviorStackNames
end behavior_StackNames

getprop layout_BehaviorNames [scriptObject]
   put env_ListBehaviorStackNames() into behaviorStackNames
   put behaviorStackNames into layoutBehaviorNames
   filter layoutBehaviorNames with "behavior_Layout*"
   filter behaviorStackNames with "behavior_ViewLayout*"
   put CR & behaviorStackNames after layoutBehaviorNames
   sort layoutBehaviorNames
   return layoutBehaviorNames
end layout_BehaviorNames

getprop disabled_EditBehavior [scriptObject]
   put the behavior of scriptObject into bObject
   if exists (bObject) is true then
      return false
   else
      return true
   end if
end disabled_EditBehavior

getprop disabled_EditBehavior [scriptObject]
   put the behavior of scriptObject into bObject
   return bObject is empty
end disabled_EditBehavior

function menu_TableFromHkeys hKeys
   repeat for each line hKey in hKeys
      put menu_DefaultTableLine (hKey) into mTableLine
      put mTableLine & CR after mTable
   end repeat
   delete char -1 of mTable
   return mTable
end menu_TableFromHkeys

function menu_TextFromHkeys hKeys, mView
   put menu_TableFromHkeys (hKeys) into mTable
   put menu_ConvertTable(mTable, mView) into mText
   return mText
end menu_TextFromHkeys

function menu_TableLineFromHkey hKey
   put "hKey" into mItemType
   put empty into mTitle
   
   hkey_Deconstruct hKey, handlerName, handlerType, mController, handlerNum
   set the itemdelimiter to "_"
   put item 1 of handlerName into handlerPrefix
   put item 2 of handlerName into handlerSuffix
   
   put hkey_ExtractHandlerFromObject (hKey) into someHandler
   put line 1 of someHandler into mLine
   put token 2 of mLine into firstParam
   
   -- only add disabled_Prop if it exists in the menu_Controller (optional)
   put "disabled_" & handlerSuffix into mFormatProp
   if the script_GetProp [mFormatProp] of mController is empty then put empty into mFormatProp
   
   put text_SplitCaps (handlerSuffix) into mLine
   if firstParam is empty or param_IsObject (firstParam) then
      put handlerName && "mTarget" into pigeon
      put menu_ConstructTableLine(mController, pigeon, mTitle, mLine, mFormatProp, mItemType) into mTableLine
   else
      put mCommand && "subMenuPath," && mTarget into pigeon
      put menu_ConstructTableLine(mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp) into mTableLine
   end if
   return mTableLine
end menu_TableLineFromHkey

getprop editLayoutBehavior_Params [scriptObject]
   put env_ListBehaviorStackNames() into behaviorStackNames
   put behaviorStackNames into layoutBehaviorNames
   filter layoutBehaviorNames with "behavior_Layout*"
   filter behaviorStackNames with "behavior_ViewLayout*"
   put CR & behaviorStackNames after layoutBehaviorNames
   sort layoutBehaviorNames
   return layoutBehaviorNames
end editLayoutBehavior_Params

getprop behavior_StackNames [scriptObject]
   put the behavior_Objects of scriptObject into bObjects
   repeat for each line bObject in bObjects
      if word 1 of bObject is not "stack" then
         -- it's a button not a stack behavior
         next repeat
      end if
      
      put the short name of bObject into behaviorStackName
      put behaviorStackName & CR after behaviorStackNames
   end repeat
   delete char -1 of behaviorStackNames
   return behaviorStackNames
end behavior_StackNames

getprop layout_BehaviorNames [scriptObject]
   put env_ListBehaviorStackNames() into behaviorStackNames
   put behaviorStackNames into layoutBehaviorNames
   filter layoutBehaviorNames with "behavior_Layout*"
   filter behaviorStackNames with "behavior_ViewLayout*"
   put CR & behaviorStackNames after layoutBehaviorNames
   sort layoutBehaviorNames
   return layoutBehaviorNames
end layout_BehaviorNames

getprop removeBehavior_Param [scriptObject]
   put the behavior of scriptObject into bObject
   switch
      case bObject is empty
         return "None"
      case exists (bObject) is false
         return empty
      case word 1 of bObject is not "stack"
         return empty
      default
         put the short name of bObject into stackName
         return stackName
   end switch
end removeBehavior_Param

getprop removeBehavior_Params
   put env_ListBehaviorStackNames() into bNames
   --  put project_ListBehaviorStackNames ("all") into bNames
   put "None,-" & CR before bNames
   return bNames
end removeBehavior_Params


--> Global | Behavior | Dev | Menu
-
on menu_RemoveBehavior scriptObject, behaviorStackName
   put the name of stack behaviorStackName into bObject
   put the behavior_Objects of scriptObject into bObjects
   line_Delete bObject, bObjects
   set the behavior_Objects of scriptObject to bObjects
end menu_RemoveBehavior

on menu_EditLayoutBehavior scriptObject, layoutBehaviorName
   if exists (stack layoutBehaviorName) then
      edit the script of stack layoutBehaviorName
   else
      breakpoint
   end if
end menu_EditLayoutBehavior

on menu_AddLayoutBehavior scriptObject, layoutBehaviorName
   put the name of stack layoutBehaviorName into layoutBehaviorObject
   put the behavior_Objects of scriptObject into bObjects
   if bObjects is empty then
      put layoutBehaviorObject into bObjects
   else
      put CR & layoutBehaviorObject after bObjects
   end if
   set the behavior_Objects of scriptObject to bObjects
end menu_AddLayoutBehavior

private on _
end _

on menu_SetStandardBehavior sObject, standardBehaviorStackName
   put the name of sObject into someName
   if standardBehaviorStackName = "None" then
      answer merge ("Set the named script-only behavior of [[someName]] to '[[standardBehaviorStackName]]'.") with "Cancel" or "OK"
      if it is "Cancel" then exit to top
      
      set the behavior of sObject to empty
   else    
      answer merge ("Set the named script-only behavior of [[someName]] to '[[standardBehaviorStackName]]'.") with "Cancel" or "OK"
      if it is "Cancel" then exit to top
      
      put the name of stack standardBehaviorStackName into bObject
      set the behavior of sObject to bObject
      edit the script of stack standardBehaviorStackName
   end if
end menu_SetStandardBehavior

on menu_EditStandardBehavior sObject, standardBehaviorStackName
   if bName is "Clear" then return false
   put name of stack standardBehaviorStackName into bObject
   edit the script of bObject
end menu_EditStandardBehavior

private on ____
end ____

getprop setStandardBehavior_Param [scriptObject]
   return LocalArray ["sBehaviorName"]
end setStandardBehavior_Param

getprop setStandardBehavior_Params
   return LocalArray ["sBehaviorNames"]
end setStandardBehavior_Params

getprop editStandardBehavior_Param [scriptObject]
   return LocalArray ["sBehaviorName"]
end editStandardBehavior_Param

getprop editStandardBehavior_Params
   return LocalArray ["sBehaviorNames"]
end editStandardBehavior_Params

on menu_DisplayBehaviorHierarchy scriptObject, bhName
put behavior_GetObject (bhName) into bObject
edit the script of bObject
end menu_DisplayBehaviorHierarchy

on menu_AddBehaviorToEnd scriptObject, bName
   put the last line of the behavior_Objects of scriptObject into lastBehaviorObject
   
   set the behavior_Name of lastBehaviorObject to bName
   put the result into bObject
   
   put "Set the behavior of" && the mobile_Name of scriptObject && "to" && kwote (bName) into someMessage
   lcw_Notify someMessage
end menu_AddBehaviorToEnd

on menu_LivecodeBehaviorHacks mTarget, someBoolean
   ide_AddBehaviorHacks someBoolean
end menu_LivecodeBehaviorHacks

on menu_EditLivecodeBehaviorButton mTarget, ideBname
   put hArray_GetNamedObjectType (ideBname, "behavior") into ideBehavior
   edit the script of ideBehavior
end menu_EditLivecodeBehaviorButton

private on __
end __

on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

on menu_MenuEdit displayView
   menu_Edit "Global | Behavior | Dev | Menu"
end menu_MenuEdit
