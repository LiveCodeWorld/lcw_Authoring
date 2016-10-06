script "model_HkeyFiles"
--> MetaData
-
license: GPLv3
name: model_HkeyFiles
type: model
version: 0.1


function hkey_HandlerFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "script.txt"
end hkey_HandlerFile

command hkey_DeleteHandlerFile hKey
   put hkey_HandlerFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHandlerFile

function hkey_LibraryImagetFile hKey, pOverlayName
   put library_HandlerMetadataFolder (hKey, true) into overlayFolder
   put overlay_GetImageFile (overlayFolder, pOverlayName) into imageFile
   return imageFile
end hkey_LibraryImagetFile


--> Hkey | Files
-
function hkey_CallsFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "links.txt"
end hkey_CallsFile

function hkey_ArrayFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "overlaydata.array"
end hkey_ArrayFile

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

function hkey_Folder hKey, pDontCreate
   if the number of items of hKey = 4 and item 3 of hKey is not "Missing" then
      put item 3 of hKey into hObject
      put the data_Folder of hObject into objectScriptFolder
      put textStack_HandlerDataFolder (hKey, objectScriptFolder) into hkeyFolder
   else
      put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   end if
   return hkeyFolder
end hkey_Folder

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
   put hkey_ArrayFile (hKey) into someFile
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
