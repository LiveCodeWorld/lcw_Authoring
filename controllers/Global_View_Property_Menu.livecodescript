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

on menu_PropertyPalette someView
   display_ObjectProperties someView
end menu_PropertyPalette

private on _
end _

on menu_GoToTemplate someView
   put the template_Object of someView into tObject
   -- put the view_Template of mTarget into templateObject
   object_GoTo tObject
   
   put the behavior of tObject into tBehavior
   if exists (tBehavior) then edit the script of tBehavior
end menu_GoToTemplate

private on __
end __

on menu_ViewOutline someView
   display_ViewOutline someView
end menu_ViewOutline

on menu_TemplateOutline someView
   put the view_Template of someView into templateObject
   display_ViewOutline templateObject
end menu_TemplateOutline

on menu_ViewStyle mTarget, styleName
   if styleName = "Create new style" then
      view_CreateNewStyle mTarget
   else
      set the view_Style of mTarget to styleName
   end if
end menu_ViewStyle

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | View | Property | Menu")
end submenu_Dev
