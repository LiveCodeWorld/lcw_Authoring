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

--> TextStack | HkeyObject | Array
-
getprop textstack_HkeyObjectArray
   put the textStack_HkeyArray of the target into processedHkeyArray  
   put hkeyArray_ConstructObjectArray (processedHkeyArray) into hkeyObjectArray
   return hkeyObjectArray
end textstack_HkeyObjectArray


--> TextStack | HkeyObject | Array
-
getprop textStack_HkeyArray
   -- was "textstack_ProcessedHkeyArray"
   put the textStack_HkeyArrayFile of the target into someFile
   put array_Fetch (someFile) into rigHkeyArray
   return rigHkeyArray
end textStack_HkeyArray

setprop textStack_HkeyArray rigHkeyArray
   -- was "textstack_ProcessedHkeyArray"
   put the textStack_HkeyArrayFile of the target into someFile
   array_Save someFile, rigHkeyArray
   return someFile
end textStack_HkeyArray


--> TextStack | HkeyArray | File
-
getprop textStack_HkeyArrayFile
   -- this puts object hkeyarray files in the project overlay folder (wrong place)
   put the textStack_ProjectOverlayFolder of the target into projectOverlayFolder
   put projectOverlayFolder & "processedHkey.array" into someFile
   return someFile
end textStack_HkeyArrayFile


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
   -- /lcw_User/lcw_Metadata/LCW/data/
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

function textStack_ConstructFolder mainStackName
   -- mainStackName is the same as the name of the folder in the datafolder
   put lcw_UserMetadataFolder() into textStackRoot
   put textStackRoot & mainStackName & "/" into textStackFolder
   if pDontCreate is false then folder_CreateNested textStackFolder
   return textStackFolder
end textStack_ConstructFolder

getprop textStack_Root
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   return lcwUserMetadataFolder
end textStack_Root


-->  TextStack | File | Script
-
function textStack_ScriptFile dataFolder, pDontCreate
   if pDontCreate is false then
      folder_CreateNested dataFolder
   else
      text_AddTrailing dataFolder, slash
   end if
   put dataFolder & "lcw_script.txt" into someFile
   return someFile
end textStack_ScriptFile
