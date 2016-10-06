script "behavior_ViewShapeCobweb"
--> MetaData
-
author: David Bovill
license: GPLv3
name: behavior_ViewShapeCobweb
type: behavior
version: 0.1

/*
triangles are the quadrants of the hexagon numbered from 1-6 moving round the clock
the first triangle is the one in th etop right quadrant of the clock (between 12 qnd roughly 2).
rings are hexagons that are numbered from the outer ring inside

segments are the polygons representing the areas of the cobwed created by the intersection of the star lines and hexagons.
they are numbered in a more intuitive (from inside out) manner
*/

local LocalArray


--> Events
-
on mouseDown pKey
   switch pKey
      case 3
         menu_PopUp "Global | Shape | Cobweb | Menu"
         break
      default
   end switch
end mouseDown

-- on mouseStillDown
   put the short name of the owner of the target into oName
   switch oName
      case "Clock"
         break
      case "Triangles"
         setTraingleValueWithMouseLoc
         break
   end switch
end mouseStillDown

-- on mouseUp
   put the short name of the owner of the target into oName
   switch oName
      case "Clock"
         put the clock_GeometryArray of the target into gArray
         set the clock_GeometryArray of the target to gArray
         
         display_Array gArray, "the clock_GeometryArray"
         break
      case "Triangles"
         setTraingleValueWithMouseLoc
         break
   end switch
end mouseUp


--> Events | Clock
-
on newClockSection sectionColour, someSeconds, sectionTriggerArray, gArray
   clock_ChangeColour sectionColour, someSeconds
   pass newClockSection
end newClockSection

on clock_ChangeColour nextColour, pSectionName
   if pSectionName is a number then
      put "Slice" && pSectionName into pSectionName
   end if
   
   put the clock_Colour of me into lastColour
   set the clock_Colour of me to nextColour
   
   put LocalArray ["last_ClockAngle"] into lastAngle
   if lastAngle is empty then put 0 into lastAngle
   put item 1 of the clock_Angle of me into thisAngle
   
   if "animationEngine" is among the lines of the stacksInUse then
      create_NewSlice lastColour, 100, pSectionName
      put the result into sliceObject
      put construct_ClockGeometry (lastAngle, thisAngle) into gArray
      set the clock_GeometryArray of sliceObject to gArray
      
      aeFadeIn sliceObject, 1000
   else
      create_NewSlice lastColour, 0, pSectionName
      put the result into sliceObject
      put construct_ClockGeometry (lastAngle, thisAngle) into gArray
      set the clock_GeometryArray of sliceObject to gArray
   end if
   
   put thisAngle into LocalArray ["last_ClockAngle"]
   -- pass clock_ChangeColour
   return gArray
end clock_ChangeColour


--> Objects
-
function triangleObject qNum
   put "Triangle" && qNum into tName
   if exists (grc tName of me) is false then return empty
   
   put the long id of grc tName of me into tObject
   return tObject
end triangleObject

function triangleObjects
   repeat with qNum = 1 to 6
      put triangleObject (qNum) into tObject
      if tObject is not empty then
         put tObject & CR after tObjects
      end if
   end repeat
   delete char -1 of tObjects
   return tObjects
end triangleObjects

function borderObject
   if exists (grc "Border" of me) is false then return empty
   put the long id of grc "Border" of me into hexBorder
   return hexBorder
end borderObject

function spiderGraphic
   return the long id of grc "Cobweb" of me
end spiderGraphic

function sliceObject pName
   if pName is empty then put "Slice 0" into pName
   if exists (grc pName of group "Clock" of me) is false then return empty
   return the long id of grc pName of group "Clock" of me 
end sliceObject


--> Spider | Sections
-
getprop spider_Section [sectionItems]
   put item 1 of sectionItems into fromQnum
   put item 2 of sectionItems into toQnum
   put item 3 of sectionItems into ringNum
   if ringNum is empty then put 5 into ringNum
   
   put the hexagon_Centre of me into myCentre
   put the spider_Points of me into spiderPoints
   put hexagon_GetSpiderSection (fromQnum, toQnum, ringNum, myCentre, spiderPoints) into sectionPoints
   return sectionPoints
end spider_Section

getprop spider_SectionGeometry
   return gArray
end spider_SectionGeometry

setprop spider_SectionGeometry gArray
   deconstruct_SpiderGeometry fromQnum, toQnum, ringNum, myCentre, gArray
   
   put the hexagon_Centre of me into myCentre
   put the spider_Points of me into spiderPoints
   put hexagon_GetSpiderSection (fromQnum, toQnum, ringNum, myCentre, spiderPoints) into sectionPoints
   
   set the points of the target to sectionPoints
   set the section_Geometry of the target to gArray
end spider_SectionGeometry

function parse_SpiderPoints spiderPoints, pNumberOfSides
   if pNumberOfSides is empty then put 6 into pNumberOfSides
   
   put line 1 of spiderPoints into pointArray ["spider_Centre"]
   
   put 1 into lineNum
   repeat pNumberOfSides
      put line 1 to 2 of spiderPoints into starLinePoints
      put starLinePoints into pointArray ["star_Line"][lineNum]
      add 1 to lineNum
      delete line 1 to 4 of spiderPoints
   end repeat
   
   put 1 into reversedRingNum
   put pNumberOfSides + 2 into someNum
   repeat
      put line 1 to someNum of spiderPoints into ringPoints
      
      put ringPoints into pointArray ["ring_Points"][reversedRingNum]
      
      delete line 1 to someNum of spiderPoints
      if spiderPoints is empty then
         put reversedRingNum into pointArray ["number_OfRings"]
         return pointArray
      end if
      
      add 1 to reversedRingNum
   end repeat
   
   breakpoint
   return pointArray
end parse_SpiderPoints

function create_SpiderLinkArray spiderArray, myCentre
   put myCentre into spiderLinkArray [0,0]
   repeat with ringNum = 1 to 5
      put spiderArray ["ring_Points"][ringNum] into ringPoints
      
      repeat with starLineNum = 0 to 5
         put line (starLineNum + 1) of ringPoints into somePoint
         put somePoint into spiderLinkArray [starLineNum,ringNum]
      end repeat
   end repeat
   return spiderLinkArray
end create_SpiderLinkArray

getprop spider_LinkArray
   put the spider_Points of me into spiderPoints
   put the hexagon_Centre of me into myCentre
   put parse_SpiderPoints (spiderPoints, 6) into spiderArray
   put create_SpiderLinkArray (spiderArray, myCentre) into spiderLinkArray
   return spiderLinkArray
end spider_LinkArray

getprop spider_PointLinks [ringPoint]
   put item 1 of ringPoint into starLineNum
   put item 2 of ringPoint into ringNum
   put the spider_LinkArray of me into spiderLinkArray
   
   put spider_GetPointLinks (starLineNum, ringNum, spiderLinkArray) into pointLinks
   return pointLinks
end spider_PointLinks

getprop spider_RandomLinkPoint [ringPoint]
   put the spider_PointLinks [ringPoint] of me into ringPointLinks
   put any line of ringPointLinks into randomRingPoint
   
   put the spider_LinkArray of me into spiderLinkArray
   put spiderLinkArray [randomRingPoint] into somePoint
   return randomRingPoint
end spider_RandomLinkPoint

function spider_GetPointLinks starLineNum, ringNum, spiderLinkArray
   put (starLineNum + 1) mod 6 into newStarLineNum
   put newStarLineNum,ringNum & CR after someLinks
   
   put (starLineNum - 1) mod 6 into newStarLineNum
   if newStarLineNum < 0 then add 6 to newStarLineNum
   put newStarLineNum,ringNum & CR after someLinks
   
   switch ringNum
      case 1
         put ringNum + 1 into newRingNum
         put starLineNum,newRingNum & CR after someLinks
         
         put 0,0 & CR after someLinks
         break
      case 5
         put ringNum - 1 into newRingNum
         put starLineNum,newRingNum & CR after someLinks
         break
      default
         put ringNum + 1 into newRingNum
         put starLineNum,newRingNum & CR after someLinks
         
         put ringNum - 1 into newRingNum
         put starLineNum,newRingNum & CR after someLinks
   end switch
   
   delete char -1 of someLinks
   return someLinks
