﻿script "Global | Pref | Menu"
--> MetaData
-
license: GPLv3
name: Global | Pref | Menu
type: controller
version: 0.6

/*This is the first ever script-only menu!

This menu manipulates Livecode World preferences.
It is designed to be a general cross platform library for safely storing user preferences.

It is designed to work on "scriptObjects", that is references to Livecode controls that contain scripts.
The long id of the control is passed as the first param to the controller (menu),
and any handler that dispatches one of the commands below will work as long as you pass a reference to the scriptObject.*/


--> Global | Pref | Menu
-
on menu_RevealLibraryArrayFolder
   put lcw_ArrayFolder() into arrayFolder  
   finder_Reveal arrayFolder
end menu_RevealLibraryArrayFolder

on _
end _

on menu_FetchPrefArray scriptObject, fullSetName
   put pref_FetchArray (fullSetName) into prefArray
   put merge ("put pref_FetchArray ('[[fullSetName]]')") into someTitle
   display_Array prefArray, someTitle, "Global | Prefs | Edit | Menu", "Global | Prefs | Edit | Line | Menu"
end menu_FetchPrefArray

on menu_LoadPrefArray scriptObject, fullSetName
   project_RestoreGlobalPrefs fullSetName
   lcw_Notify merge ("User preferences loaded from the stored set '[[fullSetName]]'. This is done automatically whenever a new set is loaded!")
end menu_LoadPrefArray

on menu_DisplayPrefData scriptObject
   put pref_FetchData() into prefData
   display_Array prefData, "pref_FetchData()"
end menu_DisplayPrefData

on _
end _

on menu_DisplayCurrentPrefs
   put project_GatherGlobalPrefs() into projectPrefsArray
   display_Array projectPrefsArray, "project_GatherGlobalPrefs()"
end menu_DisplayCurrentPrefs

on menu_DisplayProjectPrefs scriptObject, projectName
   put project_FetchPrefs (projectName) into projectPrefsArray
   
   put merge ("project_FetchPrefs ('[[projectName]]')") into someTitle
   display_Array projectPrefsArray, someTitle
end menu_DisplayProjectPrefs

on menu_SavePrefsToProject scriptObject, projectName
   answer merge ("Do you want to store all gPref_* info to projectArray for '[[projectName]]'?") with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   project_SaveGlobalPrefs projectName
   put the result into projectPrefsArray
   put project_FetchPrefs (projectName) into projectPrefsArray
   
   set the displayed_Project of scriptObject to projectName
   
   put merge ("project_FetchPrefs ('[[projectName]]')") into someTitle
   display_Array projectPrefsArray, someTitle
   answer merge ("Saved all gPref_* info to projectArray for '[[projectName]]'!")
end menu_SavePrefsToProject

on menu_RestorePrefs scriptObject, projectName
   answer merge ("Do you want to restore all gPref_* info from '[[projectName]]'?") with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   project_RestoreGlobalPrefs projectName
   
   put project_GatherGlobalPrefs() into projectPrefsArray
   display_Array projectPrefsArray, "project_GatherGlobalPrefs()"
end menu_RestorePrefs

on _
end _

on menu_SaveGprefsArray mTarget, setName
   put merge ("Are you sure you want to store the current global preferences with the set '[[setName]]'?") into someQuestion
   lcw_Answer someQuestion
   
   library_StoreGlobalPrefs setName, false
   lcw_Notify merge ("Current user preferences saved to disk with the set '[[setName]]'")
end menu_SaveGprefsArray

on menu_ClearGprefsArray
   project_ClearGlobalPrefs
   lcw_Notify merge ("Cleared all 'pref' globals ie those named beginning with 'gPrefs_*'.")
end menu_ClearGprefsArray

on _
end _

on menu_FetchStoredGlobalHarray scriptObject, projectName
   put project_FetchHarray (projectName) into hArray
   display_Array hArray, "Stored gLCW"
end menu_FetchStoredGlobalHarray

on menu_DisplayGlobalHarray scriptObject, projectName
   global gLCW
   display_Array gLCW, "global gLCW"
