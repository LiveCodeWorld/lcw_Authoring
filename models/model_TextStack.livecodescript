script "model_TextStack"
--> MetaData
-
license: GPLv3
name: model_TextStack
type: model
version: 0.6

/*
A "text stack" is a representation of a stack, together with any metadata in a simple text format.
All the text files are contained in a single folder.

It should be possible to reconstruct the entire stack from the "data" folder,
while the metadata folder should contain any information which desribes or graphs any dependencies for the stack.
*/


-->  Working on
-
function handler_WikiFolder stackName
   # Folders have the same name as the stack
   get "stack/" & stackName
   put wikiFolder_ConstructAssets ("handler.livecode.wiki", it) into handlerFolder
   return handlerFolder
end handler_WikiFolder

command temp_MoveTextStackFolder stackName, newFolderName
   if there is not a folder newFolderName then
      put lcw_UserMetadataFolder() into textStackRoot
      put textStackRoot & stackName & "/" into oldTextStackFolder
      
      # Move or Create
      if there is a folder oldTextStackFolder then
         revMoveFolder oldTextStackFolder, newFolderName
         folder_CreateSymLink newFolderName, oldTextStackFolder
      end if
   end if
end temp_MoveTextStackFolder

command old_MoveHandlerFolder hkeyFolder
   if there is not a folder hkeyFolder then
      return "Error, hkey folder does not exist:" &&hkeyFolder
   end if
   
   # New Handler Folder
   set the itemdelimiter to slash
   put item -1 of hkeyFolder into shortHkey
   put word -1 of shortHkey into hName
   get wikiFolder_ConstructAssets ("handler.livecode.wiki", hName)
   put it into wikiHandlerFolder
   --
   if there is a folder wikiHandlerFolder then
      return "Error, already a new wiki handler folder:" && wikiHandlerFolder
   end if
   
   revMoveFolder hkeyFolder, wikiHandlerFolder
   folder_CreateSymLink wikiHandlerFolder, hkeyFolder
   --
   return wikiHandlerFolder
end old_MoveHandlerFolder


-->  Props
-
getprop textstack_HkeyObjectArray
   put the projectOverlay_Array ["processedHkey.array"] of the target into processedHkeyArray  
   put hkeyStackArray_From (processedHkeyArray) into hkeyObjectArray
   return hkeyObjectArray
end textstack_HkeyObjectArray

getprop textStack_MetadataFolder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/metadata/
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "metadata/" into objectMetaDataFolder
   if pDontCreate is not true then folder_CreateNested objectMetaDataFolder
   return objectMetaDataFolder
end textStack_MetadataFolder

getprop textStack_DataFolder [pDontCreate]
   /*
   This is the projects (ie for now stacks) top-level data folder.
   -- /lcw_User/lcw_Metadata/LCW/data/
   
   If you want the data folder for a specific script/object then use "the dataObject_Folder of sObject"
   */
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "data/" into textStackDataFolder
   if pDontCreate is not true then folder_CreateNested textStackDataFolder
   return textStackDataFolder
end textStack_DataFolder

getprop textStack_Folder
   put the defaultstack into stackObject
   put the mainstack of stackObject into mainStackName
   put textStack_ConstructFolder (mainStackName) into textStackFolder
   return textStackFolder
end textStack_Folder

getprop textStack_Root
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   return lcwUserMetadataFolder
end textStack_Root


--> Textstack
-
function textStack_ConstructFolder stackName
   put handler_WikiFolder (stackName) into handlerFolder
   
   # Move old folder if it exists
   dispatch "temp_MoveTextStackFolder" with stackName,handlerFolder
   
   return handlerFolder
end textStack_ConstructFolder

getprop projectOverlay_SvgFile [projectName]
   -- LCW.svg
   put the long id of the target into scriptObject
   if projectName is empty then
      put the project_Name of the target into shortFile
   end if
   put the project_OverlayFolder [false] of scriptObject into overlayFolder
   put overlayFolder & shortFile & ".svg" into svgFile
   return svgFile
end projectOverlay_SvgFile


--> ProjectOverlay | Array
-
/*
TextStack is a synonym for projectOverlay  metadata folder.
*/

getprop projectOverlay_Array [pShortFile]
   -- was "textstack_ProcessedHkeyArray" then "textStack_HkeyArray"
   put the projectOverlay_File [pShortFile] of the target into someFile
   put array_Get (someFile) into hkeyArray
   return hkeyArray
end projectOverlay_Array

setprop projectOverlay_Array [pShortFile] hkeyArray
   -- was "textstack_ProcessedHkeyArray"
   put the projectOverlay_File [pShortFile] of the target into someFile
   array_Set someFile, hkeyArray
   return someFile
end projectOverlay_Array

getprop projectOverlay_File [pShortFile]
   put the long id of the target into tObject
   --
   if pShortFile is empty then put "processedHkey.array" into pShortFile
   put the project_OverlayFolder of tObject into projectOverlayFolder
   put projectOverlayFolder & pShortFile into someFile
   return someFile
end projectOverlay_File


--> Deps
-
command folder_CreateNested someFolder
   if there is a folder someFolder then return empty   
   set the itemdelimiter to "/"
   repeat with itemNum = 2 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
   if char -1 of someFolder is not slash then
      put slash after someFolder
   end if
   return someFolder
end folder_CreateNested
