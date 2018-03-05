script "lib_FindHkey"
--> MetaData
-
license: GPLv3
name: lib_FindHkey
type: library
version: 0.2

/*
This library has a number of old and new ways of finding handlers.
It should be rationalised to do this as fast as possible.

See also model_HkeyLine
See also hkey_GetPlace(hTableLine) in model_Place for memory resident array search of index
Consider using a database.
*/

--> Working on
-
getprop hkey_StartLine [hkeyLine]
   put word 1 to 2 of hkeyLine into shortHkey
   put the revAvailableHandlers of the target into hTable
   repeat for each line someLine in hTable
      if word 1 to 2 of someLine = shortHkey then
         put word 3 of someLine into startLineNum
         return startLineNum
      end if
   end repeat
   return 0
end hkey_StartLine

getprop hkey_Find [hKey]
   -- this finds private or public handlers in the target
   
   hkey_Deconstruct hKey, hName, hType, xObject, xNum
   put hType && hName into shortHkeyLine
   put the found_Handler [shortHkeyLine] of the target into foundHkey
   return foundHkey
   
   /*
   put the long id of the target into hObject
   put item 1 of shortHkey into hName
   put item 2 of shortHkey into hType
   
   put hkey_FindAndIndex (hName, hType, hObject, pSetName) into foundHkey
   return foundHkey
   */
end hkey_Find


--> Hkey | Find | New
-
/*
These newer handlers use the more flexible "getprop script_Hierarchy" and built in "revAvailableHandlers"
*/

getprop found_Hkey [shortHkeyLine]
   -- finds private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into targetObject
   put hkey_FindFirst (shortHkeyLine, targetObject) into foundHkey
   return foundHkey
end found_Hkey

getprop found_Handler [shortHkeyLine]
   -- this finds private or public handlers in the target
   put the long id of the target into foundObject
   put the revAvailableHandlers of foundObject into hTable
   put word 1 of shortHkeyLine into typeToFind
   if char 1 of typeToFind = "P" then delete char 1 of typeToFind
   put word 2 of shortHkeyLine into handlerNameToFind
   --
   repeat for each line someLine in hTable
      put word 2 of someLine into testName
      if testName is not handlerNameToFind then next repeat
      --
      put word 1 of someLine into testType
      if testType contains typeToFind then
         put hKeyLine_FromTripple (handlerNameToFind, testType, foundObject) into foundHkey
         return foundHkey
      end if
   end repeat
   return empty
end found_Handler

function hkey_FindFirst shortHkeyLine, targetObject, pExternalObjects
   -- finds private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the hkey_ScriptHierarchy [pExternalObjects] of targetObject into externalObjects
   put hkey_FindDependency (shortHkeyLine, targetObject, externalObjects) into foundHkey
   return foundHkey
end hkey_FindFirst

function hkey_FindDependency shortHkeyLine, targetObject, pExternalObjects
   -- finds private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into targetObject
   put the found_Handler [shortHkeyLine] of targetObject into foundHkey
   if foundHkey is not empty then return foundHkey
   
   put the hkey_ScriptHierarchy [pExternalObjects] of targetObject into externalObjects
   
   put word 1 of shortHkeyLine into hType
   put word 2 of shortHkeyLine into hName
   put hkeyline_Find (hName, hType, externalObjects) into foundHkey
   return foundHkey
end hkey_FindDependency

function hkeyline_Find hName, hType, pExternalObjects
   -- ignores private handlers
   -- as fast as possible
   
   hkey_FindLines hName, hType, foundObject, startLineNum, endLineNum, pExternalObjects
   put hKeyLine_FromTripple (hName, hType, foundObject) into foundHkey
   return foundHkey
end hkeyline_Find

