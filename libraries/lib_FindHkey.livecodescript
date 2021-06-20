script "lib_FindHkey"
--> MetaData
-
license: GPLv3
name: lib_FindHkey
type: library
version: 0.2

/*
See also "model_ScriptHierarchy"

This library has a number of old and new ways of finding handlers.
It should be rationalised to do this as fast as possible.

See also model_HkeyLine
See also hkey_GetPlace(hTableLine) in model_Place for memory resident array search of index
Consider using a database.
*/

--> Display | Find
-
on mDoubleUp_FoundLib displayView, libName   
   put the title_Text of displayView into shortHkey
   put the name of stack libName into libObject
   put hKeyLine_AddObject (shortHkey, libObject) into hKey
   --
   hkey_Edit hKey
end mDoubleUp_FoundLib

command display_FoundLibs shortHkey
   put hkey_FindAllLibs (shortHkey) into libNames
   --
   display_Data libNames, shortHkey, "Found Libraries"
   put the result into displayView
   --
   display_SetInteractions displayView, "Hkey | Find", "mDoubleUp_FoundLib"
   return displayView
end display_FoundLibs


--> Props
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

getprop found_HandlerLine [shortHkey]
   put the long id of the target into targetObject
   put true into matchPrivate
   put stack_PathsToObjects (the stacksinUse) into externalObjects
   put hkey_FindHandlerLine (shortHkey, targetObject, externalObjects, matchPrivate) into hLine
   return hLine
end found_HandlerLine

getprop found_Hkey [shortHkey]
   -- finds private and non-private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into tObject
   --
   -- put the hkey_ScriptHierarchy of tObject into searchObjects
   put the walk_Hierarchy of tObject into searchObjects
   put hkey_FindShortHkey (shortHkey, tObject, searchObjects) into foundHkey
   return foundHkey
end found_Hkey


--> Hkey | Find
-
function hkey_Find hKey, pSearchObjects
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   
   if pSearchObjects is empty then
      if exists (hObject) then
         put the walk_Hierarchy of hObject into pSearchObjects
      else
         put env_ScriptHierarchy (true) into pSearchObjects
      end if
   end if
   --
   put hkey_FindShortHkey (shortHkey, hObject, pSearchObjects) into foundHkey
   return foundHkey
end hkey_Find

