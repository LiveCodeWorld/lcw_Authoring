script "lib_Mainstack"
--> MetaData
-
license: GPLv3
name: lib_Mainstack
type: library
version: 0.1


--> Mainstack | Export
-
command mainstack_ExportAsText stackObject, pHashArrayBoolean, pExportHandlers, pUseCustomFolders, pForceCreate
   put the mainstack of stackObject into mainStackName
   
   put the effective filename of stackObject into someFile
   if someFile is empty and the create_NewProjects of stackObject is true then
      breakpoint
      project_Create mainStackName
      put the result into gitRootFolder
      git_InitFolder gitRootFolder
      return "git project created in:" && gitRootFolder
   else  
      dispatch "stack_CleanBeforeSave" to stackObject
      save stackObject
      put the name of stackObject into mainStackObject
      mainStack_ExportAsFiles mainStackObject, pHashArrayBoolean, pExportHandlers, pUseCustomFolders, pForceCreate
      put the result into mainStackMetaArray
      return "exported"
   end if
end mainstack_ExportAsText

command mainStack_ExportAsFiles mainStackObject, pHashArrayBoolean, pExportHandlers, pUseCustomFolders, pForceCreate 
   -- seems like mainStackObject can be any object
   local pForceIndexHandlerCalls, pDontDiff, pLinkToViews, pDontExport
   
   if exists (mainStackObject) is false then return empty
   if char 1 to 3 of the short name of mainStackObject = "rev" then return empty -- don't index rev stack???
   
   ------ put the mainStack_MetaArray [pHashArrayBoolean] of mainStackObject into mainStackMetaArray
   -- put true into pDontExport
   -- put true into pLinkToViews
   -- put false into pForceIndexHandlerCalls
   -- put empty into pDontDiff
   -- put true into pDontExport -- as it is exported later in the handler?
   
   if pHashArrayBoolean is empty then
      put pref_GetValue ("add object to hArray on export") is not false into createHarray
      put pref_GetValue ("Construct hashArray on stack export") is true into pHashArrayBoolean
   else
      put pHashArrayBoolean is true into pHashArrayBoolean
      pref_SetValue "Construct hashArray on stack export", pHashArrayBoolean
      if pHashArrayBoolean is true then
         pref_SetValue "Add object to hArray on stack export", true
         put true into createHarray
      else
         put pref_GetValue ("Add object to hArray on export") is not false into createHarray
      end if
   end if
   
   if createHarray and pHashArrayBoolean then -- only give option of constructing hkeyCalls handlerHashArray if we are also indexing a basic hArray
      put the textStack_Folder of mainStackObject into textStackFolder
      put mainstack_FetchHandlerHashArray (textStackFolder) into handlerHashArray
      if handlerHashArray is not an array then
         put empty into hArray ["handlerHashArray"]["new"] -- forces indexing of all hKeys in a new script
      else
         delete variable handlerHashArray ["actual"]
         delete variable handlerHashArray ["new"]
         put handlerHashArray into hArray ["handlerHashArray"]
      end if
   else
      put empty into hArray -- no "handlerHashArray" indexing of hKey calls, let's recreate the rest of hArray
   end if
   
   put mainstack_ConstructMetaArray (mainStackObject, hArray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceCreate) into mainStackMetaArray
   mainstack_AddArrayToGlobal mainStackMetaArray
   
   put mainStackMetaArray ["mainstackArray"]["manifest"] into manifestArray
   put the mainStack_Hash of mainStackObject into mainStackHash
   put manifestArray ["sha1"] into storedHash
   
   /* this is not working reliably
   if mainStackHash = storedHash and pForceCreate is not true then
      put the mainstack_WalkArray of scriptObject into mainStackHkeyWalkArray
      return mainStackHkeyWalkArray
   end if
   */
   
   -- safety check to delete any hashed handlers in old object that are not in actual object
   put mainStackMetaArray ["hArray"]["handlerHashArray"] into handlerHashArray
   put handlerHashArray ["actual"] into actualHashArray
   put handlerHashArray ["cached"] into cachedHashArray
   delete variable mainStackMetaArray ["hArray"]["handlerHashArray"]["actual"]
   delete variable mainStackMetaArray ["hArray"]["handlerHashArray"]["new"]
   intersect cachedHashArray with actualHashArray
   put cachedHashArray into mainStackMetaArray ["hArray"]["handlerHashArray"]["cached"]
   
   put mainStackMetaArray ["hArray"] into hArray
   -- delete variable hArray ["handlerHashArray"]
   put the textStack_Folder of mainStackObject into textStackFolder
   mainstack_StoreHarray hArray, textStackFolder
   
   --here we delete the object folder and re-export
   stackArray_DeleteObjectFolder textStackFolder
   put the result into objectsFolder
   
   put mainStackMetaArray ["mainStackArray"] into mainStackArray
   put mainStackArray ["objects"] into objectArray
   put mainStackArray ["manifest"] into manifestArray
   
   -- put manifestArray ["object"] into stackObject
   put manifestArray ["name"] into stackName   
   if char 1 to 3 of stackName = "rev" then return empty -- don't allow accidental export of rev stacks
   
   put objectArray ["substacks"] into substackData
   delete variable objectArray ["substacks"]
   
   put empty into subStackName
   repeat for each key objectBit in objectArray
      set the cursor to busy
      put stackArray_ConstructObjectFolder (textStackFolder, objectBit, subStackName) into objectFolder
      put objectArray [objectBit] into objectPropArray
      
      if objectBit = "stack" then
         stackArray_ExportStackFiles objectFolder, objectPropArray
         stackArray_ExportVideoClips objectFolder, objectPropArray
         stackArray_ExportAudioClips objectFolder, objectPropArray
      end if
      
      objectArray_ExportAsFiles objectPropArray, objectFolder, pUseCustomFolders, pExportHandlers, pDontExport  -- folder_CreateNested objectFolder
   end repeat
   
   repeat for each key subStackName in substackData
      if char 1 to 3 of subStackName = "rev" then return empty -- don't allow accidental export of rev stacks
      put substackData [subStackName] into subStackArray
      
      put subStackArray ["objects"] into objectArray
      put mainStackMetaArray ["mainstackArray"]["manifest"]["substacks"][subStackName] into subManifestArray
      put subManifestArray into manifestArray ["substacks"][subStackName]
      
      repeat for each key objectBit in objectArray
         set the cursor to busy
         put stackArray_ConstructObjectFolder (textStackFolder, objectBit, subStackName) into objectFolder
         put objectArray [objectBit] into objectPropArray
         
         if objectBit = "stack" then
            stackArray_ExportStackFiles objectFolder, objectPropArray
            stackArray_ExportVideoClips objectFolder, objectPropArray
            stackArray_ExportAudioClips objectFolder, objectPropArray
         end if
         
         objectArray_ExportAsFiles objectPropArray, objectFolder, pUseCustomFolders, pExportHandlers, pDontExport  -- folder_CreateNested objectFolder
      end repeat
   end repeat
   
   mainStack_StoreManifestArray textStackFolder, manifestArray
   
   return mainStackMetaArray