command hkey_FindLines hName, hType, @foundObject, @startLineNum, @endLineNum, pExternalObjects
   -- ignores private handlers
   -- as fast as possible
   if pExternalObjects is empty then put stack_ListUsed() into pExternalObjects
   put hType && hName into shortHkey
   repeat for each line foundObject in pExternalObjects
      put the revAvailableHandlers of foundObject into hTable
      repeat for each line someLine in hTable
         if word 1 to 2 of someLine = shortHkey then
            put word 3 of someLine into startLineNum
            put word 4 of someLine into endLineNum
            return true
         end if
      end repeat
   end repeat
   --
   put empty into foundObject
   put 0 into startLineNum
   put 0 into endLineNum
   --
   return false
end hkey_FindLines


--> Older
-
getprop hkey_ScriptHierarchy [externalObjects]
   if externalObjects is empty then
      put stack_PathsToObjects (the stacksinUse) into externalObjects
   end if
   put the long id of the target into targetObject
   put the behavior_Objects of the target into bObjects
   
   -- let's just do used stacks for now
   put bObjects & CR & externalObjects into scriptHierarchy
   put word 1 to -1 of scriptHierarchy into scriptHierarchy
   --
   return scriptHierarchy
end hkey_ScriptHierarchy

getprop handler_InHierarchy [hKey]
   put the long id of the target into tObject
   hkeyLine_Normalise hKey
   put the result into shortHkey
   
   put hkey_FoundArray (shortHKey, tObject) into foundArray
   put foundArray ["foundHkey"] into foundHkey
   if foundHkey is empty then return empty
   
   hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
   try
      put the script of fObject into fScript
   catch e
      return empty -- stack locked
   end try
   
   put foundArray ["startLineNum"] into startLineNum
   put foundArray ["endLineNum"] into endLineNum
   put line startLineNum to endLineNum of fScript into fHandler
   return fHandler
end handler_InHierarchy

function hkey_Find hKey, pProjectName
   breakpoint
   hkey_Deconstruct hKey, hName, hType, xObject, xNum
   put hkey_FindInProject (hName, hType, pProjectName) into foundHkey 
   return foundHkey
end hkey_Find

function hkey_FindExternalObjectArray hName, hType, externalObjects
   -- ignores private handlers
   -- finds in order of objects
   put hType && hName into shortHkey
   repeat with lineNum = the number of lines of externalObjects down to 1
      put line lineNum of externalObjects into foundObject
      put the revAvailableHandlers of foundObject into hTable
      --
      -- hkey_FindInTable shortHkey, hTable, startLineNum, endLineNum
      repeat for each line someLine in hTable
         if word 1 to 2 of someLine = shortHkey then
            put hTable into foundArray [foundObject]["handlerTable"]
            put word 3 of someLine into foundArray [foundObject]["startLineNum"]
            put word 4 of someLine into foundArray [foundObject]["endLineNum"]
            put hKeyLine_FromTripple (hName, hType, hObject) into foundArray [foundObject]["foundHkey"]
            exit repeat
         end if
      end repeat
   end repeat
   return foundArray
end hkey_FindExternalObjectArray

function hkey_FindLongCalls shortCalls, hKey, pProjectName
   repeat for each line shortCall in shortCalls      
      put hkey_FindInHierarchy (shortHKey, tObject, pProjectName) into foundHkey
      put foundHkey & CR after longCalls
   end repeat
   delete char -1 of longCalls
   return longCalls
end hkey_FindLongCalls

function hkey_FindInProject hName, hType, pProjectName
   put env_ListUsedHierarchy (pProjectName) into searchHierarchy
   put hkey_FindInSearchHierarchy (hName, hType, searchHierarchy) into foundArray
   return foundArray ["foundHkey"]
end hkey_FindInProject

function hkey_FindInHierarchy shortHKey, tObject, pProjectName
   put hkey_FoundArray (shortHKey, tObject, pProjectName) into foundArray 
   return foundArray ["foundHkey"]
end hkey_FindInHierarchy

