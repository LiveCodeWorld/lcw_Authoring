script "Global | Behavior | Menu"
--> MetaData
-
license: GPLv3
name: Global | Behavior | Menu
type: controller
version: 0.2


--> Menu | Props
-

--> Global | Behavior | Menu
-
on menu_EditLayoutBehavior scriptObject, layoutBehaviorName
   edit the script of stack layoutBehaviorName
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

on menu_RemoveBehavior scriptObject, behaviorStackName
   put the name of stack behaviorStackName into bObject
   put the behavior_Objects of scriptObject into bObjects
   line_Delete bObject, bObjects
   set the behavior_Objects of scriptObject to bObjects
end menu_RemoveBehavior

on _
end _

on menu_EditBehavior scriptObject
   put the behavior of scriptObject into bObject
   if exists (bObject) then
      edit the script of bObject
   else
      answer warning "Unable to find referenced behavior [[bObject]]!"
      put bObject
   end if
end menu_EditBehavior

on _
end _

on menu_SetStandardBehavior scriptObject, standardBehaviorStackName
   put the name of scriptObject into someName
   if standardBehaviorStackName = "None" then
      answer merge ("Set the named script-only behavior of [[someName]] to '[[standardBehaviorStackName]]'.") with "Cancel" or "OK"
      if it is "Cancel" then exit to top
      
      set the behavior of scriptObject to empty
   else    
      answer merge ("Set the named script-only behavior of [[someName]] to '[[standardBehaviorStackName]]'.") with "Cancel" or "OK"
      if it is "Cancel" then exit to top
      
      put the name of stack standardBehaviorStackName into bObject
      set the behavior of scriptObject to bObject
      edit the script of stack standardBehaviorStackName
   end if
end menu_SetStandardBehavior

on menu_EditStandardBehavior scriptObject, standardBehaviorStackName
   if bName is "Clear" then return false
   put name of stack standardBehaviorStackName into bObject
   edit the script of bObject
end menu_EditStandardBehavior

on _
end _

on submenu_ViewBehavior
   return "Global | Behavior | View | Menu"
end submenu_ViewBehavior

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Behavior | Menu | Props
-
getprop layout_BehaviorNames [scriptObject]
   put env_ListBehaviorStackNames() into behaviorStackNames
   put behaviorStackNames into layoutBehaviorNames
   filter layoutBehaviorNames with "behavior_Layout*"
   filter behaviorStackNames with "behavior_ViewLayout*"
   put CR & behaviorStackNames after layoutBehaviorNames
   sort layoutBehaviorNames
   return layoutBehaviorNames
end layout_BehaviorNames

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

getprop standard_BehaviorStackName [scriptObject]
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
end standard_BehaviorStackName

getprop standard_BehaviorStackNames
   put env_ListBehaviorStackNames() into bNames
   --  put project_ListBehaviorStackNames ("all") into bNames
   put "None,-" & CR before bNames
   return bNames
end standard_BehaviorStackNames


--> Global | Script | Behavior | Menu | Disabled
-
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


--> Menu | Props
-
--> Deps
-
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


--> Dev | Menu
-
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

on _
end _

on menu_LivecodeBehaviorHacks mTarget, someBoolean
   rev_AddBehaviorHacks someBoolean, true
end menu_LivecodeBehaviorHacks

on menu_EditLivecodeBehaviorButton mTarget, ideBname
   put hArray_GetNamedObjectType (ideBname, "behavior") into ideBehavior
   edit the script of ideBehavior
end menu_EditLivecodeBehaviorButton
