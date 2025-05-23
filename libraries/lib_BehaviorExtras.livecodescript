﻿script "lib_BehaviorExtras"
--> MetaData
-
license: GPLv3
name: lib_BehaviorExtras
type: library
version: 0.2


--> Old | Behavior | hArray
-
getprop behavior_Name
   put the behavior of the target into behaviorObject
   if behaviorObject is empty then return empty
   -- put behavior_GetName (behaviorObject) into bName
   put hArray_GetName (behaviorObject, "behavior") into bName
   return bName
end behavior_Name

setprop behavior_Name bName
   if bName is empty then
      set the behavior of the target to empty
      return empty
   end if
   
   -- put behavior_GetObject (bName) into bObject - this would get either view behavior or plain behavior oject
   put hArray_GetNamedObjectType (bName, "behavior") into bObject
   if exists (bObject) is false then return empty
   set the behavior of the target to bObject
   return bObject
end behavior_Name
 
getprop behavior_Names
   put the long id of the target into targetObject
   put behavior_GetNameHierarchy (targetObject) into bNames
   return bNames
end behavior_Names

setprop behavior_Names bNames
   put the long id of the target into targetObject
   behavior_SetNameHierarchy targetObject, bNames
   return the result
end behavior_Names

function behavior_GetNameHierarchy targetObject
   repeat
      put the behavior of targetObject into bObject
      if exists(bObject) is false then exit repeat
      
      put behavior_GetName (bObject) into bName
      if bName is empty then exit repeat
      
      put bName & CR after bNames
      put bObject into targetObject
   end repeat
   delete char -1 of bNames
   return bNames
end behavior_GetNameHierarchy

command behavior_SetNameHierarchy targetObject, bNames
   replace comma with CR in bNames
   put behavior_GetObjects (bNames) into bObjects
   behavior_SetHierarchy targetObject,  bObjects
   return the result
end behavior_SetNameHierarchy

function hArray_ListBehaviorNames
   put hArray_ListObjectNamesOfType ("behavior") into bNames
   sort bNames
   return bNames
end hArray_ListBehaviorNames

function hArray_ListViewBehaviorNames
   put hArray_ListObjectNamesOfType ("view behavior") into bNames
   sort bNames
   return bNames
end hArray_ListViewBehaviorNames

function hArray_ListBehaviors
   put hArray_ListObjectsOfType ("behavior") into rObjects
   return rObjects
end hArray_ListBehaviors

function hArray_ListViewBehaviors
   put hArray_ListObjectsOfType ("view behavior") into rObjects
   return rObjects
end hArray_ListViewBehaviors


--> View | Behavior | List | Standard
-
function behavior_ListStandardNames
   put behavior_ListStandardPaths() into stackPaths
   repeat for each line stackPath in stackPaths
      put the short name of stack stackPath & CR after stackNames
   end repeat
   delete char -1 of stackNames
   sort stackNames
   return stackNames
end behavior_ListStandardNames

function behavior_ListStandardPaths
   put the project_StackPaths ["behavior"] of stack "LCW" into stackPaths
   return stackPaths
end behavior_ListStandardPaths


--> Old | View | Behavior | List
-
function behavior_ListLibraryCardButtons
   put the behaviorButton_Card of me into behaviorButtonCard
   repeat with btnNum = 1 to the number of buttons on behaviorButtonCard
      put the long id of btn btnNum of behaviorButtonCard into bButton
      -- put revRuggedID (bButton) & CR after bButtons
      put the name of bButton & CR after bButtons
   end repeat
   delete char -1 of bButtons
   return bButtons
end behavior_ListLibraryCardButtons


