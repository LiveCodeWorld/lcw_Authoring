script "Global | View | Property | Menu"
--> MetaData
-
license: GPLv3
name: Global | View | Property | Menu
type: controller
version: 0.3


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put the display_View of tObject into indexView
   put the displayed_Object of indexView into viewObject
   return viewObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | View | Property | Menu
-
on menu_ViewProperty someView, someProp
   view_DoPropertyMenu someProp, someView
end menu_ViewProperty

getprop viewProperty_Params [mTarget]
   return LocalArray ["view_PropertyMenu"]
end viewProperty_Params

getprop disabled_ViewProperty [mTarget]
   put the view_PropertyMenu of mTarget into viewPropertyMenu
   put viewPropertyMenu into LocalArray ["view_PropertyMenu"]
   --
   if viewPropertyMenu is empty then
      return "delete"
   else
      return false
   end if
end disabled_ViewProperty

on menu_EditModuleBehaviors someView
   put the module_Behaviors of someView into moduleBehaviors
   repeat for each line moduleBehavior in moduleBehaviors
      edit the script of moduleBehavior
   end repeat
end menu_EditModuleBehaviors

private on _
end _

on menu_EditViewBehavior someView
   put the behavior of someView into bObject
   edit the script of bObject
end menu_EditViewBehavior

on menu_EditViewTemplate mTarget
   put the view_Template of mTarget into templateObject
   object_GoTo templateObject
   put the behavior of templateObject into templateBehavior
   if exists(templateBehavior) then edit the script of templateBehavior
end menu_EditViewTemplate

private on __
end __

on menu_PropertyPalette someView
   display_ObjectProperties someView
end menu_PropertyPalette

on menu_GoToTemplate someView
   put the template_Object of someView into tObject
   object_GoTo tObject
end menu_GoToTemplate

private on ___
end ___

on menu_ViewOutline someView
   display_ViewOutline someView
end menu_ViewOutline

on menu_TemplateOutline someView
   put the view_Template of someView into templateObject
   display_ViewOutline templateObject
end menu_TemplateOutline

private on ____
end ____

on menu_ViewStyle mTarget, styleName
   if styleName = "Create new style" then
      view_CreateNewStyle mTarget
   else
      set the view_Style of mTarget to styleName
   end if
end menu_ViewStyle

on submenu_Dev
   return menu_DevTitle ("Global | View | Property | Menu")
end submenu_Dev