end mainStack_ExportAsFiles

function mainstack_ConstructMetaArray mainStackObject, pHarray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   -- this will also construct hArray if pref_GetValue ("add object to hArray on export") is true
   -- basically a walkArray with added metaArray ["mainStackArray"] key
   
   local mainStackArray, subStackArray
   try
      -- put hArray ["handlerHashArray"] into oldHandlerHashArray
      put false into pStripStackRects
      put the stackArray_Version of me into stackArrayVersion
      
      stack_GetPropertArrays mainStackObject, mainStackArray, pHarray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
      if pStripStackRects is true then delete local mainStackArray ["objects"]["stack"]["rev"]["rect"] -- lets strip the stack rects
   catch e
      breakpoint
   end try
   
   put the short name of stack mainStackObject into mainStackName
   put the substacks of mainStackObject into subStackNames
   repeat for each line subStackName in subStackNames
      try
         -- put the long name of stack subStackName of mainStackObject into subStackObject -- LiveCode bug does not work (returns mainstack)
         -- put the long id of stack subStackName of mainStackObject into subStackObject -- LiveCode bug does not work (returns mainstack)
         put the long id of stack subStackName of stack mainStackName into subStackObject
         -- put revRuggedID (subStackObject) into subStackObject
         
         put empty into subStackArray
         stack_GetPropertArrays subStackObject, subStackArray, pHarray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
         delete variable subStackArray ["manifest"]["version"]
         put subStackArray ["manifest"] into mainStackArray ["manifest"]["substacks"][subStackName]
         delete variable subStackArray ["manifest"]
         
         if pStripStackRects is true then delete local subStackArray ["objects"]["stack"]["rev"]["rect"] -- lets strip the stack rects
         put subStackArray into mainStackArray ["objects"]["substacks"][subStackName]
      catch e
         breakpoint
      end try
   end repeat
   
   -- put harray_ConstructHkeyArray (pHarray) into hKeyArray
   -- put hKeyArray into metaArray ["hKeyArray"]
   
   put mainStackArray into metaArray ["mainStackArray"]
   put pHarray into metaArray ["hArray"]
   put the mainStack_Hash of mainStackObject into mainstackHash
   put mainstackHash into metaArray ["mainStackArray"]["manifest"]["sha1"]
   put mainstackHash into metaArray ["hArray"]["metadata"]["sha1"]
   return metaArray
