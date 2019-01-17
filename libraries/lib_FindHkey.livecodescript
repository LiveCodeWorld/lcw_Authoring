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


--> Working on
-
getprop found_HandlerLine [shortHkey]
   put the long id of the target into targetObject
   put hkey_FindHandlerLine (shortHkey, targetObject) into hLine
   return hLine
end found_HandlerLine


--> Props
-
getprop found_Hkey [shortHkeyLine]
   -- finds private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into targetObject
   put hkey_Find (shortHkeyLine, targetObject) into foundHkey
   return foundHkey
end found_Hkey

getprop hkeyLine_Either [hkeyLine]
   -- this finds private or public handlers in the target
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   
   if char 1 of hkeyLine = "P" then
      delete char 1 of hkeyLine -- "M"
   end if
   put htable_GetEither (hkeyLine, hTable, tObject) into foundHkey
   return foundHkey
end hkeyLine_Either

getprop hkeyLine_Exact [hkeyLine]
   -- this finds private or public handlers in the target
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   
   put htable_GetExact (hkeyLine, hTable, tObject) into foundHkey
   return foundHkey
end hkeyLine_Exact

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


--> Hkey | Find | New
-
/*
These newer handlers use the more flexible "getprop script_Hierarchy" and built on "revAvailableHandlers"
*/

function hkey_Find hKey, pObject, pExternalObjects
   -- should take any form of hKey
   -- finds the first occurence in teh default or specified script_Hierarchy
   -- needs fully testing
   put "Flexible" into pFindHow
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   if pObject is empty then put hObject into pObject -- in case we use a long hKey
   
   if exists (pObject) is false then -- hopefully "Missing"
      put env_ScriptHierarchy() into objectIndex
   else
      put the hkey_ScriptHierarchy [pExternalObjects] of pObject into objectIndex
   end if
   put hkeyLine_FindInObjects (hkeyLine, objectIndex, pFindHow) into foundHkey
   return foundHkey
end hkey_Find

function hkey_FindHandlerLine hkey, pObject, pExternalObjects
   hkeyLine_Normalize hkey
   
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

function hkeyLine_FindInObjects hkeyLine, objectIndex, pFindHow
   -- could speed up a bit by removing case condition
   local foundHkey
   
   repeat for each line foundObject in objectIndex
      put the revAvailableHandlers of foundObject into hTable
      switch pFindHow
         case "Flexible"
            put hTable_GetFlexible (hkeyLine, hTable, foundObject) into foundHkey
            break
         case "Either"
            put hTable_GetEither (hkeyLine, hTable, foundObject) into foundHkey
            break
         case "Exact"
         default
            put hTable_GetExact (hkeyLine, hTable, foundObject) into foundHkey
      end switch
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty   
end hkeyLine_FindInObjects

command hkey_ConvertShort @shortHkeys, pObject
   put hkey_FindLongCalls (shortHKeys, pObject) into shortHkeys
end hkey_ConvertShort

function hkey_FindLongCalls shortHKeys, pObject, pExternalObjects, pFindHow
   repeat for each line shortHKey in shortHKeys      
      put hkey_Find (shortHKey, pObject, pExternalObjects, pFindHow) into foundHkey
      if foundHkey is empty then
         put shortHKey && "Missing" into foundHkey
      end if
      put foundHkey & CR after longCalls
   end repeat
   delete char -1 of longCalls
   return longCalls
end hkey_FindLongCalls
