script "lib_ObjectArray"
--> MetaData
-
license: GPLv3
name: lib_ObjectArray
type: library
version: 0.1


--> Stack | JSON
-
setprop stack_PropertyJSON [newStackName] pJSON
   put the long id of the target into tObject
   --
   put json_ToArray (pJSON) into pArray
   set the stack_Array [newStackName] of tObject to pArray
   --
   return pArray
end stack_PropertyJSON


--> Object | Array | Stack
-
getprop stack_Array [pLinkToViews]
   put the stack_Object of the target into stackObject
   
   local stackArray, stackPropertyArray, hArray, pExportHandlers, pDontDiff, pForceIndexHandlerCalls
   stack_GetPropertArrays stackObject, stackArray, hArray, pLinkToViews, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   put the stack_Object of the target into stackObject
   return stackArray
end stack_Array

setprop stack_Array [pRename] stackArray
   local newCreationArray
   lock screen
   set the relayerGroupedControls to false -- required otherwize setting layers moves objects out of groups = hack
   
   put the stack_Object of the target into stackNameObject
   set the defaultstack to stackNameObject
   --
   if pRename is not false then
      put stackNameObject into stackArray ["manifest"]["object"]
      
      put the short name of stackNameObject into shortStackName
      put shortStackName into stackArray ["manifest"]["name"]
      --
      put shortStackName into stackArray ["objects"]["stack"]["rev"]["name"]
      delete variable stackArray ["objects"]["stack"]["rev"]["id"]
      delete variable stackArray ["objects"]["stack"]["rev"]["fileName"]
      --
      -- display_Array stackArray
   end if
   --
   put stackArray ["objects"]["stack"] into stackPropertyArray
   set the object_PropertyArray of stackNameObject to stackPropertyArray
   
   put stackArray ["manifest"]["cards"] into allCdsArray
   if allCdsArray is an array then
      put the number of lines of keys (allCdsArray) into numberOfCards
      put 1 into cardNum
      repeat with cardNum = 1 to numberOfCards
         card_CreateFromArray cardNum, stackArray, newCreationArray
         if cardNum = numberOfCards then exit repeat
         
         -- now loop again
         create card
         repeat for each line bgID in the groupIDs of this card
            -- if there are any bg behavior grps, remove them and let the objectProp set them back if needed
            remove group id bgID from this cd
         end repeat
      end repeat
   else
      -- lazy zero manifest (objects only array)
      put stackArray ["objects"] into oArray
      repeat for each key aFolder in oArray
         if aFolder = "stack" then next repeat
         put oArray [aFolder] into objectPropertyArray
         put aFolder into aObject
         replace "_" with " id " in aObject
         
         object_Create aObject, empty, objectPropertyArray
      end repeat
   end if
   
   -- interestingly filename is not in the properties of a stack
   put manifestArray ["filename"] into someFile
   if someFile is not empty then set the filename of stackNameObject to someFile
   
   put 1 into clipNum
   repeat for each element clipArray in stackArray ["manifest"]["videoclips"]
      put clipArray ["object"] into aObject
      put aObject into aFolder
      replace " id " with "_" in aFolder
      put stackArray ["objects"][aFolder]["rev"] into revPropertyArray
      put stackArray ["objects"][aFolder]["videoclip"] into clipData
      if clipData is empty then next repeat
      
      put the tempname into someFile
      put clipData into url ("binfile:" & someFile)
      -- create videoClip -- does not work for videoClips
      import videoClip from file someFile
      -- put the result into createdObject -- RunRev bug it or the result does not give the createdObject
      
      delete local revPropertyArray ["layer"]
      set the rev_PropertyArray of videoClip clipNum to revPropertyArray
      add 1 to clipNum
   end repeat
   
   put 1 into clipNum
   repeat for each element clipArray in stackArray ["manifest"]["audioClips"]
      put clipArray ["object"] into aObject
      put aObject into aFolder
      replace " id " with "_" in aFolder
      put stackArray ["objects"][aFolder]["rev"] into revPropertyArray
      put stackArray ["objects"][aFolder]["audioclip"] into clipData
      if clipData is empty then next repeat
      
      put the tempname into someFile
      put clipData into url ("binfile:" & someFile)
      -- create audioClip -- does not work for videoClips
      import audioClip from file someFile
      -- put the result into createdObject -- RunRev bug it or the result does not give the createdObject
      
      delete local revPropertyArray ["layer"]
      set the rev_PropertyArray of audioClip clipNum to revPropertyArray
      add 1 to clipNum
   end repeat
   unlock screen
   return manifestArray
end stack_Array


--> Object | JSON
-
getprop object_PropertyJSON
   put the long id of the target into tObject
   --
   put the object_PropertyArray of tObject into pArray
   put json_FromArray (pArray, false, true) into pJSON
   --
   return pJSON
