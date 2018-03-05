script "model_HkeyFiles"
--> MetaData
-
license: GPLv3
name: model_HkeyFiles
type: model
version: 0.2

/*
Handlers, their calls and their metadata are now stored in a folder that reflects the folder structure of project and object scripts:

Scripts are stored as merge files inside the data_Folder eg:
-- /lcw_User/lcw_Metadata/LCW/data/objects/stack/lcw_script.txt

Handlers and calls are stored inside the data_Folder:
-- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/M someCommand/lcw_handler.txt
-  put textStack_HandlerDataFolder (hKey, objectScriptFolder) into hkeyFolder

While hander graphs and dependency arrays are stored inside the metadat_Folder:
-- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/M someCommand/lcw_handler.txt

The old hkey_Folder was here:
-  put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
*/


--> Working on
-
-->  Hkey | Files
-
function hkey_SvgFile hKey, pGraphStyle
   if pGraphStyle is empty then
      put "hierarchical" into pGraphStyle
   end if
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   put hkeyMetadataFolder & pGraphStyle & ".svg" into svgFile
   return svgFile
end hkey_SvgFile


-->  Hkey | Folder | Model
-
function hkey_DataFolder hKey, pDontCreate
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the data_Folder [pDontCreate] of hObject into dataFolder
   return dataFolder
end hkey_DataFolder

function hkey_MetadataFolder hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the metadata_Folder of hObject into metaDataFolder
   put textStack_HandlerDataFolder (hKey, metaDataFolder) into hkeyMetadataFolder
   return hkeyMetadataFolder
end hkey_MetadataFolder


--> Hkey | Files
-
function hkey_LibraryImagetFile hKey, pOverlayName
   put library_HandlerMetadataFolder (hKey, true) into overlayFolder
   put overlay_GetImageFile (overlayFolder, pOverlayName) into imageFile
   return imageFile
end hkey_LibraryImagetFile

function hkey_OverlayDataFile hKey, pDontCreate
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   return hkeyMetadataFolder & "overlaydata.array"
end hkey_OverlayDataFile

function hkey_DotFile hKey, pVersionName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "dot" into shortFile
   return hkey_Folder (hKey, pDontCreate) & shortFile
end hkey_DotFile

function hkey_CmapxFile hKey, pOverlayName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "cmapx" into shortFile
   return hkey_Folder (hKey, pDontCreate) & shortFile
end hkey_CmapxFile

function hkey_ImageFile hKey, pOverlayName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "png" into shortFile
   return hkey_Folder (hKey, pDontCreate) & shortFile
end hkey_ImageFile

function hkey_HelpFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "help.html"
end hkey_HelpFile


--> Hkey | Folders
-
/*
These handlers refer to the permanent fixed shared location of the files in hkey handler database.
*/
command hkey_DeconstructFolder scriptFolder, @shortHkey, @versionName
   set the itemdelimiter to "/"
   get item -1 of scriptFolder
   
   put word 1 of it into shortFolder
   put word 2 of it into versionName
   
   set the itemdelimiter to "_"
   put item 1 to -2 of shortFolder into handlerName
   put item -1 of shortFolder into handlerType
   put handlerName,handlerType into shortHkey
end hkey_DeconstructFolder

function hkey_FromFolder someFolder
   set the itemdelimiter to "/"
   put item - 1 of someFolder into shortFolder
   put hkey_FromShortFolder (shortFolder) into shortHkey
   return shortHkey
end hkey_FromFolder

function hkey_FromShortFolder shortFolder
   put word 1 of shortFolder into handlerInfo
   
   set the itemdelimiter to "_"
   put item -1 of handlerInfo into handlerType
   put item 1 to -2 of handlerInfo into handlerName
   
   set the itemdelimiter to comma
   if handlerType is not among the items of "g,s,c,f,m,pg,ps,pc,pf" then return empty
   return handlerName,handlerType
end hkey_FromShortFolder

function hkey_FolderName hKey
   put item 1 of hKey into hName
   put item 2 of hKey into hType
   if hType = "o" then put "c" into hType -- as "on" and "command" are functionally equivalent
   put hName & "_" & tolower (hType) into folderName
   return folderName
end hkey_FolderName


--> Hkey | Files
-
function hkey_Files hKey, pVersionName
   put library_HandlerFile (hKey, empty, true) into someFolder
   put folder_ShortFiles (someFolder) into someFiles
   return someFiles
end hkey_Files

function hkey_ImageMapPngs hKey, pVersionName
   put hkey_Files (hKey, pVersionName) into somePngs
   filter somePngs with "*.png"
   return somePngs
end hkey_ImageMapPngs

function hkey_GraphFiles hKey, pOverlayName, pVersionName
   put library_HandlerFile (hKey, empty, true) into dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapFile, xdotFile, dotArrayFile, pOverlayName
   put dotFile,imageFile,cmapFile,xdotFile,dotArrayFile,pOverlayName into someFiles
   replace comma with  CR in someFiles
   return someFiles
end hkey_GraphFiles


--> Hkey | Files | Delete
-
command hkey_DeleteArrayFile hKey
   put hkey_OverlayDataFile (hKey) into someFile
   delete file someFile
end hkey_DeleteArrayFile

command hkey_DeleteDotFile hKey
   put hkey_DotFile (hKey) into someFile
   delete file someFile
end hkey_DeleteDotFile

command hkey_DeleteImageMapPngs hKey
   put hkey_ImageMapPngs (hKey) into someFiles
   repeat for each line someFile in someFiles
      delete file someFile
   end repeat
end hkey_DeleteImageMapPngs

command hkey_DeleteImageFile hKey, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   delete file someFile
end hkey_DeleteImageFile

command hkey_DeleteHelpFile hKey
   put hkey_HelpFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHelpFile


--> Hkey | Data
-
function hkey_ListShortFolders
   put library_PluginFolder ("opn_Text/rev/handlers/") into helpFolder
   put the defaultfolder into oFolder
   set the defaultfolder to helpFolder
   put the folders into tFolders
   filter tFolders without ".*"
   set the defaultfolder to oFolder  
   return tFolders
end hkey_ListShortFolders 

function hkey_ListShortVersionFolders hKey
   local versionNames
   put hkey_ListShortFolders() into shortFolders
   
   put hkey_FolderName (hKey) into folderName
   filter shortFolders with (folderName & " *")
   return shortFolders
end hkey_ListShortVersionFolders