end mainstack_ConstructMetaArray

command mainstack_AddArrayToGlobal mainStackMetaArray
   /*
   Rescued from text export
   Better to wait till full db replacement, and / or nested mainstack structure for global gLCW.
   */
   
   global gLCW
   
   put mainStackMetaArray ["hArray"] into newHarray
   put gLCW ["hArray"] into gHarray
   
   put newHarray ["scriptArray"] into scriptArray
   put gHarray ["scriptArray"] into gScriptArray
   union scriptArray with gScriptArray
   put scriptArray into gHarray ["scriptArray"]
   
   -- need to delete all mainstack entries for behaviorArray
   put newHarray ["behaviorArray"] into behaviorArray
   put gHarray ["behaviorArray"] into behaviorArray
   
   -- need to delete all Global Menus in mainstack other than new entries
   put newHarray ["Global Menus"] into menuArray
   put gHarray ["Global Menus"] into menuArray
   
   -- need to add all handlers in handlerArray and remove any old handlers in gHarray
   put newHarray ["handlerArray"] into handlerArray
   put gHarray ["handlerArray"] into handlerArray
   
   put newHarray ["keywordArray"] into keywordArray
   put gHarray ["keywordArray"] into keywordArray
   
   put newHarray ["objectTypeArray"] into objectTypeArray
   put gHarray ["objectTypeArray"] into objectTypeArray
   
end mainstack_AddArrayToGlobal

command objectArray_ExportAsFiles objectPropArray, objectFolder, pUseCustomFolders, pExportHandlers, pDontExport
   local revPropText, someScript, objectText, objectHtml, metadataArray, customArray, someImage
   
   folder_Format objectFolder
   object_DeconstructPropertyArray objectPropArray, revPropertyArray, someScript, objectText, objectHtml, customArray, someImage
   put rev_PropertyArrayToText (revPropertyArray) into revPropText
   
   -- don't translate to native encoding for text files (keep with unix line endings on all platforms)
   if someScript is not empty then
      -- hack
      put object_FromScriptFolder (objectFolder) into someObject
      object_ExportScript someObject, someScript, pExportHandlers, pDontExport
   end if
   if revPropText is not empty then object_ExportRevPropText objectFolder, revPropText
   if objectText is not empty then object_ExportMetaText objectFolder, objectText
   if objectHtml is not empty then object_ExportMetaHtml objectFolder, objectHtml
   if someImage is not empty then object_ExportMetaImage objectFolder, someImage -- put someImage into url ("binfile:" & objectFolder & "image.png")  -- no idea what type of image it is (use imagedata) ???
   
   put objectPropArray ["videoclip"] into someData
   if someData is not empty then
      put someData into url ("binfile:" & objectFolder & "video")
   end if
   
   put objectPropArray ["audioclip"] into someData
   if someData is not empty then
      put someData into url ("binfile:" & objectFolder & "audioclip_object")
   end if
   
   object_ExportCustomArray objectFolder, customArray, pUseCustomFolders
   return objectFolder
