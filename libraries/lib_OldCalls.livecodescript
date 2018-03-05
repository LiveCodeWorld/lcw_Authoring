script "lib_OldCalls"
--> MetaData
-
license: GPLv3
name: lib_OldCalls
type: library
version: 0.1


--> Old Mixed | Hkey | Deps
-
function hkey_ExtractShortCalls hKey
   put hArray_GetHandler (hKey) into callHandler
   put handler_ExtractCalls (callHandler) into shortCalls
   return shortCalls
end hkey_ExtractShortCalls

function script_ExtractSubGraphArray shortHkey, scriptHkey, pSetName, pTestExceptions
   put hkey_GetLinkArray (scriptHkey) into scriptHkeyArray
   put hkeyArray_ExtractSubArray (shortHkey, hkeyArray) into hKeySubGraphArray
   return hKeySubGraphArray
end script_ExtractSubGraphArray

function hkey_ConstructShortKeyArray hKeys
   repeat for each line hKey in hKeys
      hkey_Deconstruct hKey, hName, hType, hObject, hNum
      put hName,hType into shortHkey
      put empty into shortHkeyArray [shortHkey][hKey]
   end repeat
   return shortHkeyArray
end hkey_ConstructShortKeyArray


getprop script_IsGlobal [hKey]
   -- should the handlers in this script be exported by default into the hkey handler library?
   -- place a "getprop script_IsGlobal" in an object if you want to override the default behavior below
   put the uRIP ["type"] of the target into scriptType
   switch
      case scriptType contains "library"
         return true
      case scriptType contains "model"
         return true
      case scriptType contains "behavior"
         return true
      case scriptType contains "front script"
         return true
      case scriptType contains "backscript"
         return true
      default
         return false
   end switch
end script_IsGlobal

command hkey_StoreCallsAndHandler hkey, someHandler, hKeyCalls
   /*
   Used by a number of hArray walk scripts
   For now, not storing anything (by default), other than handlers in a uRip marked library
   */
   hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
   
   if the script_IsGlobal [hKey] of scriptObject is true then
      hkey_StoreHandler hKey, someHandler
      hkey_StoreCalls hKey, hKeyCalls
      return true
   else
      put "Not stored" && hKey into someMessage
      lcw_Notify someMessage
      return false
   end if
end hkey_StoreCallsAndHandler


--> hkey | overlaydata | hkeyArray | Model
-
function hkey_GetOverlayArray hKey, pOverlayName
   put hkey_FetchOverlayData (hKey) into overlayData
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName] into overlayArray
   return overlayArray
end hkey_GetOverlayArray

command hkey_SetOverlayArray hKey, overlayArray, pOverlayName
   hkey_StripDefaultDotArray overlayArray
   
   put hkey_FetchOverlayData (hKey) into overlayData
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayArray into overlayData [pOverlayName]
   hkey_SaveOverlayData hKey, overlayData
end hkey_SetOverlayArray


--> hkey | overlaydata | Metadata | Model
-
function hkey_GetMetadataArray hKey
   put hkey_FetchOverlayData (hKey) into overlayData
   put overlayData ["metadata"] into metadataArray
   return metadataArray
end hkey_GetMetadataArray

command hkey_SetMetadataArray hKey, metadataArray
   put hkey_FetchOverlayData (hKey) into overlayData
   put metadataArray into overlayData ["metadata"]
   hkey_SaveOverlayData hKey, overlayData
   return overlayData
end hkey_SetMetadataArray


--> Handler | List
-
function handler_ListExportedShortHkeys stackName
   put handler_ListShortExportedFolders (stackName) into hkeyFolders
   set the itemdelimiter to "_"
   repeat for each line hkeyFolder in hkeyFolders
      put item -1 of hkeyFolder into hType
      delete item -1 of hkeyFolder
      put hkeyFolder,hType into shortHkey
      put shortHkey & CR after shortHkeys
   end repeat
   delete char -1 of shortHkeys
   return shortHkeys
end handler_ListExportedShortHkeys

