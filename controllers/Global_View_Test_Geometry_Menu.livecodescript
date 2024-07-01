script "Global | View | Test | Geometry | Menu"
--> MetaData
-
license: GPLv3
name: Global | View | Test | Geometry | Menu
type: controller
version: 0.2

/*            set the rect_Test ["red"] of cardObject to vCardRect
            set the rect_Test ["yellow"] of cardObject to vRect*/


--> Global | View | Test | Geometry | Menu
-
on menu_LayoutSquare viewObject
   put the card_Object of viewObject into cardObject
   put the view_RectOnCard of cardObject into vCardRect
   put rect_GetSquare (vCardRect) into squareRect
   --
   dispatch "LayoutControl" to viewObject with squareRect
   
   if the shiftKey is "Down" then
      set the rect_Test of cardObject to squareRect
   end if
   put the rect of viewObject into realRect
   rect_ExtractDimensions squareRect, squareW, squareH
   rect_ExtractDimensions realRect, realW, realH
   
   put "Real:" && realRect && "w:" & realW && "h:" & realH & CR into sInfo
   put "Square:" && squareRect && "w:" & squareW && "h:" & squareH after sInfo
   put sInfo
   --
   _HandleDispatch it, viewObject, cardObject
end menu_LayoutSquare

on menu_SixLayoutTests someView
   put the card_Object of someView into cardControl
   put the view_RectOnCard of cardControl into cardRect
   
   repeat 6
      set the cursor to busy
      dispatch "LayoutControl" to someView with cardRect
   end repeat
   
   put merge ("Dispatched 'LayoutControl' to [[the name of someView]] 6 times") into someComment
   lcw_Notify someComment
end menu_SixLayoutTests

private on ___
end ___

on menu_DispatchResizeToFit viewObject
   dispatch "ResizeToFit" to viewObject
end menu_DispatchResizeToFit

on menu_DispatchResizeStack vObject
   put the card_Object of vObject into cardObject
   dispatch "resizeStack" to cardObject
end menu_DispatchResizeStack

on menu_DispatchResizeControl vObject
   dispatch "resizeControl" to vObject
end menu_DispatchResizeControl

on menu_DispatchPreopenCard viewObject
   if the shiftKey is "Down" then breakpoint
   dispatch "preOpenCard" to viewObject
end menu_DispatchPreopenCard

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

private on _
end _

on menu_Gather vObject
   put LocalArray ["stackTopLeft"] into stackTopLeft
   put the stack_Name of vObject into vStackName
   --
   set the topleft of stack vStackName to stackTopLeft
   show stack vStackName
end menu_Gather

on menu_EditCardBehavior vObject
   put the card_Object of vObject into cObject
   put the behavior of cObject into bObject
   if exists (bObject) then
      edit the script of bObject
   else
      lcw_AnswerWarning "There is no behavior for this card!", vObject
   end if
end menu_EditCardBehavior

on menu_SetViewRect vObject
   put the view_RectOnCard of vObject into viewRect
   set the rect of vObject to viewRect
end menu_SetViewRect

private on __
end __

on menu_TestViewRectOnCard vObject
   put the card_Object of vObject into cObject
   --
   put the view_RectOnCard of cObject into viewRect
   rect_Test viewRect, cObject
end menu_TestViewRectOnCard

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
