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

-- private command _SetChoice menuChoice, @mainChoice, @secondChoice
   -- bug - needs to take account of quoted things like stack names with "|" in their name.
   text_StarQuoted menuChoice
   put the result into replacedArray
   put replacedArray ["original text"] into oText
   
   put line 1 of menuChoice into menuChoice
   set the itemdelimiter to "|"
   put the number of chars of item 1 of menuChoice into firstLength
   put char 1 to firstLength of oText into mainChoice
   
   put firstLength + 2 into secondStart
   put char secondStart to -1 of oText into secondChoice
end _SetChoice


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
   object_GoTo tObject
   
   put the behavior of tObject into tBehavior
   if exists (tBehavior) then edit the script of tBehavior
end menu_GoToTemplate

private on __
end __

on menu_SetCardMargin dView
   put the view_Name of dView into viewName
   put the card_Margin of dView into cMargin
   put lcw_Ask ("Set the card_Margin of [[viewName]]", cMargin, dView, viewName) into cMargin
   --
   set the card_Margin of dView to cMargin
end menu_SetCardMargin

private on ___
end ___

on menu_ViewOutline someView
   display_ViewOutline someView
end menu_ViewOutline

on menu_TemplateOutline someView
   put the view_ModuleObject of someView into templateObject
   display_ViewOutline templateObject
end menu_TemplateOutline

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