end spider_GetPointLinks


--> Object | Create
-
command delete_Border
   put borderObject() into borderObject
   if borderObject is empty then return empty
   delete borderObject
end delete_Border

command create_Border
   put borderObject() into borderObject
   if borderObject is not empty then return borderObject
   
   put the ring_Points of me into ringPoints
   set the points of templategraphic to ringPoints
   set the style of templategraphic to "polygon"
   set the linesize of templategraphic to 4
   
   create grc "Border" in me
   put it into borderObject
   reset templategraphic
   return borderObject
end create_Border

private command create_SpiderSection fromQnum, toQnum, ringNum
   if graphicName is empty then put "Spider Section" into graphicName
   create_GraphicSection graphicName, "Sections", pColour, pBlendLevel
   return the result
end create_SpiderSection

private command create_NewSlice pColour, pBlendLevel, pName
   if pName is empty then put "Slice 0" into pName
   create_GraphicSection pName, "Clock", pColour, pBlendLevel
   return the result
end create_NewSlice

private command create_HexagonTriangle qNum 
   lock screen
   put "Triangle" && qNum into tName
   if exists (grc tName of me) is false then
      create grc tName in me
      put it into tObject
      set the style of tObject to "polygon"
      set the opaque of tObject to true
      set the backgroundColor of tObject to triangle_GetColour (qNum)
      set the blendlevel of tObject to 50
   end if
   
   LayoutControl
   unlock screen
   return the result
end create_HexagonTriangle

private command create_GraphicSection graphicName, sectionName, pColour, pBlendLevel
   if exists (grc graphicName of group sectionName) then
      -- already exists
      put the long id of grc graphicName of group sectionName into sliceObject
      if pColour is not empty then set the backgroundcolor of sliceObject to pColour
      if pBlendLevel is not empty then set the blendlevel of sliceObject to pBlendLevel
      return sliceObject
   end if
   
   if exists (group sectionName of me) is false then
      set the margins of the templateGroup to 0
      create group sectionName in me
      
      put borderObject() into borderObject
      if borderObject is not empty then
         relayer borderObject to front of owner
      end if
   end if
   
   setUpTemplateGraphic pColour, pBlendLevel
   create grc graphicName in group sectionName of me
   put it into graphicObject
   
   reset templategraphic
   return graphicObject
end create_GraphicSection

private command setUpTemplateGraphic pColour, pBlendLevel
   if pColour is empty then put "red" into pColour
   if pBlendLevel is empty then put 50 into pBlendLevel
   
   set the style of the templategraphic to "polygon"
   set the linesize of the templategraphic to 0
   set the opaque of the templategraphic to true
   set the backgroundcolor of the templategraphic to pColour
   set the blendlevel of the templategraphic to pBlendLevel
end setUpTemplateGraphic

private command create_Slice slicePoints, pColour, pBlendLevel, pName
   if pName is empty then put "Slice 0" into pName
   set the lockupdates of me to true   
   if exists (grc pName of group "Clock" of me) then
      put the long id of grc pName of group "Clock" of me into sliceObject
      set the points of sliceObject to slicePoints
   else
      set the points of the templategraphic to slicePoints
      create_NewSlice pColour, pBlendLevel, pName
      put the result into sliceObject
   end if
   set the lockupdates of me to false   
   return sliceObject
end create_Slice

-- command create_Nodes
if exists (grp "Hexagon Nodes" of me) is false then
   create grp "Hexagon Nodes" in me
   put it into nodeGroup
end if
set the rect of grp "Hexagon Nodes" of me to the rect of spiderGraphic()

set the width of the templateButton to 12
set the height of the templateButton to 12
set the backgroundcolor of the templateButton to "red"
set the style of the templateButton to "roundrect"
set the loc of templateButton to the hexagon_Centre of me

create button "1,1" in group "Hexagon Nodes" of me
put it into createdButton

create button "2,1" in group "Hexagon Nodes" of me
put it into createdButton

reset the templateButton
end create_Nodes


--> Object | Delete
-
command delete_Clock
   if exists (grp "Clock" of me) is false then return empty
   delete grp "Clock" of me
end delete_Clock

command delete_Nodes
   if exists (grp "Hexagon Nodes" of me) is false then return empty
   delete grp "Hexagon Nodes" of me
end delete_Nodes

private command delete_Slice
   if exists (grc "Slice 0" of me) is false then return empty
   delete grc "Slice 0" of me 
end delete_Slice

private command setTraingleValueWithMouseLoc
   put the triangle_Number of the target into qNum
   get the hexagon_Value [the mouseLoc] of me
   put trunc (it) + 1 into tValue
   set the triangle_Value [qNum] of the target to tValue
end setTraingleValueWithMouseLoc

getprop triangle_Number
   put the short name of the target into someName
   if word 1 of someName is not "Triangle" then
      put the click_TriangleNum of me into qNum
      return qNum
   else
      return word -1 of someName
   end if
end triangle_Number

getprop click_TriangleNum
   put the click_Angle of me into cAngle
   put cAngle div 60 + 1 into qNum
   return qNum
end click_TriangleNum

getprop click_Angle
   put the clickLoc into sLoc
   put the loc of spiderGraphic() into myCentre
   put item 1 of sLoc - item 1 of myCentre into someX
   put item 2 of myCentre - item 2 of sLoc into someY
   
   -- put someY / someX into theMagnitude
   put atan2 (someX, someY) * 180 / pi into clickAngle
   if clickAngle > 0 then
      return clickAngle
   else
      return 360 + clickAngle
   end if
end click_Angle


--> Clock
-
command clock_Start pStartColour
   delete_Clock
   set the clock_Seconds [pStartColour] of me to 0
   put the seconds into startSeconds
   put startSeconds into LocalArray ["start_Seconds"]
   put 0 into LocalArray ["last_ClockAngle"]
   
   -- set the clock_Stopped of me to false
   put false into LocalArray ["clock_Stopped"]
   clock_Update 0, pStartColour
end clock_Start

command clock_Stop
   set the clock_Stopped of me to true
end clock_Stop

getprop clock_Stopped
   put LocalArray ["clock_Stopped"] is true into someBoolean
   return someBoolean
end clock_Stopped

setprop clock_Stopped someBoolean
   put someBoolean is true into LocalArray ["clock_Stopped"]
   if someBoolean is false then
      clock_Update
   else
      -- aeCancelPending
   end if
   put the clock_Seconds of me into cSeconds
   return cSeconds
end clock_Stopped

command clock_Update startSeconds, pColour
   put LocalArray ["start_Seconds"] into startSeconds
   put the seconds into nowSeconds
   put nowSeconds - startSeconds into someSeconds
   
   set the clock_Seconds [pColour] of me to someSeconds
   put the result into gArray
   
   dispatch "clock_Updated" to the owner of me with someSeconds
   
   put LocalArray ["clock_TriggerArray"] into clockTriggerArray
   put clockTriggerArray [someSeconds]["command"] into someCommand
   if someCommand is not empty then
      put clockTriggerArray [someSeconds] into sectionTriggerArray
      put sectionTriggerArray ["param"] into someParam
      dispatch someCommand with someParam,someSeconds,sectionTriggerArray,gArray
   end if
   
   if the clock_Stopped of me is false then
      put the clock_Duration of me into cDuration
      if someSeconds >= cDuration then
         set the clock_Stopped of me to true
         dispatch "clock_Finished" with someSeconds,clockTriggerArray
      else
         send "clock_Update startSeconds" to me in 60 ticks
      end if
   end if
end clock_Update

on clock_Finished someSeconds
   -- answer "Clock has finished"
   clock_ChangeColour "green", "Finished"
   
   put empty into LocalArray ["last_ClockAngle"]
   pass clock_Finished
end clock_Finished


--> Pie Chart
-
setprop display_PieChart [pBlendLevel] clockSectionModel
   local sortedIndex, proportionalDuration
   
   delete_Clock
   if pBlendLevel is empty then put 0 into pBlendLevel
   put empty into pRingNum
   put the section_Colours of me into sectionColours
   
   pie_CreateChart clockSectionModel, sectionColours, pBlendLevel, pRingNum
   return the result
