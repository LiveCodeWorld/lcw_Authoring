script "behavior_ViewShapeHexagon"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewShapeHexagon
type: behavior
version: 0.1


--> Objects
-
getprop hexagon_View
   return the long id of me
end hexagon_View

getprop view_Object
   return the long id of me
end view_Object


--> Class
-
getprop class_Size
   put the class_Array of me into classArray
   put item 2 of the extents of classArray into classSize
   return classSize
end class_Size

getprop class_Array
   put the inner_View of me into innerView
   if exists (innerView) is false then return empty
   put the ring_NodeArray of innerView into classArray
   return classArray
end class_Array

setprop class_Array [pDontRelayout] classArray
   lock screen
   put the rect of me into oRect
   set the locklocation of me to true
   addRing classArray
   put the result into ringView
   if pDontRelayout is not true then LayoutControl oRect
   set the locklocation of me to false
   unlock screen
   return ringView
   
   repeat for each key pNum in classArray
      put classArray [pNum]["person_Type"] into pType
      set the class_PersonType [pNum] of me to pType
   end repeat
   LayoutControl oRect
   unlock screen
end class_Array

getprop class_PersonType [pNum]
   put the inner_View of me into innerView
   if exists (innerView) is false then return empty
   put the ring_NodeType [pNum] of innerView into pType
   return pType
end class_PersonType

setprop class_PersonType [pNum] pType
   put the inner_View of me into innerView
   if exists (innerView) is false then return empty
   set the ring_NodeType [pNum] of innerView to pType
   return the result
end class_PersonType

private command addRing classArray
   if classArray is not an array then
      put the inner_View of me into ringView
      if exists (ringView) is true then
         delete ringView
      end if
      return empty
   end if
   
   put item 2 of the extents of classArray into pNum
   set the show_Label of me to false
   set the inner_View of me to "Shape|Ring"
   put the result into ringView
   set the showborder of ringView to false
   set the ring_NodeNumber of ringView to pNum
   set the ring_Visible of ringView to false
   
   set the ring_NodeArray of ringView to classArray
   return ringView
end addRing

--> Events
-
on mouseDown pButton
   if pButton is not 3 then pass mouseDown
   menu_PopUp "Global | Shape | Hexagon | Menu"
end mouseDown

-- on mouseUp
   LayoutControl
end mouseUp

on resizecontrol
   LayoutControl
end resizecontrol


--> Geometry
-
command LayoutControl pRect, pRotation
   if the long id of the target is not the long id of me then pass LayoutControl
   
   put the inner_View of me into innerView
   put the graphic_Object of me into graphicObject
   
   put the hexagon_Rect [pRect] of me into hexagonRect
   
   lock screen
   set the rect of graphicObject to hexagonRect
   if exists (innerView) then
      put round (the inner_Margin [pRect] of me) into innerMargin
      put rect_SubtractMargin (innerMargin, hexagonRect) into innerViewRect
      subtract 1 from item 1 of innerViewRect -- hack
      subtract 1 from item 3 of innerViewRect -- hack
      set the rect of innerView to innerViewRect
   end if
   set the rect of me to hexagonRect
   unlock screen
end LayoutControl

getprop inner_Margin [pRect]
   put the inner_Factor of me into innerFactor
   if pRect is empty then
      put the width of me into pWidth
   else
      put item 3 of pRect - item 1 of pRect into pWidth
   end if
   put pWidth * innerFactor into innerMargin  
   return innerMargin
end inner_Margin

setprop inner_Margin [pDontLayout] innerMargin
   lock screen
   put the rect of me into oRect
   init_Stuff innerMargin
   if pDontLayout is not true then LayoutControl oRect
   unlock screen
end inner_Margin

getprop inner_Factor
   put the inner_Factor of me into someFactor
   if someFactor is empty then
      init_Stuff
      return the result
   else
      return someFactor
   end if
end inner_Factor

setprop inner_Factor someFactor
   lock screen
   set the inner_Factor of me to someFactor
   -- LayoutControl
   LayoutControl
   unlock screen
end inner_Factor

command init_Stuff pMargin
   if pMargin is empty then put 14 into pMargin
   put the width of me into pWidth
  
   put pMargin / pWidth into someFactor
   set the inner_Factor of me to someFactor
   
   return someFactor
end init_Stuff


--> Objects
-
getprop graphic_Object
   return the long id of grc 1 of me
end graphic_Object