end objectArray_ExportAsFiles

function object_FromScriptFolder scriptFileOrFolder
   set the itemdelimiter to "/"
   
   if item -1 of scriptFileOrFolder = "script.txt" then delete item -1 of scriptFileOrFolder
   if item -2 of scriptFileOrFolder = "handlers" then delete item -2 to -1 of scriptFileOrFolder
   
   put item -1 of scriptFileOrFolder into objectBit
   replace "_" with " id " in objectBit
   
   if item -3 of scriptFileOrFolder = "substacks" then
      put item -2 of scriptFileOrFolder into subStackName
      put item -6 of scriptFileOrFolder into mainStackName
      if objectBit = "stack" then
         put "stack" && kwote (subStackName) && "of stack" && kwote (mainStackName) into someObject
      else
         put objectBit && "of stack" && kwote (subStackName) && "of stack" && kwote (mainStackName) into someObject
      end if
   else
      put item -4 of scriptFileOrFolder into mainStackName
      if objectBit = "stack" then
         put "stack" && kwote (mainStackName) into someObject
      else
         put objectBit && "of stack" && kwote (mainStackName) into someObject
      end if
   end if
   return someObject
end object_FromScriptFolder

command object_ExportScript someObject, pSomeScript, pExportHandlersAndCalls, pDontExportScript
   -- simply export the objects script to the right place (see also "exported_Script")
   -- note use of binFile to avoid translating of LF to CR on Macs by Revolution (which causes difficulties for git)
   
   if pSomeScript is empty then put the script of someObject into pSomeScript
   if pDontExportScript is true then return empty
   
   if pExportHandlersAndCalls is not false then
      script_ExportHandlersAndCalls someObject, pExportHandlersAndCalls, pSomeScript
      put the script_File of someObject into scriptFile
      return scriptFile
   else
      put the script_File of someObject into scriptFile
      if pSomeScript is empty then
         delete file scriptFile
         return empty
      else
         text_Set scriptFile, pSomeScript
         return scriptFile
      end if
   end if
end object_ExportScript

command object_ExportCustomArray objectFolder, customArray, pUseCustomFolders
   if pUseCustomFolders is not true then
      -- export as encoded array
      put meta_GetCustomArrayFile (objectFolder) into someFile
      array_Set someFile, customArray
      return someFile
   else
      -- export as folder
      folder_Format objectFolder
      put objectFolder & "custom/" into customFolder
      if customArray is not an array then
         revDeleteFolder customFolder
         return empty
      else
         put objectFolder & "custom/" into customFolder
         array_ToFolder customFolder, customArray
         return customFolder
      end if
   end if
end object_ExportCustomArray


--> Harray | handlerHashArray
-
command object_UpdateHandlerHashArray scriptObject, pUpdateAll
   if pUpdateAll is false then
      hArray_TidyHandlerHashes scriptObject, true
      put the result into resultArray
      if resultArray ["isTidy"] is true then return resultArray
      put resultArray ["oldHandlerHashArray"] into objectHandlerHashArray
      put resultArray ["newHkeys"] into newHkeys
      
      put the mainstack_HandlerHashArray of scriptObject into mainStackHandlerHashArray
      repeat for each key handlerHash in objectHandlerHashArray
         delete variable mainStackHandlerHashArray ["cached"][handlerHash]
         delete variable mainStackHandlerHashArray ["new"][handlerHash]
      end repeat
      set the mainstack_HandlerHashArray of scriptObject to mainStackHandlerHashArray
   else
      set the mainstack_HandlerHashArray of scriptObject to empty
   end if
   
   -- force reindex
   mainStack_ExportAsFiles scriptObject, true, true
   put the result into mainStackMetaArray
   
   -- update
   object_CheckHandlerHashArray scriptObject
   return the result