end menu_DisplayGlobalHarray

on menu_LoadGlobalHarray scriptObject, projectName
   put project_FetchHarray (projectName) into hArray
   display_Array hArray, "Stored gLCW"
   answer warning "Are you sure you want to replace the current gLCW with the one displayed?" with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   project_LoadGlobalHarray projectName
   put the result into hArray
   display_Array hArray, "Loaded gLCW"
end menu_LoadGlobalHarray

on menu_SaveGlobalHarray
   global gLCW
   display_Array gLCW, "global gLCW"
   answer warning "Are you sure you want to save the global gLCW (and other globals) to the database?" with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   project_SaveGlobalHarray
   put the result into hArrayFile
   put lcw_GetArrayFile ("Hkey_Data") into hArrayFile  
   finder_Reveal hArrayFile
end menu_SaveGlobalHarray

on _
end _

on menu_DisplayTempGlobal scriptObject, tempGlobal
   display_GlobalValue gName
end menu_DisplayTempGlobal

on menu_DeleteTempGlobal scriptObject, tempGlobal
   display_GlobalValue tempGlobal
   lcw_Answer merge ("Are you sure you want to remove the global variable '[[tempGlobal]]' from memory?")
   global_Delete tempGlobal
   lcw_Notify merge ("Removed the global variable '[[tempGlobal]]' from memory!")
end menu_DeleteTempGlobal

on _
end _

on menu_CurrentGpref scriptObject, prefName
   put pref_GetValue (prefName) into prefValue
   if prefValue is an array then
      display_Array prefValue, prefName
   else
      put prefValue
   end if
end menu_CurrentGpref

on menu_CurrentGprefsArray
   global gPrefs_Array
   display_Array gPrefs_Array, "global gPrefs_Array", "Global | Prefs | Edit | Menu", "Global | Prefs | Edit | Line | Menu"
end menu_CurrentGprefsArray

on _
end _

on menu_DisplayCheckoutGlobal scriptObject, opnGlobal
   put opn_GetGlobalArray (opnGlobal) into opnGlobalArray
   display_Array opnGlobalArray, ("Global:" && opnGlobal)
end menu_DisplayCheckoutGlobal

on menu_DeleteCheckoutGlobal mTarget, opnGlobal
   lcw_Answer merge ("Are you sure you want to remove the global variable '[[opnGlobal]]' from memory?")
   opn_DeleteGlobalArray opnGlobal
   lcw_Notify merge ("Removed the global variable [[opnGlobal]] from memory!")
end menu_DeleteCheckoutGlobal

on menu_LoadCheckoutGlobal scriptObject, setName
   put merge ("Are you sure you want to replace the current global checkout variables with those loaded from the set '[[setName]]'?") into someQuestion
   lcw_Answer someQuestion
   
   library_ReloadCheckoutGlobals setName
   
   put library_GetSetName() into currentSetName
   put merge ("The global checkout variables loaded from the stored set '[[setName]]' have been loaded into memory. They will now automatically be saved with the currently active set ('[[currentSetName]])!") into someComment
   lcw_Notify someComment
end menu_LoadCheckoutGlobal

on menu_StoreCheckoutGlobalWith scriptObject, setName
   put merge ("Are you sure you want to store the current global checkout variables with the set '[[setName]]'?") into someQuestion
   lcw_Answer someQuestion
   
   library_StoreCheckoutGlobals setName
   
   put library_GetSetName() into currentSetName
   put merge ("The global checkout variables in the current set '[[currentSetName]]' have been have been saved with the set ('[[setName]])!") into someComment
   lcw_Notify someComment
end menu_StoreCheckoutGlobalWith

on menu_StoreCurrentCheckoutGlobals
   library_StoreCheckoutGlobals
   
   put library_GetSetName() into setName
   lcw_Notify merge ("Stored the gOPN globals in the current set ('[[setName]]'), as an encoded array!")
end menu_StoreCurrentCheckoutGlobals