function view_WithBehaviorObjects
    put view_PathIndex() into pathIndex
    filter pathIndex without "Compound|*"
    
    repeat for each line viewName in pathIndex
        set the cursor to busy
        put view_GetTemplateObject (viewName) into libraryObject
        if exists(libraryObject) then
            put the view_Behavior of libraryObject into viewBehavior
            if exists(viewBehavior) then
                put view_GetTemplateObject (viewName) into libraryObject
                put libraryObject & CR after libraryObjects
                -- set the behavior of libraryObject to the behavior of libraryObject
            end if
        end if
    end repeat
    delete char -1 of libraryObjects
    return libraryObjects
end view_WithBehaviorObjects


--> Behavior | Props
-
getprop object_IsOldBehavior
   -- must be a button
   put the long id of the target into scriptObject
   if word 1 of scriptObject is not "button" then return false
   
   -- must also be marked as a "view behavior" in the script metadata
   put the script_MetaData of scriptObject into scriptMetaData
   put scriptMetaData ["type"] into scriptType
   return scriptType is "view behavior"
end object_IsOldBehavior

getprop stack_IsBehavior
   -- must be a stack and must be script only
   put the long id of the target into scriptObject
   if word 1 of scriptObject is not "stack" then return false
   if the scriptonly of scriptObject is false then return false
   
   -- must also be marked as a "view behavior" in the script metadata
   put the script_MetaData of scriptObject into scriptMetaData
   put scriptMetaData ["type"] into scriptType
   return scriptType is "view behavior"
end stack_IsBehavior

getprop object_HasBehavior
   return the behavior of the target is not empty
end object_HasBehavior

getprop behavior_Version
   put the long id of the target into targetObject
   if the object_Type of targetObject is "behavior" then
      return the object_Version of targetObject
   else if exists(the behavior of targetObject) then
      return the object_Version of the behavior of targetObject
   else
      return empty
   end if
end behavior_Version

getprop behavior_Name
   put the behavior of the target into behaviorObject
   if behaviorObject is empty then return empty
   -- put behavior_GetName (behaviorObject) into bName
   put hArray_GetName (behaviorObject, "behavior") into bName
   return bName
end behavior_Name

setprop behavior_Name bName
   if bName is empty then
      set the behavior of the target to empty
      return empty
   end if
   
   -- put behavior_GetObject (bName) into bObject - this would get either view behavior or plain behavior oject
   put hArray_GetNamedObjectType (bName, "behavior") into bObject
   if exists (bObject) is false then return empty
   set the behavior of the target to bObject
   return bObject
end behavior_Name
 
getprop view_Behavior
   put the behavior of the target into behaviorObject
   if behaviorObject is empty then return empty
   put hArray_GetName (behaviorObject, "view behavior") into vbName
   return vbName
end view_Behavior

setprop view_Behavior vbName
   if vbName is empty then
      set the behavior of the target to empty
      return empty
   end if
   
   -- put view_GeBehaviorObject (bName) into vbObject
   put hArray_GetNamedObjectType (bName, "view behavior") into vbObject
   if exists (vbObject) is false then return empty
   set the behavior of the target to vbObject
   return vbObject
end view_Behavior


--> Old | Behavior | Hierarchy
-
getprop behavior_NameHierarchy
   return the behavior_Names of the target
end behavior_NameHierarchy

setprop behavior_NameHierarchy bNames
   set the behavior_Names of the target to bNames
   return the result
end behavior_NameHierarchy

getprop behavior_LibraryObjectName
   put the long id of the target into behaviorObject
   
   put behaviorModel_GetArray() into behaviorArray
   repeat for each key bName in behaviorArray
      put behaviorArray [bName]["ruggedID"] into ruggedObject
      if exists(ruggedObject) is false then
         next repeat
      end if
      if the long id of ruggedObject = behaviorObject then
         return bName
      end if
   end repeat
   return empty
end behavior_LibraryObjectName

setprop behavior_LibraryObjectName [notify] bName
   put the long id of the target into behaviorObject
   behaviorModel_SetObject bName, behaviorObject
   if notify is not false then lcw_Notify merge("Added behavior '[[bName]]' to model")
   if "libOPN_Behavior" is among the lines of the openstacks then
      display_Behaviors
   end if
