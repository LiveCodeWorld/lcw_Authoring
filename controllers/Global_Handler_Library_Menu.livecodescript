script "Global_Handler_Library_Menu"
--> MetaData
-
license: GPLv3
name: Global_Handler_Library_Menu
type: controller
version: 0.1


--> Deps
-
/*
Sort these and see if there a newer versions.
Most of these handlers should be deprecated.
*/

--> Menu | Init
-
getprop disabled_DisplayProjectDeps [hKey]
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   if projectName is empty then
      return true
   else
      return false
   end if
end disabled_DisplayProjectDeps

getprop disabled_RevealHandlerFile [hkey]
   put hkey_HandlerFile (hkey) into handlerFile
   if there is a file handlerFile then
      return false
   else
      return true
   end if
end disabled_RevealHandlerFile

command library_AddHkey hKey, pHandler, pForceAdd
   -- these library handlers seem old. Exported the tmporarily to handler formlder in documents.
   
   if pHandler is empty then
      put hkey_ExtractHandlerFromObject (hKey) into pHandler
   end if
   if word 1 of pHandler = "private" then delete word 1 of pHandler
   put library_FetchHandler (hKey) into libraryHandler
   
   put libraryHandler = pHandler into isExported
   if (isExported is true and pForceAdd is not true) then return false
   
   put item 1 to 2 of hKey into shortHKey
   library_StoreHandler shortHKey, pHandler
   
   -- sure this could be much faster !
   put handler_ConstructCallArray (pHandler) into handlerMetadata
   
   put handlerMetadata ["sha1"] into handlerHash
   -- put sha1_Hash (someHandler) into handlerHash
   
   hkey_AddToKeyWordArray handlerMetadata, hKey, handlerHash
   
   put handlerMetadata ["hKeyCalls"] into hKeyCalls
   hkey_StoreCalls shortHKey, hKeyCalls
   
   put library_FetchHandlerDatabaseArray () into hkeyData
   put hkeyData [shortHKey] into shortHkeyArray
   union handlerMetadata with shortHkeyArray
   put handlerMetadata into hkeyData [shortHKey]
   library_StoreHandlerDatabaseArray hKeyData
   
   return shortHkeyArray -- was returning hKeyData
end library_AddHkey

command library_DeleteHkey hKey
   put library_HkeyToPublicShortHkey (hKey) into shortHkey
   
   put library_FetchHandlerDatabaseArray () into hkeyData
   delete variable hkeyData [shortHKey]
   library_StoreHandlerDatabaseArray hkeyData
   
   hkey_DeleteFolder shortHKey
end library_DeleteHkey

-- command hkey_AddHandlerFromObject shortHKey, somePlace
-- not used
put the script_Handler [shortHKey] of somePlace into otherHandler
library_AddHkey shortHkey, otherHandler

put hkey_IsInLibrary (shortHkey) into someBoolean
if someBoolean is true then
   lcw_Notify merge ("Exported handler 'shortHkey', and added it to the hkey library array!")
else
   lcw_Notify merge ("Failed to add handler 'shortHkey' to the hkey library array!")
end if
end hkey_AddHandlerFromObject

command hkey_Export hKey, pHandler
   -- exports basic info (the handler and the short hKey calls) from an objects script
   if pHandler is empty then
      put item 3 of hKey into hObject
      if exists (hObject) is false then
         put library_FetchHandler (hKey) into pHandler
      else
         put the script_Handler [hKey] of hObject into pHandler
      end if
   end if
   if pHandler is empty then return empty
   
   library_AddHkey hKey, pHandler
   put the result into hKeyData
   return hKeyData
end hkey_Export

function hkey_ExportStatus hKey, pHandlerScript
   breakpoint
   put hkey_ExtractHandlerFromObject (hKey) into objectHandler
   if pHandlerScript is empty then
      put library_FetchHandler (hKey) into fileHandler
   else
      put script_ExtractHandler (hKey, pHandlerScript) into fileHandler
   end if
   
   switch
      case objectHandler = fileHandler
         return "ok"
      case objectHandler is not empty and fileHandler is not empty
         return "different"
      case fileHandler = empty
         return "no file"
      case objectHandler = empty
         return "no object script"
   end switch
end hkey_ExportStatus

function hkey_ExportStatus hKey, pHandlerScript
   put hkey_ExtractHandlerFromObject (hKey) into objectHandler
   if pHandlerScript is empty then
      put library_FetchHandler (hKey) into fileHandler
   else
      put script_ExtractHandler (hKey, pHandlerScript) into fileHandler
   end if
   
   switch
      case objectHandler = fileHandler
         return "ok"
      case objectHandler is not empty and fileHandler is not empty
         return "different"
      case fileHandler = empty
         return "no file"
      case objectHandler = empty
         return "no object script"
   end switch
