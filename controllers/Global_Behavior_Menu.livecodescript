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
   
   --  put project_ListBehaviorStackNames ("all") into bNames
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

getprop checked_DisplayBehaviorStackNames
   put _dView() into dView
   return the title_Text of dView = "the view_BehaviorStackNames"
end checked_DisplayBehaviorStackNames

getprop checked_DisplayBehaviorObjects
   put _dView() into dView
   return the title_Text of dView = "the behavior_Objects"
end checked_DisplayBehaviorObjects

getprop checked_AddMenuBehaviors
   put _dView() into dView
   return the title_Text of dView = "template_Behaviors of menubarView"
end checked_AddMenuBehaviors

getprop disabled_AddMenuBehaviors [sObject]
   put the menubar_View of sObject into menubarView
   put exists (menubarView) is fale into notThere
   return notThere
end disabled_AddMenuBehaviors

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

-- on submenu_ViewBehavior
return "Global | Behavior | View | Menu"
end submenu_ViewBehavior


--> Global | Behavior | Menu
-
on menu_DisplayBehaviorStackNames mView
   put _dView() into dView
   put the view_BehaviorStackNames of mView into sData ["view_BehaviorStackNames"]
   put the view_CardBehaviorStackNames of mView into sData ["view_CardBehaviorStackNames"]
   --
   put the name of mView into pTitle
   display_Data sData, pTitle, "BehaviorStackNames"
end menu_DisplayBehaviorStackNames

on menu_EditBehaviorStack mView, bStackName
   edit the script of stack bStackName
end menu_EditBehaviorStack

getprop editBehaviorStack_Params [mView]
   put the view_BehaviorStackNames of mView into sNames
   return sNames
end editBehaviorStack_Params

on menu_SetBehaviorStackNames mView
   lcw_Answer "Automatically set the view_BehaviorStackNames of this view to the view_CardBehaviorStackNames of this card?", mView
   ---
   put the view_CardBehaviorStackNames of mView into bNames
   set the view_BehaviorStackNames of mView to bNames
   --
   if there is a stack "Display ViewData" then
      put the long id of control 1 of cd 1 of stack "Display ViewData" into dView
   else
      display_NestedViewArray viewObject
      put the result into dView
   end if
   
   set the displayed_Data ["the view_BehaviorStackNames"] of dView to bNames
end menu_SetBehaviorStackNames

on menu_EditViewBehaviorStackNames sObject
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
end menu_EditViewBehaviorStackNames

private on _
end _

on menu_DisplyBehaviorObjects mView
   put _dView() into dView
   put the behavior_Objects of mView into bObjects
   --
   set the displayed_Data ["the behavior_Objects"] of dView to bObjects
   put the view_Name of mView into vName
   set the stack_Label of dView to vName
end menu_DisplyBehaviorObjects

private on __
end __

on menu_AddMenuBehaviors sObject
   put _dView() into dView
   --
   put the menubar_View of sObject into menubarView
   put the template_Behaviors of menubarView into templateBehaviors
   --
   set the displayed_Data ["template_Behaviors of menubarView"] of dView to templateBehaviors
   put the view_Name of menubarView into vName
   set the stack_Label of dView to vName
end menu_AddMenuBehaviors

on menu_AddBehavior sObject
   put lcw_Ask ("Add behavior...", "View|Browser", sObject) into vName
   --
   set the module_AddBehavior of sObject to vName
   --
   menu_Refresh sObject
end menu_AddBehavior

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

on menu_EditBehavior sObject
   put the behavior of sObject into bObject
   if exists (bObject) then
      edit the script of bObject
   else
      answer warning "Unable to find referenced behavior [[bObject]]!"
      put bObject
   end if
end menu_EditBehavior

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
