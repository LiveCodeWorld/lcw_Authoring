script "lib_DisplayHkeyDeps"
--> MetaData
-
license: GPLv3
name: lib_DisplayHkeyDeps
type: library
version: 0.2


--> Display | Hkey | Calls
-
command display_HandlerCalls hKey
   put hkey_FetchCalls (hKey) into shortCalls
   hkeyLine_Normalise hKey
   display_Lines shortCalls, hKey, "mDouble_EditShortHkey", "hkey_FetchCalls (hKey)"
end display_HandlerCalls

on mDouble_EditShortHkey indexView, shortCall
   put the title_Text of indexView into hKeyLine
   hKeyLine_Deconstruct hKeyLine, hName, hType, hObject
   put the handler_InHierarchy [shortCall] of hObject
end mDouble_EditShortHkey

command display_SpotlightHandler hkeyLine
   put spotlight_FindExportedHandler (hkeyLine) into foundFiles
   if foundFiles is empty then
      put hkeyLine
      answer "Could not find handler!"
      exit to top
   end if
   
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   set the itemdelimiter to slash
   put the number of items of lcwUserMetadataFolder into rootItemNum
   repeat for each line foundFile in foundFiles
      put item (rootItemNum + 1) of foundFile into mainStackName
      put item -2 of foundFile into shortHkey
      put hkeyLine_FromHandlerFile (foundFile) into hkeyLine
      put hkeyLine & CR after hkeyLines
   end repeat
   delete char -1 of hkeyLines
   
   put merge ("[[shortHkey]],spotlight_FindExportedHandler()") into someTitle
   display_HkeyLines hkeyLines, someTitle
   put foundFiles
end display_SpotlightHandler

command hkey_CreateAndDisplayDeps hkey, pProjectName, pClusterBoolean
   set the cursor to watch
   
   hkey_CreateDependencyGraph hkey, pProjectName, "hierarchical", pClusterBoolean
   put the result into imageFile
   
   display_HkeySVG hkey
   put the result into displayView
   return displayView
end hkey_CreateAndDisplayDeps

command hkey_RedrawAndDisplayDeps hkey, searchHierarchy, pClusterBoolean
   set the cursor to watch
   hkey_CreateSearchHierarchyGraph hkey, searchHierarchy, "hierarchical", pClusterBoolean
   
   put the result into imageFile
   display_HkeySVG hkey
   put the result into displayView
   return displayView
end hkey_RedrawAndDisplayDeps

command display_HkeySVG hkey
   put hkey_SvgFile (hKey) into svgFile
   
   put hkey into stackLabel
   if scriptEditor_PaneExists ("Deps") then
      display_ScriptEditorSvg svgFile
   else
      display_Svg svgFile, stackLabel
   end if
   put the result into displayView
   set the displayed_Hkey of displayView to hkey
   return displayView
end display_HkeySVG 


--> Deps
-
command hkey_CreateSearchHierarchyGraph hKey, searchHierarchy, pGraphStyle, pClusterBoolean
   put empty into overlayName -- defaults to pGraphStyle or "hierarchical"
   if pClusterBoolean is not false then 
      put empty into clusterRank
   else
      put "none" into clusterRank
   end if
   
   put hkey_SearchHierarchyDependencyArray (hKey, searchHierarchy, true) into hKeyArray
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   
   overlay_CreateGraph hkeyMetadataFolder, hkeyArray, overlayName, hKey, pGraphStyle, clusterRank, empty, "svg"
   
   put hkey_SvgFile (hKey, pGraphStyle) into svgFile
   return svgFile
end hkey_CreateSearchHierarchyGraph

function hkey_SearchHierarchyDependencyArray hKeys, searchHierarchy, pAllCalls
   -- from objects
   local hKeyLinkArray
   try  
      repeat for each line hKey in hkeys
         -- should this be hkey_GetHandler - anywhere from hierarchy ????
         put hkey_ExtractHandlerFromObject (hKey) into someHandler
         if pAllCalls is true then
            -- returns modern format
            put handler_ExtractCalls (someHandler) into shortCalls
         else
            put handler_ExtractFilteredCalls (someHandler) into shortCalls
         end if
         
         repeat for each line shortCall in shortCalls
            hkey_ObjectWalkSearchHierarchy shortCall, hKey, hKeyLinkArray, searchHierarchy, pAllCalls
         end repeat
      end repeat
      return hKeyLinkArray
   catch e -- script is locked
      return empty
   end try
end hkey_SearchHierarchyDependencyArray