end display_PieChart

command pie_CreateChart clockSectionModel, sectionColours, pBlendLevel, pRingNum
   lock screen
   clock_NormalizeProportionalTimes clockSectionModel, sortedIndex, proportionalDuration
   
   put 0 into lastTriggerTime
   put the number of lines of sortedIndex into maxlineNum
   repeat with qNum = 1 to maxlineNum
      put line qNum of sortedIndex into sIndex
      
      put clockSectionModel [sIndex] into sArray
      deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
      if sDuration is not a number then
         put proportionalDuration into sDuration
      end if
      -- put trunc (lastTriggerTime + sDuration) into endSectionTriggerTime
      put lastTriggerTime + sDuration into endSectionTriggerTime
      
      put clock_ConvertSeconds (lastTriggerTime) into fromAngle
      put clock_ConvertSeconds (endSectionTriggerTime) into toAngle
      
      put construct_ClockGeometry (fromAngle, toAngle, pRingNum) into gArray
      put item qNum of sectionColours into someColour
      
      -- put "Slice" && qNum into graphicName
      put sName into graphicName
      create_GraphicSection graphicName, "Clock", someColour, pBlendLevel
      put the result into sliceObject
      
      set the clock_GeometryArray of sliceObject to gArray
      -- set the backgroundcolor of sliceObject to someColour
      
      put endSectionTriggerTime into lastTriggerTime
   end repeat
   unlock screen
   return empty
end pie_CreateChart


--> Clock | Section | Model
-
/*
Clock sections are numerically indexed, named, and have duration and other properties.
From these sections it is possible to create pie charts and animate default clocks with triggers.
Section differ from triggers as they have explicit duration, while triggers happen simply at a point in time.
naturally they are realted as it is possible to derive sections from triggers and define triggers at the borders of sections.
*/

setprop clock_SectionEventsOn [pDontClearPrevious] someBoolean
   if pDontClearPrevious is not true then
      set the clock_TriggerArray of me to empty
   end if
   
   put the clock_SectionModel of me into clockSectionModel
   if someBoolean is true then
      clock_AddSectionModelTimes clockSectionModel
   else
      clock_RemoveSectionModelTimes clockSectionModel
   end if
end clock_SectionEventsOn

command clock_RemoveSectionModelTimes clockSectionModel
   -- not done yet
   local sortedIndex, proportionalDuration
   clock_NormalizeProportionalTimes clockSectionModel, sortedIndex, proportionalDuration
   
end clock_RemoveSectionModelTimes

command clock_AddSectionModelTimes clockSectionModel
   local sortedIndex, proportionalDuration
   put the section_Colours of me into sectionColours
   
   clock_NormalizeProportionalTimes clockSectionModel, sortedIndex, proportionalDuration
   
   put 0 into lastTriggerTime
   put the number of lines of sortedIndex into maxlineNum
   repeat with lineNum = 1 to maxlineNum
      put line lineNum of sortedIndex into sIndex
      
      put clockSectionModel [sIndex] into sArray
      deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
      if sDuration is not a number then
         put proportionalDuration into sDuration
      end if
      put trunc (lastTriggerTime + sDuration) into endSectionTriggerTime
      -- put lastTriggerTime + sDuration into endSectionTriggerTime
      
      put item lineNum of sectionColours into someColour
      clock_SetTrigger lastTriggerTime, "newClockSection", someColour, sArray
      
      put endSectionTriggerTime into lastTriggerTime
   end repeat
end clock_AddSectionModelTimes

private command clock_NormalizeProportionalTimes clockSectionModel, @sortedIndex, @proportionalDuration
   put 0 into allocatedTime
   put keys(clockSectionModel) into sortedIndex
   sort numeric sortedIndex
   repeat for each line sIndex in sortedIndex
      put clockSectionModel [sIndex] into sArray
      deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
      
      if sDuration is a number then
         add sDuration to allocatedTime
      else
         put sIndex & CR after proportinalTimeIndex
      end if
   end repeat
   delete char -1 of proportinalTimeIndex
   put the number of lines of proportinalTimeIndex into numberOfProportionalTimes
   
   put the clock_Duration of me into totalDuration
   put totalDuration - allocatedTime into timeLeft
   if numberOfProportionalTimes is 0 then
      put 0 into proportionalDuration
   else
      put timeLeft / numberOfProportionalTimes into proportionalDuration
   end if
end clock_NormalizeProportionalTimes

getprop section_Colours
   return "red,yellow,green,blue,orange, white"
end section_Colours

command clock_SetTrigger someSeconds, someCommand, someParam, pInfoArray
   put someCommand into LocalArray ["clock_TriggerArray"][someSeconds]["command"]
   put someParam into LocalArray ["clock_TriggerArray"][someSeconds]["param"]
   put pInfoArray into LocalArray ["clock_TriggerArray"][someSeconds]["infoArray"]
end clock_SetTrigger

setprop clock_SectionName [pSectionProps] sName
   put item 1 of pSectionProps into sIndex
   put item 1 of pSectionProps into sColour
   put item 1 of pSectionProps into sDuration
   put item 1 of pSectionProps into sColour
   
   put construct_ClockSectionArray (sIndex, sColour, sDuration, sName) into sArray
   set the clock_SectionArray [sIndex] of me to sArray
end clock_SectionName

getprop clock_SectionArray [sNameOrIndex]
   put the clock_SectionModel of me into clockSectionModel
   if sNameOrIndex is a number then
      put clockSectionModel [sIndex] into sArray
      return sArray
   else
      return clock_GetNamedSectionArray (sName, clockSectionModel)
   end if
end clock_SectionArray

setprop clock_SectionArray [pNameOrIndex] sArray
   put the clock_SectionModel of me into clockSectionModel
   switch
      case pNameOrIndex is a number
         put pNameOrIndex into sIndex
         put sIndex into sArray ["section_Index"]
         put sArray into clockSectionModel [sIndex]
         break
      case pNameOrIndex is empty
         deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
         put sArray into clockSectionModel [sIndex]
         break
      default 
         put pNameOrIndex into sName
         put sName into sArray ["section_Name"]
         deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
         put sArray into clockSectionModel [sIndex]
   end switch
   set the clock_SectionModel of me to clockSectionModel
end clock_SectionArray

function clock_GetNamedSectionArray sName, clockSectionModel
   local testName
   repeat for each key sIndex in clockSectionModel
      put clockSectionModel [sIndex] into sArray
      deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
      if testName = sName then return sArray
   end repeat
   return empty
end clock_GetNamedSectionArray

getprop clock_SectionNames
   put the clock_SectionModel of me into clockSectionModel
   repeat for each key sIndex in clockSectionModel
      put clockSectionModel [sIndex] into sArray
      deconstruct_ClockSectionArray sIndex, sColour, sDuration, sName, sArray
      put sName & CR after clockSectionNames
   end repeat
   delete char -1 of clockSectionNames
   return clockSectionNames
end clock_SectionNames

getprop clock_SectionModel
   return the clock_SectionModel of me
end clock_SectionModel

setprop clock_SectionModel clockSectionModel
   set the clock_SectionModel of me to clockSectionModel
end clock_SectionModel

function construct_ClockSectionArray sIndex, sColour, pDuration, pSectionName
   -- if pDuration is empty each empty slice is set to an equal share of what is left
   put pDuration into sArray ["section_Duration"]
   
   -- pSectionName is needed but can be set as "set the clock_SectionArray [pSectionName] of..."
   put pSectionName into sArray ["section_Name"]
   
   put sColour into sArray ["section_Colour"]
   put sIndex into sArray ["section_Index"]
   return sArray
end construct_ClockSectionArray

command deconstruct_ClockSectionArray @sIndex, @sColour, @sDuration, @sName, sArray
   put sArray ["section_Name"] into sName
   put sArray ["section_Colour"] into sColour
   put sArray ["section_Index"] into sIndex
   put sArray ["section_Duration"] into sDuration
end deconstruct_ClockSectionArray


--> Clock | Props
-
getprop clock_Visible
   put sliceObject() into sliceObject
   if sliceObject is empty then return false
   return the visible of sliceObject