end hkey_ExportStatus


--> Global | Handler | Library | Menu
-
on menu_HkeyLinkArray hKey
   put hkey_GetLinkArray (hKey) into hkeyLinkArray
   display_Array hkeyLinkArray, "hkey_GetLinkArray (hKey)"
end menu_HkeyLinkArray

on menu_HkeyOverlayData hKey
   put hkey_FetchOverlayData (hKey) into overlayData
   display_Array overlayData, "hkey_FetchOverlayData (hKey)"
   
   /*
   -- not working
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the overlay_Folder of hObject into overlayFolder
   display_OverlayData overlayFolder
   */
end menu_HkeyOverlayData

on menu_HkeyDepArray hKey
   -- reads "hkey_FetchOverlayData" and displays stuff from there
   display_HkeyDepArray hKey
end menu_HkeyDepArray

on menu_DisplayProjectDeps hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   put project_ListProjectDepNames (projectName)
end menu_DisplayProjectDeps

on _
end _

on menu_RevealHandlerFile hkey
   put hkey_HandlerFile (hkey) into handlerFile
   finder_Reveal handlerFile
end menu_RevealHandlerFile

on menu_RevealHkeyFolder hkey
   put hkey_Folder (hkey) into hkeyFolder
   finder_Reveal hkeyFolder
end menu_RevealHkeyFolder

on menu_RevealHandlerDataFolder hkeyLine
   put hkey_DataFolder (hKeyLine) into hkeyDataFolder
   finder_Reveal hkeyDataFolder
end menu_RevealHandlerDataFolder

on _
end _

on menu_SpotlightHandler hkeyLine
   hkey_Deconstruct hkeyLine, hName, hType, hObject, hNum
   
   put spotlight_FindHandlerFile (hkeyLine) into handlerFile
   if there is a file asfd then
      atom_Edit handlerFile
   end if
end menu_SpotlightHandler

on menu_DisplaySpotlight hkeyLine
   display_SpotlightHandler hkeyLine
end menu_DisplaySpotlight

on menu_RevealHandlerMetadataFolder hkeyLine
   put hkey_MetadataFolder (hKeyLine) into hkeyMetadataFolder
   finder_Reveal hkeyMetadataFolder
end menu_RevealHandlerMetadataFolder

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_AddHandlerToLibrary hKey
   library_AddHkey hKey
   display_Hkey hKey, "project"
   put merge ("Added handler '[[item 1 to 2 of hKey]]' to the handler library!") into someComment
   lcw_Notify someComment
end menu_AddHandlerToLibrary

on menu_ReplaceHandlerInLibrary hKey
   library_AddHkey hKey
   display_Hkey hKey, "project"
   put merge ("Added handler '[[item 1 to 2 of hKey]]' to the handler library!") into someComment
   lcw_Notify someComment
end menu_ReplaceHandlerInLibrary

on menu_FetchProjectHandler hKey
   put project_FetchHandler (hKey) into someHandler
   script_CreateAndEditHashCard someHandler
end menu_FetchProjectHandler

on _
end _

on menu_AddHandlerToLibrary hKey
   library_AddHkey hKey
   
   display_Hkey hKey, "project"
   put merge ("Added handler 'hKey' to the handler library!") into someComment
   lcw_Notify someComment
end menu_AddHandlerToLibrary

on menu_EditHandler hKey
   hkey_Edit hKey
end menu_EditHandler

on menu_EditHandlerHelp hKey
   put hkey_FetchHelp (hKey) into helpText
   put lcw_Ask ("Edit the help text...", helpText) into helpText
   hkey_StoreHelp hKey, helpText
end menu_EditHandlerHelp

on menu_RevealHandlerHelpFile hKey
   put hkey_HelpFile (hKey) into someFile
   finder_Reveal someFile
end menu_RevealHandlerHelpFile

on _
end _

on menu_FetchDeps hKey, fetchHow
   set the cursor to watch
   put hkey_FetchDeps (hKey, fetchHow) into hKeyDeps
   put hKeyDeps
end menu_FetchDeps

on menu_FilteredLibraryDeps hKey
   local hKeyArray
   hkey_RecurseCallArray hKey, hkeyArray
   display_HKeyArray hkey, hKeyArray
end menu_FilteredLibraryDeps
