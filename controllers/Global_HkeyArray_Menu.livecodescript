script "Global | HkeyArray | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Menu
type: controller
target: hKey
version: 0.5

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
   put the display_View of tObject into dView
   put dView into LocalArray ["dView"]
   --
   put the displayed_Hkey of dView into hKey
   --
   put the displayed_Array of dView into LocalArray ["displayed_Array"]
   put the displayed_HkeyArray of dView into hkeyArray
   put hkeyArray into LocalArray ["hkeyArray"]
   
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the overlay_Folder of hObject into overlayFolder
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

private command _DeconstructLocalArray @overlayFolder, @hKey, @stackLabel, @scriptObject
   put LocalArray ["overlayFolder"] into overlayFolder
   put LocalArray ["hKey"] into hKey
   put LocalArray ["stackLabel"] into stackLabel
   put LocalArray ["scriptObject"] into scriptObject
end _DeconstructLocalArray

private command _SetHkeyLine dView, @hKeyLine
   put the displayed_Object of dView into stackObject
   put the selected_Value of dView into selectedValue
   put the selected_Path of dView into pathItems
   
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

private command _SetShow dView, hkeyArray, showHow, stripMissingProps, hKey
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissingProps, hKey) into dData
   --
   set the displayed_Array of dView to dData
   set the show_How of dView to showHow
end _SetShow

private function _HkeyArray hKey
   return LocalArray ["hkeyArray"]
end _HkeyArray

function _DisplayedHkeys
   put LocalArray ["dView"] into dView
   put the displayed_Data of dView into dData
   put the show_How of dView into showHow
   --
   
end _DisplayedHkeys

getprop show_Param
   put LocalArray ["dView"] into dView
   put the show_How of dView into showHow
   if showHow is empty then put "projects" into showHow
   return showHow
end show_Param

getprop show_Params
   return "projects,stacks,hKeys,depKeys,-,hkeyArray"
end show_Params

getprop stripHkeys_Params
   return scriptEditor_ListTabScriptObjects()
   -- return scriptEditor_ListTabNames()
end stripHkeys_Params

private function _ScriptObject
   put LocalArray ["dView"] into dView
   put the title_Text of dView into sObject
   if exists (sObject) then
      return sObject
   else
      return empty
   end if
end _ScriptObject

private function _DisplayedHkey
   put _DisplayedView() into dView
   put the displayed_Hkey of dView into hKey
   return hKey
end _DisplayedHkey

private function _DisplayedView
   return LocalArray ["dView"]
end _DisplayedView

function hkeyStackArray_FromIndex hkeys
   repeat for each line hkey in hkeys
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      switch
         case hObject is "Missing"
         case hObject is empty
            put empty into hkeyArray ["Missing"][hKey]
            break
         default
            put revRuggedID (hObject) into hObject
            put empty into hkeyArray [hObject][hKey]
      end switch
   end repeat
   return hkeyArray
end hkeyStackArray_FromIndex

function hkeyIndex_FromProjectDepArray projectDepArray
   local hkeyArray
   repeat for each key projectName in projectDepArray
      put projectDepArray [projectName] into stackArray
      repeat for each key stackObject in stackArray
         get stackArray [stackObject]
         union hkeyArray with it
      end repeat
   end repeat
   return hkeyArray
end hkeyIndex_FromProjectDepArray

function hkeyIndex_FromData sData, showHow
   switch showHow
      case "hKeys"
         return sData
      case "hKeyArray"
         put array_List (sData) into hKeys
         return hKeys
      case "stacks"
         put hkeyStackArray_To (sData) into hkeyArray
         put array_List (hkeyArray) into hKeys
         return hKeys
      case "projects"
         put hkeyIndex_FromProjectDepArray (sData) into hkeyArray
         put array_List (hkeyArray) into hKeys
         sort hKeys
         return hKeys
      default
         return empty
   end switch
end hkeyIndex_FromData


--> Global | HkeyArray | Menu
-
on menu_DisplayedHkeys hKey
   put _DisplayedView() into dView
   put the show_How of dView into showHow
   put the displayed_Data of dView into sData 
   --
   put hkeyIndex_FromData (sData, showHow) -- into hkeys
end menu_DisplayedHkeys

on menu_DisplayDepTable hKey
   put _ScriptObject() into sObject
   put _HkeyArray() into hkeyArray
   --
   display_HkeyDepTable hkeyArray, hKey
end menu_DisplayDepTable

on menu_StripHkeys hKey, sObject
   put _DisplayedView() into dView
   put the show_How of dView into showHow
   --
   if the shiftKey is down then
      put _HkeyArray() into hKeyArray
      put hkeyArray_ListKeysWithoutObject (hkeyArray, sObject) into hKeys
   else
      put _DisplayedHkeys() into hKeys
   end if
   put hkeyStackArray_FromIndex (hKeys) into strippedStackArray
   --
   set the displayed_Array of dView to strippedStackArray
   set the show_How of dView to "stacks"
end menu_StripHkeys

on menu_Show hKey, showHow
   put _DisplayedView() into dView
   --
   put the strip_MissingProps of dView into stripMissingProps
   put the title_Text of dView into hKey
   put _HkeyArray (hKey) into hkeyArray
   --
   _SetShow dView, hkeyArray, showHow, stripMissingProps, hKey
end menu_Show

on _
end _

on menu_StackDepScript hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   --
   put the dep_StackNames of hObject
end menu_StackDepScript

on menu_CollectAll
   put _DisplayedHkey() into hKey
   put _HkeyArray (hKey) into hkeyArray
   --
   put hkeyArray_CollectScript (hkeyArray) into hkeyScript
   --
   display_Text hkeyScript, hKey, "Dep Script"
end menu_CollectAll

on menu_CollectOutside
   put _DisplayedHkey() into hKey
   put _HkeyArray (hKey) into hkeyArray
   --
   put hkeyArray_CollectScript (hkeyArray, hKey) into hkeyScript
   --
   display_Text hkeyScript, hKey, "Dep Script"
end menu_CollectOutside

on __
end __

on menu_RefreshWalk
   put _DisplayedHkey() into hKey
   display_HandlerHkeyArray hKey
end menu_RefreshWalk

on menu_RefreshStored
   put _DisplayedView() into dView
   put the displayed_Hkey of dView into hKey
   put the show_How of dView into showHow
   put hKey_GetArray (hkey) into hkeyArray
   --
   display_HandlerHkeyArray hKey, hkeyArray, hkey, showHow
end menu_RefreshStored

on ___
end ___

on submenu_HkeyArray
   return "Global | HkeyArray | Tree | Menu"
end submenu_HkeyArray

on submenu_CreateGraph
   return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

on submenu_Filter
   return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_Filter

on ____
end ____

on submenu_Dev
   return menu_DevTitle ("Global | HkeyArray | Menu")
end submenu_Dev