end clock_Visible

setprop clock_Visible someBoolean
   put sliceObject() into sliceObject
   if sliceObject is empty then return false
   set the visible of sliceObject to someBoolean
   return sliceObject
end clock_Visible

getprop clock_Colour
   put the backgroundcolor of sliceObject() into someColour
   return someColour
end clock_Colour

setprop clock_Colour [fadeTime] someColour
   put sliceObject() into sliceObject
   if "animationEngine" is among the lines of the stacksInUse then
      if fadeTime is empty then put 2000 into fadeTime
      aeChangeBackColor sliceObject, someColour, fadeTime, "inout"
   else
      set the backgroundcolor of sliceObject to someColour
   end if
end clock_Colour

getprop clock_Trigger [someSeconds]
   put the clock_TriggerCommand [someSeconds] of me into someCommand
   put the clock_TriggerParam [someSeconds] of me into someParam
   return someCommand,someParam
end clock_Trigger

setprop clock_Trigger [someSeconds] someTrigger
   put item 1 of someTrigger into someCommand
   put item 2 of someTrigger into someParam
   set the clock_TriggerCommand [someSeconds] of me to someCommand
   set the clock_TriggerParam [someSeconds] of me to someParam
   return LocalArray ["clock_TriggerArray"]
end clock_Trigger

getprop clock_TriggerArray
   return LocalArray ["clock_TriggerArray"]
end clock_TriggerArray

setprop clock_TriggerArray triggerArray
   put triggerArray into LocalArray ["clock_TriggerArray"]
end clock_TriggerArray

getprop clock_TriggerCommand [someSeconds]
   -- delete variable LocalArray ["clock_TriggerArray"]
   put LocalArray ["clock_TriggerArray"] into clockTriggerArray
   put clockTriggerArray [someSeconds]["command"] into someCommand
   return someCommand
end clock_TriggerCommand

setprop clock_TriggerCommand [someSeconds] someCommand
   put someCommand into LocalArray ["clock_TriggerArray"][someSeconds]["command"]
end clock_TriggerCommand

getprop clock_TriggerParam [someSeconds]
   put LocalArray ["clock_TriggerArray"] into clockTriggerArray
   put clockTriggerArray [someSeconds]["param"] into someParam
   return someParam
end clock_TriggerParam

setprop clock_TriggerParam [someSeconds] someParam
   put someParam into LocalArray ["clock_TriggerArray"][someSeconds]["param"]
end clock_TriggerParam

getprop clock_GeometryArray
   put the geometry_Array of the target into gArray
   return gArray
end clock_GeometryArray

setprop clock_GeometryArray gArray
   deconstruct_ClockGeometry fromAngle, toAngle, ringNum, gArray
   put clock_GetSlicePoints (fromAngle, toAngle, ringNum) into slicePoints
   set the points of the target to slicePoints
   set the geometry_Array of the target to gArray
   return slicePoints
end clock_GeometryArray

getprop clock_Seconds
   put LocalArray ["clock_Seconds"] into cSeconds
   return cSeconds
end clock_Seconds

setprop clock_Seconds [pColour] cSeconds
   put cSeconds into LocalArray ["clock_Seconds"]
   put clock_ConvertSeconds (cSeconds) into someAngle
   set the clock_Angle [pColour] of me to someAngle
   put the result into gArray
   return gArray
end clock_Seconds

function clock_ConvertSeconds cSeconds
   put the clock_Duration of me into sDuration
   put cSeconds/sDuration * 360 into someAngle
   return someAngle
end clock_ConvertSeconds

getprop clock_Minutes
   put the clock_Seconds of me into cSeconds
   put cSeconds / 60 into cMinutes
   return cMinutes
end clock_Minutes

setprop clock_Minutes [pColour] someMinutes
   put someMinutes * 60 into cSeconds
   put cSeconds into LocalArray ["clock_Seconds"]
   set the clock_Seconds [pColour] of me to cSeconds
   return the result
end clock_Minutes

getprop clock_Duration
   put the clock_Duration of me into someDuration
   if someDuration is empty then return 3600
   return someDuration
end clock_Duration

setprop clock_Duration someDuration
   set the clock_Duration of me to someDuration
end clock_Duration

getprop clock_Angle
   return the clock_Angle of me
end clock_Angle

setprop clock_Angle [pColour] twoAngles
   put item 1 of twoAngles into toAngle
   put item 2 of twoAngles into pFromAngle
   clock_SetAngles toAngle, pFromAngle, pColour
   put the result into gArray
   set the clock_Angle of me to twoAngles
   return gArray
end clock_Angle

-- command slice_SetAngle toAngle, pFromAngle, pColour
   put construct_ClockGeometry (pFromAngle, toAngle) into gArray
   set the clock_GeometryArray of sliceObject to gArray
   set lockmessages to true
   set the clock_Angle of me to twoAngles
   set lockmessages to false
   return the result
end slice_SetAngle

command clock_SetAngles toAngle, pFromAngle, pColour, pBlendLevel, pName
   if toAngle is empty then
      delete_Slice
      return empty
   else
      lock screen
      if pFromAngle is empty then put 0 into pFromAngle
      -- create_NewSlice pColour, pBlendLevel
      if pName is empty then put "Slice 0" into pName
      create_GraphicSection pName, "Clock", pColour, pBlendLevel
      put the result into sliceObject
      
      put construct_ClockGeometry (pFromAngle, toAngle) into gArray
      set the clock_GeometryArray of sliceObject to gArray
      put the result into slicePoints
      unlock screen
      return gArray
   end if
end clock_SetAngles

getprop clock_Exists
   return sliceObject() is not empty
end clock_Exists

function clock_GetSlicePoints fromAngle, toAngle, pReversedRingNum
   if pReversedRingNum is empty then put 1 into pReversedRingNum
   put hexagon_GetPeriTriangle (fromAngle, toAngle) into slicePoints
   
   put the spider_Points of me into spiderPoints
   put hexagon_GetRingPoints (pReversedRingNum, spiderPoints) into ringPoints
   put trunc (fromAngle/60) + 1 into fromQnum
   put trunc (toAngle/60) + 1 into toQnum
   
   repeat with itemNum = (fromQnum + 1) to toQnum
      put item itemNum wrap 6 of "1,2,3,4,5,6" into lineNum
      put line lineNum of ringPoints & CR before line -1 of slicePoints
   end repeat
   return slicePoints
end clock_GetSlicePoints

function hexagon_GetSpiderSection fromQnum, toQnum, ringNum, myCentre, spiderPoints
   put parse_SpiderPoints (spiderPoints, 6) into pointArray
   put pointArray ["ring_Points"][ringNum] into ringPoints
   
   put create_SpiderLinkArray (pointArray, myCentre) into spiderLinkArray
   
   put clock_GetRingCoords (fromQnum, toQnum, ringNum) into ringCoords
   repeat for each line ringCoord in ringCoords
      put spiderLinkArray [ringCoord] into somePoint
      put somePoint & CR after slicePoints
   end repeat
   delete char -1 of slicePoints
   return slicePoints
end hexagon_GetSpiderSection

function clock_GetRingCoords fromQnum, toQnum, pRingNum
   if pRingNum is empty then put 5 into pRingNum
   put "0,0" & CR into ringCoords
   repeat with itemNum = fromQnum to (toQnum + 1)
      put item itemNum wrap 6 of "1,2,3,4,5,6" into lineNum
      put (lineNum - 1),pRingNum & CR after ringCoords
   end repeat
   delete char -1 of ringCoords   
   return ringCoords
end clock_GetRingCoords

setprop hexagon_SlicePoints [pFromAngle] toAngle
   if pFromAngle is empty then put 0 into pFromAngle
   put hexagon_GetPeriTriangle (pFromAngle, toAngle) into slicePoints
   set the points of the target to slicePoints
   return slicePoints
end hexagon_SlicePoints