end behavior_LibraryObjectName

getprop behavior_Instances [bName]
   if bName is empty then
      put behaviorModel_GetArray (modelObject) into behaviorArray
      put empty into behaviorObjectIndex
      repeat for each key bName in behaviorArray
         put behaviorArray [bName] into newObjects
         put line_AddToIndex(newObjects, behaviorObjectIndex) into behaviorObjectIndex
      end repeat
      return behaviorObjectIndex
   else
      return behaviorModel_GetInstances(bName, modelObject)
   end if
end behavior_Instances

getprop objects_WithBehavior
   -- hArray | Behaviors
   put the behavior_Array of the target into behaviorArray
   put behaviorArray ["behaviorArray"]["data"]["object"] into objectArray
   put keys (objectArray) into rObjects
   return rObjects
end objects_WithBehavior

getprop behavior_Array
   -- hArray | Behaviors
   put the rugged_ID of the target into behaviorObject
   put hArray_GetBehaviorArray() into behaviorArray
   put behaviorArray [behaviorObject] into objectArray
   return objectArray
end behavior_Array


--> Behavior
-
function behavior_GetName behaviorObject
   -- hack for updating to new hArray technique
   put hArray_GetBehaviorName (behaviorObject) into bName
   return bName
end behavior_GetName

function behavior_FindStoredName behaviorObject
   return hArray_GetBehaviorName (behaviorObject) -- hack for updating to new hArray technique
   
   -- old model version
   put the rugged_ID of behaviorObject into behaviorObject
   put behaviorModel_GetArray() into behaviorArray
   repeat for each key bName in behaviorArray
      put behaviorArray [bName]["ruggedID"] into ruggedObject
      if exists(ruggedObject) is false then
         -- display_Lines ruggedObject, "Behavior does not exist!"
         next repeat
      end if
      if ruggedObject = behaviorObject then
         return bName
      end if
   end repeat
   return empty
end behavior_FindStoredName

function behavior_Objects
   put behaviorModel_GetArray() into behaviorArray
   put keys(behaviorArray) into bNames
   sort bNames
   repeat for each line bName in bNames
      put behaviorArray [bName]["ruggedID"] into behaviorObject
      put behaviorObject & CR after behaviorObjects
   end repeat
   delete char -1 of behaviorObjects
   return behaviorObjects
end behavior_Objects

function behavior_GetObjects bNames
   repeat for each line bName in bNames
      put behavior_GetObject (bName) into bObject
      if exists (bObject) is false then
         -- not sure what to do -- should return an error
         return empty
      end if
      put bObject & CR after bObjects
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_GetObjects

command behavior_EditScript bName
   put behavior_GetObject (bName) into behaviorObject
   if exists(behaviorObject) then
      edit the script of behaviorObject
   end if
end behavior_EditScript


--> Behavior | Scripts
-
function behavior_GetScript bName
   put library_TextUrl ("script.txt", bName, "behavior", true) into someUrl
   if someUrl is empty then return empty
   put url someUrl into helpHtml
   return helpHtml
end behavior_GetScript

on behavior_SetScript bName, someScript
   put library_TextUrl ("script.txt", bName, "behavior", false) into someUrl
   if someUrl is not empty then put someHtml into url someUrl
   return someUrl
end behavior_SetScript


--> Behavior | Help
-
function behavior_GetHelpHtml bName
   put library_TextUrl ("help.html", bName, "behavior", true) into someUrl
   if someUrl is empty then return empty
   put url someUrl into helpHtml
   return helpHtml
end behavior_GetHelpHtml

on behavior_SetHelpHtml bName, someHtml, pOnLineMode
   put library_TextUrl ("help.html", bName, "behavior", false) into someUrl
   if someUrl is not empty then put someHtml into url someUrl
   return someUrl
end behavior_SetHelpHtml


