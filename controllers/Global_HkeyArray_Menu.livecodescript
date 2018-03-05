script "Global_HkeyArray_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Menu
type: controller
version: 0.4

/*
The menu for tree views of overlay arrays.
See also "Global | Image | Dot | Menu" and "Global | Script | Dependency | Menu"
These menus should be renamed "Global | HkeyArray | Tree | ...."

This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!
*/



--> Variables
-
local LocalArray


private command _SetHkeyLine treeView, @hKeyLine
   put the displayed_Object of treeView into stackObject
   put the selected_Value of treeView into selectedValue
   put the hilited_Element of treeView into pathItems
   
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
on menu_DisplayDepObjects mTarget
   -- mTarget seems to be cardObject ???
   put LocalArray ["treeView"] into treeView
   
   put the displayed_Object of treeView into hObject
   put the displayed_Hkey of treeView into hKey
   
   put the hkey_Array of treeView into hkeyArray
   -- put the view_Data of treeView into hkeyArray
   put the displayed_Array of treeView into objectHkeyArray
   
   put keys (objectHkeyArray) into depObjects
   put hKey into someTitle
   put "DepObjects" into item 2 to -1 of someTitle
   
   display_Index depObjects, someTitle, "Global | DepObjects | Tree | Menu", "Global | DepObjects | Line | Menu"
   put the result into indexView
   
   set the displayed_Hkey of indexView to hKey
   --  set the displayed_Object of indexView to hObject
   
   set the displayed_HkeyArray of indexView to hkeyArray
   set the displayed_ObjectHkeyArray of indexView to objectHkeyArray
   
   -- set the displayed_Object of indexView to hObject
   set the displayed_Hkey of indexView to hKey
end menu_DisplayDepObjects

on _
end _

on menu_FetchHandler treeView
   _SetHkeyLine treeView, hKeyLine
   put hkey_FetchHandler (hKeyLine)
end menu_FetchHandler

on menu_DisplayHandlerDeps treeView
   _SetHkeyLine treeView, hKeyLine
   display_HandlerDeps hKeyLine
end menu_DisplayHandlerDeps

on menu_AddToDictionary treeView
   breakpoint
   
   put the displayed_Object of treeView into stackObject
   put the selected_Value of treeView into selectedValue
   put the hilited_Element of treeView into pathItems
   
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
end menu_AddToDictionary

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

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev

on _
end _

on menu_TestValue treeView
   put the selected_Value of treeView into selectedValue
   if selectedValue is an array then
      display_Array selectedValue
   else
      put selectedValue
   end if
end menu_TestValue


--> Global | HkeyArray | Menu | Props
-

--> Global | HkeyArray | Menu | Disabled
-
getprop disabled_FetchHandler [treeView]
   _SetHkeyLine treeView, hKeyLine
   if hKeyLine is empty then
      return true
   else
      return false
   end if
end disabled_FetchHandler

getprop disabled_DisplayHandlerDeps [treeView]
   _SetHkeyLine treeView, hKeyLine
   put hkey_FetchCalls (hKeyLine) into hCalls
   return hCalls is empty
end disabled_DisplayHandlerDeps

getprop disabled_DisplayHandlerDeps [treeView]
   put the hilited_Element of treeView into pathItems
   
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

getprop disabled_AddToDictionary [treeView]
   put the hilited_Element of treeView into pathItems
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


--> Deps
-

--> Dev | Menu
-
on menu_RecreateOverlay treeView, overlayName
   set the cursor to watch
   
   local pImageView, pResizeStyle
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   put overlay_GetArray (overlayFolder, overlayName) into overlayArray
   overlayArray_ConstructOverlayAndCreateFiles overlayArray, overlayFolder, overlayName
   
   display_Overlay overlayFolder, overlayName, pImageView, pResizeStyle, stackLabel
end menu_RecreateOverlay

on menu_SaveDisplayedOverlayArray treeView, graphStyle
   put the displayed_Object of treeView into scriptObject
   
   put the title_Text of treeView into hKey
   put the displayed_Array of treeView into hKeyArray
   
   -- put the displayed_OverlayFolder of treeView into overlayFolder
   put library_HkeyFolder (hKey) into overlayFolder
   
   -- put the displayed_OverlayName of treeView into overlayName
   put lcw_Ask ("What name would you like to give this overlay?", graphStyle) into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   overlay_SetArray overlayFolder, overlayArray, overlayName
   
   lcw_Notify "Saved array, but not created graph files for this new array!", true
   display_OverlayData overlayFolder, hKey
end menu_SaveDisplayedOverlayArray

on menu_SetOverlayObject treeView
   put the displayed_Object of treeView into scriptObject
   overlay_SetOverlayObject overlayFolder, scriptObject
end menu_SetOverlayObject

on menu_ExportScriptArray treeView
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   -- set the script_OverlayData of scriptObject
   put the displayed_OverlayName of treeView into overlayName
   set the script_LinkArray [overlayName] of scriptObject to hKeyArray
   put the result into someFile
   finder_Reveal someFile
end menu_ExportScriptArray

on menu_RevealOverlayFolder treeView
   put LocalArray ["overlayFolder"] into overlayFolder
   finder_Reveal overlayFolder
end menu_RevealOverlayFolder


--> Menu | Props
-
on menu_Init targetObject, mPath, mTitlePath
   put the tree_View of targetObject into treeView
   
   put the displayed_Object of treeView into scriptObject
   if exists (scriptObject) is true then
      put empty into hKey
      put the name of scriptObject into stackLabel
      put the overlay_Folder of scriptObject into overlayFolder 
   else
      put the displayed_Hkey of treeView into hKey
      -- put the title_Text of treeView into hKey
      put hKey into stackLabel
      -- put library_HkeyFolder (hKey) into overlayFolder
      -- put the overlay_Folder of scriptObject into overlayFolder
   end if
   
   put treeView into LocalArray ["treeView"]
   put targetObject into LocalArray ["targetObject"]
   put overlayFolder into LocalArray ["overlayFolder"]
   put hKey into LocalArray ["hKey"]
   put stackLabel into LocalArray ["stackLabel"]
   put scriptObject into LocalArray ["scriptObject"]
end menu_Init

command deconstructLocalArray @overlayFolder, @hKey, @stackLabel, @scriptObject
   put LocalArray ["overlayFolder"] into overlayFolder
   put LocalArray ["hKey"] into hKey
   put LocalArray ["stackLabel"] into stackLabel
   put LocalArray ["scriptObject"] into scriptObject
end deconstructLocalArray