getprop inner_View  
   put the inner_View of me into innerView
   if exists (innerView) is false then
      if exists (group 1 of me) then
         return the long id of group 1 of me
      end if
      return empty
   end if
   return innerView
end inner_View

setprop inner_View vName
   lock screen
   clear_InnerView
   if vName is empty then return the result
   
   put view_GetTemplateObject (vName) into templateObject  
   copy templateObject to me
   put it into copiedView
   set the inner_View of me to copiedView
   LayoutControl
   unlock screen
   return copiedView
end inner_View

command clear_InnerView
   put the inner_View of me into innerView
   if exists (innerView) is false then return empty
   delete innerView
   return innerView
end clear_InnerView

getprop inner_Visible
   put the inner_View of me into innerView
   if exists (innerView) is false then return empty
   return the visible of innerView
end inner_Visible

setprop inner_Visible someBoolean
   put the inner_View of me into innerView
   set the visible of innerView to someBoolean
end inner_Visible


--> Hexagon
-
command hexagon_InitPoints
   LayoutControl
   put the hexagon_Rect of me into hexagonRect
   put hexagon_PointsFromRect (hexagonRect) into hexagonPoints
   set the hexagon_Points of me to hexagonPoints
   
   -- if pWidth is empty then put the width of grc 1 of me into pWidth
   -- if pLoc is empty then put the loc of grc 1 of me into pLoc
   -- put round (pWidth/2) into someDiameter
   -- put hexagon_GetPoints (someDiameter, pLoc, pRotation) into somePoints
   -- set the points of grc 1 of me to somePoints
end hexagon_InitPoints

function hexagon_PointsFromRect hexagonRect
   put 1 into someMargin -- weird hack
   put item 1 of hexagonRect + someMargin into hLeft
   put item 2 of hexagonRect + someMargin into hTop
   put item 3 of hexagonRect - someMargin into hRight
   put item 4 of hexagonRect - someMargin into hBottom
   
   put hRight - hLeft into hWidth
   put hBottom - hTop into hHeight
   put round (hWidth / 4) into quaterWidth
   put hTop + round (hHeight / 2) into hMid
   
   put hRight -  quaterWidth into item 1 of someLoc
   put hTop into item 2 of someLoc
   put someLoc & CR after somePoints
   
   put someLoc into firstPoint
   
   put hRight into item 1 of someLoc
   put hMid into item 2 of someLoc
   put someLoc & CR after somePoints
   
   put hRight -  quaterWidth into item 1 of someLoc
   put hBottom into item 2 of someLoc
   put someLoc & CR after somePoints
   
   put hLeft + quaterWidth into item 1 of someLoc
   put hBottom into item 2 of someLoc
   put someLoc & CR after somePoints
   
   put hLeft into item 1 of someLoc
   put hMid into item 2 of someLoc
   put someLoc & CR after somePoints
   
   put hLeft + quaterWidth into item 1 of someLoc
   put hTop into item 2 of someLoc
   put someLoc & CR after somePoints
   
   put firstPoint after somePoints
   return somePoints
end hexagon_PointsFromRect

getprop hexagon_ConstructPoints [someDiameter]
   -- based on trig and can be rounding errors?
   local pRotation
   put the loc of the target into centreLoc
   if someDiameter is empty then put 30 into someDiameter
   put hexagon_GetPoints (someDiameter, centreLoc, pRotation) into somePoints
   return somePoints
end hexagon_ConstructPoints

function hexagon_GetPoints someDiameter, centreLoc, pRotation
   repeat with pNum = 1 to 6
      put hexagon_GetPoint (pNum, someDiameter, centreLoc, pRotation) into somePoint
      put somePoint & CR after somePoints
   end repeat
   -- delete char -1 of somePoints
   put line 1 of somePoints after somePoints
   return somePoints
end hexagon_GetPoints

function hexagon_GetPoint pNum, someDiameter, pCentreLoc, pRotation
   if pCentreLoc is empty then put 0,0 into pCentreLoc
   
   put (pNum -1) * 60 + 30 into someRad
   subtract pRotation from someRad
   angle_ConvertDegrees someRad
   
   put someDiameter * sin (someRad) into someX
   put someDiameter * cos (someRad) into someY
   
   add round(someX) to item 1 of pCentreLoc
   add round(someY) to item 2 of pCentreLoc
   return pCentreLoc
end hexagon_GetPoint


--> Hexagon
-
-- getprop hexagon_FormattedBorder
   switch the hexagon_Width of me
      
   end switch
end hexagon_FormattedBorder

