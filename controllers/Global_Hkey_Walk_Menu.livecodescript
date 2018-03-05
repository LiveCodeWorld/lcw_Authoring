script "Global_Hkey_Walk_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Walk_Menu
type: controller
version: 0.3

/*
This menu concentrates on walking the dependency tree of a handler.

set the behavior of group "Editor" of me to 
set the behavior of group "Menubar" of me to the long id of stack revIDEScriptEditorBehavior("menubar")
set the behavior of group "Script Tabs" me to the long id of stack revIDEScriptEditorBehavior("scripttabs")
set the behavior of group "Toolbar" of me to the long id of stack revIDEScriptEditorBehavior("toolbar")
set the behavior of group "Handler List" of me to the long id of stack revIDEScriptEditorBehavior("handlerlist")
set the behavior of group "Left Bar" of me to the long id of stack revIDEScriptEditorBehavior("leftbar")
set the behavior of field "Filter" of group "Left Bar" of me to the long id of stack revIDEScriptEditorBehavior("filterfield")
set the behavior of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("variablespane")
set the behavior of group "Documentation" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("documentationpane")
set the behavior of field "Filter" of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("filterfield")
set the behavior of button "Show Globals" of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("variablescheckbox")
set the behavior of button "Show Environment Vars" of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("variablescheckbox")
set the behavior of group "Gutter" of group "Editor" of me to the long id of stack revIDEScriptEditorBehavior("gutter")
set the behavior of group "Interactive Find" of group "Editor" of me to the long id of stack revIDEScriptEditorBehavior("interactive find")

*/

--> Variables
-
local LocalArray


--> Global | Hkey | Walk | Menu
-
on menu_CreateHandlerObjectGraph hKey
   -- set the behavior of stack "Temp Revigniter Controllers" to empty
   
   -- put empty into projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   
   hkey_CreateAndDisplayDeps hkey, projectName
   
   put hkey_SvgFile (hKey) into svgFile
   finder_Reveal imageFile
   
   -- set the behavior of stack "Temp Revigniter Controllers" to the long id of stack "behavior_RigLocalOveride"
end menu_CreateHandlerObjectGraph

on menu_CreateHandlerGraph hKey
   -- without clusters
   set the behavior of stack "Temp Revigniter Controllers" to empty
 
   -- put empty into projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   
   hkey_CreateAndDisplayDeps hkey, projectName, false
   put hkey_SvgFile (hKey) into svgFile
   finder_Reveal imageFile
end menu_CreateHandlerGraph

on _
end _

on menu_WalkExportedHkeyDeps hKey
   display_HandlerDeps hKey
end menu_WalkExportedHkeyDeps

on menu_WalkHkey hKey, projectName
   set the behavior of stack "Temp Revigniter Controllers" to empty
   
   hkey_CreateAndDisplayDeps hkey, projectName
   put hkey_SvgFile (hKey) into svgFile
   finder_Reveal imageFile
end menu_WalkHkey

on _
end _

on menu_DisplayHkeySvg hKey
   put hkey_SvgFile (hKey) into svgFile
   if scriptEditor_PaneExists ("Deps") then
      display_ScriptEditorSvg svgFile
   end if
   
   put hkey into stackLabel
   display_SVG svgFile, stackLabel
end menu_DisplayHkeySvg

on _
end _

on menu_HkeyArrayFromExported hKey
   put hkeyArray_FromExported (hKey) into hkeyArray
   display_Array hkeyArray
end menu_HkeyArrayFromExported

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_TestFindAndAdd hKey
   put "lcw_Wiki" into projectName
   -- put empty into projectName
   
   set the behavior of stack "Temp Revigniter Controllers" to empty
   -- put empty into projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   
   put "json_FromArray,f" into shortHKey
   put empty into foundStackArray
   put hkey_FindAndAdd (shortHKey, hObject, foundStackArray, projectName)
end menu_TestFindAndAdd

on menu_OverlayArrayFile hKey
   put hkey_OverlayDataFile (hKey) into overlayArrayFile
   finder_Reveal overlayArrayFile
end menu_OverlayArrayFile

on menu_RevealMetadataFolder hKey
   put hkey_MetadataFolder (hKey) into metadataFolder
   finder_Reveal metadataFolder
end menu_RevealMetadataFolder


--> Global | Hkey | Walk | Menu | Props
-
getprop project_Name [hKey]
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   return projectName
end project_Name

getprop project_Names
   put library_ListProjectNames() into projectNames
   return projectNames
end project_Names