function hexagon_GetPeriTriangle fromAngle, toAngle
   put the hexagon_Centre of me into clockCentre
   put the hexagon_PerimeterPoint [fromAngle] of me into startPerimeterPoint
   put the hexagon_PerimeterPoint [toAngle] of me into endPerimeterPoint
   
   put clockCentre & CR & startPerimeterPoint & CR & endPerimeterPoint into slicePoints
   return slicePoints
end hexagon_GetPeriTriangle

getprop hexagon_Side [sectorItems]
   put item 1 of sectorItems into qNum
   put item 2 of sectorItems into pRingNum
   if qNum is empty then put 1 into qNum
   if pRingNum is empty then put 1 into pRingNum
   
   put the ring_Points [pRingNum] of me into ringPoints
   put line qNum to (qNum + 1) of ringPoints into linePoints
   return linePoints
end hexagon_Side

getprop ring_Points [reversedRingNum]
   put the spider_Points of me into spiderPoints
   if reversedRingNum is empty then put 1 into reversedRingNum
   
   put hexagon_GetRingPoints (reversedRingNum, spiderPoints) into ringPoints
   return ringPoints
end ring_Points

getprop hexagon_ClockHand [someAngle]
   put the hexagon_Centre of me into clockCentre
   put the hexagon_InnerCirclePoint [someAngle] of me into clockPoint
   put clockCentre & CR & clockPoint into handPoints
   
   put hexagon_DegreesToSector (someAngle) into qNum
   put the hexagon_Side [qNum] of me into hexLinePoints
   
   put line_IntersectionPoint (handPoints, hexLinePoints) into pPoint
   put clockCentre & CR & pPoint into handPoints
   return handPoints
end hexagon_ClockHand

getprop hexagon_PerimeterPoint [sectorItems]
   put item 1 of sectorItems into someAngle
   put item 2 of sectorItems into pRingNum
   if someAngle is empty then put 0 into qNum
   if pRingNum is empty then put 1 into pRingNum
   
   put the hexagon_Centre of me into clockCentre
   put the hexagon_OuterCirclePoint [someAngle] of me into clockPoint
   
   put clockCentre & CR & clockPoint into handPoints
   put hexagon_DegreesToSector (someAngle) into qNum
   put qNum,pRingNum into sectorItems
   put the hexagon_Side [sectorItems] of me into hexLinePoints
   
   put line_IntersectionPoint (handPoints, hexLinePoints) into pPoint
   return pPoint
end hexagon_PerimeterPoint

getprop hexagon_OuterCirclePoint [pAngleInDegrees]
   if pAngleInDegrees is empty then put 0 into pAngleInDegrees
   put the hexagon_Height of me into hexHeight
   
   put angle_SinInDegrees (pAngleInDegrees) * hexHeight into extraX
   put angle_CosInDegrees (pAngleInDegrees) * hexHeight into extraY
   
   put the hexagon_Centre of me into clockPoint
   add extraX to item 1 of clockPoint
   subtract extraY from item 2 of clockPoint
   return clockPoint
end hexagon_OuterCirclePoint

getprop hexagon_InnerCirclePoint [pAngleInDegrees]
   if pAngleInDegrees is empty then put 0 into pAngleInDegrees
   put the hexagon_Width of me into hexHeight
   
   put angle_SinInDegrees (pAngleInDegrees) * hexHeight into extraX
   put angle_CosInDegrees (pAngleInDegrees) * hexHeight into extraY
   
   put the hexagon_Centre of me into clockPoint
   add extraX to item 1 of clockPoint
   subtract extraY from item 2 of clockPoint
   return clockPoint
end hexagon_InnerCirclePoint

function hexagon_DegreesToSector someDegrees
   put trunc (someDegrees/60) + 1 into qNum
   put qNum wrap 6 into wrappedSector
   return wrappedSector
end hexagon_DegreesToSector

function line_IntersectionPoint firstLinePoints, secondLinePoints
   -- http://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
   
   put line 1 of firstLinePoints into firstLineStart
   put line -1 of firstLinePoints into firstLineEnd
   put item 1 of firstLineStart into x1
   put item 2 of firstLineStart into y1
   put item 1 of firstLineEnd into x2
   put item 2 of firstLineEnd into y2
   
   put line 1 of secondLinePoints into secondLineStart
   put line -1 of secondLinePoints into secondLineEnd
   
   put item 1 of secondLineStart into x3
   put item 2 of secondLineStart into y3
   put item 1 of secondLineEnd into x4
   put item 2 of secondLineEnd into y4
   
   put (x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4) into pxTop
   put (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4) into commonBottom
   put round (pxTop/commonBottom) into pX
   
   put (x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4) into pyTop
   put round (pyTop/commonBottom) into pY
   
   return pX,pY
end line_IntersectionPoint

on mouseEnter
   if the mouse_RollOver of me is false then pass mouseEnter
   
   if word 1 of the short name of the target = "Triangle" then
      set the triangle_On of the target to true
   end if
end mouseEnter

on mouseLeave
   if the mouse_RollOver of me is false then pass mouseLeave
   
   if word 1 of the short name of the target = "Triangle" then
      set the triangle_On of the target to false
   end if
end mouseLeave

on resizeControl
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl


--> Mouse
-
getprop mouse_RollOver
   return LocalArray ["mouse_RollOver"] is true
end mouse_RollOver

setprop mouse_RollOver someBoolean
   put someBoolean is true into LocalArray ["mouse_RollOver"]
end mouse_RollOver


--> Hexagon | Geometry
-
getprop hexagon_Centre
   return the loc of spiderGraphic()
end hexagon_Centre

getprop hexagon_Height
   put the rect of me into hexRect
   hexagon_NormalizeRect hexRect, newCentre, hexWidth, hexHeight
   return hexHeight
end hexagon_Height

getprop hexagon_Width
   put the rect of me into hexRect
   hexagon_NormalizeRect hexRect, newCentre, hexWidth, hexHeight
   return hexWidth
end hexagon_Width

getprop hexagon_RingWidth
   -- old way (not direct from spider_Points?)
   put the hexagon_Height of me into hexHeight
   put the numberOf_Rings of me into ringNum
   
   put hexHeight/ringNum into pixelsPerUnit
   return pixelsPerUnit
end hexagon_RingWidth


--> Hexagon | Click
-
getprop hexagon_Value [pLoc]
   if pLoc is empty then put the clickLoc into pLoc
   
   put the hexagon_Height of me into hexHeight
   put the numberOf_Rings of me into ringNum
   
   put hexagon_GetValue (pLoc, ringNum, hexHeight) into numberOfRings
   return numberOfRings
end hexagon_Value

function hexagon_GetValue someLoc, ringNum, hexHeight
   put hexHeight/ringNum into pixelsPerUnit
   put hexagon_GetPixelDistance (someLoc) into pixelDistance
   return pixelDistance/pixelsPerUnit
end hexagon_GetValue

function hexagon_GetPixelDistance someLoc
   put the loc of spiderGraphic() into myCentre
   put point_GetDistance (someLoc, myCentre) into pixelDistance
   return pixelDistance
end hexagon_GetPixelDistance

function point_GetDistance someLoc, myCentre
   put item 1 of someLoc - item 1 of myCentre into someX
   put item 2 of someLoc - item 2 of myCentre into someY
   put (someX^2 + someY^2)^0.5 into pixelDistance
   return pixelDistance
end point_GetDistance


--> Hexagon | Triangles and Rings
-
getprop number_OfTriangles
   return 6
   get the ring_Points of me
   put the number of lines of it - 1 into numberOfTriangles
   return numberOfTriangles
end number_OfTriangles

getprop number_OfRings
   put the spider_Points of me into spiderPoints
   put hexagon_GetNumberOfRings (spiderPoints) into numberOfRings
   return numberOfRings
end number_OfRings

setprop numberOf_Rings pNumberOfRings
   if pNumberOfRings is empty then put 5 into pNumberOfRings
   -- set the numberOf_Rings of me to pNumberOfRings
   
   put the rect of me into someRect
   hexagon_NormalizeRect someRect, someCentre, hexWidth, hexHeight
   put hexagon_GetSpiderPoints (hexHeight, someCentre, pNumberOfRings) into spiderPoints
   set the spider_Points of me to spiderPoints
   return spiderPoints
end numberOf_Rings