--> Behavior | Repository Script
-
function behavior_GetRepositoryScript bName
   put library_TextUrl ("script.txt", bName, "behavior", true) into someUrl
   if someUrl is empty then return empty
   put url someUrl into someScript
   return someScript
end behavior_GetRepositoryScript

on behavior_SetRepositoryScript bName, someScript, pOnLineMode
   put library_TextUrl ("script.txt", bName, "behavior", false) into someUrl
   if someUrl is not empty then put someScript into url someUrl
   return someUrl
end behavior_SetRepositoryScript


--> Behavior | Utilities
-
function behavior_GetStackOutline
    put the behavior_Array of the target into behaviorArray
    put stack_OutlineFromObjectArray(behaviorArray) into stackOutline
    return stackOutline
end behavior_GetStackOutline


--> hArray | Behaviors
-
/*
put scriptHash into hArray ["behaviorArray"][behaviorObject]["data"]["object"][ruggedObject]["scriptHash"]
*/

function hArray_GetOtherPlaces hKey
   put hArray_ListHkeyObjects (hKey) into otherObjects
   put item 3 of hKey into hObject
   line_Delete hObject, otherObjects
   return word 1 to -1 of otherObjects
end hArray_GetOtherPlaces

function hArray_GetBehavior bName
   put hArray_GetNamedObjectType (bName, "behavior") into bObject
   if exists(bObject) then return bObject
   put hArray_GetNamedObjectType (bName, "view behavior") into bObject
   return bObject
end hArray_GetBehavior

function hArray_GetBehaviorName behaviorObject
   put hArray_GetName (behaviorObject, "behavior") into objectViewName
   return objectViewName
   
   put revRuggedID (behaviorObject) into rObject
   put hArray_GetObjectTypeArray ("behavior") into objectArray
   put objectArray [rObject]["scriptHash"] into scriptHash
   if scriptHash is empty then return empty
   
   put hArray_GetUripArray (rObject, "name") into objectViewName
   return objectViewName
end hArray_GetBehaviorName

function hArray_GetName behaviorObject, harrayName
   put revRuggedID (behaviorObject) into rObject
   put hArray_GetObjectTypeArray (harrayName) into objectArray
   put objectArray [rObject]["scriptHash"] into scriptHash
   if scriptHash is empty then return empty
   
   put hArray_GetUripArray (rObject, "name") into objectViewName
   return objectViewName
end hArray_GetName


--> Behavior | Model | Old
-
/*
These handlers use a unique stored file based array for each Library Set.
put lcw_FetchArray ("OPN_Behavior") into behaviorArray

The new model has moved over to the more general object types of hArray.
*/
-- getprop behavior_Model
   return the the long id of me
end behavior_Model

command behaviorModel_SetObject bName, behaviorObject
   put the rugged_ID of behaviorObject into behaviorObject
   behaviorModel_SetRecordValue "ruggedID", bName, behaviorObject
   return the result
end behaviorModel_SetObject

function behaviorModel_GetSourceUrl bName
   return behaviorModel_GetRecordValue ("sourceURL", bName)
end behaviorModel_GetSourceUrl

on behaviorModel_SetSourceUrl bName, sourceURL
   behaviorModel_SetRecordValue "sourceURL", bName, sourceURL
   return the result
end behaviorModel_SetSourceUrl

function behaviorModel_GetHelpUrl bName
   return behaviorModel_GetRecordValue ("helpURL", bName)
end behaviorModel_GetHelpUrl

on behaviorModel_SetHelpUrl bName, helpURL
   behaviorModel_SetRecordValue "helpURL", bName, helpURL
   return the result
end behaviorModel_SetHelpUrl