function handler_ListShortExportedFolders stackName
   put the handler_Folder of stack stackName into handlerFolder
   put the defaultfolder into oDefault
   set the defaultfolder to handlerFolder
   put the folders into hkeyFolders
   filter hkeyFolders without ".*"
   set the defaultfolder to oDefault
   return hkeyFolders
end handler_ListShortExportedFolders


--> hKey | Find  | hArray | Old ???
-
getprop hkey_FindInFullHierarchy [shortHkey]
   -- was "script_FindInFullHierarchy"
   /*
   It includes front scripts and the object itself should it contain the call.
   Currently it ignores Rev development environment.
   */
   if the number of items of shortHkey = 2 then
      put item 1 of shortHkey into handlerName
      put item 2 of shortHkey into handlerType
      put the long id of the target into scriptObject
      put hkey_Construct (handlerName, handlerType, scriptObject) into hKey
   else
      put shortHkey into hKey
   end if
   
   put the script_Hierarchy of the target into scriptHierarchy
   put hkey_SearchObjectHierarchy (hKey, scriptHierarchy) into foundHkey
   return foundHkey
end hkey_FindInFullHierarchy

function hkey_FindAndIndex hName, hType, hObject, pSetName, pNoLibraryBehaviors
   put the script_Hierarchy [pSetName] of hObject into scriptHierarchy
   
   if exists (hObject) is false then
      put hObject && "does not exist! Exiting..." into someMessage
      lcw_Notify someMessage, true
      return empty
   end if
   
   put hName,hType into shortHKey
   
   repeat with lineNum = (the number of lines of scriptHierarchy) down to 1
      set the cursor to busy
      put line lineNum of scriptHierarchy into testObject
      -- lcw_Notify testObject, true
      
      if exists (testObject) is false then
         put testObject && "does not exist! Skipping..." into someMessage
         lcw_Notify someMessage
         next repeat
      end if
      
      switch the hArray_IsCurrent of testObject 
         case empty
            put testObject && "is locked... skipping..." into someMessage
            lcw_Notify someMessage
            next repeat
         case false
            -- add to global index so we can search
            object_AddToGlobalArray testObject
            break
         default -- case true
            -- keep on trucking
      end switch
      
      if the long id of testObject = the long id of hObject then
         -- allow private handlers (as it is where the shortHkey is called from )
         if the hArray_HkeyPresent [shortHKey] of testObject is false then next repeat
         put hkey_Construct (hName, hType, testObject) into foundHkey
         return foundHkey
      else
         -- Don't allow private handlers (not where the shortHkey is called from)
         if the hArray_PublicKeyPresent [shortHKey] of testObject is false then next repeat
         put hkey_Construct (hName, hType, testObject) into foundHkey
         return foundHkey 
      end if
   end repeat
   
   -- gone through every object in hierarchy
   return empty 
end hkey_FindAndIndex

command hkey_FastFindHandlerAndKey hName, hType, hObject, @foundHkey, @foundHandler, pSetName
   put the script_Hierarchy [pSetName] of hObject into scriptHierarchy
   hkey_AddDevelopmentHierarchy scriptHierarchy, pSetName, hObject
   
   if exists (hObject) is false then
      put hObject && "does not exist! Exiting..." into someMessage
      lcw_Notify someMessage, true
      return empty
   end if
   
   put hName,hType into shortHKey
   
   repeat with lineNum = (the number of lines of scriptHierarchy) down to 1
      set the cursor to busy
      put line lineNum of scriptHierarchy into testObject
      -- put testObject
      
      if exists (testObject) is false then
         put testObject && "does not exist! Skipping..." into someMessage
         lcw_Notify someMessage, true
         next repeat
      end if
      
      switch the hArray_IsCurrent of testObject 
         case empty
            put testObject && "is locked... skipping..." into someMessage
            lcw_Notify someMessage
            next repeat
         case false 
            object_AddToGlobalArray testObject
            break
         default -- case true
            -- keep on trucking
      end switch
      
      if the long id of testObject = the long id of hObject then
         -- allow private handlers (as it is where the shortHkey is called from )
         
         if the hArray_HkeyPresent [shortHKey] of testObject is false then next repeat
         
         put hkey_Construct (hName, hType, testObject) into foundHkey
         put library_FetchHandler (foundHkey) into foundHandler
         return hKey
      else
         -- Don't allow private handlers (not where the shortHkey is called from)
         
         if the hArray_PublicKeyPresent [shortHKey] of testObject is false then next repeat
         
         put hkey_Construct (hName, hType, testObject) into foundHkey
         put library_FetchHandler (foundHkey) into foundHandler
         return hKey 
      end if
   end repeat
   
   -- gone through every object in hierarchy
   put empty into foundHkey
   put empty into foundHandler
   return empty 