function hkey_FoundArray shortHKey, tObject, pProjectName
   hkey_Deconstruct shortHKey, hName, hType, xObject, xNum
   put the script_Hierarchy [pProjectName] of tObject into searchHierarchy
   
   put the long id of tObject into tObject
   repeat with lineNum = the number of lines of searchHierarchy down to 1
      put line lineNum of searchHierarchy into hierarchyObject
      put the revAvailableHandlers of hierarchyObject into handlerTable
      
      if the long id of hierarchyObject = tObject and char 1 of hType is not "p" then -- if looking for private skip
         -- look for private handlers first (ideally should get the first version?)
         put "p" & hType into privateHype
         put hName,privateHype into privateShortKey
         hkey_FindInTable privateShortKey, handlerTable, startLineNum, endLineNum
         if the result is true then
            put handlerTable into foundArray ["handlerTable"]
            put startLineNum into foundArray ["startLineNum"]
            put endLineNum into foundArray ["endLineNum"]
            put hkey_Construct (hName, privateHype, hierarchyObject) into foundArray ["foundHkey"]
            return foundArray
         else
            hkey_FindInTable shortHkey, handlerTable, startLineNum, endLineNum
            if the result is true then
               put handlerTable into foundArray ["handlerTable"]
               put startLineNum into foundArray ["startLineNum"]
               put endLineNum into foundArray ["endLineNum"]
               put hkey_Construct (hName, hType, hierarchyObject) into foundArray ["foundHkey"]
               return foundArray
            end if
         end if
      else
         hkey_FindInTable shortHkey, handlerTable, startLineNum, endLineNum
         if the result is true then
            put handlerTable into foundArray ["handlerTable"]
            put startLineNum into foundArray ["startLineNum"]
            put endLineNum into foundArray ["endLineNum"]
            put hkey_Construct (hName, hType, hierarchyObject) into foundArray ["foundHkey"]
            return foundArray
         end if
      end if
   end repeat
   return empty
end hkey_FoundArray

function hkey_FindInSearchHierarchy hName, hType, searchHierarchy
   repeat with lineNum = the number of lines of searchHierarchy down to 1
      put line lineNum of searchHierarchy into hObject
      put the revAvailableHandlers of hObject into handlerTable
      
      -- look for private handlers first (ideally should get the first version?)
      put "P" & hType into privateHype
      put hName,privateHype into privateShortKey
      hkey_FindInTable privateShortKey, handlerTable, startLineNum, endLineNum
      if the result is true then exit repeat
      
      -- put hName,hType into shortHkey
      put hType && hName into shortHkey
      hkey_FindInTable shortHkey, handlerTable, startLineNum, endLineNum
      if the result is true then exit repeat
   end repeat
   
   put handlerTable into foundArray ["handlerTable"]
   put startLineNum into foundArray ["startLineNum"]
   put endLineNum into foundArray ["endLineNum"]
   -- put hkey_Construct (hName, privateHype, hierarchyObject) into foundArray ["foundHkey"]
   put hKeyLine_FromTripple (hName, hType, hObject) into foundArray ["foundHkey"]
   return foundArray
end hkey_FindInSearchHierarchy

command hkey_FindScriptLine hKey, someScript, @scriptLine, @lineNum
   put word 1 to -1 of someScript into someScript
   script_ExtractAndStripMultiLineComments someScript, mulitLineComment
   put script_StripComments (someScript) into someScript
   
   put someScript into testScript
   put text_StripQuoted (testScript, "•••") into testScript
   
   hkey_Deconstruct hKey, hName, hType, scriptObject, hNum
   put empty into scriptLine
   put 0 into lineNum
   put 0 into lastWordNum
   repeat
      put wordoffset (hName, testScript, lastWordNum) into wordNum
      if wordNum = 0 then return false
      
      get testScript
      delete word (wordNum + lastWordNum + 1) to -1 of it
      put the number of lines of it into lineNum
      put word 1 to -1 of line lineNum of someScript into scriptLine
      
      switch hType
         case "g"
            if word (wordNum - 1) of someScript = "the" then return true
         case "s"
            if word (wordNum - 1) of someScript = "the" then return true
         case "c"
            if hName = token 1 of scriptLine then return true
         case "f"
            put someScript into testFunctionScript
            delete word 1 to (wordNum + lastWordNum) of testFunctionScript
            if token 1 of testFunctionScript = "(" then return true
         case "m"
            if hName = token 1 of scriptLine then return true
      end switch
      put empty into scriptLine
      put 0 into lineNum
      put wordNum into lastWordNum
   end repeat
   return false