function behaviorModel_GetInstances bName
   -- put behaviorModel_GetRecordValue ("instances", bName) into bInstances
   -- put behaviorModel_GetRecordValue ("ruggedID", bName) into behaviorObject
   put behaviorModel_GetArray ("all") into someArray
   put someArray ["nameArray"][bName]["ruggedID"] into ruggedID
   put the mobile_ID of ruggedID into mobileID -- annoying !!! -- behaviors are stored using my custom mobile_ID - not revs internal ruggedID
   put someArray ["objectArray"][mobileID] into bInstances
   return bInstances
end behaviorModel_GetInstances

on behaviorModel_SetInstances bName, instanceObjects
   behaviorModel_SetRecordValue "instances", bName, instanceObjects
   return the result
end behaviorModel_SetInstances


--> Behavior | Model | Named Record Arrays
-
/*
Each behavior has a name and a record array associated with that name stored in a nested array.
These utility handlers make it easy to get and set properties of these record arrays.
*/

private function behaviorModel_GetRecordValue recordName, bName
   put behaviorModel_GetArray() into behaviorArray
   return behaviorArray [bName][recordName]
end behaviorModel_GetRecordValue

private command behaviorModel_SetRecordValue recordName, bName, recordValue
   put behaviorModel_GetArray() into behaviorArray
   put recordValue into behaviorArray [bName][recordName]
   behaviorModel_SetArray behaviorArray
   return the result
end behaviorModel_SetRecordValue


--> Behavior | Model | CRUD
-
command behaviorModel_DeleteNamedRecord bName
   -- not sure this is doing everything it should
   global gLCW
   put hArray_GetBehavior (bName) into rObject
   hArray_RemoveObjectFromTypeArray rObject, gLCW
   return gLCW
   
   -- old array based model
   local behaviorArray
   put behaviorModel_GetArray() into behaviorArray
   delete local behaviorArray [bName]
   behaviorModel_SetArray behaviorArray
   display_Behaviors
   return the result
end behaviorModel_DeleteNamedRecord

command behaviorModel_RenameRecord oldName, newName
   -- old move to hArray
   breakpoint
   
   local behaviorArray
   put behaviorModel_GetArray() into behaviorArray
   put behaviorArray [oldName] into behaviorArray [newName]
   delete local behaviorArray [oldName]
   behaviorModel_SetArray behaviorArray
   return the result
end behaviorModel_RenameRecord

function behaviorModel_GetData pSetName
   -- old move to hArray
   breakpoint
   
   if pSetName is empty then put library_GetSetName() into pSetName
   put library_GetModelArray() into modelArray
   put modelArray [pSetName]["behavior"] into behaviorArray
   return behaviorArray
end behaviorModel_GetData

command behaviorModel_SetData behaviorArray, pSetName
   -- old move to hArray
   breakpoint
   
   if pSetName is empty then put library_GetSetName() into pSetName
   put library_GetModelArray() into modelArray
   put behaviorArray into modelArray [pSetName]["behavior"]
   library_SetModelArray modelArray
end behaviorModel_SetData


