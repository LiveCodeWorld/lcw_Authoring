script "Global_Menu_Global_Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Global | Menu
type: controller
version: 0.6


--> Global | Menu | Global | Menu
-
on menu_DisplayProjectArray mTarget, projectName
   put project_FetchArray (projectName) into projectArray
   
   put merge ("project_FetchArray(),[[projectName]]") into someTitle
   display_Array projectArray, someTitle, "Global | Menu | Global | Menu"
end menu_DisplayProjectArray

on menu_DisplayProjectGlobals mTarget, projectName
   put project_FetchValue ("projectGlobalArray", projectName) into projectGlobalArray
   
   put merge ("project_FetchValue ('projectGlobalArray'),[[projectName]]") into someTitle
   display_Array projectGlobalArray, someTitle, "Global | Menu | Global | Menu"
end menu_DisplayProjectGlobals

on _
end _

on menu_DisplayDefaultStackfileArray mTarget, projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ConstructStackFileArray (projectFolder) into projectStackFileArray
   
   display_Array projectStackFileArray, "project_ConstructStackFileArray()"
end menu_DisplayDefaultStackfileArray

on menu_DisplaySavedStackfileArray mTarget, projectName
   put project_FetchValue ("stackFileArray", projectName) into projectStackFileArray
   
   display_Array projectStackFileArray, "project_FetchValue ('stackFileArray', projectName)"
end menu_DisplaySavedStackfileArray

on menu_StoreProjectStackfileArray mTarget, projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ConstructStackFileArray (projectFolder) into projectStackFileArray
   project_SaveValue "stackFileArray", projectStackFileArray, projectName
   
   menu_DisplayDefaultStackfileArray mTarget, projectName
end menu_StoreProjectStackfileArray

on menu_StoreDefaultProjectGlobals mTarget, projectName
   lcw_LoadProjectMenus projectName
   put the result into gMenuArray
   
   project_SaveValue "Global Menus", gMenuArray, projectName
   
   -- temp hack
   project_DeleteValue "projectGlobalArray", projectName
   
   menu_DisplayProjectArray mTarget, projectName
end menu_StoreDefaultProjectGlobals

on _
end _

-- on menu_FixOpenStacks mTarget, projectName
   put project_FetchArray (projectName) into projectArray
   
   put projectArray ["openStacks"] into projectOpenStacks
   delete variable projectArray ["openStacks"]
   put projectOpenStacks into projectArray ["projectGlobalArray"]["gLCW"]["openStacks"]
   
   put projectArray ["Global Menus"] into gMenuTitleArray
   delete variable projectArray ["Global Menus"]
   put gMenuTitleArray into projectArray ["projectGlobalArray"]["gLCW"]["Global Menus"]
   
   project_StoreArray projectName, projectArray
end menu_FixOpenStacks

on menu_StoreGatheredProjectGlobals mTarget, projectName
   put global_Gather() into projectGlobalArray
   project_SaveValue "projectGlobalArray", projectGlobalArray, projectName
end menu_StoreGatheredProjectGlobals

on menu_RestoreProjectGlobals mTarget, projectName
   project_RestoreGlobals projectName
   
   menu_DisplayProjectGlobals mTarget, projectName
end menu_RestoreProjectGlobals

on _
end _

on menu_DisplayGatherGlobals
   put global_Gather() into globalArray
   display_Array globalArray, "global_Gather()", "Global | Menu | Global | Menu"
end menu_DisplayGatherGlobals
   
on menu_DisplayGlobal mTarget, globalName
   display_GlobalValue globalName
end menu_DisplayGlobal

on menu_DeleteGlobal mTarget, globalName
   global_Delete globalName
end menu_DeleteGlobal

-- on menu_DeleteAllGlobals
   global_DeleteAll
end menu_DeleteAllGlobals

on _
end _

on menu_DisplayDumpedGlobals
   put library_FetchGlobalDump() into globalArray
   display_Array globalArray, "library_FetchGlobalDump()", "Global | Menu | Global | Menu"
end menu_DisplayDumpedGlobals

on menu_RestoreDumpedGlobals
   library_RestoreGlobalDump
   menu_DisplayGatherGlobals
end menu_RestoreDumpedGlobals

on menu_DumpAllGlobals
   put global_Gather() into globalArray
   library_StoreGlobalDump globalArray
