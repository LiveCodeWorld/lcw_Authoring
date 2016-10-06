script "behavior_ViewShapeRing"
--> MetaData
-
license: GPLv3
name: behavior_ViewShapeRing
type: behavior
version: 0.1


--> Objects
-
getprop ring_View
   return the long id of me
end ring_View

getprop view_Object
   return the long id of me
end view_Object


--> Data
-
getprop ring_NodeArray
   put the ring_NodeNumber of me into maxNum   
   repeat with nodeNum = 1 to maxNum
      put the ring_Node [nodeNum] of me into ringNode
      if exists (ringNode) is false then next repeat
      
      put the rect of ringNode into nodeArray [nodeNum]["rect"]
      put the rugged_ID of ringNode into nodeArray [nodeNum]["rugged_ID"]
      
      put the ring_NodeType [nodeNum] of me into pType
      put pType into nodeArray [nodeNum]["person_Type"]
   end repeat
   return nodeArray
end ring_NodeArray

setprop ring_NodeArray nodeArray
   put item 2 of the extents of nodeArray into maxNum
   repeat with nodeNum = 1 to maxNum
      set the ring_NodeType [nodeNum] of me to nodeArray [nodeNum]["person_Type"]
      -- set the rect of ringNode to nodeArray [nodeNum]["rect"]
   end repeat
   return empty
end ring_NodeArray


--> Events
-
-- on mouseUp
   LayoutControl
   -- test_RingRadius
end mouseUp

on resizecontrol
   LayoutControl
   LayoutControl
end resizecontrol


--> Tests
-
-- command test_RingRadius pRingRadius, pRect
   if pRect is empty then put the rect of me into pRect
   if pRingRadius is empty then put the ring_Radius of me into pRingRadius
   
   put round (2 * pRingRadius) into ringWidth
   put rect_GetCentre (pRect) into centreLoc
   put rect_LocWidthHeight (centreLoc, ringWidth, ringWidth) into nodeRect
   rect_CreateMask nodeRect, "Ring Test mask"
end test_RingRadius


--> Geometry
-
getprop initial_Rotation
   put the initial_Rotation of me into initialRotation
   if initialRotation is empty then return 0
   return initialRotation
end initial_Rotation

setprop initial_Rotation initialRotation
   set the initial_Rotation of me to initialRotation
   LayoutControl
end initial_Rotation

getprop ring_Radius [pNodeWidth]
   if pNodeWidth is empty then put the node_Width of me into pNodeWidth
   put the inner_Rect of me into innerRect
   
   -- rect_CreateMask innerRect, "innerRect"
   
   put item 3 of innerRect - item 1 of innerRect into innerWidth
   put item 4 of innerRect - item 2 of innerRect into innerHeight
   put min (innerWidth, innerHeight) into smallDiameter
   put (smallDiameter - pNodeWidth) / 2 into ringRadius
   
   -- subtract 2 from ringRadius -- hack
   -- add round (pNodeWidth/4) to ringRadius -- hack
   subtract round (pNodeWidth/4) from ringRadius -- hack
   
   return ringRadius
end ring_Radius

command LayoutControl pRect, pNodeWidth
   if pRect is empty then put the rect of me into pRect
   
   lock screen
   put the ring_Graphic of me into ringGraphic
   
   put the ring_Radius [pNodeWidth] of me into someRadius
   -- test_RingRadius someRadius, pRect
   
   put the ring_FormattedBorder of me into ringBorderWidth
   set the linesize of ringGraphic to ringBorderWidth
   
   put the initial_Rotation of me into initialRotation
   put the ring_Nodes of me into ringNodes
   put the number of lines of ringNodes into numberOfPoints
   if numberOfPoints = 0 then
      return empty
   end if
   
   put rect_GetCentre (pRect) into centreLoc
   put ring_GetPoints (numberOfPoints, someRadius, centreLoc, initialRotation) into somePoints
   
   set the points of ringGraphic to somePoints
   
   put the node_FactorWidth of me into nodeWidth  
   repeat with nodeNum = 1 to (the number of lines of somePoints - 1)
      put line nodeNum of somePoints into someLoc
      put line nodeNum of ringNodes into nodeView
      
      put rect_LocWidthHeight (someLoc, nodeWidth, nodeWidth) into nodeRect
      set the rect of nodeView to nodeRect
      -- set the loc of nodeView to someLoc
      set the image_Margins of nodeView to 0
   end repeat
   return ringNodes
end LayoutControl


--> Node
-
getprop node_ViewName
   put the node_ViewName of me into vName
   if vName is empty then return "View|Image|Masked"
   return vName
end node_ViewName

setprop node_ViewName vName
   set the node_ViewName of me to vName
end node_ViewName

getprop node_FactorWidth [pRingWidth]
   put 28 into minW
   put the ring_Graphic of me into ringGraphic
   if pRingWidth is empty then put the width of ringGraphic into pRingWidth
   put the node_Factor of me into nodeFactor
   put round (pRingWidth * nodeFactor) into nodeWidth
   if nodeWidth < minW then return minW
   return nodeWidth
end node_FactorWidth

command init_Stuff pNodeWidth
   if pNodeWidth is empty then put the node_Width of me into pNodeWidth
   
   put the ring_Graphic of me into ringGraphic
   put the width of ringGraphic into myWidth
   -- put the width of me into myWidth
   
   put pNodeWidth/myWidth into nodeFactor
   set the node_Factor of me to nodeFactor
   
   return the node_FactorWidth of me
end init_Stuff