getprop hexagon_PointWidth
   put the hexagon_Points of me into somePoints
   put line 1 of somePoints into someLoc
   delete line 1 of somePoints
   put item 1 of someLoc into maxX
   put item 1 of someLoc into minX
   
   repeat for each line someLoc in somePoints
      put item 1 of someLoc into someX
      if someX is empty then next repeat
      
      if someX > maxX then put someX into maxX
      if someX < minX then put someX into minX
   end repeat
   return maxX - minX
end hexagon_PointWidth

getprop hexagon_PointWidth
   put the hexagon_Points of me into somePoints
   put line 1 of somePoints into someLoc
   delete line 1 of somePoints
   put item 2 of someLoc into maxY
   put item 2 of someLoc into minY
   
   repeat for each line someLoc in somePoints
      put item @ of someLoc into someX
      if someX is empty then next repeat
      
      if someX > maxX then put someX into maxX
      if someX < minX then put someX into minX
   end repeat
   return maxX - minX
end hexagon_PointWidth

getprop hexagon_Rect [pRect]
   if pRect is empty then put the rect of me into pRect
   
   put the inner_Rect [pRect] of me into innerRect
   put item 3 of innerRect - item 1 of innerRect into mWidth
   put item 4 of innerRect - item 2 of innerRect into mHeight
   put rect_GetCentre (innerRect) into mLoc
   
   put hexagon_GetHeight (mWidth) into hHeight
   if hHeight > mHeight then
      put hexagon_GetWidth (mHeight) into hWidth
      put rect_LocWidthHeight (mLoc, hWidth, mHeight) into hexagonRect
   else
      put rect_LocWidthHeight (mLoc, mWidth, hHeight) into hexagonRect
   end if
   if hexagonRect is not newRect then
      add 1 to item 2 of hexagonRect
      add 1 to item 4 of hexagonRect
   end if
   return hexagonRect
end hexagon_Rect

getprop hexagon_NeighbourNums
   repeat with gNum = 1 to 6
      put the hexagon_NeighbourLoc [gNum] of me into someLoc
      put controlAtLoc (someLoc) into someControl
      if exists (someControl) is false then next repeat
      put the hexagon_View of someControl into hexagonView
      if exists (hexagonView) is false then next repeat
      
      put gNum & comma after neighbourNums
   end repeat
   delete char -1 of neighbourNums
   return neighbourNums
end hexagon_NeighbourNums

setprop hexagon_NeighbourNums numList
   local hNeighbours
   if numList = "all" then put "1,2,3,4,5,6" into numList
   
   repeat with gNum = 1 to 6
      switch
         case numList is empty
            -- delete them all
            hexagon_DeleteNeighbour gNum
            break
         case itemoffset (gNum, numList) is a number
            -- need to make sure it is added
            hexagon_CreateNeighbour gNum
            put the result into hNeighbour
            put hNeighbour & CR after hNeighbours
            break
         default
            -- need to make sure it is not there
            hexagon_DeleteNeighbour gNum
      end switch
   end repeat
   return hNeighbours
end hexagon_NeighbourNums

command hexagon_DeleteNeighbour gNum
   put the hexagon_Neighbour [gNum] of me into someNeighbour
   if exists(someNeighbour) then
      delete someNeighbour
   end if
end hexagon_DeleteNeighbour

command hexagon_CreateNeighbour gNum
   put the hexagon_Neighbour [gNum] of me into someNeighbour
   if exists(someNeighbour) is true then return empty
   
   put the hexagon_NeighbourLoc [gNum] of me into newLoc
   
   lock screen
   clone me
   put it into newHexagon
   set the hexagon_Label of newHexagon to gNum
   set the loc of newHexagon to newLoc
   unlock screen
   return newHexagon
end hexagon_CreateNeighbour

getprop hexagon_Neighbour [gNum]
   put the hexagon_NeighbourLoc [gNum] of me into someLoc
   put controlAtLoc (someLoc) into someControl
   if exists (someControl) is false then return empty
   
   put the hexagon_View of someControl into hexagonView
   if exists (hexagonView) is false then return empty
   return hexagonView
end hexagon_Neighbour

getprop hexagon_Neighbours
   repeat with gNum = 1 to 6
      put the hexagon_Neighbour [gNum] of me into someHexagon
      if exists (someHexagon) is false then next repeat
      
      put someHexagon & CR after someControls
   end repeat
   delete char -1 of someControls
   return someControls
end hexagon_Neighbours

