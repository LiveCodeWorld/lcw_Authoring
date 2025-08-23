script "Global | HkeyArray | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | HkeyArray | Dev | Menu
-
--> Dev | Menu
-
on menu_DisplayHkeyDepArray hKey
   put LocalArray ["hkeyArray"] into hkeyArray
   put hkeyArray_GetStackDepArray (hkeyArray) into hkeyDepArray
   --
   display_Data hkeyDepArray, hKey, "hkeyDepArray"
   put the result into dView
   --
   display_SetInteractions dView, "DepObjects | Tree", mDoubleUp
   --
   set the displayed_Hkey of indexView to hKey
   set the displayed_HkeyArray of indexView to hkeyArray
   set the displayed_HkeyDepArray of indexView to hkeyDepArray
   --
   return dView
end menu_DisplayHkeyDepArray

on menu_DisplayStoredDepArray hKey
   display_HkeyDepArray hKey
end menu_DisplayStoredDepArray

on _FetchHandler hKey
   _SetHkeyLine dView, hKeyLine
   put hkey_FetchHandler (hKeyLine)
end _FetchHandler

on _DisplayHandlerDeps hKey
   _SetHkeyLine dView, hKeyLine
   display_HandlerDeps hKeyLine
end _DisplayHandlerDeps

on _AddToDictionary dView
   breakpoint
   
   put the displayed_Object of dView into stackObject
   put the selected_Value of dView into selectedValue
   put the hilited_Element of dView into pathItems
   
   if selectedValue is an array then
      put line 1 of the keys of selectedValue into pShortCall
      put selectedValue [pShortCall] into hObject
   else
      put selectedValue into hObject
      put item -1 of pathItems into pShortCall
   end if
   put hKeyLine_Construct (pShortCall, hObject) into pHkey
   
   put item 3 of pathItems into shortHkeyLine
   put word 2 of shortHkeyLine into ignoreTerm
   
   put merge ("You want to add the term '[[ignoreTerm]]' to the dictionary of built-in Livecode terms?") into someComment
   lcw_Answer someComment
   
   ide_AddToDictionaryTerms ignoreTerm, pHkey
   
   put merge ("Added term '[[ignoreTerm]]'. Do you want to re-index the script?") into someComment
   lcw_Answer someComment
   
   put ide_ListExtraDicTerms()
   script_ExportHandlersAndCalls stackObject, true
end _AddToDictionary

on _
end _

on _RecreateOverlay dView, overlayName
   set the cursor to watch
   
   local pImageView, pResizeStyle
   _DeconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   put overlay_GetArray (overlayFolder, overlayName) into overlayArray
   overlayArray_ConstructOverlayAndCreateFiles overlayArray, overlayFolder, overlayName
   
   display_Overlay overlayFolder, overlayName, pImageView, pResizeStyle, stackLabel
end _RecreateOverlay

on _SaveDisplayedOverlayArray dView, graphStyle
   put the displayed_Object of dView into scriptObject
   
   put the title_Text of dView into hKey
   put the displayed_Data of dView into hKeyArray
   
   -- put the displayed_OverlayFolder of dView into overlayFolder
   put library_HkeyFolder (hKey) into overlayFolder
   
   -- put the displayed_OverlayName of dView into overlayName
   put lcw_Ask ("What name would you like to give this overlay?", graphStyle) into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   overlay_SetArray overlayFolder, overlayArray, overlayName
   
   lcw_Notify "Saved array, but not created graph files for this new array!", true
   display_OverlayData overlayFolder, hKey
end _SaveDisplayedOverlayArray

on _SetOverlayObject dView
   put the displayed_Object of dView into scriptObject
   overlay_SetOverlayObject overlayFolder, scriptObject
end _SetOverlayObject

on _ExportScriptArray dView
   put the displayed_Data of dView into hKeyArray
   put the displayed_Object of dView into scriptObject
   -- set the script_OverlayData of scriptObject
   put the displayed_OverlayName of dView into overlayName
   set the script_LinkArray [overlayName] of scriptObject to hKeyArray
   put the result into someFile
   finder_Reveal someFile
end _ExportScriptArray

on _RevealOverlayFolder dView
   put LocalArray ["overlayFolder"] into overlayFolder
   finder_Reveal overlayFolder
end _RevealOverlayFolder