function hkey_FindShortHkey shortHkey, pObject, pSearchObjects
   put word 1 to 2 of shortHkey into shortHkey
   
   -- let's make shortHkey public
   if char 1 of shortHkey = "P" then delete char 1 of shortHkey
   
   if exists (pObject) then
      -- search for private handlers in pObject if it is provided
      put the hkey_Either [shortHkey] of pObject into foundHkey
      if foundHkey is not empty then return foundHkey
      
      -- so we dont search it again later
      line_Delete pSearchObjects, pObject
   end if
   
   -- now search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      put the hkey_Exact [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty  
end hkey_FindShortHkey

function hkey_PublicFind shortHKey, pSearchObjectHierarchy
   if pSearchObjectHierarchy is empty then
      -- put stack_PathsToObjects (the stacksinUse) into pSearchObjectHierarchy
      put env_ScriptHierarchy (true) into pSearchObjectHierarchy
      put hkeyLine_FindExact (shortHKey, pSearchObjectHierarchy) into foundHkey
   else
      -- for first line of hierarchy we can find private
      put line 1 of pSearchObjectHierarchy into tObject
      delete line 1 of pSearchObjectHierarchy
      put hKeyLine_AddObject (shortHkey, tObject) into hkeyLine
      --
      put the hkey_Either [hkeyLine] of tObject into foundHkey
      if foundHkey is not empty then return foundHkey
      
      put hkeyLine_FindExact (hkeyLine, pSearchObjectHierarchy) into foundHkey
   end if
   return foundHkey
end hkey_PublicFind


--> Hkey | Find
-
function hkey_FindAllLibs shortHkey
   -- simple and fast
   put the stacksInUse into stackNames
   --
   local startLineNum, endLineNum
   repeat for each line libName in stackNames
      put the revAvailableHandlers of stack libName into hTable
      htable_ExactLineOffsets shortHkey, hTable, startLineNum, endLineNum
      if the result is false then next repeat
      
      put libName & CR after foundStackNames
   end repeat
   delete char -1 of foundStackNames
   return foundStackNames
end hkey_FindAllLibs

function hkey_FindObjects shortHKey, pSearchObjectHierarchy
   -- only public
   if pSearchObjectHierarchy is empty then
      put env_ScriptHierarchy (true) into pSearchObjectHierarchy
   end if
   
   repeat for each line libObject in pSearchObjectHierarchy
      set the cursor to busy
      if exists (libObject) is false then next repeat
      
      put the revAvailableHandlers of libObject into hTable
      put hTable_GetExact (shortHkey, hTable, libObject) into foundHkey
      if foundHkey is empty then next repeat
      
      put libObject & CR after foundObjects
   end repeat
   delete char -1 of foundObjects
   return foundObjects
end hkey_FindObjects

function hkeyLine_FindExact hkeyLine, searchObjectHierarchy
   repeat for each line foundObject in searchObjectHierarchy
      if exists (foundObject) is false then next repeat
      
      put the revAvailableHandlers of foundObject into hTable
      put hTable_GetExact (hkeyLine, hTable, foundObject) into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty   
end hkeyLine_FindExact

function hkey_GetFoundArray shortHkeys, pSearchObjectHierarchy
   put pSearchObjectHierarchy into foundArray ["meta"]["search hierarchy"]
   --
   repeat for each line shortHkey in shortHkeys
      put hkey_PublicFind (shortHkey, pSearchObjectHierarchy) into foundHkey
      --
      switch
         case foundHkey is empty and pSearchObjectHierarchy is empty
            put empty into foundArray ["missing"]["nowhere"][shortHkey]
            break
         case foundHkey is empty
            put hkey_FindInUsed (shortHkey) into foundHkey
            if foundHkey is empty then
               put empty into foundArray ["missing"]["nowhere"][shortHkey]
            else
               hkeyLine_Deconstruct foundHkey, fName, fType, fObject
               put foundHkey into foundArray ["missing"][fObject][shortHkey]
            end if
            break
         default
            hkeyLine_Deconstruct foundHkey, fName, fType, fObject
            put shortHkey into foundArray ["object"][fObject][foundHkey]
      end switch
   end repeat
   return foundArray
end hkey_GetFoundArray


--> Hkey | Find | New
-
/*
These newer handlers use the more flexible "getprop script_Hierarchy" and built on "revAvailableHandlers"
*/

function hkey_FindMissing hKeys
   hkey_SetFound hKeys, foundHkeys, stillMissing
   return foundHkeys
end hkey_FindMissing

command hkey_SetFound hKeys, @foundHkeys, @stillMissing
   repeat for each line hKey in hKeys
      put hkey_FindShortHkey (hKey) into foundHkey
      if foundHkey is empty then
         put hKey & CR after stillMissing
      else
         put foundHkey & CR after foundHkeys
      end if
   end repeat
   delete char -1 of foundHkeys
   delete char -1 of stillMissing
end hkey_SetFound

function hkey_FindHandlerLine hkey, pObject, pExternalObjects, pMatchPrivate
   hkey_Normalize hkey
   
   local startLineNum, endLineNum
   if pObject is empty then
      put env_ScriptHierarchy() into objectIndex
   else
      put the hkey_ScriptHierarchy [pExternalObjects] of pObject into objectIndex
   end if
   
   repeat for each line foundObject in objectIndex
      put the revAvailableHandlers of foundObject into hTable
      hTable_FlexibleLineOffsets hkey, hTable, startLineNum, endLineNum, pMatchPrivate
      if the result is false then next repeat
      
      get the script of foundObject
      put word 1 to -1 of line startLineNum of it into hLine
      return hLine
   end repeat
   return empty   
end hkey_FindHandlerLine

command hkey_ConvertShort @shortHkeys, pObject
   put hkey_FindLongCalls (shortHKeys, pObject) into shortHkeys
end hkey_ConvertShort

function hkey_FindLongCalls shortHKeys, pObject, pExternalObjects, pFindHow
   repeat for each line shortHKey in shortHKeys      
      put hkey_FindShortHkey (shortHKey, pObject, pExternalObjects, pFindHow) into foundHkey
      if foundHkey is empty then
         put shortHKey && "Missing" into foundHkey
      end if
      put foundHkey & CR after longCalls
   end repeat
   delete char -1 of longCalls
   return longCalls
end hkey_FindLongCalls
