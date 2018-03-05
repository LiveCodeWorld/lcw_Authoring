script "model_Hkey"
--> MetaData
-
license: GPLv3
name: model_Hkey
type: model
version: 0.9


/*
A model for indexing handlers.
*/


--> Handler
-
function handler_IsComponent someHandler
   -- this uses regular expression (http://www.regextester.com/pregsyntax.html)
   -- may be faster way of checking
   put "--\s*component\s*:\s*true\b" into someReg
   put matchtext (someHandler, someReg) into someBoolean
   return someBoolean
end handler_IsComponent


--> Hkey | Help
-
function hkey_FetchHelp hKey
   put hkey_HelpFile (hKey, true) into someFile
   put script_FetchRaw (someFile) into someHelp
   return someHelp
end hkey_FetchHelp

command hkey_StoreHelp hKey, helpText
   put hkey_HelpFile (hKey, false) into someFile
   if helptext is empty then
      delete file someFile
   else
      put helpText into url ("binfile:" & someFile)
   end if
   return someFile
end hkey_StoreHelp


--> Script | scriptLine
-
function hkey_GetScriptLine hKey, pHandler
   switch
      case pHandler is not empty
         return line 1 of pHandler
      case the number of items of hKey = 2
         put library_FetchHandler (hKey) into pHandler
         return line 1 of pHandler
      case the number of items of hKey = 4
         put hkey_ExtractHandlerFromObject (hKey) into pHandler
         return line 1 of pHandler
   end switch
   return empty
end hkey_GetScriptLine

function hkey_ScriptLineNum hKey, someScript
   hkey_FindScriptLine hKey, someScript, scriptLine, lineNum
   return lineNum
end hkey_ScriptLineNum

function hkey_ScriptLine hKey, someScript
   hkey_FindScriptLine hKey, someScript, scriptLine, lineNum
   return scriptLine
end hkey_ScriptLine

function hkey_ListVersionNames hKey
   put hkey_ListShortVersionFolders (hKey) into shortFolders
   repeat for each line shortFolder in shortFolders
      put word 2 to -1 of shortFolder & CR after versionNames
   end repeat
   delete char -1 of versionNames
   return versionNames
end hkey_ListVersionNames


--> Hkey | MetaData | DotText
-
function hkey_GetDotText hKey, pVersionName
   put hkey_DotFile (hKey, pVersionName) into someFile
   get url ("file:" & someFile) into encodedArray
   return it
end hkey_GetDotText

command hkey_SetDotText hKey, dotText, pVersionName
   put hkey_DotFile (hKey, pVersionName) into someFile
   put dotText into url ("file:" & someFile)
end hkey_SetDotText


--> Hkey | MetaData | Image
-
function hkey_GetImage hKey, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   get url ("binfile:" & someFile)
   return it
end hkey_GetImage

command hkey_SetImage hKey, imageFile, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   put imageFile into url ("binfile:" & someFile)
end hkey_SetImage


--> hkey | Model | BackLinks
-
/*
Probably better done with a live database, rather than this cache approach.
*/

command hkey_AddBackLink backKey, hKey
   put hkey_GetBackLinks (hKey) into backLinks
   line_Add backKey, backLinks
   hkey_SetBackLinks hKey, backLinks
end hkey_AddBackLink

function hkey_GetBackLinks hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put overlayArray ["data"]["backLinks"] into backLinks
   return backLinks
end hkey_GetBackLinks

command hkey_SetBackLinks hKey, backLinks, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   if backLinks is empty then
      delete local overlayArray ["data"]["backLinks"]
   else
      put backLinks into overlayArray ["data"]["backLinks"]
   end if
   hkey_SetOverlayArray hKey, overlayArray, pOverlayName
   return the result
end hkey_SetBackLinks

command hkey_AddToBackLinks overlayData
   -- for each frontKey add the backKey to the backLinks
   put overlayData ["data"]["linkArray"] into hkeyArray
   repeat for each key backKey in hkeyArray
      put hkeyArray [backKey] into frontKeys
      repeat for each line frontKey in frontKeys
         set the cursor to busy
         put hkey_GetBackLinks (frontKey) into backLinks
         -- hkey_CheckBackLinks backLinks
         line_Add backKey, backLinks
         hkey_SetBackLinks frontKey, backLinks
      end repeat
   end repeat
end hkey_AddToBackLinks

command hkey_CheckBackLinks @backLinks
   -- line_Delete "backLinks", backLinks
   -- put empty into backLinks
   -- loop through the backLinks and check they are still current
end hkey_CheckBackLinks


--> hkey | Model | Deps
-
function hkey_FetchDeps hKey, pFetchHow  
   local hKeyArray
   hkey_RecurseCallArray hKey, hkeyArray, pFetchHow
   put array_AllNodes (hKeyArray) into allShortDeps
   put item 1 to 2 of hKey into shortKey
   line_Delete shortKey, allShortDeps
   return allShortDeps
end hkey_FetchDeps

-- function hkey_FetchFilteredDeps shortHKey
   return library_HkeyDeps (shortHKey)
   
   -- fetches all deps from link text files
   local hKeyArray
   hkey_RecurseCallArray shortHKey, hkeyArray, "filtered"
   put array_AllNodes (hKeyArray) into allShortDeps
   put item 1 to 2 of shortHKey into shortKey
   line_Delete shortKey, allShortDeps
   return allShortDeps
end hkey_FetchFilteredDeps

function hkey_FetchDepsFromLinkArray hKey, pReturnShortHkey
   put item 1 to 2 of hKey into shortHKey
   put hkey_GetLinkArray (shortHKey, "hierarchical") into hkeyDepArray
   return deps_FromHkeyArray (hKey, hkeyDepArray, pReturnShortHkey)
end hkey_FetchDepsFromLinkArray

function script_FetchDepsFromScriptArray hKey, pReturnShortHkey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the script_LinkArray of hObject into scriptLinkArray
   put hkeyArray_ExtractSubArray (hKey,scriptLinkArray) into hkeyLinkArray
   return deps_FromHkeyArray (hKey, hkeyLinkArray, pReturnShortHkey)
end script_FetchDepsFromScriptArray

function deps_FromHkeyArray hKey, hkeyDepArray, pReturnShortHkey
   put array_AllNodes (hkeyDepArray) into allHkeys
   sort allHkeys by item 1 of each
   repeat for each line depKey in allHkeys
      put item 1 to 2 of depKey into shortDepKey
      if shortDepKey =  item 1 to 2 of hKey then next repeat
      if pReturnShortHkey is not false then
         put shortDepKey & CR after hKeyDeps
      else
         put depKey & CR after hKeyDeps
      end if
   end repeat
   delete char -1 of hKeyDeps
   return hKeyDeps
end deps_FromHkeyArray

function hkeyArray_ShortNodes hkeyArray
   local indexArray
   repeat for each key hKey in hkeyArray
      put item 1 to 2 of hKey into shortHkey
      put empty into indexArray [shortHkey]
      put hkeyArray [hKey] into childHkeys
      repeat for each line childHkey in childHkeys
         put item 1 to 2 of childHkey into shortHkey
         put empty into indexArray [shortHkey]
      end repeat
   end repeat
   return keys (indexArray)
end hkeyArray_ShortNodes

function hkey_ExternalHkeysFromArray externalHkeyArray
   repeat for each key shortExternalCall in externalHkeyArray
      put externalHkeyArray [shortExternalCall] into callArray
      put line 1 of keys (callArray) into parentKey
      put callArray [parentKey] into externalHkey
      put externalHkey & CR after externalHkeys
   end repeat
   delete char -1 of externalHkeys
   return externalHkeys
end hkey_ExternalHkeysFromArray 

function hArray_FetchHkeyDeps hKey
   put item 3 of hKey into hObject
   if exists (hObject) is false then return false -- maybe it is a shortheky in a library?
   put the mainstack_WalkArray of hObject into mainstackHkeyWalkArray
   if mainstackHkeyWalkArray is not an array then return false
   put mainstackHkeyWalkArray ["hkeyArray"] into hkeyArray
   if mainstackHkeyWalkArray is not an array then return false
   put hkeyArray_ExtractSubArray (hKey, hkeyArray) into hkeySubArray
   
   put array_AllNodes (hkeySubArray) into hKeyDeps
   line_Delete hKey, hKeyDeps
   sort hKeyDeps by item 1 of each
   return hKeyDeps
end hArray_FetchHkeyDeps

function hkey_FetchLinkArray hKey, pFetchHow
   -- this handler is mainly to show the different ways of fetching hkeyLinkArray
   switch pFetchHow
      case "stored hkeyLinkArray"
         put hkey_GetLinkArray (hKey) into hkeyLinkArray
         return hkeyLinkArray
      case "stored script_LinkArray"
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put the script_LinkArray of hObject into scriptLinkArray
         put hkeyArray_ExtractSubArray (hKey,scriptLinkArray) into hkeyLinkArray
         return hkeyLinkArray
      case "from object"
         -- does not use hArray
         put hkey_ScriptDependencyArray (hKey) into hkeyLinkArray
         return hkeyLinkArray
      case "library_HkeyFolder()"
         -- mixture of hArray and walking
         put library_HkeyFolder (hKey) into hkeyLinkArray
         return hkeyLinkArray
      default  -- everywhere but fastest first
         put hkey_GetLinkArray (hKey) into hkeyLinkArray
         if hkeyLinkArray is an array then return hkeyLinkArray
         
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         if exists (hObject) is false then
            -- breakpoint
            return empty
         end if
         
         put the script_LinkArray of hObject into hkeyLinkArray
         if hkeyLinkArray is an array then return hkeyLinkArray
         
         put library_HkeyFolder (hKey) into hkeyLinkArray
         return hkeyLinkArray
   end switch
end hkey_FetchLinkArray


--> hkey | Model | Global
-
/*
A LinkArray is used to graph arrays. To do this LinkArrays provide a suite of tools that take complex keys and convert them into simple IDs,
and dictionaries to translate from these IDS to the orginal keys.
*/

function hkey_GetLinkArray hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put overlayArray ["data"]["linkArray"] into hkeyArray
   return hkeyArray
end hkey_GetLinkArray

command hkey_SetLinkArray hKey, hkeyArray, pOverlayName, pGraphStyle
   -- makes no sense to set hkeyArray without setting the rest of the derived arrays
   put library_HandlerFile (hKey, empty, false) into overlayFolder
   overlay_SetLinkArray overlayFolder, hkeyArray, pOverlayName, pGraphStyle
   put the result into overlayArray
   return overlayArray
end hkey_SetLinkArray

function hkey_GetGeometryArray hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put hFileArray ["data"]["geometry"] into geometryArray
   return geometryArray
end hkey_GetGeometryArray

command hkey_SetGeometryArray hKey, geometryArray, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put geometryArray into overlayArray ["data"]["geometry"]
   hkey_SetOverlayArray hKey, overlayArray, pOverlayName
end hkey_SetGeometryArray

command hkey_StripDefaultDotArray overlayArray
   put overlay_GetDefaultArray() into defaultArray
   overlayArray_StripDefaultProps overlayArray, defaultArray
end hkey_StripDefaultDotArray

command hkey_StripDefaultProps @overlayData
   repeat for each key graphName in overlayData
      put overlayData [graphName] into overlayArray
      overlayArray_StripDefaultProps overlayArray
      put overlayArray into overlayData [graphName]
   end repeat
end hkey_StripDefaultProps

command hkey_NormalizeGraphName @pOverlayName
   if pOverlayName is empty then
      put hkey_GetDefaultGraphName() into pOverlayName
   end if
end hkey_NormalizeGraphName

function hkey_GetDefaultGraphName
   put overlay_GetDefaultArray() into overlayDefaultArray
   put overlayArray_GetGraphProperty (overlayDefaultArray, "overlay_Name") into graphName
   return graphName
end hkey_GetDefaultGraphName


--> Hkey | Wrappers
-
command hKey_DeconstructStoredArray hKey, @hKeyCalls, @backLinks, @allCalls, pVersionName, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName, pVersionName) into overlayArray
   put overlayArray ["data"]["backLinks"] into backLinks
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdArray, dotClusterArray
   
   put linkArray [hKey] into hKeyCalls
   put array_AllNodes (linkArray) into allCalls
   sort allCalls
   line_Delete hKey, allCalls -- just in case
end hKey_DeconstructStoredArray
