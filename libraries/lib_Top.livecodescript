script "lib_Top"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Top
type: library
version: 0.1

/*Some help*/


--> Working on
-
getprop top_Views [vParam]
   local topViews
   put the top_ControlIDs of the target into topControlIDs
   repeat for each line cID in topControlIDs
      put the long id of control id cID into tObject
      if vParam is empty then
         if the object_IsView of tObject is true then
            put tObject & CR after topViews
         end if
      else
         put the vParam of tObject into vObject
         if exists (vObject) then
            put vObject & CR after topViews
         end if
      end if
   end repeat
   delete char -1 of topViews
   return topViews
end top_Views

getprop top_Named [sName]
   put the childcontrolids of the target into topIDs
   repeat for each line someID in topIDs
      get the short name of control id someID
      if it = sName then
         put the long id of control id someID & CR after topNamed
      end if
   end repeat
   delete char -1 of topNamed
   return topNamed
end top_Named

getprop top_View
   -- this is the default value for a view
   -- which is the top (highest) someView in the current layout
   put the long id of the target into testGroup
   put view_HierarchyObjects (testGroup) into groupHierarchy
   put line 1 of groupHierarchy into topView
   return topView
end top_View


--> Top | Controls
-
getprop top_GroupArray
   local oArray
   put the top_ControlIDs of the target into someIDs
   put 1 into indexNum
   repeat for each line someID in someIDs
      put the long id of control id someID of the target into testObject
      if word 1 of testObject = "group" then
         get the properties of testObject
         put it into oArray [indexNum]
         add 1 to indexNum
      end if
   end repeat
   return oArray
end top_GroupArray

getprop top_Groups
   local testObjects
   put the top_ControlIDs of the target into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into testObject
      if word 1 of testObject = "group" then
         put testObject & CR after testObjects
      end if
   end repeat
   delete char -1 of testObjects
   return testObjects
end top_Groups

getprop top_GroupNames
   local groupNameIndex
   put the top_ControlIDs of the target into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into testObject
      if word 1 of testObject = "group" then
         put the short name of testObject & CR after groupNameIndex
      end if
   end repeat
   delete char -1 of groupNameIndex
   return groupNameIndex
end top_GroupNames


--> Top | View
-
getprop top_ViewNames [vName]
   put the top_ControlIDs of the target into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into topObject
      put the view_Name of topObject into testViewName
      
      switch
         case testViewName is empty
            next repeat
         case vName is empty
         case vName = testViewName
            put the short name of topObject & CR after topViewNames
            break 
      end switch      
   end repeat
   delete char -1 of topViewNames
   return topViewNames
end top_ViewNames

getprop top_ControlIDs
   put word 1 of the target into tWord
   switch
      case tWord = "stack"
         -- should we search. backgrounds?
         put the number of cards of the target into maxNum
         repeat with cardNum = 1 to maxNum
            put the long id of card cardNum of the target into cardObject
            put the childControlIDs of cardObject & CR after stackControlIds
         end repeat
         delete char -1 of stackControlIds
         return stackControlIds
      case tWord is among the items of "card,group"
         return the childControlIDs of the target
      default
         return empty
   end switch
end top_ControlIDs

getprop top_ViewObject [vName]
   put the top_ControlIDs of the target into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into topObject
      put the view_Name of topObject into testViewName
      switch
         case testViewName is empty
            next repeat
         case vName is empty
         case vName = testViewName
            return topObject
      end switch
   end repeat
   return empty
end top_ViewObject

getprop top_ViewObjects [vName]
   put the top_ControlIDs of the target into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into topObject
      put the view_Name of topObject into testViewName
      switch
         case testViewName is empty
            next repeat
         case vName is empty
         case vName = testViewName
            put topObject & CR after topViewObjects
            break 
      end switch
   end repeat
   delete char -1 of topViewObjects
   return topViewObjects
end top_ViewObjects


--> Bottom | Layer | Controls
-
getprop bottom_ControlName
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   if topIDs is empty then return empty
   
   put line -1 of topIDs into bottomID
   put the short name of control id bottomID into bottomName
   return bottomName
end bottom_ControlName

setprop bottom_ControlName bottomName
   put the long id of the target into layoutView
   
   put the top_Control [bottomName] of layoutView into someControl
   if exists (someControl) is false then return empty
   
   relayer someControl to front of layoutView
   dispatch "LayoutControl" to layoutView
   
   return someControl
end bottom_ControlName


--> Top | Layer | Controls
-
getprop top_ControlName
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   if topIDs is empty then return empty
   
   put line 1 of topIDs into topID
   put the short name of control id topID into topName
   return topName
end top_ControlName

setprop top_ControlName topName
   put the long id of the target into layoutView
   
   put the top_Control [topName] of layoutView into topControl
   if exists (topControl) is false then return empty
   
   relayer topControl to back of layoutView
   dispatch "LayoutControl" to layoutView
   
   return topControl
end top_ControlName

getprop top_Control [topName]
   put the long id of the target into targetObject
   
   -- finds or returns the top control
   put the childcontrolids of targetObject into topIDs
   if topIDs is empty then return empty
   if topName is empty then
      put line 1 of topIDs into topID
      put the long id of control id topID into topControl
      return topControl
   end if
   
   -- let's find a top control with the name "topName"
   repeat for each line someID in topIDs
      put the long id of control id someID into someControl
      put the short name of someControl into testName
      if testName = topName then
         return someControl
      end if
   end repeat
   return empty
end top_Control

getprop top_ControlNames
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   repeat for each line someID in topIDs
      put the short name of control id someID & CR after topNames
   end repeat
   delete char -1 of topNames
   return topNames
