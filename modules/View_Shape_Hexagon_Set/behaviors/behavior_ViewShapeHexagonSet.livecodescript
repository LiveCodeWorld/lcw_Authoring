script "behavior_ViewShapeHexagonSet"
--> MetaData
-
license: GPLv3
name: behavior_ViewShapeHexagonSet
type: behavior
version: 0.1


--> Objects
-
getprop set_View
   return the long id of me
end set_View

getprop view_Object
   return the long id of me
end view_Object


--> Events
-
-- on resizecontrol
   LayoutControl
end resizecontrol


--> Geometry
-
command LayoutControl pRect
   if the long id of the target is not the long id of me then pass LayoutControl
   if pRect is empty then put the rect of me into pRect
   put rect_GetCentre (pRect) into myLoc
   put the formattedwidth of me into fWidth
   put the formattedheight of me into fHeight
   put rect_LocWidthHeight (myLoc, fWidth, fHeight) into newRect
   -- set the loc of me to myLoc
   repeat with itemNum = 1 to 4
      add 1 to item itemNum of newRect
   end repeat
   set the rect of me to newRect
end LayoutControl


--> Hexagon
-
getprop hexagon_Views
   put the number of groups of me into mNum
   repeat with gNum = 1 to mNum
      put the hexagon_View of group gNum of me into hexagonView
      put gNum into viewArray [hexagonView]
   end repeat
   put keys(viewArray) into hexagonViews
   return hexagonViews
end hexagon_Views


--> Set
-
getprop skin_Hexagons
   local viewObjects
   put the hexagon_Views of me into hexagonViews
   repeat for each line hexagonView in hexagonViews
      put the hexagon_NeighbourNums of hexagonView into nNums
      if nNums is not "1,2,3,4,5,6" then
         put hexagonView & CR after viewObjects
      end if
   end repeat
   delete char -1 of viewObjects
   return viewObjects
end skin_Hexagons

command skin_Grow
   local viewObjects
   lock screen
   put the hexagon_Views of me into hexagonViews
   repeat for each line hexagonView in hexagonViews
      put the hexagon_NeighbourNums of hexagonView into nNums
      if nNums is not "1,2,3,4,5,6" then
         set the hexagon_NeighbourNums of hexagonView to "all"
      end if
   end repeat
   unlock screen
   return the skin_Hexagons of me
end skin_Grow

command skin_Colourize pSkinColour, pBodyColour
   local viewObjects
   if pSkinColour is empty then put "red" into pSkinColour
   if pBodyColour is empty then put empty into pBodyColour
   
   put the hexagon_Views of me into hexagonViews
   repeat for each line hexagonView in hexagonViews
      put the hexagon_NeighbourNums of hexagonView into nNums
      if nNums is not "1,2,3,4,5,6" then
         put hexagonView & CR after viewObjects
         set the backgroundcolor of hexagonView to pSkinColour
      else
         set the backgroundcolor of hexagonView to pBodyColour
      end if
   end repeat
   delete char -1 of viewObjects
   return viewObjects
end skin_Colourize