getprop hexagon_Data [pFromGeometry]
   if pFromGeometry is true then
      return the hexagon_DataFromTriangles of me
   else
      return the hexagon_Data of me
   end if
end hexagon_Data

getprop hexagon_DataFromTriangles
   repeat with qNum = 1 to 6
      put the triangle_Value [qNum] of me into someNumber
      put someNumber into item qNum of someData
   end repeat
   return someData
end hexagon_DataFromTriangles

setprop hexagon_Data numList
   lock screen
   repeat with qNum = 1 to 6
      put item qNum of numList into someNumber
      set the triangle_Value [qNum] of me to someNumber
   end repeat
   unlock screen
   set the hexagon_Data of me to numList
end hexagon_Data

getprop triangle_Value [qNum]
   if qNum is empty then
      put the triangle_Number of the target into qNum
   end if
   
   -- workign out from points is complicated !
   put triangleObject (qNum) into tObject
   put the points of tObject into displayedTrianglePoints
   
   put line 1 of displayedTrianglePoints into myCentre
   put line 2 of displayedTrianglePoints into leftPoint
   put point_GetDistance (leftPoint, myCentre) into valueInPixels
   
   put the triangle_Points [qNum] of me into bigTrianglePoints
   put line 2 of bigTrianglePoints into outerLeftPoint
   put point_GetDistance (outerLeftPoint, myCentre) into maxValueInPixels
   
   put valueInPixels / maxValueInPixels into vProportion
   
   -- quick hack
   -- faster to not fetch and parse all over again
   put the number_OfRings of me into numberOfRings
   put vProportion * numberOfRings into tValue
   return round (tValue, 1)
end triangle_Value

setprop triangle_Value [qNum] ringNumber
   if qNum is empty then
      put the triangle_Number of the target into qNum
   end if
   
   put the hexagon_Data of me into hexagonData
   --
   put qNum,ringNumber into pQnum
   put the triangle_Points [pQnum] of me into trianglePoints
   put triangleObject (qNum) into tObject
   set the points of tObject to trianglePoints
   --
   put ringNumber into item qNum of hexagonData
   set the lockmessages to true
   set the hexagon_Data of me to hexagonData
   set the lockmessages to false
   return trianglePoints
end triangle_Value

getprop triangle_Points [pQnum]
   if pQnum is empty then
      put 1 into qNum
   else
      put item 1 of pQnum into qNum
      put item 2 of pQnum into pRingNum
   end if
   
   put the spider_Points of me into spiderPoints
   put hexagon_GetTrianglePoints (qNum, spiderPoints, pRingNum) into trianglePoints
   return trianglePoints
end triangle_Points

getprop segment_Points [pQnum]
   if pQnum is empty then
      put 1 into qNum
   else
      put item 1 of pQnum into qNum
      put item 2 of pQnum into pRingNum
   end if
   
   put the spider_Points of me into spiderPoints
   put hexagon_GetSegmentPoints (qNum, spiderPoints, pRingNum) into segmentPoints
   return segmentPoints
end segment_Points

getprop spider_Points
   put spiderGraphic() into spiderGraphic
   put the points of spiderGraphic into spiderPoints
   return spiderPoints
end spider_Points

setprop spider_Points somePoints
   put spiderGraphic() into spiderGraphic
   set the points of spiderGraphic to somePoints
end spider_Points

getprop cobweb_Array
   put the spider_Points of me into spiderPoints
   put parse_SpiderPoints (spiderPoints) into pointArray
   return pointArray
end cobweb_Array


--> --> Hexagon | Spider Point Functions
-
function hexagon_GetSpiderCentre spiderPoints
   put parse_SpiderPoints (spiderPoints) into pointArray
   put pointArray ["spider_Centre"] into spiderCentre
   return spiderCentre
end hexagon_GetSpiderCentre

function hexagon_GetSegmentPoints qNum, spiderPoints, pReversedRingNum
   put parse_SpiderPoints (spiderPoints) into pointArray
   put pointArray_GetSegmentPoints (qNum, pointArray, pReversedRingNum) into segmentPoints
   return segmentPoints
end hexagon_GetSegmentPoints

function pointArray_GetSegmentPoints qNum, pointArray, pReversedRingNum
   if pReversedRingNum is empty then put 1 into pReversedRingNum -- outer ring
   
   put pointArray ["number_OfRings"] into numberOfRings
   put numberOfRings - pReversedRingNum + 1 into pRingNum
   
   put pRingNum into outerNum
   put pRingNum + 1 into innerNum
   
   put pointArray ["ring_Points"][outerNum] into outerRingPoints
   if innerNum > numberOfRings then
      put pointArray ["spider_Centre"] into segmentPoints
   else
      put pointArray ["ring_Points"][innerNum] into innerRingPoints
      put line qNum to (qNum+1) of innerRingPoints into segmentPoints
   end if
   
   -- need to reverse order of points to get poly instead of crossed poly
   put CR & line (qNum+1) of outerRingPoints after segmentPoints
   put CR & line qNum of outerRingPoints after segmentPoints
   
   return segmentPoints
end pointArray_GetSegmentPoints

function hexagon_GetTrianglePoints qNum, spiderPoints, pReversedRingNum
   put parse_SpiderPoints (spiderPoints) into pointArray
   put pointArray_GetTrianglePoints (qNum, pointArray, pReversedRingNum) into trianglePoints
   return trianglePoints
end hexagon_GetTrianglePoints

function pointArray_GetTrianglePoints qNum, pointArray, pRingNum
   reverseRingNumber pRingNum, pointArray
   
   put pointArray ["spider_Centre"] into spiderCentre
   put pointArray ["ring_Points"][pRingNum] into ringPoints
   
   put spiderCentre into trianglePoints
   get line qNum to (qNum+1) of ringPoints
   put CR & it after trianglePoints
   
   return trianglePoints
end pointArray_GetTrianglePoints

command reverseRingNumber @reversedRingNum, pointArray
   if reversedRingNum is empty then
      put 1 into reversedRingNum -- outer ring
   else
      put pointArray ["number_OfRings"] into numberOfRings
      put numberOfRings - reversedRingNum + 1 into reversedRingNum
   end if
end reverseRingNumber

function hexagon_GetRingPoints reversedRingNum, spiderPoints
   put parse_SpiderPoints (spiderPoints) into pointArray
   put pointArray ["ring_Points"][reversedRingNum] into ringPoints
   return ringPoints
end hexagon_GetRingPoints

function hexagon_GetNumberOfRings spiderPoints
   put parse_SpiderPoints (spiderPoints) into pointArray
   put pointArray ["number_OfRings"] into ringNumber
   return ringNumber
end hexagon_GetNumberOfRings


--> Props
-
getprop border_Width
   put borderObject() into borderObject
   if borderObject is empty then return 0
   return the lineSize of borderObject
end border_Width

setprop border_Width someNum
   lock screen
   set the lockUpdates of me to true
   put the rect of me into oRect
   
   create_Border
   put the result into borderObject
   set the lineSize of borderObject to someNum
   
   -- no idea why this does not do the same as resizing and needs lockUpdates
   
   LayoutControl oRect
   -- set the rect of me to oRect
   set the lockUpdates of me to false
   unlock screen
   return borderObject
end border_Width


--> Cobweb
-
getprop cobweb_Style
   return the visible of spiderGraphic()
end cobweb_Style

setprop cobweb_Style someStyle
   set the visible of spiderGraphic() to someBoolean
end cobweb_Style

getprop cobweb_Visible
   return the visible of spiderGraphic()
end cobweb_Visible

setprop cobweb_Visible someBoolean
   set the visible of spiderGraphic() to someBoolean
end cobweb_Visible

getprop cobweb_Colour
   put the backgroundcolor of spiderGraphic() into someColour
   return someColour
end cobweb_Colour

setprop cobweb_Colour someColour
   set the backgroundcolor of spiderGraphic() to someColour
end cobweb_Colour


--> Triangles
-
getprop triangles_Visible
   return the visible of grp "Triangles" of me
end triangles_Visible

setprop triangles_Visible someBoolean
   set the visible of grp "Triangles" of me to someBoolean
end triangles_Visible