end menu_DumpAllGlobals

on _
end _

on menu_DeleteAllGlobals
   global_DeleteAll
end menu_DeleteAllGlobals

on menu_DeleteDumpFile
   library_DeleteGlobalDump
end menu_DeleteDumpFile

on _
end _

on submenu_Project
   return "Global | Project | Menu"
end submenu_Project

on submenu_Prefs
   return "Global | Pref | Menu"
end submenu_Prefs

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Menu | Global | Menu | Props
-
getprop project_Name
   return env_GetProjectFocus()
end project_Name

getprop project_Names
   return library_ListProjectNames ()
end project_Names

getprop global_Names
   put global_ListNames (false) into gNames
   return gNames
end global_Names


--> Global | Menu | Global | Menu | Disabled
-
getprop disabled_DisplayDumpedGlobals
   return library_GlobalDumpFileMissing()
end disabled_DisplayDumpedGlobals

getprop disabled_RestoreDumpedGlobals
   return library_GlobalDumpFileMissing()
end disabled_RestoreDumpedGlobals

getprop disabled_DeleteDumpFile
   return library_GlobalDumpFileMissing()
end disabled_DeleteDumpFile


--> Dev | Menu
-
on menu_ConstructDefaultGlobals mTarget, projectName
   global gLCW
   
   lcw_LoadProjectMenus projectName
   put the result into gMenuArray
   -- put gMenuArray into gLCW ["Global Menus"]
   
   display_Array gMenuArray, "project_LoadMenus", "Global | Menu | Global | Menu"
   display_Array gLCW, "gLCW", "Global | Menu | Global | Menu"
end menu_ConstructDefaultGlobals

on menu_DeleteUneededGlobals
   global gLCW
   delete variable gLCW ["behaviorArray"]
   delete variable gLCW ["handlerArray"]
   delete variable gLCW ["keywordArray"]
   delete variable gLCW ["objectType"]
   delete variable gLCW ["scriptArray"]
   
   menu_DisplayGatherGlobals
end menu_DeleteUneededGlobals

on _
end _

on menu_IndexLcwScripts
   -- lcw_ExportAndAddScriptToHarray cardObject
   put lcw_GetRootFolder() into projectFolder
   project_IndexAllScripts projectFolder
end menu_IndexLcwScripts

on menu_IndexAStack
   global gLCW
   
   put the name of stack "Global_Git_Log_Menu" into mController
   put the script of mController into someScript
   
   -- update the extensive metadata stored in gLCW
   -- script_UpdateHarrayAndExport mController, false
   
   put true into forceIndexHandlerCalls
   put true into createHashArray
   
   lcw_ExportAndAddScriptToHarray gLCW, mController, someScript --, createHashArray, forceIndexHandlerCalls, false
   put the result into scriptFile
   
   set the menu_Update of mController to true
   put the result into mTitleTableArray
   
   display_Array gLCW, "lcw_ExportAndAddScriptToHarray lcwArray"
   display_Array mTitleTableArray, "the script_MenuTitleTableArray"
end menu_IndexAStack

on menu_IndexAnotherStack
   put "Global_Array_Menu" into gMenuTitle
   
   put the name of stack gMenuTitle into mController
   script_UpdateHarrayAndExport mController, false
   
   replace "_" with " | " in gMenuTitle
   put menu_GetGlobalTitleArray (gMenuTitle) into gMenuTitleArray
   display_Array gMenuTitleArray, "menu_GetGlobalTitleArray (gMenuTitle)"
end menu_IndexAnotherStack

on menu_IndexAllMenus
   global gLCW
   
   -- put lcw_GetRootFolder() into projectFolder
   put library_FetchProjectFolder ("lcw_Authoring") into projectFolder
   put project_ListPaths ("controller", projectFolder) into stackPaths
   
   repeat for each line stackPath in stackPaths
      put the name of stack stackPath into mController
      
      -- script_UpdateHarrayAndExport mController, false
      put the script of mController into someScript
      lcw_ExportAndAddScriptToHarray gLCW, mController, someScript
      set the menu_Update of mController to true
      put the result into mTitleTableArray
   end repeat
end menu_IndexAllMenus

on menu_GlobalArrayMenu
   go to stack "Global_Array_Menu"
end menu_GlobalArrayMenu


--> Deps
-
