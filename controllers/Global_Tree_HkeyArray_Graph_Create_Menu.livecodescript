script "Global | Tree | HkeyArray | Graph | Create | Menu"
--> MetaData
-
license: GPLv3
name: Global | Tree | HkeyArray | Graph | Create | Menu
type: controller
version: 0.4

--> Variables
-
local LocalArray


--> Menu | Props
-
/*
This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!
*/

--> Menu | Init
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put the displayed_Object of dView into scriptObject
   if exists (scriptObject) is false then
      -- put the title_Text of dView into hKey
      put the displayed_Hkey of dView into hKey
      hkey_Deconstruct hKey, hName, hType, hObject, hNum
      put hObject into scriptObject
   end if
   
   if exists (scriptObject) is true then
      put the overlay_Folder of scriptObject into overlayFolder
      put overlay_ListNames (overlayFolder) into LocalArray ["overlayNames"]
      --
      put overlayFolder into LocalArray ["overlayFolder"]
      put dot_ListGraphStyles() into LocalArray ["graphStyles"]
      put scriptObject into LocalArray ["scriptObject"]
   end if
   --
   put dView into LocalArray ["dView"]
   put hkeyArray into LocalArray ["hkeyArray"]
   return scriptObject
end menu_Target

getprop menu_CheckTarget [scriptObject]
   return exists (scriptObject)
end menu_CheckTarget

command deconstructLocalArray @overlayFolder, @hKey, @stackLabel, @scriptObject
   put LocalArray ["overlayFolder"] into overlayFolder
   put LocalArray ["hKey"] into hKey
   put LocalArray ["stackLabel"] into stackLabel
   put LocalArray ["scriptObject"] into scriptObject
end deconstructLocalArray


--> Menu | Props
-
getprop displaySvg_Params [treeView]
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put the script_SvgShortFiles of scriptObject into shortSvgFiles
   return shortSvgFiles
end displaySvg_Params

getprop createSvgGraph_Params
   return LocalArray ["graphStyles"]
end createSvgGraph_Params

getprop createNewGraphFromTree_Params
   return LocalArray ["graphStyles"]
end createNewGraphFromTree_Params

getprop createTemporaryObjectGraphFromTree
   return LocalArray ["graphStyles"]
end createTemporaryObjectGraphFromTree

getprop createTemporaryHkeyGraphFromTree_Params
   return LocalArray ["graphStyles"]
end createTemporaryHkeyGraphFromTree_Params

getprop createLibraryHkeyDependencyGraph
   return LocalArray ["graphStyles"]
end createLibraryHkeyDependencyGraph

getprop createLibraryObjectHkeyDependencyGraph_Params
   return LocalArray ["graphStyles"]
end createLibraryObjectHkeyDependencyGraph_Params

getprop createLibraryObjectHkeyDependencyGraph_Params
   return LocalArray ["graphStyles"]
end createLibraryObjectHkeyDependencyGraph_Params

getprop displayHkeyOverlayGraph_Params
   return LocalArray ["overlayNames"]
end displayHkeyOverlayGraph_Params

getprop displayOverlayGraph_Params
   return LocalArray ["overlayNames"]
end displayOverlayGraph_Params

getprop disabled_DisplaySvg [scriptObject]
   -- should be a simpler way
   put the project_OverlayFolder of scriptObject into projectMetaDataFolder
   put empty into pOverlayName
   put overlay_GetArray (projectMetaDataFolder, pOverlayName) into overlayArray
   put overlayArray_GetImageFile (overlayArray, projectMetaDataFolder) into svgFile
   put svgFile into LocalArray ["svgFile"]
   if svgFile is empty then
      return true
   else
      return false
   end if
end disabled_DisplaySvg


--> Global | Tree | HkeyArray | Graph | Create | Menu
-
on menu_DisplaySvg scriptObject, shortSvgFile
   -- put the projectOverlay_SvgFile of scriptObject into svgFile
   put the scriptObject_SvgFile [shortSvgFile] of scriptObject into svgFile
   --
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      display_SVG svgFile
   end if
end menu_DisplaySvg

on menu_CreateSvgGraph sObject, graphStyle
   put LocalArray ["hkeyArray"] into hkeyArray
   put LocalArray ["dView"] into dView
   
   graph_CreateFromScriptHkeyArray hKeyArray, sObject, graphStyle
   put the result into svgFile
   --
   put the title_Text of dView into stackLabel
   display_SVG svgFile, stackLabel
   put the result into displayView
   --
   set the displayed_Object of displayView to sObject
   return displayView
end menu_CreateSvgGraph

on menu_DisplayLinkArrayGraph sObject
   put LocalArray ["hkeyArray"] into linkArray
   --
   display_LinkArrayGraph linkArray, "LinkArray Graph"
end menu_DisplayLinkArrayGraph

on menu_SimpleGraph sObject
   put LocalArray ["hkeyArray"] into linkArray
   --
   put dot_FromHkeyLinkArray (linkArray) into dotText
   dot_CreateGraph dotText
   put the result into svgFile
   --
   display_SVG svgFile
end menu_SimpleGraph


on _
end _

on menu_DisplayProcessedHkeyArray scriptObject
   display_ObjectDepArray scriptObject
end menu_DisplayProcessedHkeyArray

on menu_DisplayOverlayFolder scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   finder_Reveal overlayFolder
end menu_DisplayOverlayFolder

on menu_DisplayProjectOverlayFolder scriptObject
   put the project_OverlayFolder of scriptObject into projectMetaDataFolder
   finder_Reveal projectMetaDataFolder