end hkey_FastFindHandlerAndKey

function hkey_SearchObjectHierarchy hKey, scriptHierarchy
   -- was "script_SearchObjectHierarchy"
   /*
   This script finds where a handler call is in the hierarchy.
   It returns multiple objects if the handler is passed and also intercepted further up the hierarchy.
   
   It does not use any caching at the moment but looks directly at the script.
   */
   hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
   hkey_FindHandlerInHierarchy handlerName, handlerType, scriptObject, scriptHierarchy, foundHKey, callHandler
   
   hkey_Deconstruct foundHKey, foundHandlerName, foundHandlerType, foundScriptObject, handlerNum
   return foundScriptObject
end hkey_SearchObjectHierarchy

function hkey_FindAndExtractCalls hKey, pEnvironmentFilter, pHkeyArray, pScriptObject
   local foundHKey, foundHandler
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if pScriptObject is empty then put hObject into pScriptObject
   
   put the script_Hierarchy [pEnvironmentFilter] of pScriptObject into scriptHierarchy
   hkey_FindHandlerInHierarchy hName, hType, pScriptObject, scriptHierarchy, foundHKey, foundHandler
   hkey_Deconstruct foundHkey, foundName, foundType, foundObject, foundNum
   
   -- save unecessary indexing work
   if foundHkey is among the lines of keys (pHkeyArray) then
      lcw_Notify merge ("Already indexed '[[hkey]]'. Lets not index it again please :)")
      return empty
   end if
   
   -- get handler calls
   -- this should be short calls for simplicity and speed of recursion
   
   put library_FetchHandler (foundHkey) into storedHandler
   if foundHandler = storedHandler and pForceSearch is not true then
      -- already stored, faster to fetch stored calls
      put hkey_FetchCalls (foundHkey) into handlerCalls
   else
      put the script_Hierarchy [pEnvironmentFilter] of foundObject into foundHierarchy
      put script_ParseHandlerForCalls (foundHandler, foundHierarchy, foundObject) into handlerCalls
      hkey_StoreCallsAndHandler foundHkey, foundHandler, handlerCalls
   end if
   return handlerCalls
end hkey_FindAndExtractCalls