end hkey_FindScriptLine

function hkey_FindAndAdd shortHKey, tObject, @foundStackArray, pProjectName
   hkey_Deconstruct shortHKey, hName, hType, xObject, xNum
   
   -- let's just add used (forget behaviors of libs for now)
   put the object_Hierarchy of tObject into objectHierarchy
   
   --  put project_ListUsedStacks (pProjectName) into usedProjectStacks
   if pProjectName is empty then
      repeat for each line stackName in the stacksinUse
         put the name of stack stackName & CR after usedProjectDepStacks
      end repeat
      delete char -1 of usedProjectDepStacks
   else
      put project_ListUsedDeps (pProjectName) into usedProjectDepStacks
   end if
   put keys (foundStackArray) into foundStacks
   
   put objectHierarchy into searchHierarchy
   
   -- let's add the ones already found first
   if foundStacks is not empty then
      -- should delete duplicate lines in searchHierarchy
      put foundStacks & CR before searchHierarchy
   end if
   
   if usedProjectDepStacks is not empty then
      -- should delete duplicate lines in searchHierarchy
      put usedProjectDepStacks & CR before searchHierarchy
   end if
   
   -- put searchHierarchy
   
   put hkey_FoundArrayFromSearchHierarchy (hName, hType, shortHKey, tObject, searchHierarchy) into foundArray
   put foundArray ["foundHkey"] into foundHkey
   
   if foundHkey is not empty then
      -- let's add it to found stacks to be added to hierarchy
      hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
      if word 1 of fObject = "stack" then
         put the project_Name of fObject into foundProjectName
         put foundProjectName into foundStackArray [fObject]
      else
         -- breakpoint
      end if
   end if
   return foundHkey
end hkey_FindAndAdd

function hkey_FoundArrayFromSearchHierarchy hName, hType, shortHKey, tObject, searchHierarchy
   put the long id of tObject into tObject
   repeat with lineNum = the number of lines of searchHierarchy down to 1
      put line lineNum of searchHierarchy into hierarchyObject
      put the revAvailableHandlers of hierarchyObject into handlerTable
      
      if the long id of hierarchyObject = tObject and char 1 of hType is not "p" then -- if looking for private skip
         -- look for private handlers first (ideally should get the first version?)
         put "p" & hType into privateHype
         put hName,privateHype into privateShortKey
         hkey_FindInTable privateShortKey, handlerTable, startLineNum, endLineNum
         if the result is true then
            put handlerTable into foundArray ["handlerTable"]
            put startLineNum into foundArray ["startLineNum"]
            put endLineNum into foundArray ["endLineNum"]
            put hkey_Construct (hName, privateHype, hierarchyObject) into foundArray ["foundHkey"]
            return foundArray
         else
            hkey_FindInTable shortHkey, handlerTable, startLineNum, endLineNum
            if the result is true then
               put handlerTable into foundArray ["handlerTable"]
               put startLineNum into foundArray ["startLineNum"]
               put endLineNum into foundArray ["endLineNum"]
               put hkey_Construct (hName, hType, hierarchyObject) into foundArray ["foundHkey"]
               return foundArray
            end if
         end if
      else
         hkey_FindInTable shortHkey, handlerTable, startLineNum, endLineNum
         if the result is true then
            put handlerTable into foundArray ["handlerTable"]
            put startLineNum into foundArray ["startLineNum"]
            put endLineNum into foundArray ["endLineNum"]
            put hkey_Construct (hName, hType, hierarchyObject) into foundArray ["foundHkey"]
            return foundArray
         end if
      end if
   end repeat
   return empty
end hkey_FoundArrayFromSearchHierarchy
