script "model_ScriptMetadataFiles"
--> MetaData
-
license: GPLv3
name: model_ScriptMetadataFiles
type: model
version: 0.1


--> Old | Hkey | Data | Folder
-
command library_DeleteHandlerFolder shortHkey
   put library_HkeyFolder (shortHkey) into hkeyFolder
   revDeleteFolder hkeyFolder
end library_DeleteHandlerFolder

function library_HandlerFile hKey, pShortFileBit, pDontCreate
   -- returns empty if there is no folder, but the filename if there is
   if pDontCreate is empty then put true into pDontCreate
   put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   if there is not a folder hkeyFolder then return empty
   put pShortFileBit after hkeyFolder
   return hkeyFolder
end library_HandlerFile


--> Old
-
function checkout_ConstructDefaultFolder objectFile
   put objectFile into checkoutFolder
   set the itemdelimiter to "/"
   -- put "opn_TextStacks/" into item -1 of checkoutFolder
   put "liveworld/" into item -1 of checkoutFolder
   return checkoutFolder
end checkout_ConstructDefaultFolder

-- function checkout_ConstructDefaultFolder objectFile
put objectFile into checkoutFolder
set the itemdelimiter to "/"
put "opn_TextStacks/" into item -1 of checkoutFolder
return checkoutFolder
end checkout_ConstructDefaultFolder

function checkout_FindRoot objectFile, repoType
   -- ignoreCall: fossil_FindCheckoutFolder,f
   -- ignoreCall: git_GetCheckoutFolder,f
   
   switch repoType
      case "fossil"
         try
            put fossil_FindCheckoutFolder (objectFile) into checkoutFolder
            return checkoutFolder
         catch e
            return empty 
         end try
      case "git"
         try
            put git_GetCheckoutFolder (objectFile) into checkoutFolder
            return checkoutFolder
         catch e
            return empty 
         end try
      default
         -- let's try to see if there is a repo
         try
            put git_GetCheckoutFolder (objectFile) into gitCheckoutFolder
         catch e
            put empty into gitCheckoutFolder
         end try
         
         try
            put fossil_FindCheckoutFolder (objectFile) into fossilCheckoutFolder
         catch e
            put empty into fossilCheckoutFolder
         end try
         
         switch
            case gitCheckoutFolder is empty and fossilCheckoutFolder is empty
               return empty
            case gitCheckoutFolder is empty and fossilCheckoutFolder is not empty
               return fossilCheckoutFolder
            case gitCheckoutFolder is not empty and fossilCheckoutFolder is empty
               return gitCheckoutFolder
            default -- case objectFile begins with gitCheckoutFolder and objectFile begins with fossilCheckoutFolder
               -- let's just return the longest (usually the closest folder above objectFile)
               if the number of chars of gitCheckoutFolder > the number of chars of fossilCheckoutFolder then
                  return gitCheckoutFolder
               else
                  return fossilCheckoutFolder
               end if
         end switch
   end switch
end checkout_FindRoot


--> Stack | Folder
-
getprop checkout_Folder [repoType]
   -- important handler needs to be fast and work even if there is no version control
   put the mainstack_File of the target into objectFile
   put checkout_FindRoot (objectFile, repoType) into checkoutFolder
   -- put checkout_ConstructDefaultFolder (objectFile) into checkoutFolder
   return checkoutFolder
end checkout_Folder


--> Project | Folder | Functions
-
function textStack_FindRoot objectFile, repoType
   -- put checkout_FindRoot (objectFile, repoType) into checkOutFolder
   checkout_SetFolderAndRepotype objectFile, repoType
   put the result into checkOutFolder
   
   switch
      case checkoutFolder is empty
         -- not in a repo
         put checkout_ConstructDefaultFolder (objectFile) into textStackFolder
         return textStackFolder
      case checkoutFolder = rev_GetPluginFolder()
         -- this legacy mammoth project is also in "git"
         put checkoutFolder & "opn_Plugins/opn_Text/rev/object/" into textStackFolder
         return textStackFolder
      case (checkoutFolder is not empty and repoType = "fossil")
         -- attempt at catering for legacy fossil projects
         put checkoutFolder & "opn_TextStacks/" into textStackFolder
         return textStackFolder
      case checkoutFolder is not empty and repoType = "git"
         -- it's a new git project
         -- let's use the new folder name
         put checkoutFolder & "liveworld/" into textStackFolder
         return textStackFolder
      case checkoutFolder is not empty
         -- as strange type of repo :)
         put checkoutFolder & "liveworld/" into textStackFolder
         return textStackFolder
   end switch
end textStack_FindRoot


getprop object_MetaDataFolder [pDontCreate]
   -- inside the textStack_Folder
   if pDontCreate is empty then put true into pDontCreate
   put the long id of the target into someObject
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   
   -- put mainstack_MetaDataRoot (mainStackName, pDontCreate) into metadataFolder
   put the textStack_Folder of stack mainStackName into mainStackFolder
   put mainStackFolder & "metadata/" into metadataFolder
   
   folder_AddObjectBit metadataFolder, someObject
   if pDontCreate is not true then folder_CreateNested metadataFolder
   return metadataFolder
end object_MetaDataFolder

command folder_AddObjectBit @objectFolder, someObject
   put word 1 of someObject into objectType
   switch
      case objectType = "stack"
         put "stack/" after objectFolder
         break
      default
         put objectType & "_" & word 3 of someObject & "/" after objectFolder
         break
   end switch
end folder_AddObjectBit