end object_UpdateHandlerHashArray

command object_CheckHandlerHashArray scriptObject, pDontNotify
   hArray_TidyHandlerHashes scriptObject, pDontNotify
   put the result into resultArray
   put resultArray ["isTidy"] into someBoolean
   if someBoolean is true and pDontNotify is not true then
      put the mobile_Name of scriptObject into mObject
      put "There are no problems with the object_HandlerHashArray of" && mObject into someComment
      lcw_Notify someComment, true
   end if
   return resultArray
end object_CheckHandlerHashArray

command hArray_TidyHandlerHashes scriptObject, pDontNotify
   -- just in case things get out of sync
   put the object_HandlerHashArray of scriptObject into objectHandlerHashArray
   -- put the script_Array of scriptObject into scriptArray -- this is broken due to 2 different formats being returned
   put the hArray_ScriptData of scriptObject into scriptData
   repeat for each key indexNum in scriptData
      put scriptData [indexNum]["hKey"] into hKey
      if hKey is empty then next repeat
      put scriptData [indexNum]["sha1"] into handlerHash
      -- put scriptArray [indexNum]["handler"] into someHandler
      -- put sha1_Hash (someHandler) into handlerHash
      
      if objectHandlerHashArray [handlerHash] is an array then
         delete variable objectHandlerHashArray [handlerHash]
      else
         put scriptData [indexNum] into newKeys [hKey]
      end if
   end repeat
   
   put true into isTidy
   
   if objectHandlerHashArray is an array then
      repeat for each key oldHash in objectHandlerHashArray
         put objectHandlerHashArray [oldHash]["hkey"] into hKeyArray
         put keys (hKeyArray) & CR after oldHkeys
      end repeat
      delete char -1 of oldHkeys
      
      if pDontNotify is not true then
         put the mobile_Name of scriptObject into mObject
         put "Old handlers for" && kwote (mObject) into someTitle
         display_Lines oldHkeys, someTitle
      end if
      put false into isTidy
   end if
   
   put keys (newKeys) into newHkeys
   if newHkeys is not empty then
      if pDontNotify is not true then
         /*
         put "The following new handlers have been added to the index:" into someComment
         put CR & outline_IncreaseIndent (newHkeys, 4, space) after someComment
         lcw_Notify someComment, true
         */
         
         put the mobile_Name of scriptObject into mObject
         put "New handlers for" && kwote (mObject) into someTitle
         display_Lines newHkeys, someTitle
      end if
      put false into isTidy
   end if
   
   put isTidy into resultArray ["isTidy"]
   put objectHandlerHashArray into resultArray ["oldHandlerHashArray"]
   put newHkeys into resultArray ["newHkeys"]
   return resultArray
end hArray_TidyHandlerHashes

function hArray_GetHashedHandler hKey, handlerHash
   put hArray_GetFoundHkeyArray (hKey) into hkeyArray
   repeat for each key hKey in hkeyArray
      if hkeyArray [hKey]["handlerHash"] = handlerHash then
         put hkeyArray [hKey]["startLineNum"] into startLineNum
         put hkeyArray [hKey]["endLineNum"] into endLineNum
         put item 3 of hKey into hObject
         put line startLineNum to endLineNum of the script of hObject into someHandler
         return someHandler
      end if
   end repeat
   return empty
end hArray_GetHashedHandler

function hArray_GetHandlerHashArray hArray
   put hArray ["handlerHashArray"] into handlerHashArray
   return handlerHashArray
end hArray_GetHandlerHashArray

