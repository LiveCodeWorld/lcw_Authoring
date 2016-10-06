script "Global_Shape_Hexagon_Menu"
--> MetaData
-
license: GPLv3
name: Global_Shape_Hexagon_Menu
type: controller
version: 0.1


--> Global | Shape | Hexagon | Menu
-
on menu_AnimateStudent sHexagon
   put random (6) into nodeNum
   put the class_Array of sHexagon into classArray
   put classArray [nodeNum]["rect"] into destRect
   put classArray [nodeNum]["rugged_ID"] into destinationView
   
   rect_CreateMask destRect
   
   put the loc of destinationView into destLoc
   -- hide destinationView
   -- put the rect of destinationView into destRect
   
   put view_GetTemplateObject ("Image|Masked") into templateObject
   lock screen
   copy templateObject to me
   put it into personView
   set the loc of personView to "-200,-200"
   unlock screen
   
   -- aeMoveTo personView, destLoc, 1000, "inOut"
   aeChangeRect personView, destRect, 1000, "inOut"
end menu_AnimateStudent

on aeChangeRectDone
   put the params
   -- show destinationView
   -- delete personView
end aeChangeRectDone

on menu_AddClass sHexagon, cNum
   put "Teacher" into classArray [1]["person_Type"]
   put "N" into classArray [2]["person_Type"]
   put "S" into classArray [3]["person_Type"]
   put "S" into classArray [4]["person_Type"]
   put "P" into classArray [5]["person_Type"]
   
   switch cNum
      case 5
         break
      case 6
         put "E" into classArray [6]["person_Type"]
         break
      case 7
         put "E" into classArray [6]["person_Type"]
         put "E" into classArray [7]["person_Type"]
         break
      case 8
         put "E" into classArray [6]["person_Type"]
         put "E" into classArray [7]["person_Type"]
         put "E" into classArray [8]["person_Type"]
         break
      case 9
         put "E" into classArray [6]["person_Type"]
         put "E" into classArray [7]["person_Type"]
         put "E" into classArray [8]["person_Type"]
         put "E" into classArray [9]["person_Type"]
         break
      case 10
         put "E" into classArray [6]["person_Type"]
         put "E" into classArray [7]["person_Type"]
         put "E" into classArray [8]["person_Type"]
         put "E" into classArray [9]["person_Type"]
         put "E" into classArray [10]["person_Type"]
         break
   end switch
   set the class_Array [true] of sHexagon to classArray
end menu_AddClass

getprop c_Num [sHexagon]
   return the class_Size of sHexagon
end c_Num

getprop c_Nums
   return "5,6,7,8,9,10"
end c_Nums

on _
end _

on menu_IncreaseNodeFactor sHexagon
   put the inner_View of sHexagon into ringView
   
   put the node_Factor of ringView into nodeFactor
   add (0.1 * nodeFactor) to nodeFactor
   set the node_Factor of ringView to nodeFactor
end menu_IncreaseNodeFactor

on menu_DecreaseNodeFactor mTarget
   put the inner_View of sHexagon into ringView
   
   put the node_Factor of ringView into nodeFactor
   subtract (0.1 * nodeFactor) from nodeFactor
   set the node_Factor of ringView to nodeFactor
end menu_DecreaseNodeFactor

on _
end _

on menu_AddRing sHexagon
   lock screen
   put the rect of sHexagon into oRect
   -- set the inner_Margin of sHexagon to 14
   set the inner_Factor of sHexagon to 0.08
   set the show_Label of sHexagon to false
   set the inner_View of sHexagon to "Shape|Ring"
   put the result into ringView
   set the showborder of ringView to false
   set the ring_NodeNumber [30] of ringView to 6
   set the ring_Visible of ringView to false
   
   set the rect of sHexagon to oRect
   set the rect of sHexagon to oRect
   unlock screen
end menu_AddRing

on menu_RemoveRing sHexagon
   set the inner_View of sHexagon to empty
end menu_RemoveRing

on _
end _

on menu_GrowSkin sHexagon
   -- dispatch "skin_Colourize" to sHexagon
   lock screen
   dispatch "skin_Grow" to sHexagon
   dispatch "skin_Colourize" to sHexagon
   unlock screen
   -- hexagon_IterateSkin sHexagon
end menu_GrowSkin

on menu_DeleteSkin sHexagon
   put the owner of sHexagon into setContainer
   put the skin_Hexagons of sHexagon into skinHexagons
   put false into sendLater
   lock screen
   repeat for each line skinHexagon in skinHexagons
      if the long id of skinHexagon = the long id of sHexagon then
         put true into sendLater
         next repeat
      end if
      
      delete skinHexagon
   end repeat
   if sendLater is true then
      send "delete sHexagon" to sHexagon in 1 ticks
      send "skin_Colourize" to setContainer in 3 ticks
   else
      dispatch skin_Colourize to setContainer
   end if  
   unlock screen
end menu_DeleteSkin

on menu_ColourSkin sHexagon, someColour
   dispatch "skin_Colourize" to sHexagon with someColour
end menu_ColourSkin

on _
end _

on menu_ColourHexagons sHexagon, someColour
   if someColour = "none" then put empty into someColour
   
   put the hexagon_Views of sHexagon into hexagonViews
   repeat for each line hexagonView in hexagonViews
      set the backgroundcolor of hexagonView to someColour
   end repeat