setprop triangles_On someBoolean
   lock screen
   repeat with qNum = 1 to 6
      put triangleObject (qNum) into tObject
      set the triangle_On of tObject to someBoolean
   end repeat
   unlock screen
end triangles_On

setprop triangle_On someBoolean
   lock screen
   if someBoolean is true then
      put the triangle_Number of the target into qNum
      put LocalArray ["colour"][qNum] into someColour
      if someColour is empty then put triangle_GetColour (qNum) into someColour
      set the backgroundcolor of the target to someColour
      set the blendlevel of the target to 50
   else
      put the triangle_Number of the target into qNum
      put the backgroundcolor of the target into currentColour
      -- if currentColour is not empty then
      put currentColour into LocalArray ["colour"][qNum]
      
      set the backgroundcolor of the target to empty
      set the blendlevel of the target to 100
   end if
   unlock screen
end triangle_On

getprop triangles_AreOpaque
   put triangleObject (1) into tObject
   put the opaque of tObject into someBoolean
   return someBoolean
end triangles_AreOpaque

setprop triangles_AreOpaque someBoolean
   lock screen
   repeat with qNum = 1 to 6
      put triangleObject (qNum) into tObject
      set the opaque of tObject to someBoolean
   end repeat
   unlock screen
end triangles_AreOpaque

getprop triangle_LineSize
   put triangleObject (1) into tObject
   put the lineSize of tObject into someNum
   return someNum
end triangle_LineSize

setprop triangle_LineSize someNum
   lock screen
   repeat with qNum = 1 to 6
      put triangleObject (qNum) into tObject
      set the lineSize of tObject to someNum
   end repeat
   unlock screen
end triangle_LineSize

getprop triangle_BlendLevel
   put triangleObject (1) into tObject
   put the blendlevel of tObject into somePercent
   return somePercent
end triangle_BlendLevel

setprop triangle_BlendLevel somePercent
   lock screen
   repeat with qNum = 1 to 6
      put triangleObject (qNum) into tObject
      set the blendlevel of tObject to somePercent
   end repeat
   unlock screen
end triangle_BlendLevel

getprop triangle_Colours
   repeat with qNum = 1 to 6
      put the triangle_Colour [qNum] of me & CR after tColours
   end repeat
   delete char -1 of tColours
   return tColours
end triangle_Colours

setprop triangle_Colours colourIndex
   repeat with qNum = 1 to 6
      put line qNum of colourIndex into tColour
      if tColour is empty then
         put triangle_GetColour (qNum) into tColour
      end if
      put triangleObject (qNum) into tObject
      set the backgroundcolor of tObject to tColour
      put tColour & CR after tColours
   end repeat
   delete char -1 of tColours
   return tColours
end triangle_Colours

setprop triangle_Colour [qNum] someColour
   if gNum is not empty then
      put triangleObject (qNum) into tObject
      set the backgroundcolor of tObject to someColour
   else if word 1 of the short name of the target = "Triangle" then
      set the backgroundcolor of the target to someColour
   else
      return empty
   end if
end triangle_Colour

getprop triangle_Colour [qNum]
   if gNum is not empty then
      put triangleObject (qNum) into tObject
      return the backgroundcolor of tObject
   else if word 1 of the short name of the target = "Triangle" then
      return the backgroundcolor of the target
   else
      return empty
   end if
end triangle_Colour

function triangle_GetColour qNum
   put "red,green,blue,pink,orange,purple" into colourList
   put item qNum of colourList into someColour
   return someColour
end triangle_GetColour


--> Layout
-
on LayoutControl pRect
   lock screen
   set the lockupdates of me to true
   if pRect is empty then put the rect of me into pRect
   put pRect into hexRect
   hexagon_NormalizeRect hexRect, newCentre, hexWidth, hexHeight
   if min (hexWidth, hexHeight) < 10 then return empty  -- to avoid dividing by zero
   
   put spiderGraphic() into spiderGraphic
   set the rect of spiderGraphic to hexRect
   
   -- triangles and slices could be the same set of objects
   put the hexagon_Data of me into hexagonData
   put the spider_Points of me into spiderPoints
   put parse_SpiderPoints (spiderPoints) into pointArray
   
   repeat with qNum = 1 to 6
      put item qNum of hexagonData into tValue
      -- set the triangle_Value [qNum] of me to tValue
      -- put the triangle_Points [qNum] of me into trianglePoints
      -- put hexagon_GetTrianglePoints (qNum, spiderPoints, tValue) into trianglePoints
      put pointArray_GetTrianglePoints (qNum, pointArray, tValue) into trianglePoints
      
      put triangleObject (qNum) into tObject
      set the points of tObject to trianglePoints
   end repeat
   
   layout_Clock
   
   -- could do with tweeking to take into account borderwidth
   put pointArray ["ring_Points"][1] into borderPoints
   put borderObject() into hexBorder
   set the points of hexBorder to borderPoints
   
   -- set the rect of me to pRect -- makes it jump to the left?
   set the lockupdates of me to false -- not strictly needed
   unlock screen
end LayoutControl

command layout_Clock
   /* 
   Triangles and slices could be the same set of objects. However the geometry of slices is more complex
   and it is not easy to simpligy the code below. 
   */
   
   if exists (group "Clock" of me) is false then return empty
   
   put the number of graphics of group "Clock" of me into numberOfSlices
   repeat with sliceNum = 1 to numberOfSlices
      put the long id of grc sliceNum of group "Clock" of me into sliceObject
      put the clock_GeometryArray of sliceObject into gArray
      set the clock_GeometryArray of sliceObject to gArray
   end repeat
end layout_Clock


--> Hexagon | Geometry
-
function hexagon_GetSmallRadius bigRadius
   -- hexagons are not square
   -- for point at top hexagons - then the height is big and the width small
   -- angle_CosInDegrees (30) = smallRadius / bigRadius
   -- smallRadius = bigRadius * angle_CosInDegrees (30)
   
   put bigRadius * angle_CosInDegrees (30) into smallRadius
   return trunc (smallRadius)
end hexagon_GetSmallRadius

function hexagon_GetBigRadius smallRadius
   -- hexagons are not square
   -- angle_CosInDegrees (30) = smallRadius / bigRadius
   -- bigRadius = smallRadius / angle_CosInDegrees (30)
   
   put smallRadius / angle_CosInDegrees (30)  into bigRadius
   return trunc (bigRadius)
end hexagon_GetBigRadius

command hexagon_NormalizeRect @someRect, @someCentre, @hexWidth, @hexHeight
   -- need to tweek for borderwidth of borderObject()
   put the border_Width of me into bWidth
   
   put item 1 of someRect into someLeft
   put item 2 of someRect into someTop
   put item 4 of someRect into someBottom
   
   put item 3 of someRect - someLeft into someWidth
   put someBottom - someTop into someHeight
   
   put round (someWidth/2) into someHalfWidth
   put round (someHeight/2) into someHalfHeight
   
   put someLeft + someHalfWidth into centreX
   put someTop + someHalfHeight into centreY
   
   get someHalfWidth/someHalfHeight
   put angle_CosInDegrees (30) into cos30
   if it > cos30 then
      -- wide => work out from height
      put someHalfHeight into hexHeight
      put hexagon_GetSmallRadius (someHalfHeight) into hexWidth
   else
      -- high => work out from width
      put someHalfWidth into hexWidth
      put hexagon_GetBigRadius (someHalfWidth) into hexHeight
   end if
   
   put 1 into fudgeFactor
   put round(bWidth/2) + 2 into fudgeFactor
   
   put centreX - hexWidth + fudgeFactor into newLeft
   put centreX + hexWidth - fudgeFactor into newRight
   put centreY - hexHeight +fudgeFactor into newTop
   put centreY + hexHeight - fudgeFactor into newBottom
   
   subtract fudgeFactor from hexWidth
   subtract fudgeFactor from hexHeight
   subtract 1 from centreY
   
   put centreX,centreY into someCentre
   put newLeft,newTop,newRight,newBottom into someRect
   -- set the rect of grc "Mask" to someRect
end hexagon_NormalizeRect

