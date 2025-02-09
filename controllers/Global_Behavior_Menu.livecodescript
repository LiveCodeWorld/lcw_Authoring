script "Global | Behavior | Menu"
--> MetaData
-
license: GPLv3
name: Global | Behavior | Menu
type: controller
version: 0.3


--> Menu | Props
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop disabled_EditBehavior [sObject]
   put the behavior of sObject into bObject
   if exists (bObject) is true then
      return false
   else
      return true
   end if
end disabled_EditBehavior


--> Global | Behavior | Menu
-
on menu_Test sObject
   put the view_BehaviorStackNames of sObject into sNames
   put sNames
end menu_Test

private on _
end _

on menu_EditBehavior sObject
   put the behavior of sObject into bObject
   if exists (bObject) then
      edit the script of bObject
   else
      answer warning "Unable to find referenced behavior [[bObject]]!"
      put bObject
   end if
end menu_EditBehavior

private on __
end __

on menu_AddBehavior sObject
   put lcw_Ask ("Add behavior...", "View|Browser", sObject) into vName
   --
   set the module_AddBehavior of sObject to vName
   --
   menu_Refresh sObject
end menu_AddBehavior

on menu_ViewBehaviorStackNames sObject
   put the view_BehaviorStackNames of sObject into sNames
   if sNames is empty then
      put the behavior_StackNames of sObject into sNames
   end if
   replace CR with comma in sNames
   put lcw_Ask ("Add behavior...", sNames, sObject) into sNames
   --
   set the view_BehaviorStackNames of sObject to sNames
   --
   menu_Refresh sObject
end menu_ViewBehaviorStackNames

private on ___
end ___

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

-- on submenu_ViewBehavior
   return "Global | Behavior | View | Menu"
end submenu_ViewBehavior

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
