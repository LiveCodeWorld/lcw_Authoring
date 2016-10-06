script "Global_Shape_Cobweb_Menu"
--> MetaData
-
license: GPLv3
name: Global_Shape_Cobweb_Menu
type: controller
version: 0.1


--> Global | Shape | Cobweb | Menu
-
private command setUpLearningObject mTarget
   local sColour, pDuration, pSectionName
   
   put the clock_Duration of mTarget into cDuration
   put cDuration/60 into cFactor
   
   set the clock_SectionArray ["Talk"] of mTarget to construct_ClockSectionArray (1, "black", 10*cFactor)
   set the clock_SectionArray ["Tools"] of mTarget to construct_ClockSectionArray (2, sColour, 5*cFactor)
   set the clock_SectionArray ["Questions"] of mTarget to construct_ClockSectionArray (3, sColour, 15*cFactor)
   set the clock_SectionArray ["Practice"] of mTarget to construct_ClockSectionArray (4, sColour)
   set the clock_SectionArray ["Requirements"] of mTarget to construct_ClockSectionArray (5, sColour, 5*cFactor)
   set the clock_SectionArray ["Info"] of mTarget to construct_ClockSectionArray (6, sColour, 5*cFactor)
end setUpLearningObject

on menu_DisplayPieChart mTarget
   put the clock_SectionModel of mTarget into clockSectionModel
   set the display_PieChart of mTarget to clockSectionModel
end menu_DisplayPieChart

on _
end _

on menu_StartLearningObject mTarget
   setUpLearningObject mTarget
   set the clock_SectionEventsOn of mTarget to true
   dispatch "clock_Start" to mTarget
end menu_StartLearningObject

on _
end _

on menu_ClockDuration mTarget, clockDuration
   set the clock_Duration of mTarget to clockDuration
end menu_ClockDuration

getprop clock_Duration [mTarget]
   return the clock_Duration of mTarget
end clock_Duration

getprop clock_Durations [mTarget]
   return "60,3600"
end clock_Durations

on menu_StartClock mTarget
   dispatch "clock_Start" to mTarget with "light green"
end menu_StartClock

on menu_ClockStopped mTarget, someBoolean
   set the clock_Stopped of mTarget to someBoolean
end menu_ClockStopped

on menu_ClockVisible mTarget, someBoolean
   set the clock_Visible of mTarget to someBoolean
end menu_ClockVisible

on _
end _

on menu_StartClockSections mTarget
   set the clock_SectionEventsOn of mTarget to true
   dispatch "clock_Start" to mTarget
end menu_StartClockSections

on menu_SetClockSections mTarget
   local sColour, pDuration, pSectionName
   
   set the clock_SectionArray ["Talk"] of mTarget to construct_ClockSectionArray (1, sColour, 8)
   set the clock_SectionArray ["Tools"] of mTarget to construct_ClockSectionArray (2, sColour, 3)
   set the clock_SectionArray ["Questions"] of mTarget to construct_ClockSectionArray (3, sColour, pDuration)
   set the clock_SectionArray ["Practice"] of mTarget to construct_ClockSectionArray (4, sColour, pDuration)
   set the clock_SectionArray ["Requirements"] of mTarget to construct_ClockSectionArray (5, sColour, 3)
   set the clock_SectionArray ["Info"] of mTarget to construct_ClockSectionArray (6, sColour, 3)
   
   put the clock_SectionModel of mTarget into clockSectionModel
   display_Array clockSectionModel, "the clock_SectionModel"
end menu_SetClockSections

on menu_DisplaySectionModel mTarget
   put the clock_SectionModel of mTarget into clockSectionModel
   display_Array clockSectionModel, "the clock_SectionModel"
end menu_DisplaySectionModel

on _
end _

on menu_DisplayTriggerArray mTarget
   put the clock_TriggerArray of mTarget into triggerArray
   display_Array triggerArray, "the clock_TriggerArray"
end menu_DisplayTriggerArray

on menu_SetTriggerArray mTarget
   set the clock_Trigger [3] of mTarget to "clock_ChangeColour,green"
   set the clock_Trigger [9] of mTarget to "clock_ChangeColour,yellow"
   set the clock_Trigger [27] of mTarget to "clock_ChangeColour,blue"
   set the clock_Trigger [38] of mTarget to "clock_ChangeColour,light green"
   set the clock_Trigger [50] of mTarget to "clock_ChangeColour,orange"
   
   put the clock_TriggerArray of mTarget into triggerArray
   display_Array triggerArray, "the clock_TriggerArray"
end menu_SetTriggerArray

on menu_ClearTriggerArray mTarget
   set the clock_TriggerArray of mTarget to empty
end menu_ClearTriggerArray

on _
end _

on menu_DisplaySpiderLinkArray mTarget
   put the spider_LinkArray of mTarget into spiderLinkArray
   display_Array spiderLinkArray, "the spider_LinkArray"
end menu_DisplaySpiderLinkArray

on _
end _

on menu_TrianglesVisible mTarget, someBoolean
   set the triangles_Visible of mTarget to someBoolean
end menu_TrianglesVisible

on menu_CobwebVisible mTarget, someBoolean
   set the cobweb_Visible of mTarget to someBoolean
end menu_CobwebVisible

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Shape | Cobweb | Menu | Props
-
getprop cobweb_Visible [mTarget]
   put the cobweb_Visible of mTarget into someBoolean
   return someBoolean
end cobweb_Visible

getprop clock_Stopped [mTarget]
   put the clock_Stopped of mTarget into someBoolean
   return someBoolean
end clock_Stopped

getprop clock_Visible [mTarget]
   put the clock_Visible of mTarget into someBoolean
   return someBoolean
end clock_Visible

getprop triangles_Visible [mTarget]
   put the triangles_Visible of mTarget into someBoolean
   return someBoolean
end triangles_Visible


--> Global | Shape | Cobweb | Menu | Disabled
-


--> Dev | Menu
-
on menu_ObjectExists mTarget, objectName
   switch objectName
      case "Clock"
         if exists(group objectName of mTarget) then
            delete group objectName of mTarget
         else
            
         end if
         break
      case "Hexagon Slice"
         put exists( control objectName of mTarget) is false into notThere
         set the clock_Exists of mTarget to notThere
         break
      default
   end switch
end menu_ObjectExists

getprop object_Name [mTarget]
   put the object_Names of me into nameList
   repeat for each item oName in nameList
      if exists( control oName of mTarget) then
         put oName & comma after objectNames
      end if
   end repeat
   delete char -1 of objectNames
   return objectNames
end object_Name

getprop object_Names
   return "Clock,-,Slice 0,Border,Cobweb,Triangles"
end object_Names

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
