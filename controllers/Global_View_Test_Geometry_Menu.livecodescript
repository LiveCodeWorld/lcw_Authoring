script "Global_View_Test_Geometry_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Test_Geometry_Menu
type: controller
version: 0.2

/*
Now moved to "Global | View | Geometry | Menu" as it is prettier :)
*/


--> Global | View | Test | Geometry | Menu
-
on menu_TestLayoutControl viewObject
   test_ViewRect "LayoutControl", viewObject
end menu_TestLayoutControl

on menu_TestViewRect mTarget
   test_ViewRect "view_rect", mTarget
end menu_TestViewRect

on menu_TestRect viewObject
   test_ViewRect "rect", viewObject
end menu_TestRect

on menu_TestFormattedRect viewObject
   test_ViewRect "view_FormattedRect", viewObject
end menu_TestFormattedRect

on menu_TestViewRectToFormattedRect viewObject
   test_ViewRect "set the view_Rect to view_FormattedRect", viewObject
end menu_TestViewRectToFormattedRect


--> Global | View | Test | Geometry | Menu | Disabled
-
getprop disabled_TestFormattedRect [mTarget]
   if exists(mTarget) is false then return true
   put the view_FormattedRect of mTarget into fRect
   return fRect is empty
end disabled_TestFormattedRect

getprop disabled_TestViewRectToFormattedRect [mTarget]
   if exists(mTarget) is false then return true
   put the view_FormattedRect of mTarget into fRect
   return fRect is empty
end disabled_TestViewRectToFormattedRect


--> Deps
-
command test_ViewRect menuChoice, mTarget
   if the shiftKey is "Down" then breakpoint
   
   put the view_RectOnCard of mTarget into oRect
   rect_CreateMask oRect, "Original Rect", mTarget, "yellow"
   
   repeat 6
      switch menuChoice
         case "LayoutControl"
            put the rect of mTarget into someRect
            dispatch "LayoutControl" to mTarget with someRect
            break
         case "view_Rect"
            put the rect of mTarget into someRect
            set the view_Rect of mTarget to someRect
            break
         case "rect"
            put the rect of mTarget into someRect
            set the rect of mTarget to someRect
            break
         case "view_FormattedRect"
            put the view_FormattedRect of mTarget into someRect
            set the rect of mTarget to someRect
            break
         case "set the view_Rect to view_FormattedRect"
            put the view_FormattedRect of mTarget into someRect
            set the view_Rect of mTarget to someRect
            break
      end switch
   end repeat
   put the rect of mTarget into newRect
   rect_CreateMask someRect, "Test Mask", mTarget
   
   if newRect = oRect then
      put "Test passed - same as original rect!" into someMessage
      if menuChoice = "rect" then
         put CR & CR & "However, setting a rect of a group to it's original rect doed not trigger a resizeControl handler" after someMessage
      end if
   else
      beep
      put "Test failed - new rect is different from original!" into someMessage
   end if
   lcw_Notify someMessage, true
end test_ViewRect