on menu_ReloadCurrentCheckoutGlobals
   library_ReloadCheckoutGlobals
   
   put library_GetSetName() into setName
   lcw_Notify merge ("Restored the gOPN globals from the stored array, to the current set ('[[setName]]')!")
end menu_ReloadCurrentCheckoutGlobals

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Pref | Menu | Disabled
-
getprop disabled_CurrentPreference
   global gPrefs_Array
   return keys (gPrefs_Array) is empty
end disabled_CurrentPreference

getprop disabled_SaveGlobalPreferences
   global gPrefs_Array
   return keys (gPrefs_Array) is empty
end disabled_SaveGlobalPreferences

getprop disabled_ClearGlobalPrefs
   global gPrefs_Array
   return keys (gPrefs_Array) is empty
end disabled_ClearGlobalPrefs


--> Global | Pref | Menu | Props
-
-- getprop project_Name
   put env_GetProjectFocus() into activeProjectName
   return activeProjectName
end project_Name

getprop project_Names
   put library_ListProjectNames() into projectNames
   return projectNames
end project_Names

getprop pref_Names
   return pref_ListValues()
end pref_Names

-- getprop pref_GlobalNames
return global_ListPrefs()
end pref_GlobalNames

-- getprop pref_ModelName
put the uOPN ["pref_ModelName"] of me into pModelName
return pModelName
end pref_ModelName

-- setprop pref_ModelName prefName
set the uOPN ["pref_ModelName"] of me to prefName
end pref_ModelName

getprop full_SetName
   return env_GetProjectFocus()
end full_SetName

getprop full_SetNames
   return library_ListProjectNames (true) & CR & "None"
end full_SetNames

getprop set_Name
   return env_GetProjectFocus()
end set_Name

getprop set_Names
   return library_ListProjectNames ()
end set_Names

/*


-- getprop pref_ModelNames
get pref_ListSetNames()
if it is empty then
   return "Default"
else
   return it & CR & "-,Default"
end if
end pref_ModelNames

function opn_PrefNameOutline
   global gPrefs_Array
   -- put pref_FetchGlobal() into prefArray
   put array_ToOutline (gPrefs_Array) into prefOutline
   return prefOutline
end opn_PrefNameOutline

function opn_GetGlobalArray opnGlobalName
   put "global" && opnGlobalName into doScript
   put CR & "get" && opnGlobalName after doScript
   do doScript
   return it
end opn_GetGlobalArray

on opn_DeleteGlobalArray opnGlobalName
    put "global" && opnGlobalName into doScript
    put CR & "delete global" && opnGlobalName after doScript
    do doScript
end opn_DeleteGlobalArray

getprop opn_Globals
    return global_ListOpnNames()
end opn_Globals

getprop temp_Globals
   return global_ListOtherNames()
 end temp_Globals

getprop opn_External
   repeat for each item someExternal in external_ListAllComponents()
      if external_GetInstalled (someExternal) then
         put someExternal & CR after someExternals
      end if
   end repeat
   delete char -1 of someExternals
   return someExternals
end opn_External

getprop opn_Externals
    return external_ListAllComponents()
end opn_Externals
*/


--> Deps
-


--> Dev | Menu
-
on menu_InstalledExternals scriptObject, opnExternal
   put not external_GetInstalled (opnExternal) into toggleBoolean
   external_SetInstalled opnExternal, toggleBoolean
end menu_InstalledExternals

on menu_AutoSetExternals scriptObject
   external_AutoSet
   lcw_Notify "Tested for working command-line tools and externals, and added these if present!"
end menu_AutoSetExternals

on _
end _

on menu_StoreGlobalHarray
   hArray_StoreGlobal
   
   put merge ("Stored global hArray database to disk!") into someComment
   lcw_Notify someComment
end menu_StoreGlobalHarray

on menu_LoadGlobalHarray
   hArray_LoadGlobal
   
   put merge ("Reloaded the stored global hArray database from disk!") into someComment
   lcw_Notify someComment
end menu_LoadGlobalHarray

on _
end _

on menu_DisplayGhkeyArray mTarget
   global gLCW
   display_Array gLCW, "Global gLCW"
end menu_DisplayGhkeyArray
