script "model_ProjectArray"
--> MetaData
-
license: GPLv3
name: model_ProjectArray
type: model
version: 0.7

/*
A project array is an array stored at the top-level of a project fodler. ]
So it is specific to the project.

It is a place to store any project specific preferences or data that is needed when loading the project.
Things like defaults, or important stacks to open and provide easy navigation to, or any specific globals that need loading.

- projectPrefsArray
- projectGlobalArray
- openstacks
- stackFileArray

The location of the array file can be returned by using either of the folowing forms:

- put project_ArrayFile (pProjectName) into projectArrayFile
- the array_File of the target

For now we access and store the data to and from disk using "fetch" and "save"
To speed things up we could use "get" and "set" with a global array stored inside of gLCW.
*/


--> Working On
-
--> Working on (Library | Array | Files)
-
function library_PluginFolder pSubFolder, pDontCreate
   put revEnvironmentUserPluginsPath() & "/opn_Plugins/opn_Libraries/" into oldLibFolder
   
   if pSubFolder is not empty then
      text_AddTrailing pSubFolder, slash
      put pSubFolder after oldLibFolder
   end if
   
   if pDontCreate is not true then folder_CreateNested oldLibFolder
   return oldLibFolder
end library_PluginFolder


--> Project | Initialise | After
-
command project_IndexAfterUsed projectFolder
   -- "project_LoadAfterUsing" depends on handlers in stack "model_ProjectArray"
   try
      -- project_LoadAfterUsing projectFolder
   catch e
      put projectFolder
      answer warning merge ("Failed to load project globals and index scripts for project '[[projectName]]'!")
   end try
end project_IndexAfterUsed

command project_LoadAfterUsing projectFolder
   -- the code below requires the above libraries to be used
   -- should be stored as arrays in the projects folder
   put project_GetHomeStackName (projectFolder) into projectName
   
   project_LoadGlobalPrefs projectName
   project_LoadGlobalHarray projectName -- this clobbers any previously loaded hArray
   project_LoadGlobalArray projectName
   
   project_IndexAllScripts projectFolder
   return the result
end project_LoadAfterUsing


--> Project | Array | Model | Files | Names
-
command project_AddArrayToGlobal projectArray, pRecursively
   /*
   By default (if pRecursively is false or empty), this command merges the all keys recursively, adding new items to gLCW from projectArray
   but keeping any old items that are not in projectArray.
   Consequenlty this "adds" the contents of the projectArray to gLCW with the exception of leaf contents which are updated or replaced.
   So if you want a merge - store your data as an array not an index.
   
   if pRecursively is false then this command replaces items that are already there with the contents of projectArray
   Consequenlty this adds or "sets" the contents of the variable
   */
   global gLCW
   
   if pRecursively is not false then
      union projectArray with gLCW recursively
   else
      union projectArray with gLCW
   end if
   put projectArray into gLCW
   return gLCW
end project_AddArrayToGlobal

command project_RestoreGlobals projectName, pDeleteAllGlobals
   global gLCW
   
   put project_GetArrayFromFolder (projectName) into projectArray
   if pDeleteAllGlobals is true then
      global_DeleteAll
   else
      delete variable gLCW
   end if
   project_AddArrayToGlobal projectArray, false
   return projectGlobalArray
end project_RestoreGlobals

command project_AddProjectGlobals projectName
   put project_GetArrayFromFolder (projectName) into projectArray
   project_AddArrayToGlobal projectArray, true
   return projectGlobalArray
end project_AddProjectGlobals

command project_RestoreGlobalPrefs pProjectName
   -- was "libary_RestoreGlobalPrefs"   
   project_DeleteGlobalPrefs
   project_LoadGlobalPrefs pProjectName
   put the result into projectPrefsArray
   return projectPrefsArray
end project_RestoreGlobalPrefs


--> Project | Index
-
command project_IndexAllScripts projectFolder, pExportHandlers
   -- has lot's of dependencies (but wrapped in "try")
   
   put folder_ListLong (projectFolder) into standardFolders
   set the itemdelimiter to slash
   repeat for each line standardFolder in standardFolders
      put folder_ListStackPaths (standardFolder) into stackPaths
      repeat for each line stackPath in stackPaths
         set the cursor to busy
         put the long id of stack stackPath into stackObject
         
         switch item -1 of standardFolder
            case "view"
               -- let's just index the views script (so we can add it to hArray)
               -- the assumption is teh view is the toplevel (ie control 1) of teh first card in the stack)
               -- this is of course usually a group
               if exists (control 1 of cd 1 of stackObject) then
                  try
                     put the long id of cd 1 of stackObject into viewTemplateCard
                     if pExportHandlers is true then
                        set the script_IsIndexed of viewTemplateCard to true -- may have a global menu on it
                     else
                        script_UpdateHarrayAndExport viewTemplateCard, false
                     end if
                     
                     -- let's add the view to the index of views available
                     put the long id of control 1 of viewTemplateCard into viewTemplate
                     if pExportHandlers is true then
                        set the script_IsIndexed of viewTemplate to true
                     else
                        script_UpdateHarrayAndExport viewTemplate, false
                     end if
                  catch e
                     put viewTemplateCard
                     -- answer "Error with view"
                     breakpoint
                     put viewTemplateCard & CR after stackPathProblems
                  end try
               end if
               break
            default
               -- index the stack script
               -- we should index all scripts for non-script only stacks
               
               try
                  if pExportHandlers is true then
                     set the script_IsIndexed of stackObject to true
                  else
                     script_UpdateHarrayAndExport stackObject, false
                  end if
               catch e
                  -- put stackObject
                  -- put the name of stackObject into stackObject
                  -- answer warning merge ("Error with [[stackObject]]")
                  breakpoint
                  script_UpdateHarrayAndExport stackObject, false
                  
                  put stackPath & CR after stackPathProblems
               end try
         end switch
      end repeat
   end repeat
   return stackPathProblems
end project_IndexAllScripts


--> Project | Important Stacks
-
command project_AddImportantStack stackNames
   put project_FetchValue ("openStacks") into oldProjectStackNames
   put stackNames & CR & oldProjectStackNames into newProjectStackNames
   sort newProjectStackNames
   put word 1 to -1 of newProjectStackNames into newProjectStackNames
   project_SaveValue "openStacks", newProjectStackNames
   return newProjectStackNames
end project_AddImportantStack

function project_ListImportantStacks pProjectName
   put project_FetchValue ("openStacks", pProjectName) into stackNames
   sort stackNames
   return stackNames
end project_ListImportantStacks

command project_StoreImportantStacks stackNames, pProjectName
   sort stackNames
   project_SaveValue "openStacks", stackNames,  pProjectName
   return the result
end project_StoreImportantStacks


--> Project | Prefs | Model
-
/*
A project array stores everything a project depends on to function, as well as additional authoring metadata.
It is equivalent to the older "library set", and is currently stored as part of the library array keyd under the project name.
In the future we will split this out to metadata stored in the projects folder.
*/

function project_FetchPrefs pProjectName
   put project_FetchValue ("projectPrefsArray", pProjectName) into projectPrefsArray
   return projectPrefsArray
end project_FetchPrefs

command project_SavePrefs projectPrefsArray, pProjectName
   project_SaveValue "projectPrefsArray", projectPrefsArray, pProjectName
end project_SavePrefs