getprop hexagon_NeighbourLoc [gNum]
   put the rect of me into mRect
   put rect_GetCentre (mRect) into mLoc
   put the loc of me into mLoc
   
   put item 3 of mRect - item 1 of mRect into mWidth
   put item 4 of mRect - item 2 of mRect into mHeight
   put round(mWidth/2) into mSide
   
   put round (1.5 * mSide) into someX
   put round (mHeight/2) into someY
   
   put mLoc into newLoc
   switch gNum
      case 0
         return mLoc
      case 1
         subtract (mHeight - 2) from item 2 of newLoc
         return newLoc
      case 2
         add (someX - 2) to item 1 of newLoc
         subtract (someY - 1) from item 2 of newLoc
         return newLoc
      case 3
         add (someX - 2) to item 1 of newLoc
         add (someY - 1) to item 2 of newLoc
         return newLoc
      case 4
         add (mHeight - 2) to item 2 of newLoc
         return newLoc
      case 5
         subtract (someX - 2) from item 1 of newLoc
         add (someY - 1) to item 2 of newLoc
         return newLoc
      case 6
         subtract (someX - 2) from item 1 of newLoc
         subtract (someY - 1) from item 2 of newLoc
         return newLoc
   end switch
end hexagon_NeighbourLoc

function hexagon_GetHeight someWidth
   put angle_DegreesToRadians (30) into someRad
   put someWidth * cos (someRad) into someHeight
   return round (someHeight)
end hexagon_GetHeight

function hexagon_GetWidth someHeight
   put angle_DegreesToRadians (30) into someRad
   put someHeight / cos (someRad) into someWidth
   return round (someWidth)
end hexagon_GetWidth

getprop hexagon_Side
   put the long id of grc 1 of me into polyObject
   put the width of polyObject into w
   put w/2 into hSide
   return hSide
   
   -- do some unecessary trig
   put angle_DegreesToRadians(60) into eAngle
   put 4* cos (eAngle) into someFactor
   put w / someFactor into cSide
   
   -- check actual points
   put the hexagon_Points of me into somePoints
   put item 1 of line -1 of somePoints into farX
   put item 1 of line -2 of somePoints into nearX
   put farX - nearX into pSide
end hexagon_Side

-- setprop hexagon_Side hSide
   put the loc of 
end hexagon_Side

getprop hexagon_Points
   put the long id of grc 1 of me into polyObject
   put the points of polyObject into somePoints
   return somePoints
end hexagon_Points

setprop hexagon_Points somePoints
   put the long id of grc 1 of me into polyObject
   set the points of polyObject to somePoints
   return polyObject
end hexagon_Points

-- setprop hexagon_Points [pRotation] someDiameter
   put the loc of the target into centreLoc
   if someDiameter is empty then put 30 into someDiameter
   
   set the style of the target to polygon
   put hexagon_GetPoints (someDiameter, centreLoc, pRotation) into somePoints
   
   set the points of the target to somePoints
   return somePoints
end hexagon_Points

getprop hexagon_Width
   return the width of me
end hexagon_Width

setprop hexagon_Width [pRotation] someWidth
   put the loc of me into oLoc
   -- set the hexagon_Points of grc 1 of me to round (someWidth/2)
   put rect_LocWidthHeight (oLoc, someWidth, someWidth) into newRect
   LayoutControl newRect, pRotation
   return the result
end hexagon_Width

getprop show_Label
   put the graphic_Object of me into graphicObject
   return the showname of graphicObject
end show_Label

setprop show_Label someBoolean
   put the graphic_Object of me into graphicObject
   set the showname of graphicObject to someBoolean
   return graphicObject
end show_Label

getprop hexagon_Label
   put the graphic_Object of me into graphicObject
   return the label of graphicObject
end hexagon_Label

setprop hexagon_Label someLabel
   put the graphic_Object of me into graphicObject
   set the label of graphicObject to someLabel
   return graphicObject
end hexagon_Label


--> Angle
-
command angle_ConvertDegrees @someDegree
   put angle_DegreesToRadians (someDegree) into someDegree
end angle_ConvertDegrees

function angle_DegreesToRadians someDegree
   put pi * someDegree / 180 into someRadians
   return someRadians
end angle_DegreesToRadians

command angle_ConvertRadians @someRadians
   put 180 * someRadians / pi into someDegrees
   put someDegrees into someRadians
end angle_ConvertRadians

function angle_RadiansToDegrees someRadians
   put 180 * someRadians / pi into someDegrees
   return someDegrees
end angle_RadiansToDegrees