command hkey_FindHandlerInHierarchy handlerName, handlerType, scriptObject, scriptHierarchy, @hKey, @foundHandler, pNotPrivate
   -- this is the step that takes time
   -- looks for first hKey in scriptHierarchy
   local startHandler, endHandler
   
   if exists (scriptObject) is false then
      put scriptObject && "does not exist! Exiting..." into someMessage
      lcw_Notify someMessage, true
      return empty
   end if
   
   --  and from now on search rest of hierarchy only for public handler
   put handlerName,handlerType into shortHKey
   repeat with lineNum = (the number of lines of scriptHierarchy) down to 1
      set the cursor to busy
      put empty into hKey
      put line lineNum of scriptHierarchy into someObject
      
      if exists (someObject) is false then
         put someObject && "does not exist! Skipping..." into someMessage
         lcw_Notify someMessage, true
         next repeat
      end if
      
      if the long id of someObject = the long id of scriptObject then
         -- as it is the script object where the shortHkey is called from 
         -- allow private handlers
         
         if the hArray_IsCurrent of someObject is true then
            if the hArray_HkeyPresent [hKey] of someObject is true then
               put hkey_Construct (handlerName, handlerType, someObject) into hKey
               put library_FetchHandler (hKey) into foundHandler
               return hKey
            end if         
         else
            -- not properly indexed, so do it manually.
            try
               put the script of someObject into someScript
               
               -- don't think we need to have this option 
               -- change to look for either. Forget whether handlerType = "p"
               if char 1 of handlerType = "p" then
                  put handlerType into privateHandlerType
                  
                  put handlerName,privateHandlerType into shortHKey
                  hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
                  put the result into foundHandler
                  
                  if foundHandler is not empty then
                     -- found private handler => construct and return hKey
                     put hkey_Construct (handlerName, privateHandlerType, someObject) into hKey
                     return hKey
                  else
                     -- no point in searching hierarchy for private handlers
                     return empty
                  end if
               else
                  -- should find first regardless of public or private
                  -- for now finds private first
                  put "p" & handlerType into privateHandlerType
                  
                  put handlerName,privateHandlerType into shortHKey
                  hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
                  put the result into foundHandler
                  
                  if foundHandler is not empty then
                     -- found private handler => construct and return hKey
                     put hkey_Construct (handlerName, privateHandlerType, someObject) into hKey
                     return hKey
                  else
                     -- lets try public
                     put handlerName,handlerType into shortHKey
                     hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
                     put the result into foundHandler
                     if foundHandler is not empty then
                        -- found public handler => construct and return hKey
                        put hkey_Construct (handlerName, handlerType, someObject) into hKey
                        return hKey
                     end if
                  end if
                  
               end if
            catch someError
               -- locked
               put "Did not search" && the mobile_Name of someObject && "as it's script is locked!" into someMessage
               lcw_Notify someMessage, true
               next repeat
            end try
         end if
      else
         -- not the script object where the shortHkey is called from
         -- don't allow private handlers
         
         if the hArray_IsCurrent of someObject is true then
            if the hArray_PublicHkeyPresent [hKey] of someObject is true then
               put hkey_Construct (handlerName, handlerType, someObject) into hKey
               put library_FetchHandler (hKey) into foundHandler
               return hKey
            end if         
         else
            try
               put the script of someObject into someScript
            catch someError
               -- locked
               next repeat
            end try
            
            hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
            put the result into foundHandler
            if foundHandler is empty then next repeat
            if script_HandlerContainsPass (handlerName, foundHandler) is false then
               -- found => construct and return hKey
               put hkey_Construct (handlerName, handlerType, someObject) into hKey
               return hKey
            end if
         end if
         
      end if
   end repeat
   
   -- gone through every object in hierarchy
   return empty
end hkey_FindHandlerInHierarchy

function hkey_Search hKey, pSearchHow 
   local pSetName
   
   switch pSearchHow
      case "not hdb"
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put hkey_FindAndIndex (hName, hType, hObject, pSetName) into foundHkey
         return foundHkey
      case "not hierarchy"
         put hArray_SimpleSearch (hKey) into foundHkey
         return foundHkey
      default
         put item 1 to 2 of hKey into shortHKey
         put item 3 of hKey into pScriptObject
         if exists (pScriptObject) is false then
            put hArray_FindHkey (shortHkey) into foundHkey
            
            if foundHkey is empty then
               -- should use rev search
               hkey_Deconstruct hKey, hName, hType, hObject, hNum
               put the long id of the target into hObject -- hack
               put hkey_FindAndIndex (hName, hType, hObject, pSetName) into foundHkey
               return foundHkey
            else
               return foundHkey
            end if
         else
            put hArray_FindHkeyInHierarchy (shortHKey, pScriptObject) into foundHkey
            return foundHkey
         end if
   end switch
end hkey_Search

function hArray_SimpleSearch hKey, pHandlerHash
   put hArray_GetFoundHkeyArray (hKey) into hkeyArray
   if pHandlerHash is empty then
      -- let's get the hKey with the shortest object reference
      put keys (hkeyArray) into foundHKeys
      sort numeric lines of foundHKeys by the number of chars of item 3 of each
      put line 1 of foundHKeys into foundHKey
      return foundHKey
   else
      repeat for each key foundHKey in hkeyArray
         if hkeyArray [hKey]["handlerHash"] is pHandlerHash then
            return foundHKey
         end if
      end repeat
      return empty
   end if
end hArray_SimpleSearch

