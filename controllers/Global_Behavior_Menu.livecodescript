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
   return display_MenuTarget(tObject)
   -- return the display_View of tObject
end menu_Target

getprop disabled_EditBehavior [scriptObject]
   put the behavior of scriptObject into bObject
   if exists (bObject) is true then
      return false
   else
      return true
   end if
end disabled_EditBehavior


--> Global | Behavior | Menu
-
on menu_Refresh scriptObject
   put display_MenuDisplayView() into displayView
   put the behavior_Objects of scriptObject into bObjects
   set the displayed_Data of displayView to bObjects
end menu_Refresh

private on _
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

private on __
end __

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

private on ___
end ___

-- on submenu_ViewBehavior
   return "Global | Behavior | View | Menu"
end submenu_ViewBehavior

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
