script "Global | View | Property | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | View | Property | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget

getprop style_Name [mTarget]
   put the view_StyleName of mTarget into viewStyleName
   return viewStyleName
end style_Name

getprop style_Names [mTarget]
   put the template_StyleNames of mTarget into viewStyleNames
   if viewStyleNames is empty then
      put "Create new style" into viewStyleNames
   else
      put CR & "-" & CR & "Create new style" after viewStyleNames
   end if
   return viewStyleNames
end style_Names


--> Display | Events
-
command tree_BackspaceKey treeField
   put the linked_View of treeField into someView
   put the template_Array of someView into someArray
   
   set the itemdelimiter to "/"
   put the tree_SelectedPath of treeField into somePath
   
   switch the title_Text of treeField
      case "template_Array"
         -- display/template_StyleArrays/Bank Green/view_PropArray/...
         put item 3 of somePath into styleName
         put item 4 of somePath into arrayType
         if arrayType = "view_PropArray" then
            -- display/template_StyleArrays/Bank Green/view_PropArray/record_LabelLocked/true
            put 0 into cNum
            put item 5 of somePath into someProp
            put item 6 of somePath into someValue
            
            if someProp is empty then
               -- the whole "view_PropArray"
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType]
            else
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType][someProp]
            end if
         else
            -- display/template_StyleArrays/Bank Green/view_RevPropArray/1/htmlText/1234
            put item 5 of somePath into cNum
            put item 6 of somePath into someProp
            put item 7 of somePath into someValue
            
            if someProp is empty then
               -- a whole object
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType][cNum]
            else
               delete local someArray ["display"]["template_StyleArrays"][styleName][arrayType][cNum][someProp]
            end if
         end if
         break
      case "view_RevPropertyArray"
         put item 1 of somePath into cNum
         put item 2 of somePath into someProp
         put item 3 of somePath into someValue
         
         if someProp is empty then
            -- a whole object
            delete local someArray [cNum]
         else
            delete local someArray [cNum][someProp]
         end if
         break
   end switch
   
   set the template_Array of someView to someArray
   put array_ToOutline (someArray) into someOutline
   set the tree_Outline of treeField to someOutline
end tree_BackspaceKey


--> Global | View | Property | Dev | Menu
-
on menu_DisplayArray someView, menuChoice
   breakpoint
   switch menuChoice
      case "template_Array"
         put the template_Array of someView into someArray
         break
      case "view_DisplayedStyleArray"
         put the view_DisplayedStyleArray of someView into someArray
         break
      case "view_RevPropertyArray"
         put the view_RevPropArray of someView into someArray
         break
   end switch
   
   if someArray is not an array then
      beep
      lcw_Notify "Array is empty!", true
      return false
   end if
   
   
   display_Array someArray, menuChoice
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   put the object_Hkey ["M tree_BackspaceKey"] of me into hKey
   set the event_Trigger ["backspaceKey"] of treeField to hKey
   set the linked_View of treeField to someView
end menu_DisplayArray

on menu_ViewOutline someView
   display_ViewOutline someView
end menu_ViewOutline

on menu_TemplateOutline someView
   put the view_Template of someView into templateObject
   display_ViewOutline templateObject
end menu_TemplateOutline

on _
end _

on menu_ViewStyle mTarget, styleName
   if styleName = "Create new style" then
      view_CreateNewStyle mTarget
   else
      set the view_Style of mTarget to styleName
   end if
end menu_ViewStyle

on menu_DisplayArray someView, menuChoice
   switch menuChoice
      case "template_Array"
         put the template_Array of someView into someArray
         break
      case "view_DisplayedStyleArray"
         put the view_DisplayedStyleArray of someView into someArray
         break
      case "view_RevPropertyArray"
         put the view_RevPropArray of someView into someArray
         break
   end switch
   
   if someArray is not an array then
      beep
      lcw_Notify "Array is empty!", true
      return false
   end if
   
   
   display_Array someArray, menuChoice
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   put the object_Hkey ["M tree_BackspaceKey"] of me into hKey
   set the event_Trigger ["backspaceKey"] of treeField to hKey
   set the linked_View of treeField to someView
end menu_DisplayArray

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | View | Property | Dev | Menu"
end menu_MenuEdit
