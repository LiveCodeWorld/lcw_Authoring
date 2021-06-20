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


--> TextStack | HkeyObject | Array
-
getprop textstack_HkeyObjectArray
   put the projectOverlay_Array ["processedHkey.array"] of the target into processedHkeyArray  
   put hkeyArray_GetDepArray (processedHkeyArray) into hkeyObjectArray
   return hkeyObjectArray
end textstack_HkeyObjectArray


--> ProjectOverlay | Array
-
/*
TextStack is a synonym for projectOverlay  metadata folder.
*/

getprop projectOverlay_Array [pShortFile]
   -- was "textstack_ProcessedHkeyArray" then "textStack_HkeyArray"
   put the projectOverlay_File [pShortFile] of the target into someFile
   put array_Fetch (someFile) into hkeyArray
   return hkeyArray
end projectOverlay_Array

setprop projectOverlay_Array [pShortFile] hkeyArray
   -- was "textstack_ProcessedHkeyArray"
   put the projectOverlay_File [pShortFile] of the target into someFile
   array_Save someFile, hkeyArray
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


-->  TextStack | Folders
-
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

getprop textStack_Folder [pDontCreate]  
   put the defaultstack into stackObject
   put the mainstack of stackObject into mainStackName
   put textStack_ConstructFolder (mainStackName) into textStackFolder
   return textStackFolder
end textStack_Folder

getprop textStack_Root
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   return lcwUserMetadataFolder
end textStack_Root


-->  TextStack | Functions
-
function textStack_ConstructFolder mainStackName
   -- mainStackName is the same as the name of the folder in the datafolder
   put lcw_UserMetadataFolder() into textStackRoot
   put textStackRoot & mainStackName & "/" into textStackFolder
   if pDontCreate is false then folder_CreateNested textStackFolder
   return textStackFolder
end textStack_ConstructFolder