end top_ControlNames

setprop top_ControlNames topNames
   replace comma with CR in topNames
   put the long id of the target into layoutView
   
   repeat for each line topName in topNames
      put the top_Control [topName] of layoutView into topControl
      if exists (topControl) is false then next repeat
      
      relayer topControl to front of layoutView
   end repeat
   dispatch "LayoutControl" to layoutView
   return the top_ControlNames of layoutView
end top_ControlNames

getprop top_Controls
   get word  1 of the name of the target
   if it is not among the items of "group,card" then return empty
   --
   put the childControlIDs of the target into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID & CR after topControls
   end repeat
   delete char -1 of topControls
   return topControls
end top_Controls


--> Top
-
getprop top_Card
   -- using a virtual custom property sets the target and therefore "this"
   put the long id of this card into cardObject
   return cardObject
end top_Card


--> Top | Control
-
getprop top_Control [pName]
   put the childcontrolids of the target into topControlIDs
   switch
      case pName is empty
         put line 1 of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of the target
      case pName is a number
         put line pName of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of the target
      default
         repeat for each line cID in topControlIDs
            put the long id of control id cID of the target into topControl
            if the short name of topControl = pName then
               return topControl
            end if
         end repeat
         return empty
   end switch
end top_Control

getprop top_Controls
   local tObjects
   put the childcontrolids of the target into topControlIDs
   repeat for each line cID in topControlIDs
      put the long id of control id cID into tObject
      put tObject & CR after tObjects
   end repeat
   delete char -1 of tObjects
   return tObjects
end top_Controls


--> Object | Top
-
function object_GetTopViews groupOrCard
   put the top_Controls of groupOrCard into topControls
   put empty into topViews
   repeat for each line someObject in topControls
      if the object_IsView of someObject is true then
         put someObject & CR after topViews
      end if
   end repeat
   delete last char of topViews
   return topViews
end object_GetTopViews

getprop top_Control [pName]
   put the childcontrolids of the target into topControlIDs
   switch
      case pName is empty
         put line 1 of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of the target
      case pName is a number
         put line pName of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of the target
      default
         repeat for each line cID in topControlIDs
            put the long id of control id cID of the target into topControl
            if the short name of topControl = pName then
               return topControl
            end if
         end repeat
         return empty
   end switch
end top_Control

getprop object_TopViews
   put the long ID of the target into groupOrCard
   return object_GetTopViews (groupOrCard)
end object_TopViews

getprop object_TopGroupIDs
   put the long ID of the target into someContainer
   
   local topGroupIDs
   repeat with controlNum = 1 to the number of controls in someContainer
      put the long ID of control controlNum of someContainer into someObject
      if word 1 of someObject is "group" then
         add the number of layers in someObject to controlNum
         put the short ID of someObject & comma after topGroupIDs
      end if
   end repeat
   delete last char of topGroupIDs
   return topGroupIDs
end object_TopGroupIDs

getprop object_TopGroups [visibleOnly]
   put the long ID of the target into someContainer
   return object_GetTopGroups(someContainer, true, visibleOnly)
end object_TopGroups

function object_TopLevelGroup someCard, testGroupName
   object_SetToplevelGroupArrays topLevel_NameDictionary, topLevel_IdDictionary, someCard
   put keys(topLevel_NameDictionary) into possibleGroupNames
   put keys(topLevel_IdDictionary) into possibleGroupIds
   
   -- guess from the name
   repeat for each line possibleGroup in possibleGroupIds
      if the short name of possibleGroup is testGroupName then
         return possibleGroup
      end if
   end repeat
   return empty
end object_TopLevelGroup

function object_GetTopViews groupOrCard
   put the top_Controls of groupOrCard into topControls
   put empty into topViews
   repeat for each line someObject in topControls
      if the object_IsView of someObject is true then
         put someObject & CR after topViews
      end if
   end repeat
   delete last char of topViews
   return topViews
end object_GetTopViews

function object_GetTopGroups someContainer, setShort, visibleOnly
   -- was "object_TopGroups"
   -- this stem technique is not needed (use same as "object_GetGroupControls")
   
   put the long ID of someContainer into someContainer
   put empty into myGroups
   repeat with groupNum = 1 to the number of groups in someContainer
      put the long ID of group groupNum of someContainer into testGroup
      if visibleOnly is true and the visible of testGroup is false then next repeat
      
      put offset(someContainer, testGroup) - 1 into endStem
      put char 1 to endStem of testGroup into groupStem
      put the number of words of groupStem into wordNum
      if wordNum = 4 then
         if setShort is not false then object_SetShortStackName testGroup, stackNameStart, stackNameEnd
         put testGroup & return after myGroups
      end if
   end repeat
   delete last char of myGroups
   return myGroups
end object_GetTopGroups

command object_SetToplevelGroupArrays @topLevel_NameDictionary, @topLevel_IdDictionary, cardObject
   -- should be renamed to "object_SetToplevelCardGroupArrays"?
   if cardObject is empty then put the long ID of this card into cardObject
   put the groupNames of cardObject into topLevelGroupNames
   put the groupIDs of cardObject into topLevelGroupIds
   repeat with lineNum = 1 to the number of lines of topLevelGroupNames
      put line lineNum of topLevelGroupNames into topLevelGroupName
      put line lineNum of topLevelGroupIds into topLevelGroupId
      put the long ID of group ID topLevelGroupId of cardObject into someGroup
      
      put someGroup into topLevel_NameDictionary[topLevelGroupName]
      put topLevelGroupName into topLevel_IdDictionary[someGroup]
   end repeat
end object_SetToplevelGroupArrays


--> Deps
-