getprop node_Width
   put the ring_Nodes of me into ringNodes
   put line 1 of ringNodes into ringNode
   if exists(ringNode) is false then return 0
   
   put the width of ringNode into nodeWidth
   return nodeWidth
end node_Width

setprop node_Width nodeWidth
   init_Stuff nodeWidth
   put the rect of me into pRect
   LayoutControl pRect, nodeWidth
   return empty
end node_Width


--> Node | Scale
-
getprop node_Factor
   put the node_Factor of me into nodeFactor
   if nodeFactor is empty then
      return 0.2
      init_Stuff
      return the result
   else
      return nodeFactor
   end if
end node_Factor

setprop node_Factor nodeFactor
   lock screen
   set the node_Factor of me to nodeFactor
   LayoutControl
   LayoutControl
   unlock screen
end node_Factor


--> Ring
-
getprop ring_FormattedBorder
   put the width of me into myWidth   
   switch
      case myWidth < 250
         return 1
      case myWidth > 500
         return 3
      default
         return 2
   end switch
end ring_FormattedBorder

getprop ring_Visible
    put the ring_Graphic of me into ringGraphic
    put the visible of ringGraphic into someBoolean
    return someBoolean
end ring_Visible

setprop ring_Visible someBoolean
    put the ring_Graphic of me into ringGraphic
    set the visible of ringGraphic to someBoolean
    return ringGraphic
end ring_Visible

getprop ring_Style
    put the ring_Graphic of me into ringGraphic
    put the style of ringGraphic into ringStyle
    return ringStyle
end ring_Style

setprop ring_Style ringStyle
    put the ring_Graphic of me into ringGraphic
    set the style of ringGraphic to ringStyle
    return ringGraphic
end ring_Style

getprop ring_Styles
   return "polygon,curve,oval,regular"
end ring_Styles

getprop ring_NodeType [nodeNum]
   put the ring_Node [nodeNum] of me into ringNode
   if exists (ringNode) is false then return empty
   put the node_Type of ringNode into nType
   return nType
end ring_NodeType

setprop ring_NodeType [nodeNum] nType
   put the ring_Node [nodeNum] of me into ringNode
   if exists (ringNode) is false then return empty
   set the node_Type of ringNode to nType
   return ringNode
end ring_NodeType

getprop ring_Node [nodeNum]
   put the ring_Nodes of me into ringNodes
   put line nodeNum of ringNodes into ringNode
   return ringNode
end ring_Node

getprop ring_NodeNumber
   put the ring_Nodes of me into ringNodes
   return the number of lines of ringNodes
end ring_NodeNumber

setprop ring_NodeNumber [pInitialRotation] numberOfPoints
   lock screen
   if pInitialRotation is not empty then set the initial_Rotation of me to pInitialRotation
   put the rect of me into oRect
   clear_Nodes
   if numberOfPoints = 0 then return empty
   
   put the node_ViewName of me into vName
   put view_GetTemplateObject (vName) into templateObject
   if exists (templateObject) is false then return empty
   
   put the ring_Graphic of me into ringGraphic
   put (the width of ringGraphic -2) / 2 into someRadius
   put the loc of me into centreLoc
   put ring_GetPoints (numberOfPoints, someRadius, centreLoc, pInitialRotation) into somePoints
   
   set the style of ringGraphic to "polygon"
   set the points of ringGraphic to somePoints
   
   repeat with nodeNum = 1 to (the number of lines of somePoints - 1)
      put line nodeNum of somePoints into someLoc
      
      copy templateObject to me
      put it into copiedView
      put copiedView & CR after ringNodes
      
      -- here we can position, scale and label
      -- set the loc of copiedView to someLoc
   end repeat
   delete char -1 of ringNodes
   
   LayoutControl oRect
   LayoutControl oRect
   unlock screen
   return ringNodes
end ring_NodeNumber

command clear_Nodes
   put the ring_Nodes of me into topNodes
   repeat for each line someView in topNodes
      delete someView
   end repeat
end clear_Nodes

setprop ring_PointNumber [pInitialRotation] numberOfPoints
   put the ring_Graphic of me into ringGraphic
   put the loc of me into centreLoc
   put (the width of ringGraphic -2) / 2 into someRadius
   
   put ring_GetPoints (numberOfPoints, someRadius, centreLoc, pInitialRotation) into somePoints
   
   set the style of ringGraphic to "polygon"
   set the points of ringGraphic to somePoints
   return somePoints
end ring_PointNumber

function ring_GetPoints numberOfPoints, someRadius, pCentreLoc, pInitialRotation
   if pCentreLoc is empty then put 0,0 into pCentreLoc
   angle_ConvertDegrees pInitialRotation
   
   put 2 * pi / numberOfPoints into radStep
   repeat with pNum = 1 to numberOfPoints
      put (pNum -1) * radStep into someRad
      add pInitialRotation to someRad
      
      put someRadius * sin (someRad) into someX
      put someRadius * cos (someRad) into someY
      
      put round(someX) + item 1 of pCentreLoc into item 1 of somePoint
      put round(someY) + item 2 of pCentreLoc into item 2 of somePoint
      
      put somePoint & CR after somePoints
   end repeat
   put line 1 of somePoints after somePoints
   return somePoints
end ring_GetPoints


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


--> Objects
-
getprop ring_Graphic
   return the long id of grc "Ring" of me
end ring_Graphic

getprop ring_Nodes
   put the top_Views of me into nodeViews
   -- put the ring_Graphic of me into ringGraphic
   return nodeViews
end ring_Nodes
