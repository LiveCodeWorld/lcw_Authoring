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
   put the displayed_Object of tObject into mView
   
   put the module_BehaviorStackNames of mView into LocalArray ["mBehaviorStackNames"] 
   put the view_BehaviorStackNames of mView into LocalArray ["vStackNames"] 
   put the behavior_StackNames of mView into LocalArray ["bStackNames"]
   
   return mView
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


--> Global | Behavior | Menu
-
on menu_SetDefaultBehavior sView
   put the default_Behavior of sView into bObject
   put lcw_Ask ("Set the behavior...", bObject) into bObject
   set the behavior of sView to bObject 
end menu_SetDefaultBehavior

getprop checked_SetDefaultBehavior [sView]
   put the default_Behavior of sView into dObject
   put the behavior of sView into bObject
   return the long id of dObject = the long id of bObject
end checked_SetDefaultBehavior

on menu_SetViewBehaviorStackNames mView
   put the uOPN ["view_BehaviorStackNames"] of mView into vStackNames
   --
   behavior_SetStackNames vStackNames, mView
   put the result into bObjects
   put bObjects
end menu_SetViewBehaviorStackNames

on menu_ClearBehaviors mView
   -- set the view_BehaviorStackNames of sObject to empty
   -- set the behavior_Objects of sObject to empty
   
   behavior_SafeClear mView
end menu_ClearBehaviors

getprop checked_ClearBehaviors [sObject]
   get the behavior_Objects of sObject
   return it is empty
end checked_ClearBehaviors

on menu_DispatchPreopenControl viewObject
   if the shiftKey is "Down" then breakpoint
   dispatch "preOpenControl" to viewObject
   switch it
      case "unhandled"
         put the card_Object of viewObject into cardObject
         display_BrokenBehaviors cardObject, true
         break
      default
         -- all is fine
   end switch
end menu_DispatchPreopenControl

private on ____
end ____

on menu_ModuleBehavior mView, bStackName
   put the module_Name of mView into mName
   put the module_BehaviorStackNames of mView into mBehaviorStackNames
   put the view_BehaviorStackNames of mView into vStackNames
   put the behavior_StackNames of mView into bStackNames
   
   if bStackName is among the lines of bStackNames then
      set the behavior_Remove of mView to bStackName
      lcw_Notify "Removed behavior from module", mName
   else
      set the behavior_Add of mView to bStackName
      lcw_Notify "Added behavior from module", mName, bStackName
   end if
end menu_ModuleBehavior

getprop moduleBehavior_Param [mView]
   put LocalArray ["bStackNames"] into bStackNames
   -- put the behavior_StackNames of mView into bStackNames
   return bStackNames
end moduleBehavior_Param

getprop moduleBehavior_Params [mView]
   put LocalArray ["mBehaviorStackNames"] into mBehaviorStackNames
   -- put the module_BehaviorStackNames of mView into mBehaviorStackNames
   return mBehaviorStackNames
end moduleBehavior_Params

on menu_ViewBehaviorStackNames mView, bStackName
   put the module_Name of mView into mName
   put the view_BehaviorStackNames of mView into vStackNames
   
   if bStackName is among the lines of vStackNames then
      line_Delete bStackName, vStackNames
      lcw_Notify "Removed behavior from stored view_BehaviorStackNames!", mName, bStackName
   else
      line_Add bStackName, vStackNames
      lcw_Notify "Added behavior to stored view_BehaviorStackNames!", mName, bStackName
   end if
   set the view_BehaviorStackNames of mView to vStackNames
end menu_ViewBehaviorStackNames

getprop viewBehaviorStackNames_Param [mView]
   put LocalArray ["vStackNames"] into vStackNames
   -- put the view_BehaviorStackNames of mView into vStackNames
   return vStackNames
end viewBehaviorStackNames_Param

getprop viewBehaviorStackNames_Params [mView]
   put LocalArray ["mBehaviorStackNames"] into mBehaviorStackNames
   -- put the module_BehaviorStackNames of mView into mBehaviorStackNames
   return mBehaviorStackNames
end viewBehaviorStackNames_Params

on menu_AskEditViewBehaviorStackNames sObject
   put the view_BehaviorStackNames of sObject into sNames
   if sNames is empty then
      put the behavior_StackNames of sObject into sNames
   end if
   replace CR with comma in sNames
   put lcw_Ask ("Add behavior...", sNames, sObject) into sNames
   replace comma with CR in sNames
   --
   set the view_BehaviorStackNames of sObject to sNames
   --
   menu_Refresh sObject
end menu_AskEditViewBehaviorStackNames

private on _
end _

on menu_StoreDefaultBehaviorStackNames mView
   put the module_Name of mView into mName
   if mName is empty then
      breakpoint
      --  put project_ListBehaviorStackNames ("all") into bNames
   end if
   put module_ListBehaviorStackNames (mName) into mBehaviorStackNames
   
   # Store
   set the view_BehaviorStackNames of mView to mBehaviorStackNames
end menu_StoreDefaultBehaviorStackNames

on menu_ClearModuleBehaviors mView
   put the module_Name of mView into mName
   if mName is empty then
      breakpoint
   end if
   
   # Clear
   module_ClearBehaviors mName
end menu_ClearModuleBehaviors

on menu_DisplayBehaviorStackNames mView
   put _dView() into dView
   put the view_BehaviorStackNames of mView into sData ["view_BehaviorStackNames"]
   put the view_CardBehaviorStackNames of mView into sData ["view_CardBehaviorStackNames"]
   --
   put the name of mView into pTitle
   display_Data sData, pTitle, "BehaviorStackNames"
end menu_DisplayBehaviorStackNames

on menu_SetViewBehaviorStackNames mView
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
end menu_SetViewBehaviorStackNames

private on __
end __

on menu_DisplyBehaviorObjects mView
   put _dView() into dView
   put the behavior_Objects of mView into bObjects
   --
   set the displayed_Data ["the behavior_Objects"] of dView to bObjects
   put the view_Name of mView into vName
   set the stack_Label of dView to vName
end menu_DisplyBehaviorObjects

private on ___
end ___

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