end menu_DisplayProjectOverlayFolder


--> Dev | Menu
-
/*
This section looks like a well structured old menu for manipulating hkeyArray grpah data.
needs testing. It is designed for treeView not scriptObject
*/

on menu_DisplayObjectGraph scriptObject
   local pGraphStyle, pProcessObject, projectName
   --
   display_CreateScriptObjectGraph scriptObject, projectName, pGraphStyle, pProcessObject, false
   --
   display_ObjectDepArray scriptObject
end menu_DisplayObjectGraph

/*
on menu_CreateNewGraphFromTree treeView, graphStyle
   put lcw_Ask ("What name would you like to give this overlay?", graphStyle) into overlayName
   -- put the displayed_OverlayName of treeView into overlayName
   
   put the view_Data of treeView into hkeyArray
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   -- hkeyArray_ConstructOverlayAndCreateFiles hKeyArray, graphStyle, overlayFolder, overlayName, true
   put overlayArray_FromLinkArray (hKeyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Folder", overlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   if exists(scriptObject) then
      overlayArray_SetGraphProperty overlayArray, "overlay_Of", scriptObject
   else
      overlayArray_SetGraphProperty overlayArray, "overlay_Of", hKey
   end if
   
   -- overlayArray_ConstructOverlayAndCreateFiles overlayArray, overlayFolder, overlayName
   overlay_SetArray overlayFolder, overlayArray, overlayName
   overlayArray_CreateFilesAndSetGeometry overlayArray
   
   local pImageView, pResizeStyle
   display_Overlay overlayFolder, graphStyle, pImageView, pResizeStyle, stackLabel
end menu_CreateNewGraphFromTree

on _
end _

on menu_CreateTemporaryObjectGraphFromTree treeView, graphStyle
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put the displayed_OverlayFolder of treeView into overlayFolder
   put the displayed_OverlayName of treeView into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   local imageView, resizeStyle
   if exists (scriptObject) then
      put the name of scriptObject into stackLabel
   else
      put the title_Text of treeView into stackLabel
   end if
   overlayArray_CreateAndDisplayGraph overlayArray, graphStyle, overlayFolder, imageView, resizeStyle, stackLabel
   put the result into displayView
end menu_CreateTemporaryObjectGraphFromTree

on menu_CreateTemporaryHkeyGraphFromTree treeView, graphStyle
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put the displayed_OverlayFolder of treeView into overlayFolder
   put the displayed_OverlayName of treeView into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   local imageView, resizeStyle
   if exists (scriptObject) then
      put the name of scriptObject into stackLabel
   else
      put the title_Text of treeView into stackLabel
   end if
   overlayArray_CreateAndDisplayGraph overlayArray, graphStyle, overlayFolder, imageView, resizeStyle, stackLabel
   put the result into displayView
end menu_CreateTemporaryHkeyGraphFromTree

on _
end _

on menu_CreateLibraryHkeyDependencyGraph treeView, graphStyle
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put the displayed_Array of treeView into hKeyArray
   put item 3 of hKey into hObject
   put the overlay_Folder of hObject into overlayFolder
   
   library_CreateHkeyGraph hKey, hKeyArray, graphStyle, pOverlayName, pDotCluster, pOverlayHash
end menu_CreateLibraryHkeyDependencyGraph

on menu_CreateLibraryObjectHkeyDependencyGraph treeView, graphStyle
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put the displayed_Array of treeView into hKeyArray
   put library_HandlerFile (hKey) into overlayFolder
   
   library_CreateHkeyGraph hKey, hKeyArray, graphStyle, pOverlayName, pDotCluster, pOverlayHash
end menu_CreateLibraryObjectHkeyDependencyGraph

on _
end _

on menu_DisplayHkeyOverlayGraph treeView, hkeyOverlayName
   set the cursor to watch
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put item 3 of hKey into hObject
   put the overlay_Folder of hObject into overlayFolder
   
   display_Overlay overlayFolder, hkeyOverlayName
end menu_DisplayHkeyOverlayGraph

on menu_DisplayExternalMainStackHkeyArray treeView
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put item 3 of hKey into hObject
   put the mainstack_WalkArray of hObject into mainStackHkeyWalkArray
   put mainStackHkeyWalkArray ["external"] into externalArray
   
   local hKeyArray
   repeat for each key shortCall in externalArray
      put externalArray [shortCall] into leafArray
      put line 1 of keys (leafArray) into leafkey
      put leafArray [leafkey] into externalKey
      
      get hkey_DependencyArrayFromObjects (externalKey)
      if it is not an array then
         put empty into it [externalKey]
      end if
      union hKeyArray with it
      
      /*
      put hArray_GetShortCalls (externalKey) into shortCalls
      repeat for each line shortCall in shortCalls
         hArray_DependencyWalk shortCall, externalKey, hKeyWalkArray
      end repeat
      */
   end repeat
   
   display_Array hKeyArray, hkey
end menu_DisplayExternalMainStackHkeyArray

on menu_RevealHkeyGraphFolder treeView
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put item 3 of hKey into hObject
   put the overlay_Folder of hObject into overlayFolder
   
   finder_Reveal overlayFolder
end menu_RevealHkeyGraphFolder

on _
end _

on menu_DisplayOverlayGraph treeView, overlayName
   set the cursor to watch
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   local pImageView, pResizeStyle
   display_Overlay overlayFolder, overlayName, pImageView, pResizeStyle, stackLabel
end menu_DisplayOverlayGraph
*/


--> Deps
-
function dot_ListGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring" 
end dot_ListGraphStyles