command hArray_SetHandlerHashArray @hArray, handlerHashArray
   if handlerHashArray is an array then
      put handlerHashArray into hArray ["handlerHashArray"]
   else
      delete variable hArray ["handlerHashArray"]
   end if
   return hArray
end hArray_SetHandlerHashArray

function hArray_ListHashHkeys hArray, pHandlerHash
   if pHandlerHash is empty then
      -- let's list all of them
      put hArray ["handlerHashArray"]["cached"] into hashArray
      repeat for each key handlerHash in hashArray
         put hashArray [handlerHash]["hKey"] into emptyHkeyArray
         put keys(emptyHkeyArray) & CR after hashedHkeys
      end repeat
      delete char -1 of hashedHkeys
      return hashedHkeys
   else
      put hArray ["handlerHashArray"]["cached"][handlerHash]["hKey"] into emptyHkeyArray
      return keys(emptyHkeyArray)
   end if
end hArray_ListHashHkeys

function hArray_ListNewHandlerHashes hArray
   put hArray ["handlerHashArray"]["new"] into hashArray
   return keys(hashArray)
end hArray_ListNewHandlerHashes

function hArray_ListNewHkeys hArray
   put hArray ["handlerHashArray"]["new"] into hashArray
   repeat for each key handlerHash in hashArray
      put hashArray [handlerHash]["hKey"] into emptyHkeyArray
      put keys(emptyHkeyArray) & CR after newHkeys
   end repeat
   delete char -1 of newHkeys
   return newHkeys
end hArray_ListNewHkeys


--> Stack _ PropertyArray
-
command stack_GetPropertArrays stackObject, @stackArray, @hArray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   put the stackArray_Version of me into stackArray ["manifest"]["version"]
   
   put the short name of stackObject into stackName
   put stackName into stackArray ["manifest"]["name"]
   put revRuggedID (stackObject) into stackArray ["manifest"]["object"]
   put the effective filename of stackObject into someFile
   file_StripHome someFile
   put someFile into stackArray ["manifest"]["filename"]
   
   object_GetPropertyArrays stackObject, stackPropertyArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   put stackPropertyArray into stackArray ["objects"]["stack"]
   
   set the wholematches to true
   put the cardids of stackObject into someCardIDs
   put the number of lines of someCardIDs into cardMaxNum
   repeat with cardNum = 1 to cardMaxNum
      set the cursor to busy
      put the long id of card cardNum of stackObject into cardObject
      objectArray_AddCard cardObject, stackArray, hArray, pLinkToViews, cardNum, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   end repeat
   
   -- don't now max number of duplicated background objects until end
   -- so problem with scenario of only one bg for xml reconversion comaptability of key naming
   -- as there should be a line "if maxBgNum = 1 then put "bg" into bgArrayKey
   -- have to fix at end of stack parsing
   put stackArray ["manifest"]["backgrounds"] into backgroundsArray
   if the number of lines of keys(backgroundsArray) = 1 then
      put backgroundsArray ["bg[1]"] into stackArray ["manifest"]["backgrounds"]["bg"]
      delete local stackArray ["manifest"]["backgrounds"]["bg[1]"]
   end if
   
   put the number of videoClips of stackObject into maxVclipNum
   repeat with clipNum = 1 to maxVclipNum
      put the object_PropertyArray of videoClip clipNum of stackObject into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of videoClip clipNum of stackObject into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxVclipNum = 1 then
         put "videoclip" into clipArrayKey
      else
         put "videoclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["videoclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["videoclips"][clipArrayKey]["name"]
   end repeat
   
   put the number of audioClips of stackObject into maxAclipNum
   repeat with clipNum = 1 to maxAclipNum
      put the object_PropertyArray of audioClip clipNum of stackObject into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of audioClip clipNum of stackObject into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxAclipNum = 1 then
         put "audioclip" into clipArrayKey
      else
         put "audioclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["audioclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["audioclips"][clipArrayKey]["name"]
   end repeat
end stack_GetPropertArrays