command hkey_ObjectWalkSearchHierarchy shortCall, hKey, @hKeyLinkArray, searchHierarchy, pAllCalls
   -- same as "hkey_ObjectWalk" but uses fixed searchHierarchy
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   hkey_Deconstruct shortCall, callName, callType, emptyCallObject, emptyCallNum
   
   -- put hkey_FindAndAdd (shortCall, hObject, pFoundStackArray, pProjectName) into foundCall
   put hkey_FoundArrayFromSearchHierarchy (callName, callType, shortCall, hObject, searchHierarchy) into foundArray
   put foundArray ["foundHkey"] into foundCall
   
   -- this could be filtered out at the end
   -- if _foundUselessCall (foundCall) is true then return empty -- should do something else
   
   switch
      case foundCall is empty
         put merge ("Call '[[shortCall]]' for handler '[[hKey]]' is missing!") into someMessage
         lcw_Notify someMessage, true
         
         put hkey_Construct (callName, callType, "missing", 1) into foundCall
         array_AddToIndex foundCall, hKey, hKeyLinkArray
         return empty
      case foundCall is among the keys of hKeyLinkArray
         -- already indexed so no need to recurse
         return empty
   end switch
   
   -- add it to the array
   put merge ("Added [[foundCall]] to hKeyArray!") into someMessage
   lcw_Notify someMessage
   array_AddToIndex foundCall, hKey, hKeyLinkArray
   
   -- now lets repeat and recurse for each call found
   -- should this be hkey_GetHandler - anywhere from hierarchy ????
   put hkey_ExtractHandlerFromObject (foundCall) into callHandler
   if callHandler is empty then breakPoint
   
   if pAllCalls is true then
      put handler_ExtractCalls (callHandler) into shortCalls
   else
      put handler_ExtractFilteredCalls (callHandler) into shortCalls
   end if
   
   repeat for each line shortCall in shortCalls
      set the cursor to busy
      hkey_ObjectWalkSearchHierarchy shortCall, foundCall, hKeyLinkArray, searchHierarchy, pAllCalls
   end repeat
   return empty
end hkey_ObjectWalkSearchHierarchy

command hkey_CreateDependencyGraph hKey, pProjectName, pGraphStyle, pClusterBoolean
   put empty into overlayName -- defaults to pGraphStyle or "hierarchical"
   if pClusterBoolean is not false then 
      put empty into clusterRank
   else
      put "none" into clusterRank
   end if
   
   put hkey_DependencyArrayFromObjects (hKey, pProjectName, true) into hKeyArray
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   
   overlay_CreateGraph hkeyMetadataFolder, hkeyArray, overlayName, hKey, pGraphStyle, clusterRank, empty, "svg"
   -- put the result into overlayArray
   -- put overlayArray_GetImageFile (overlayArray, hkeyMetadataFolder) into imageFile
   
   put hkey_SvgFile (hKey, pGraphStyle) into svgFile
   return svgFile
end hkey_CreateDependencyGraph

function hkey_DependencyArrayFromObjects hKeys, pProjectName, pAllCalls
   local hKeyLinkArray, pFoundStackArray
   try  
      repeat for each line hKey in hkeys
         -- should this be hkey_GetHandler - anywhere from hierarchy ????
         put hkey_ExtractHandlerFromObject (hKey) into someHandler
         if pAllCalls is true then
            -- returns modern format
            put handler_ExtractCalls (someHandler) into shortCalls
         else
            put handler_ExtractFilteredCalls (someHandler) into shortCalls
         end if
         
         repeat for each line shortCall in shortCalls
            hkey_ObjectWalk shortCall, hKey, hKeyLinkArray, pProjectName, pAllCalls, pFoundStackArray
         end repeat
      end repeat
      return hKeyLinkArray
   catch e -- script is locked
      return empty
   end try
end hkey_DependencyArrayFromObjects

command hkey_ObjectWalk shortCall, hKey, @hKeyLinkArray, pProjectName, pAllCalls, pFoundStackArray
   -- new version that incrementally adds stacks to search using "hkey_FindAndAdd"
   -- see "lib_HarrayWalk"
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   hkey_Deconstruct shortCall, callName, callType, emptyCallObject, emptyCallNum
   
   put hkey_FindAndAdd (shortCall, hObject, pFoundStackArray, pProjectName) into foundCall
   
   -- this could be filtered out at the end
   -- if _foundUselessCall (foundCall) is true then return empty -- should do something else
   
   switch
      case foundCall is empty
         put merge ("Call '[[shortCall]]' for handler '[[hKey]]' is missing!") into someMessage
         lcw_Notify someMessage, true
         
         put hkey_Construct (callName, callType, "missing", 1) into foundCall
         array_AddToIndex foundCall, hKey, hKeyLinkArray
         return empty
      case foundCall is among the keys of hKeyLinkArray
         -- already indexed so no need to recurse
         return empty
   end switch
   
   -- add it to the array
   put merge ("Added [[foundCall]] to hKeyArray!") into someMessage
   lcw_Notify someMessage
   array_AddToIndex foundCall, hKey, hKeyLinkArray
   
   -- now lets repeat and recurse for each call found
   -- should this be hkey_GetHandler - anywhere from hierarchy ????
   put hkey_ExtractHandlerFromObject (foundCall) into callHandler
   if callHandler is empty then breakPoint
   
   if pAllCalls is true then
      put handler_ExtractCalls (callHandler) into shortCalls
   else
      put handler_ExtractFilteredCalls (callHandler) into shortCalls
   end if
   
   repeat for each line shortCall in shortCalls
      set the cursor to busy
      hkey_ObjectWalk shortCall, foundCall, hKeyLinkArray, pProjectName, pAllCalls, pFoundStackArray
   end repeat
   return empty
end hkey_ObjectWalk