--> Global | Hkey | Walk | Menu | Disabled
-
getprop disabled_DisplayHkeySvg [hKey]
   put hkey_SvgFile (hKey) into svgFile
   if there is a file svgFile then
      return false
   else
      return true
   end if
end disabled_DisplayHkeySvg


/*
--> Deps
-
command project_WalkAndStoreObjectDependencies hKey, pAllCalls, pSetName 
   put hkey_DependencyArrayFromObjects (hKey, pSetName, pAllCalls) into hKeyArray
      
   -- let's store the overlay in the project handler metadata folder (and create a hierarchical graph)
   put empty into pOverlayName 
   put item 3 of hKey into hObject
   put the mainstack_Hash of hObject into mainstackHash
   project_StoreHkeyArray hKey, hkeyArray, pOverlayName, mainstackHash, "hierarchical"
   return hkeyArray
end project_WalkAndStoreObjectDependencies

command project_StoreHkeyArray hKey, hkeyArray, pOverlayName, pMainstackHash, pGraphStyle
   -- store hKeyArray in hkey project metadata folder
   if pOverlayName is empty then put "hierarchical" into pOverlayName
   -- put project_HandlerMetadataFolder (hKey) into hkeyMetadataFolder
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   
   overlay_SetLinkArray hkeyMetadataFolder, hkeyArray, pOverlayName, pGraphStyle, pMainstackHash
   return hkeyArray
end project_StoreHkeyArray

getprop disabled_FetchStoredHkeyArray [hKey]
   put hkey_OverlayDataFile (hKey) into overlayArrayFile
   if there is a file overlayArrayFile then
      return false
   else
      return true
   end if
end disabled_FetchStoredHkeyArray

getprop disabled_FetchStoredHkeyArray [hKey]
   put project_FetchHkeyArray (hKey) into hKeyArray
   if hKeyArray is an array then
      put hKeyArray into LocalArray ["project_FetchHkeyArray"]
      return false
   else
      return true
   end if
end disabled_FetchStoredHkeyArray

function project_HandlerMetadataFolder hKey, pDontCreate
   -- for the handler/hkey library metadata is in the same folder as the scripts
   -- in the project handler export - handlers and metadata are in separate roots.
   put item 3 of hKey into hObject
   if exists (hObject) is false then return empty
   
   put the textStack_MetadataFolder [pDontCreate] of hObject into metadataFolder
   
   put item 1 of hKey & "_" & item 2 of hKey into folderName
   put metadataFolder & "handlers/" & folderName & "/" into handlerFolder
   if pDontCreate is false then folder_CreateNested handlerFolder
   return handlerFolder
end project_HandlerMetadataFolder

function project_HandlerHelpFile hKey, pDontCreate
   return project_HandlerMetadataFolder (hKey, pDontCreate) & "help.html"
end project_HandlerHelpFile

function project_FetchHandlerHelp hKey
   put project_HandlerHelpFile (hKey) into someFile
   if someFile is empty then return empty
   put url ("binfile:" & someFile) into helpHtml
   return helpHtml
end project_FetchHandlerHelp


-- function project_HackExtractHkeyArray hKey, pReIndexFromObjects, pSetName, pAllCalls
   -- was "project_GetHkeyArray"
   
   -- get the best option
   -- try mainstack walkarray first, then project hkey overlay, and finally walk the objects
   -- check hashes to ensure only up to date returned
   -- create new project hkey overlay from object walk if no up-to-date hKeyArray present
   
   if pReIndexFromObjects is not true then
      put item 3 of hKey into hObject
      if exists (hObject) is false then 
         breakpoint
         return empty
      end if
      put the mainstack_Hash of hObject into mainstackHash
      
      -- first choice get from the mainstack walk array if it is indexed and up to date
      put project_HkeyArrayFromMainstackWalkArray (hKey, mainstackHash) into hKeyArray
      if hKeyArray is an array then return hKeyArray
      
      -- next let's look for a locally stored hKeyArray as part of an project hKey overlay
      put empty into pOverlayName 
      
      -- put project_FetchHkeyArray (hKey, pOverlayName, mainstackHash) into hKeyArray
      local overlayArray, storedStackHash
      put project_HandlerMetadataFolder (hKey) into overlayFolder
      project_FetchOverlayArrayAndHash hKey, pOverlayName, overlayArray, storedStackHash
      put overlayArray_GetLinkArray (overlayArray) into hkeyArray
      if storedStackHash = mainstackHash then return hkeyArray
   end if
   
   -- finally let's walk the dependency graph of each object
   project_WalkAndStoreObjectDependencies hKey, pAllCalls, pSetName
   put the result into hkeyArray
   return hkeyArray
end project_HackExtractHkeyArray
*/