--> Behavior | Model | Arrays
-
function behaviorModel_GetDataArray pWhichBehaviors, pIsExpanded
   -- suitable for datagrids
   -- pWhichBehaviors = "view", "all" or empty
   
   put 1 into lineNum
   
   if pWhichBehaviors is not "view" then
      put hArray_GetObjectTypeArray ("behavior") into oTypeArray
      repeat for each key rObject in oTypeArray
         put rObject into dataArray [lineNum]["ruggedID"]
         put oTypeArray [rObject]["uRipName"] into dataArray [lineNum]["title"]
         put oTypeArray [rObject]["scriptHash"] into dataArray [lineNum]["scriptHash"]
         put pIsExpanded is true into dataArray [lineNum]["isExpanded"]
         add 1 to lineNum
      end repeat
   end if
   
   if pWhichBehaviors is not empty then
      put hArray_GetObjectTypeArray ("view behavior") into oTypeArray
      repeat for each key rObject in oTypeArray
         put rObject into dataArray [lineNum]["ruggedID"]
         put oTypeArray [rObject]["uRipName"] into dataArray [lineNum]["title"]
         put oTypeArray [rObject]["scriptHash"] into dataArray [lineNum]["scriptHash"]
         put pIsExpanded is true into dataArray [lineNum]["isExpanded"]
         add 1 to lineNum
      end repeat
   end if
   
   return dataArray
   
   
   -- old move to hArray
   breakpoint
   
   put behaviorModel_GetArray ("nameArray") into nameArray
   put keys(nameArray) into bNames
   sort bNames
   repeat with lineNum = 1 to the number of lines of bNames
      put line lineNum of bNames into bName
      put bName into dataArray [lineNum]["title"]
      
      put nameArray [bName]["ruggedID"] into dataArray [lineNum]["ruggedID"]
      put nameArray [bName]["sourceURL"] into dataArray [lineNum]["sourceURL"]
      put nameArray [bName]["helpURL"] into dataArray [lineNum]["helpURL"]
      
      put pIsExpanded is true into dataArray [lineNum]["isExpanded"]
   end repeat
   return dataArray
end behaviorModel_GetDataArray

function behaviorModel_GetArray pWhichArray
   -- put hArray_GetObjectTypeArray ("behavior") into objectArray -- new hArray model
   -- return objectArray
   
   -- old move to hArray
   breakpoint
   
   -- this is the old file based array model
   put lcw_FetchArray ("OPN_Behavior.array") into behaviorArray
   switch
      case char 1 of pWhichArray is empty or char 1 of pWhichArray is "n" -- default for nameArray
         return behaviorArray ["nameArray"]
      case char 1 of pWhichArray is "o" -- for objectArray
         return behaviorArray ["objectArray"]
      default -- "full"
         return behaviorArray
   end switch
   return behaviorArray
end behaviorModel_GetArray

command behaviorModel_SetArray someArray, pWhichArray
   -- old move to hArray
   breakpoint
   
   switch
      case char 1 of pWhichArray is empty or char 1 of pWhichArray is "n" -- default for nameArray
         put lcw_FetchArray ("OPN_Behavior.array") into behaviorArray
         put someArray into behaviorArray ["nameArray"]
         break
      case char 1 of pWhichArray is "o" -- for objectArray
         put lcw_FetchArray ("OPN_Behavior.array") into behaviorArray
         put someArray into behaviorArray ["objectArray"]
         break
      default -- "full"
         put someArray into behaviorArray
   end switch
   lcw_StoreArray "OPN_Behavior.array", behaviorArray
   return behaviorArray
end behaviorModel_SetArray


--> Behavior | Model
-
/*
The newer handlers compatible with hArray object types.
Any script labeled "type: behavior" is not added
*/

function behavior_GetObject bName
   -- new hArray version
   return hArray_GetBehavior (bName)
end behavior_GetObject

function hArray_GetBehaviorArray
   global gLCW
   put gLCW ["behaviorArray"] into behaviorArray
   return behaviorArray
end hArray_GetBehaviorArray

command hArray_SetBehaviorArray behaviorArray
   global gLCW
   put behaviorArray into gLCW ["behaviorArray"]
   return gLCW
end hArray_SetBehaviorArray

command behaviorModel_CreateNew bName
   if bName is empty then put lcw_Ask ("New behavior name...") into bName
   put the behaviorButton_Card of me into behaviorButtonCard
   
   put the defaultstack into oDefault
   set the defaultstack to the name of me
   lock screen
   go to behaviorButtonCard
   if the result is not empty then return empty
   
   create button bName
   put it into behaviorObject
   
   -- behaviorModel_SetObject bName, behaviorObject
   set the component_Name ["behavior"] of behaviorObject to bName
   
   dispatch "resizeStack" to behaviorButtonCard
   unlock screen
   set the defaultstack to oDefault
   
   display_Behaviors
   edit the script of behaviorObject
end behaviorModel_CreateNew
