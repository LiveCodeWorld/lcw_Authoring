script "Global | HkeyArray | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Menu
type: controller
target: hKey
version: 0.4

/*The menu for tree views of overlay arrays.
See also "Global | Image | Dot | Menu" and "Global | Script | Dependency | Menu"
These menus should be renamed "Global | HkeyArray | Tree | ...."

This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   --
   -- put the displayed_Object of displayView into hObject
   put the displayed_Hkey of displayView into hKey
   -- put the title_Text of displayView into hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the overlay_Folder of hObject into overlayFolder
   put the displayed_Data of displayView into hkeyArray
   --
   put hkeyArray into LocalArray ["hkeyArray"]
   put overlayFolder into LocalArray ["overlayFolder"]
   put hKey into LocalArray ["hKey"]
   put hObject into LocalArray ["scriptObject"]
   --
   return hKey
end menu_Target

getprop menu_CheckTarget [hKey]
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   return exists (hObject)
end menu_CheckTarget

-- getprop disabled_FetchHandler [displayView]
   _SetHkeyLine displayView, hKeyLine
   if hKeyLine is empty then
      return true
   else
      return false
   end if
end disabled_FetchHandler

-- getprop disabled_DisplayHandlerDeps [displayView]
   _SetHkeyLine displayView, hKeyLine
   put hkey_FetchCalls (hKeyLine) into hCalls
   return hCalls is empty
end disabled_DisplayHandlerDeps

-- getprop disabled_DisplayHandlerDeps [displayView]
   put the hilited_Element of displayView into pathItems
   
   switch item 1 of pathItems
      case "Missing"
         return true
      case "Handlers"
         if the number of items of pathItems = 1 then return true
         break
      case "Calls"
         if the number of items of pathItems < 4 then return true
         break
   end switch
   return false
end disabled_DisplayHandlerDeps

-- getprop disabled_AddToDictionary [displayView]
   put the hilited_Element of displayView into pathItems
   put item 1 of pathItems = "Missing" into isMissing
   if isMissing is false then return true
   
   put the number of items of pathItems > 2 into isLong
   if isLong is false then return true
   
   put item 3 of pathItems into shortHkeyLine
   put word 2 of shortHkeyLine into ignoreTerm
   
   put ide_IsDictionaryTerm (ignoreTerm) into isInDictionary
   if isInDictionary is true then return true
   
   return false
end disabled_AddToDictionary

private command _DeconstructLocalArray @overlayFolder, @hKey, @stackLabel, @scriptObject
   put LocalArray ["overlayFolder"] into overlayFolder
   put LocalArray ["hKey"] into hKey
   put LocalArray ["stackLabel"] into stackLabel
   put LocalArray ["scriptObject"] into scriptObject
end _DeconstructLocalArray

private command _SetHkeyLine displayView, @hKeyLine
   put the displayed_Object of displayView into stackObject
   put the selected_Value of displayView into selectedValue
   put the hilited_Element of displayView into pathItems
   
   if item 1 of pathItems = "Calls" then
      put item 4 of pathItems into hKeyLine
   else
      put item 2 of pathItems into hKeyLine
   end if
   
   switch item 1 of pathItems
      case "Calls"
         put item 4 of pathItems into hKeyLine
         break
      case "Handlers"
         put item 2 of pathItems into hKeyLine
         break
   end switch
end _SetHkeyLine


--> Global | HkeyArray | Menu
-
on menu_DisplayHkeyDepArray hKey
   put LocalArray ["hkeyArray"] into hkeyArray
   put hkeyArray_GetDepArray (hkeyArray) into hkeyDepArray
   --
   display_Data hkeyDepArray, hKey, "hkeyDepArray"
   put the result into displayView
   --
   display_SetInteractions displayView, "DepObjects | Tree", mDoubleUp
   --
   set the displayed_Hkey of indexView to hKey
   set the displayed_HkeyArray of indexView to hkeyArray
   set the displayed_HkeyDepArray of indexView to hkeyDepArray
   --
   return displayView
end menu_DisplayHkeyDepArray

on submenu_Show
   return "Global | HkeyArray | Tree | Menu"
end submenu_Show

on menu_HkeyRefresh hKey
   display_HkeyArray hKey
end menu_HkeyRefresh

on _
end _

on submenu_Hkey
   return "Global | Tree | HkeyArray | Menu"
end submenu_Hkey

on submenu_CreateGraph
   return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

on _
end _

on submenu_Filter
   return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_Filter

on submenu_Deps
   return "Global | HkeyArray | Tree | Deps | Menu"
end submenu_Deps

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _FetchHandler hKey
   _SetHkeyLine displayView, hKeyLine
   put hkey_FetchHandler (hKeyLine)
end _FetchHandler

on _DisplayHandlerDeps hKey
   _SetHkeyLine displayView, hKeyLine
   display_HandlerDeps hKeyLine
end _DisplayHandlerDeps

on _AddToDictionary displayView
   breakpoint
   
   put the displayed_Object of displayView into stackObject
   put the selected_Value of displayView into selectedValue
   put the hilited_Element of displayView into pathItems
   
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

on _RecreateOverlay displayView, overlayName
   set the cursor to watch
   
   local pImageView, pResizeStyle
   _DeconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   put overlay_GetArray (overlayFolder, overlayName) into overlayArray
   overlayArray_ConstructOverlayAndCreateFiles overlayArray, overlayFolder, overlayName
   
   display_Overlay overlayFolder, overlayName, pImageView, pResizeStyle, stackLabel
end _RecreateOverlay

on _SaveDisplayedOverlayArray displayView, graphStyle
   put the displayed_Object of displayView into scriptObject
   
   put the title_Text of displayView into hKey
   put the displayed_Array of displayView into hKeyArray
   
   -- put the displayed_OverlayFolder of displayView into overlayFolder
   put library_HkeyFolder (hKey) into overlayFolder
   
   -- put the displayed_OverlayName of displayView into overlayName
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

on _SetOverlayObject displayView
   put the displayed_Object of displayView into scriptObject
   overlay_SetOverlayObject overlayFolder, scriptObject
end _SetOverlayObject

on _ExportScriptArray displayView
   put the displayed_Array of displayView into hKeyArray
   put the displayed_Object of displayView into scriptObject
   -- set the script_OverlayData of scriptObject
   put the displayed_OverlayName of displayView into overlayName
   set the script_LinkArray [overlayName] of scriptObject to hKeyArray
   put the result into someFile
   finder_Reveal someFile
end _ExportScriptArray

on _RevealOverlayFolder displayView
   put LocalArray ["overlayFolder"] into overlayFolder
   finder_Reveal overlayFolder
end _RevealOverlayFolder
