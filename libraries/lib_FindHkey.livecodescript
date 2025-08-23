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
getprop hierarchy_ObjectAndBehaviors [pPretty]
   local objectHierarchy
   put pPretty is not false into pPretty
   put the long id of the target into tObject
   
   _AddObjectAndBehaviors objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_ObjectAndBehaviors

function hierarchy_Construct tObject, pPretty
   -- was "object_GetHierarchy"
   local objectHierarchy
   put the long id of tObject into tObject
   put pPretty is not false into pPretty
   
   put the hierarchy_ObjectAndBehaviors [pPretty] of tObject into objectHierarchy
   hierachy_AddStackObjects objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_Construct

command hierachy_AddStackObjects @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return false
   put tObject into objectOwner
   put empty into skipThisBackgroundID
   
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists (mainStackObject) then
               _AddObjectAndBehaviors objectHierarchy, mainStackObject, pPretty
            end if
            
            delete word 1 to 3 of objectOwner
            if exists (objectOwner) is false then exit repeat
            break
         case "card"
            -- previously added a card, so check for backgrounds
            put objectOwner into cardObject
            put the backgroundIDs of cardObject into bgIDs
            -- need to add in reverse to mirror message path
            repeat with bgNum = the number of lines of bgIDs down to 1
               put line bgNum of bgIDs into someID
               if someID = skipThisBackgroundID then next repeat
               put the long ID of bg ID someID of cardObject into backgroundObject
               _AddObjectAndBehaviors objectHierarchy, backgroundObject
            end repeat
            
            # Above a card must be a stack
            put objectOwner into stackObject
            delete word 1 to 4 of stackObject
            _AddObjectAndBehaviors objectHierarchy, stackObject
            
            exit repeat
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            --
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
      end switch
   end repeat
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierachy_AddStackObjects

private command _AddObjectAndBehaviors @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return empty
   
   if pPretty is not false then
      -- put the long id of tObject into tObject
      put CR & the name of tObject after objectHierarchy
   else
      put CR & revRuggedId (tObject) after objectHierarchy
   end if
   
   put the behavior_Objects of tObject into bObjects
   if bObjects is empty then return false
   put CR & bObjects after objectHierarchy
   return true
end _AddObjectAndBehaviors

command hierarchy_AddEnv @objectHierarchy
   put env_ScriptHierarchy (true) into externalObjects
   if externalObjects is empty then return false
   
   set the wholematches to true
   repeat for each line sObject in objectHierarchy
      put lineOffset (sObject, externalObjects) into lineNum
      delete line lineNum of externalObjects
   end repeat
   if externalObjects is empty then return false
   
   put CR & word 1 to -1 of externalObjects after objectHierarchy
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierarchy_AddEnv

getprop hkey_FindAll [shortHkey]
   if the module_Name of the target is empty then
      put the walk_Hierarchy of the target into sObjects
   else
      put the module_BehaviorHierarchy [true] of the target into sObjects
   end if
   
   # Search for Private and public handlers
   repeat for each line foundObject in sObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Either [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         put foundHkey & CR after foundHkeys
      end if
   end repeat
   delete char -1 of foundHkeys
   return foundHkeys  
end hkey_FindAll

getprop found_Hkey [shortHkey]
   # Private and non-private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into tObject
   --
   put the walk_Hierarchy of tObject into searchObjects
   put hkey_FindShortHkey (shortHkey, tObject, searchObjects) into foundHkey
   return foundHkey
end found_Hkey

getprop found_HandlerLine [shortHkey]
   put the long id of the target into targetObject
   put true into matchPrivate
   put stack_PathsToObjects (the stacksinUse) into externalObjects
   put hkey_FindHandlerLine (shortHkey, targetObject, externalObjects, matchPrivate) into hLine
   return hLine
end found_HandlerLine

function hkey_FindShortHkey shortHkey, pObject, pSearchObjects
   put word 1 to 2 of shortHkey into shortHkey
   
   # Make shortHkey public
   if char 1 of shortHkey = "P" then delete char 1 of shortHkey
   
   if exists (pObject) then
      # Search for private handlers
      put the hkey_Either [shortHkey] of pObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
      line_Delete pSearchObjects, pObject -- so we dont search it again later
   end if
   
   # Search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Or [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty  
end hkey_FindShortHkey

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

function hkey_FindPublicOrPrivate shortHkey, pSearchObjects
   # Search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Either [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty 
end hkey_FindPublicOrPrivate

function hkey_ListShort hKeys
   -- unique short hkeys
   repeat for each line hKey in hKeys
      put word 1 to 2 of hKey into shortHkey
      put empty into shortArray [shortHkey]
   end repeat
   put keys (shortArray) into shortHkeys
   sort shortHkeys
   return shortHkeys
end hkey_ListShort

              
--> Display | Find
-
command ask_FindHkey pShortHkey
   put ask_Question ("What handler do you want to search for?", pShortHkey, "Handler Search") into pShortHkey
   --
   display_FoundLibs pShortHkey
   put the result into displayView
   return displayView
end ask_FindHkey

command display_FoundLibs shortHkey
   put hkey_FindAllLibs (shortHkey) into libNames
   --
   display_Data libNames, shortHkey, "Found Libraries"
   put the result into displayView
   --
   display_SetInteractions displayView, "Hkey | Find", "mDoubleUp_FoundLib"
   return displayView
end display_FoundLibs

on mDoubleUp_FoundLib displayView, libName   
   put the title_Text of displayView into shortHkey
   put the name of stack libName into libObject
   put hKeyLine_AddObject (shortHkey, libObject) into hKey
   --
   hkey_Edit hKey
end mDoubleUp_FoundLib


--> Hkey | Find
-
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