end menu_ColourHexagons

on menu_AddHexagon sHexagon, gNum
   if menu_SentIsChecked() is true then
      if gNum = "all" then
         set the hexagon_NeighbourNums of sHexagon to empty
         return the result
      end if
      
      put the hexagon_Neighbour [gNum] of sHexagon into someControl
      if exists (someControl) then
         delete someControl
      end if
   else
      if gNum = "all" then
         set the hexagon_NeighbourNums of sHexagon to "all"
         return the result
      end if
      
      dispatch "hexagon_CreateNeighbour" to sHexagon with gNum
   end if
end menu_AddHexagon

on menu_DeleteMe sHexagon
   send "delete sHexagon" to sHexagon in 2 ticks
end menu_DeleteMe

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Shape | Hexagon | Menu | Props
-
-- command hexagon_IterateSkin sHexagon
   -- recursive
   if the commandKey is "Down" then exit to top
   
   set the hexagon_NeighbourNums of sHexagon to "all"
   put the result into allNeighbours
   repeat for each line someHexagon in allNeighbours
      hexagon_IterateSkin someHexagon
   end repeat
end hexagon_IterateSkin

getprop some_Colours
   return "red,green,blue,-,none"
end some_Colours

getprop g_Num [sHexagon]
   put the hexagon_NeighbourNums of sHexagon into numList
   if numList = "1,2,3,4,5,6" then
      return "1,2,3,4,5,6,all"
   else
      return numList
   end if
end g_Num

getprop g_Nums
   return "1,2,3,4,5,6,-,all"
end g_Nums

function lesson_GetClassRect gNum, oRect
   put 0 into someMargin
   switch gNum
      case 0
         put the loc of this card into someLoc
         -- put 50 into someWidth
         put item 3 of oRect - item 1 of oRect into someWidth
         put rect_LocWidthHeight (someLoc, someWidth, someWidth) into newRect
         break
      case 1
         put item 1 of oRect into someLeft
         put item 2 of oRect + someMargin into someTop
         put item 3 of oRect - someLeft into someWidth
         
         put someLeft into item 1 of newRect
         put someTop into item 4 of newRect
         put someLeft + someWidth into item 3 of newRect
         put someTop - someWidth into item 2 of newRect
         break
      case 2
         put rect_GetCentre (oRect) into oLoc
         put item 3 of oRect - item 1 of oRect into someWidth
         put round(someWidth/2) into halfWidth
         
         put item 1 of oLoc + halfWidth into item 1 of newLoc
         put item 2 of oLoc - halfWidth into item 2 of newLoc
         put rect_LocWidthHeight (newLoc, someWidth, someWidth) into newRect
         break
      case 3
         put rect_GetCentre (oRect) into oLoc
         put item 3 of oRect - item 1 of oRect into someWidth
         put round(someWidth/2) into halfWidth
         
         put item 1 of oLoc + halfWidth into item 1 of newLoc
         put item 2 of oLoc + halfWidth into item 2 of newLoc
         put rect_LocWidthHeight (newLoc, someWidth, someWidth) into newRect
         break
      case 4
         put item 1 of oRect into someLeft
         put item 4 of oRect - someMargin into someBottom
         put item 3 of oRect - someLeft into someWidth
         
         put someLeft into item 1 of newRect
         put someBottom into item 2 of newRect
         put someLeft + someWidth into item 3 of newRect
         put someBottom + someWidth into item 4 of newRect
         break
      case 5
         put rect_GetCentre (oRect) into oLoc
         put item 3 of oRect - item 1 of oRect into someWidth
         put round(someWidth/2) into halfWidth
         
         put item 1 of oLoc - halfWidth into item 1 of newLoc
         put item 2 of oLoc + halfWidth into item 2 of newLoc
         put rect_LocWidthHeight (newLoc, someWidth, someWidth) into newRect
         break
      case 6
         put rect_GetCentre (oRect) into oLoc
         put item 3 of oRect - item 1 of oRect into someWidth
         put round(someWidth/2) into halfWidth
         
         put item 1 of oLoc - halfWidth into item 1 of newLoc
         put item 2 of oLoc - halfWidth into item 2 of newLoc
         put rect_LocWidthHeight (newLoc, someWidth, someWidth) into newRect
         break
   end switch
   return newRect
end lesson_GetClassRect



--> Global | Shape | Hexagon | Menu | Disabled
-
getprop disabled_Test [mTarget]
   return false
end disabled_Test


--> Dev | Menu
-
on menu_InitHexagon sHexagon
   put the rect of sHexagon into oRect
   lock screen
   dispatch "hexagon_InitPoints" to sHexagon
   -- dispatch "LayoutControl" to sHexagon with oRect
   unlock screen
end menu_InitHexagon

on menu_HideInnerView sHexagon, someBoolean
   set the inner_Visible of sHexagon to not someBoolean
end menu_HideInnerView

on menu_DeleteInnerView sHexagon
   put the inner_View of sHexagon into innerView
   send "delete innerView" to sHexagon in 0 ticks
end menu_DeleteInnerView

on menu_Points sHexagon, gNum
   put the hexagon_Points of sHexagon
end menu_Points


--> Dev | Menu | Props
-
getprop hide_InnerView [sHexagon]
   return the inner_Visible of sHexagon is false
end hide_InnerView