function hexagon_GetQuadrantTriangle qNum, polyCentre, hexRadius  
   put "0,60,120,180,240,300,360" into angleList
   put item qNum of angleList into firstDegree
   put line 2 of clock_GetHandPoints (firstDegree, polyCentre, hexRadius) into firstPoint
   put item (qNum + 1) of angleList into secondDegree
   put line 2 of clock_GetHandPoints (secondDegree, polyCentre, hexRadius) into secondPoint
   
   return polyCentre & CR & firstPoint & CR & secondPoint
end hexagon_GetQuadrantTriangle

function hexagon_GetQuadrant relX, relY
   put hexagon_GetPointAngle (relX, relY) into someDegree
   put "0,60,120,180,240,300,360" into angleList
   repeat with qNum = 6 down to 1
      put item qNum of angleList into minAngle
      if someDegree > minAngle then
         return qNum
      end if
   end repeat
   return 1
end hexagon_GetQuadrant

function hexagon_GetPointAngle relX, relY
   return 180 - atan2 (relX, relY) * 180 / pi
end hexagon_GetPointAngle

function hexagon_GetSpiderPoints hexRadius, polyCentre, pWebNum
   if pWebNum is empty then put 5 into pWebNum
   
   put round (hexRadius / pWebNum) into webSpacing
   
   put hexagon_GetPoints (hexRadius, polyCentre) into hexPoints
   put hexagon_GetStar (hexPoints, polyCentre) into starPoints
   
   put starPoints & CR & CR & hexPoints into spiderPoints
   
   repeat pWebNum - 1
      subtract webSpacing from  hexRadius
      put CR & CR after spiderPoints
      put hexagon_GetPoints (hexRadius, polyCentre) after spiderPoints
   end repeat
   
   return spiderPoints
end hexagon_GetSpiderPoints

function hexagon_GetStar hexPoints, polyCentre
   delete line - 1 of hexPoints
   repeat for each line hexPoint in hexPoints
      put polyCentre & CR & hexPoint after starPoints
      put CR & CR after starPoints
   end repeat
   delete char - 2 to -1 of starPoints
   return starPoints
end hexagon_GetStar

function hexagon_GetPoints hexRadius, clockCentre
   put "0,60,120,180,240,300,360" into angleList
   repeat for each item someDegree in angleList
      put clock_GetHandPoints (someDegree, clockCentre, hexRadius) into handPoints
      put line 2 of handPoints into handTipLoc
      put handTipLoc & CR after hexPoints
      -- set the points of grc "Big Hand" to handPoints
   end repeat
   delete char -1 of hexPoints
   return hexPoints
end hexagon_GetPoints

function clock_GetHandPoints someDegree, clockCentre, hexRadius
   put hexRadius * angle_SinInDegrees (someDegree) into extraX
   put hexRadius * angle_CosInDegrees (someDegree) into extraY
   
   put clockCentre into handTopLoc
   add round (extraX) to item 1 of handTopLoc
   subtract round (extraY) from item 2 of handTopLoc
   
   put clockCentre & CR & handTopLoc into handPoints
   return handPoints
end clock_GetHandPoints

function hexagon_GetRelativePoints hexRadius, clockCentre
   /*
   This is a hack as relativepoints are claculated from topleft not centre
   For now simply adding half the handheigh
   */
   
   put "0,60,120,180,240,300,360" into angleList
   put 6 into fudgeFactor
   repeat for each item someDegree in angleList
      put clock_GetHandPoints (someDegree, clockCentre, hexRadius) into handPoints
      put line 2 of handPoints into handTipLoc
      
      add hexRadius to item 2 of handTipLoc
      add (hexRadius - fudgeFactor) to item 1 of handTipLoc
      
      put handTipLoc & CR after hexPoints
      -- set the points of grc "Big Hand" to handPoints
   end repeat
   delete char -1 of hexPoints
   return hexPoints
end hexagon_GetRelativePoints


--> Private | Geometry
-
private function construct_SpiderGeometry fromQnum, toQnum, ringNum, myCentre
   put fromQnum into gArray ["from_Quadrant"]
   put toQnum into gArray ["to_Quadrant"]
   put ringNum into gArray ["ring_Num"]
   put myCentre into gArray ["hexagon_Centre"]
   return gArray
end construct_SpiderGeometry

private command deconstruct_SpiderGeometry @fromQnum, @toQnum, @ringNum, @myCentre, gArray
   put gArray ["from_Quadrant"] into fromQnum
   put gArray ["to_Quadrant"] into toQnum
   put gArray ["ring_Num"] into ringNum
   put gArray ["hexagon_Centre"] into myCentre
end deconstruct_SpiderGeometry

private function construct_ClockGeometry fromAngle, toAngle, pRingNum
   if pRingNum is empty then put 1 into pRingNum
   put fromAngle into gArray ["from_Angle"]
   put toAngle into gArray ["to_Angle"]
   put pRingNum into gArray ["ring_Number"]
   return gArray
end construct_ClockGeometry

private command deconstruct_ClockGeometry @fromAngle, @toAngle, @ringNum, gArray
   put gArray ["from_Angle"] into fromAngle
   put gArray ["to_Angle"] into toAngle
   put gArray ["ring_Number"] into ringNum
end deconstruct_ClockGeometry


--> Trig
-
function point_GetClockAngle somePoint, someCentre
   put item 1 of somePoint - item 1 of someCentre into someX
   put item 2 of someCentre - item 2 of somePoint into someY
   
   put atan2 (someX, someY) into angleInRadians
   angle_ConvertRadian angleInRadians
   return angleInRadians
end point_GetClockAngle

function angle_CosInDegrees angleInDegrees
   angle_ConvertDegrees angleInDegrees
   return cos (angleInDegrees)
end angle_CosInDegrees

function angle_SinInDegrees angleInDegrees
   angle_ConvertDegrees angleInDegrees
   return sin (angleInDegrees)
end angle_SinInDegrees

command angle_ConvertRadian @angleInRadians
   put angleInRadians * 180 / pi into angleInRadians
end angle_ConvertRadian

command angle_ConvertDegrees @angleInDegrees
   put angleInDegrees * pi / 180 into angleInDegrees
end angle_ConvertDegrees


--> Experiments
-
command aeCancelPending
   /*
   * the message ID
   * the time the message is scheduled for
   * the message name
   * the long ID property of the object that the message will be sent to
   */
   
   put the pendingmessages into tPendingMsgs
   put the long id of me into myGroup
   repeat for each line someLine in tPendingMsgs
      if item 4 of someLine ends with myGroup then
         -- if item 3 of someLine contains "ae" then
         cancel item 1 of someLine
      end if
   end repeat
end aeCancelPending

-- getprop clock_CalculatedAngle
   -- because of rounding errors
   -- this won't be the same as the stored "clock_Angle" value
   put the points of the target into slicePoints
   put line 1 of slicePoints into myCentre
   put line 2 of slicePoints into firstEnd
   put line 3 of slicePoints into secondEnd
   
   put point_GetClockAngle (secondEnd, myCentre) into secondAngle
   put point_GetClockAngle (firstEnd, myCentre) into firstAngle
   if firstAngle is 0 then return secondAngle
   return secondAngle,firstAngle
end clock_CalculatedAngle

-- getprop slice_Points
   if exists (grc "Slice 0" of me) is fale then return empty
   
   put the long id of grc "Slice 0" of me into sliceObject
   put the points of sliceObject into slicePoints
   return slicePoints
end slice_Points

-- setprop slice_Points slicePoints
   if exists (grc "Slice 0" of me) is fale then return empty
   
   put the long id of grc "Slice 0" of me into sliceObject
   set the points of sliceObject to slicePoints
   return sliceObject
end slice_Points

-- setprop hexagon_Slice [pFromAngle] toAngle
   if toAngle is empty then
      delete_Slice
      return empty
   else
      if pFromAngle is empty then put 0 into pFromAngle
      put hexagon_GetPeriTriangle (pFromAngle, toAngle) into slicePoints
      put "red" into pColour
      put 50 into pBlendLevel
      create_Slice slicePoints, pColour, pBlendLevel
      put the result into sliceObject
      return slicePoints
   end if
end hexagon_Slice