end object_PropertyJSON

getprop stack_PropertyJSON
   put the long id of the target into tObject
   --
   put the stack_Array of tObject into pArray
   put json_FromArray (pArray, false, true) into pJSON
   --
   return pJSON
end stack_PropertyJSON


--> Object | Array
-
getprop object_PropertyArray [pDontDiff]
   local objectPropArray, hArray, pExportHandlers, pForceIndexHandlerCalls
   put the long id of the target into targetObject
   object_GetPropertyArrays targetObject, objectPropArray, hArray, pExportHandlers, pDontDiff, true, pForceIndexHandlerCalls
   return objectPropArray
end object_PropertyArray

setprop object_PropertyArray [stripID] objectPropArray
   put the long id of the target into targetObject
   if objectPropArray is not an array then return targetObject
   
   lock screen 
   put objectPropArray ["rev"] into revPropertyArray
   
   put objectPropArray ["script"] into someScript
   if someScript is not empty then set the script of targetObject to someScript
   put objectPropArray ["custom"] into customArray
   if customArray is an array then set the custom_PropertyArray of targetObject to customArray
   
   switch word 1 of targetObject
      case "stack" 
         set the style of targetObject to objectPropArray ["style"]
         break
      case "field" 
         put objectPropArray ["htmlText"] into objectHtml   
         if objectHtml is not empty then put objectHtml into revPropertyArray ["htmlText"]
         break
      case "button" 
         put objectPropArray ["text"] into objectText
         if objectText is not empty then put objectText into revPropertyArray ["text"]
         break
      case "image"
         put objectPropArray ["image"] into someImage
         if someImage is not empty then
            set the fileName of targetObject to empty
            set the text of targetObject to someImage
         end if
         break
   end switch
   
   if revPropertyArray is an array then
      set the rev_PropertyArray [stripID] of targetObject to revPropertyArray
      put the result into targetObject -- id may have changed
   end if
   
   unlock screen
   return targetObject
end object_PropertyArray

command object_GetPropertyArrays targetObject, @objectPropArray, @hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   put the rev_PropertyArray [pDontDiff] of targetObject into revPropertyArray
   
   switch word 1 of targetObject
      case "stack"
         put the style of targetObject into objectPropArray ["style"]
         put the stackfiles of targetObject into stackFileTable
         if stackFileTable is not empty then put stackFileTable into objectPropArray ["stackfiles"]
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "button"
         get revPropertyArray ["text"]
         if it is not empty then put it into objectPropArray ["text"]
         delete local revPropertyArray ["text"]
         
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "field"
         get revPropertyArray ["htmlText"]
         if it is not empty then put it into objectPropArray ["htmlText"]
         delete local revPropertyArray ["htmlText"]
         
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "image"
         if revPropertyArray ["fileName"] is empty then
            put the text of targetObject into objectPropArray ["image"] -- strange hack to get the full contents of an image
         end if
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
         break
      case "videoclip"
         put the text of targetObject into objectPropArray ["videoclip"] -- strange hack to get the full contents of a videoclip
         break
      case "audioclip"
         -- put the text of targetObject into objectPropArray ["audioclip"] -- RunRev bug!!! No way to export an audoclip
         copy targetObject
         put the clipboarddata ["objects"] into objectPropArray ["audioclip"]
         break
      default
         object_AddScriptAndCustomArray objectPropArray, targetObject, hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
   end switch 
   
   put revPropertyArray into objectPropArray ["rev"] -- contains id
end object_GetPropertyArrays

command object_AddScriptAndCustomArray @objectPropArray, targetObject, @hArray, pExportHandlers, pDontExport, pForceIndexHandlerCalls
   -- this should be updated and changed to not use "lcw_ExportAndAddScriptToHarray"
   -- but use "script_ExportAndIndexMenus" or similar instead
   
   put the custom_PropertyArray of targetObject into customArray
   if customArray is an array then put customArray into objectPropArray ["custom"]
   put the script of targetObject into someScript
   if someScript is not empty then
      put someScript into objectPropArray ["script"]
      
      -- here we can also add object to the hArray (only if there is a script)
      if pref_GetValue ("Add object to hArray on stack export") is true then
         -- this can be slow (so turned off by default)
         put pref_GetValue ("Construct hashArray on stack export") into pCreateHashArray
         try
            -- a cheap way of allowing for "lcw_ExportAndAddScriptToHarray" to be missing without the handler failing
            lcw_ExportAndAddScriptToHarray hArray, targetObject, someScript, pExportHandlers, pCreateHashArray, pForceIndexHandlerCalls, pDontExport
         catch sError
            -- and so allowing for the whole comple hArtray handling set up to be in a separate (non-required) library.
            -- this should fail gracefully
            -- returning the object array (objectPropArray) without the hArray metadata
         end try
      end if
   end if
end object_AddScriptAndCustomArray
