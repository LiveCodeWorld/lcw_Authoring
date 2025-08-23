script "lib_Project"
--> MetaData
-
license: GPLv3
name: lib_Project
type: libraries
version: 0.2

/*
Here we define handlers that create projects and project specific stacks (libraries, menus, controllers, behaviors, modules etc"
*/


--> Working on
-
function project_ConstructStandardFile sName, projectFolder, pShortFolder, pExtension
   put stack_ConstructShortFile (sName, pExtension) into shortFile
   put folder_AddShort (projectFolder, pShortFolder) into standardFolder
   put standardFolder & shortFile into standardFile
   return standardFile
end project_ConstructStandardFile

function stack_ConstructShortFile sName, pExtension
   # Normalize short file and folder names (replace "|" with "_")
   if pExtension is empty then put "livecodescript" into pExtension
   put label_PipesToUnderscore (sName) into shortFileBit
   put shortFileBit & "." & pExtension into shortFile
   return shortFile
end stack_ConstructShortFile

command project_TrashStack stackObject
   # Do some checks. This handler is dangerous as it deletes a stack!
   switch
      case word 1 of stackObject is not "stack"
         return "Errror, not a stack" && stackObject
      case exists (stackObject) is false
         return "Error, stack does not exist!" && stackObject
      default
         -- good stackObject
   end switch
   
   put the filename of stackObject into longStackFile
   --
   stop using stack longStackFile
   set the stack_IsKnow of stack longStackFile to false -- do this for all projects ?
   
   # Trash stack and delete File
   delete stack longStackFile -- remove from memory
   -- delete file longStackFile
   revDeleteFile longStackFile -- bug: not in the dictionary
   --
   return longStackFile
end project_TrashStack

function module_ConstructControllerPath moduleName, moduleFolder, pShortFile
   if pShortFile is empty then
      put moduleName & ".livecodescript" into pShortFile
   end if
   put folder_AddShort (moduleFolder, "controllers") into moduleControllerFolder
   put pShortFile & pShortFile into moduleControllerPath
   return moduleControllerPath
end module_ConstructControllerPath

command project_MoveControllerToModule gMenutitle, toModuleName, toProjectName
   # Get menu path
   put menu_GetGlobalPath (gMenutitle) into mPath
   if mPath is empty then
      return "Error, cannot local global menu:" && gMenutitle
   end if
   
   # Get fromProjectFolder (we need it later)
   put the project_Folder of stack gMenutitle into fromProjectFolder
   
   # Check it is a menu
   put the script_Type of stack gMenutitle into sType
   if sType is not "controller" then
      return "Error, gMenutitle is not a menu:" && gMenutitle
   end if
   
   # Module Folder
   put project_GetFolder (toProjectName) into toProjectFolder
   if toProjectFolder is empty then
      return "Error, cannot project folder for" && toProjectName
   end if
   put label_PipesToUnderscore (toModuleName) into toModuleShortFolder
   put module_GetFolder (toModuleShortFolder, toProjectFolder) into toModuleFolder
   --
   if there is not a folder toModuleFolder then
      return "Error, problem finding module folder:" && toModuleShortFolder && "for project" && toProjectName
   end if
   
   # Module Path
   put module_GetHomeStackPath (toModuleShortFolder, toProjectName) into toModulePath
   if there is not a stack toModulePath then 
      return "Error, problem finding module path:" && toModuleShortFolder && "for project" && toProjectName
   end if
   
   
   # From Path
   put the filename of stack gMenutitle into fromControllerPath
   
   # To Path
   set the itemdelimiter to slash
   put item -1 of fromControllerPath into shortFile
   put module_ConstructControllerPath (toModuleName, toModuleFolder, shortFile) into toControllerPath
   --
   if there is a file toControllerPath then
      return "Error, there is already a file:" && toControllerPath
   end if
   
   # Start moving!
   breakpoint
   
   # Remove old menu stack from memory
   delete stack gMenutitle
   
   # Move Controller
   rename file fromControllerPath to toControllerPath
   
   # Fix project stackfiles
   project_MoveStackFile toControllerPath, fromProjectFolder, toProjectFolder
   
   breakpoint
   # Fix Module Paths
   set the stackFile_AddPaths of stack toModulePath to toControllerPath
   
   return toPath
end project_MoveControllerToModule

function project_ConstructShortFile stackName
   put label_PipesToUnderscore (stackName) & ".livecodescript" into stackName
   return stackName
end project_ConstructShortFile


--> Props
-
getprop stack_IsKnown [pName]
   put the defaultstack into sObject
   put the effective filename of sObject into sPath
   if sPath is empty then return false
   
   put project_FindHomeStackPath (sPath) into hPath
   if hPath is empty then
      if exists (stack "LCW") is false then return empty
      put the filename of stack "LCW" into hPath
   end if
   if exists (stack hPath) is false then return empty
   --
   put the stackfile_Array of stack hPath into sfArray  
   put sfArray [sName] into relFile
   return relFile is not empty
end stack_IsKnown

setprop stack_IsKnown [pName] boolean
   put the stack_Name of the target into sName
   if pName is empty then put the project_Name of the target into pName
   
   # Add or remove from the project home stackfiles
   if boolean is true then
      project_AddToStackFiles sName, pName, false
   else
      project_RemoveFromStackFiles sName, pName, false
   end if
   put the result into sfArray
   
   # Export Project JSON
   put the project_Array of the target into projectArray
   put sfArray into projectArray ["stackFileArray"]
   set the project_Array of the target to projectArray
   --
   return sfArray
end stack_IsKnown


--> Ask
-
command ask_CreateProjectModel projectName
   put "Choose a name for your script only model stack...." into someQuestion
   put "model_XXX" into suggestedAnswer
   ask_CreateProjectStack "models", projectName, someQuestion, suggestedAnswer
   put the result into newStackPath
   return newStackPath
end ask_CreateProjectModel

command ask_CreateProjectStack shortFolder, projectName, pQuestion, pExample
   -- this handler creates a script only stack in the corresponding folder of the Livecode World Library
   if pQuestion is empty then put "Give your library a name" into pQuestion
   if pExample is empty then put "lib_Example" into pExample
   put lcw_Ask (pQuestion, pExample) into stackName
   
   put project_GetFolder (projectName) into projectFolder
   project_CreateStack projectFolder, stackName, shortFolder
   put the result into newStackPath
   --
   switch shortFolder
      case "libraries"
      case "models"
         start using stack stackName
         lcw_Notify ("Stack" && kwote (stackName) && "is now known and used!")
         break
   end switch
   --
   edit the script of stack stackName
   return newStackPath
end ask_CreateProjectStack

command ask_RenameProjectStack stackName
   put "Renamme model '[[stackName]]'?" into someQuestion
   put ask_Question (someQuestion, stackName, "Rename Model", stackName) into newStackName
   --
   project_RenameStack stackName, newStackName
   put the result into newStackPath
   return newStackPath
end ask_RenameProjectStack

command project_RemoveStacksFromMemory projectName
   put project_ListAllStackPaths (projectName) into stackPaths
   stack_Remove stackPaths
end project_RemoveStacksFromMemory

private command _CheckStackDoesNotAlreadyExist stackName, stackFolder
   if stackFolder is empty then
      answer warning merge ("The project folder is empty!")
      exit to top
   end if
   if there is a stack stackName then
      put the filename of stack stackName
      go to stack stackName
      show stack stackName
      --
      put stackName
      put the short name of stack stackName into shortStackName
      answer warning merge ("Already a stack '[[shortStackName]]' with that name!")
      edit the script of stack stackName
      --
      exit to top
   end if
end _CheckStackDoesNotAlreadyExist

command library_StoreProjectFolder projectName, projectFolder
   -- used by "env_AddProject" and "lcw_LoadCustomUserProject" and "project_Create"
   put library_FetchProjectArray (projectName) into projectArray
   --
   put projectFolder into projectArray ["projectFolder"]
   set the itemdelimiter to slash
   if item - 2 of projectFolder = "modules" then
      put "module" into projectArray ["projectType"]
   else
      put "project" into projectArray ["projectType"]
   end if
   --
   library_StoreProjectArray projectName, projectArray
end library_StoreProjectFolder


--> Props
-
getprop project_RelativeFile
   put the stack_Name of the target into stackName
   put the effective filename of stack stackName into sFile
   put the project_Folder of stack stackName into pFolder
   put file_GetRelativePath (sFile, pFolder, commonPath) into rPath
   return rPath
end project_RelativeFile

setprop project_Move toProjectName
   -- moves a stack to the same relative location in a new project folder
   -- put the stack_Name of the target into stackName
   put the short name of the defaultStack into stackName
   project_MoveStackRelative stackName, toProjectName
   put the result into newPath
   return newPath
end project_Move


--> Project | Create
-
command project_Create projectFolder
   project_CreateStandardFolders projectFolder
   put project_PathFromFolder (projectFolder) into homeStackPath
   
   put project_GetShortFolder (projectFolder) into projectName -- a clean default
   create script only stack projectName
   set the filename of stack projectName to homeStackPath
   
   put metadata_ConstructArray (projectName, "project") into uRipArray
   set the script_MetaData of stack projectName to uRipArray
   
   put scaffold_Get ("lcw_HomeStackScript") into templateScript
   put merge (templateScript) into lcwHomeStackScript
   set the script of stack projectName to lcwHomeStackScript
   
   save stack projectName
   
   library_StoreProjectFolder projectName, projectFolder
   env_SetProjectFolder projectName, projectFolder
   return homeStackPath
end project_Create

command env_AddProject homeStackName, pProjectFolder
   if exists (stack homeStackName) is false then return false
   if pProjectFolder is empty then
      put env_ConstructProjectFolder (homeStackName) into pProjectFolder
   else
      if there is not a folder pProjectFolder then
         return false
      else
         library_StoreProjectFolder homeStackName, pProjectFolder
      end if
   end if
   if there is not a folder pProjectFolder then return false
   
   env_SetProjectFolder homeStackName, pProjectFolder
   return true
end env_AddProject

command project_CreateStandardFolders projectFolder, pShortFolders
   if pShortFolders is empty then put "assets,behaviors,controllers,libraries,models,modules,views" into pShortFolders
   folder_CreateNested projectFolder
   repeat for each item shortFolder in pShortFolders
      put projectFolder & shortFolder & slash into subFolder
      create folder subFolder
   end repeat
end project_CreateStandardFolders

command project_Trash projectName
   put project_GetFolder (projectName) into projectFolder
   put project_ListAllStackPaths (projectFolder) into projectStackPaths
   repeat for each line projectStackPath in projectStackPaths
      if exists (stack projectStackPath) is false then
         -- should not be
         breakpoint
         next repeat
      end if
      
      delete stack projectStackPath
   end repeat
   
   revDeleteFolder projectFolder
   library_DeleteProjectArray projectName
end project_Trash


--> Project | Stack
-
command project_RenameStack stackName, newStackName, pEditScript
   # Checks
   if exists (stack stackName) is false then
      return "Error, stack does not exists:" && stackName
   end if
   if exists (stack newStackName) is true then
      -- could check unloaded projects (tricky)
      return "Error, already a stack named:" && newStackName
   end if
   
   # Close script editor tab
   put the name of stack stackName into stackObject
   scriptEditor_CloseTab stackObject
   if pEditScript is empty then put the result into pEditScript
   
   # Rename stack
   set the name of stack stackName to newStackName
   
   # Rename short file
   put project_ConstructShortFile (newStackName) into newShortFile
   project_ChangeStackShortFileName newStackName, newShortFile
   put the result into newStackPath
   
   # Remove old and add new to stackfiles of project
   _RenameKnown newStackName, stackName
   
   # Save stack
   save stack newStackName
   
   # Refresh display if needed
   display_Project projectName, true
   
   # Re-edit script if needed
   if pEditScript is true then
      edit the script of stack newStackPath
   end if
   return newStackPath
end project_RenameStack


--> Project | Rename
-
command project_ChangeStackShortFileName stackPathOrName, newShortFile
   # Checks
   if exists (stack stackPathOrName) is false then return empty
   put the filename of stack stackPathOrName into stackPath
   if stackPath is empty then return "Error, filename is empty for stack:" && stackPathOrName
   
   # Construct new path
   put file_NewShortPath (newShortFile, stackPath) into newStackPath
   
   # Check newStackPath does not already exist
   if there is a file newStackPath then
      return "Error, new file already exist:" && newStackPath
   end if
   
   # Move
   project_MoveStack stackPath, newStackPath
   if item 1 of the result is not "Error" then
      return newStackPath
   else
      return "Error, moving file for stack to:" && newStackPath
   end if
end project_ChangeStackShortFileName


--> Project | Move
-
command project_MoveLibraryToModuleBehavior libraryStack, moduleShortFolder
   if exists (libraryStack) is false then
      return merge ("Error, [[libraryStack]] does not exist!")
   end if
   
   put the filename of libraryStack into libStackPath
   put _NewBehaviorName (libraryStack) into newBehaviorStackName
   put the project_Folder of libraryStack into projectFolder
   
   put _BehaviorPathFromLibraryStack (newBehaviorStackName, projectFolder, moduleShortFolder) into newBehaviorPath
   if item 1 of newBehaviorPath = "Error" then
      return newBehaviorPath
   end if
   
   # Close script editor tab
   scriptEditor_CloseTab libraryStack
   
   breakpoint
   
   # Rename stack
   set the name of libraryStack to newBehaviorStackName
   put the script_MetaData of libraryStack into mData
   put newBehaviorStackName into mData ["name"]
   put "behavior" into mData ["type"]
   set the script_MetaData of libraryStack to mData
   
   # Move
   _MoveStack libStackPath, newBehaviorPath
   
   # Export project JSON
   put module_GetFolder (moduleShortFolder, projectFolder) into moduleFolder
   project_ExportMenusAndStackFiles moduleFolder
   
   return newBehaviorPath
end project_MoveLibraryToModuleBehavior

command project_MoveStackRelative stackName, toProjectName, pRepoFolder
   -- Powerful but be careful!
   -- Moves a stack to the same relative location in a new project folder
   
   # Gather info
   put the name of stack stackName into stackObject
   put the project_Folder of stackObject into fromProjectFolder
   if fromProjectFolder is empty then return empty
   --
   put env_ConstructProjectFolder (toProjectName, pRepoFolder) into toProjectFolder
   text_AddTrailing toProjectFolder, slash -- just in case
   
   # Do checks
   if exists (stack stackName) is false then
      breakpoint
      return empty
   else
      -- first let's make sure it is saved!
      set lockmessages to true
      save stack stackName
      set lockmessages to false
   end if
   --
   if toProjectFolder is empty then
      breakpoint
      return empty
   end if
   
   # Move to same relative location
   put the filename of stackObject into fromPath
   set the itemdelimiter to slash
   put the number of items of fromProjectFolder into iNum
   put item (iNum + 1) to -1 of fromPath into relPath
   put toProjectFolder & relPath into toPath
   put toPath into toFolder
   put empty into item -1 of toFolder
   folder_CreateNested toFolder
   
   # Remove old stack from mmemory
   if exists (stack stackName) then
      stop using stack stackName
      delete stack stackName
   end if
   
   # Move
   rename file fromPath to toPath
   start using stack toPath
   
   # Fix LCW stackfiles
   project_MoveStackFile toPath, fromProjectFolder, toProjectFolder
   
   return newPath
end project_MoveStackRelative

command project_MoveStackFile toPath, fromProjectFolder, toProjectFolder
   put the short name of stack toPath into stackName
   put the effective filename of stack toPath into stackFile
   
   put project_PathFromFolder (fromProjectFolder) into fromHomePath
   put project_PathFromFolder (toProjectFolder) into toHomePath
   
   set the stackFile_AddPaths of stack toHomePath to toPath
   set the stackFile_RemovePaths of stack fromHomePath to toPath
   return toPath
end project_MoveStackFile

command project_MoveStack oldStackPath, newStackPath, pLeaveAlias
   # Do some checks
   if exists (stack oldStackPath) is false then
      return "Error, cannot locate stack:" && oldStackPath
   end if
   if newStackPath = oldStackPath then
      return "Error, not moving as both stacks have the same path:" && oldStackPath
   end if
   if there is a file newStackPath then
      return "Error, file already exists at new location: newStackPath"
   end if
   
   # Do the moving
   _MoveStack oldStackPath, newStackPath, pLeaveAlias
   
   return true
end project_MoveStack

command project_AddToKnown sObject, pDontSave
   -- see older "project_AddToStackFiles"
   local commonPath   
   put the project_Name of sObject into projectName
   if exists (stack projectName) is false then
      return "Error, cannot locate stack:" && projectName
   end if
   --
   put the stack_Name of sObject into stackName
   put the project_RelativeFile of sObject into rPath
   --
   put the stackfile_Array of stack projectName into stackFileArray
   put rPath into stackFileArray [stackName]
   set the stackfile_Array of stack projectName to stackFileArray
   --
   if pDontSave is not false then
      if the scriptOnly of stack projectName is false then
         save stack projectName
      else
         -- reply of project_Array
      end if
   end if
   return stackFileArray
end project_AddToKnown


--> Project | Create
-
command project_CreateHomeStack projectOrModuleFolder, homeStackName, pScript, pExtension
   put project_ConstructHomePath (projectOrModuleFolder, pExtension) into homePath
   --
   create stack homeStackName
   set the filename of stack homeStackName to homePath
   --
   put metadata_ConstructArray (homeStackName, "home") into uRipArray
   script_SetMetadataArray pScript, uRipArray
   set the script of stack homeStackName to pScript
   --
   return homePath
end project_CreateHomeStack

command project_CreateStack projectFolder, pStackName, pShortFolder, pLibType, pScript, pNotScriptOnly
   if pStackName is empty then put project_GetShortFolder (projectFolder) into pStackName -- for creating a homeStack with folder and name the same
   
   # Set the default values of the scripts metadata
   put metadata_ConstructArray (pStackName, pLibType) into uRipArray
   script_SetMetadataArray pScript, uRipArray
   --
   put project_ConstructStackPath (pStackName, projectFolder, pShortFolder, pLibType) into newStackPath
   _CheckStackDoesNotAlreadyExist pStackName, projectFolder
   --
   if pNotScriptOnly is true then
      create stack pStackName
   else
      create script only stack pStackName   -- revIDENewScriptOnlyStackWithScript pName, pScript
   end if
   --
   set the filename of stack pStackName to newStackPath
   set the script of stack pStackName to pScript
   save stack pStackName
   --
   set the stack_IsKnown of stack pStackName to true -- this also saves the stack
   return newStackPath
end project_CreateStack

function project_ConstructStackPath stackName, projectFolder, pShortFolder, pLibType
   if pShortFolder is empty then
      put label_PipesToUnderscore (stackName) into pShortFolder
      put "home" into pLibType
      put "livecode" into someExtension
   else
      if pLibType is empty then put project_ConstructSingularType (pShortFolder) into pLibType
      if pLibType = "home" then
         put "livecode" into someExtension
      else
         put "livecodescript" into someExtension
      end if
   end if
   put project_ConstructStandardFile (stackName, projectFolder, pShortFolder, someExtension, true) into newStackPath
   return newStackPath
end project_ConstructStackPath


--> Project | Hacks
-
function project_ConstructHomePath projectOrModuleFolder, pExtension
   text_AddTrailing projectOrModuleFolder, slash
   if pExtension is empty then put "livecode" into pExtension
   folder_CreateNested projectOrModuleFolder
   --
   set the itemdelimiter to slash
   put item -1 of projectOrModuleFolder into shortFileBit
   --
   put projectOrModuleFolder & shortFileBit & "." & pExtension into homePath
   return homePath
end project_ConstructHomePath


--> Project | Stackfiles
-
command project_RemoveFromStackFiles stackName, projectName, pDontSave
   local commonPath
   if exists (stack projectName) is true then
      put the filename of stack projectName into homeStackStackPath
   else
      put project_GetHomeStackPath (projectName) into homeStackStackPath
   end if
   if exists (stack homeStackStackPath) is false then
      put the filename of stack "LCW" into homeStackStackPath
   end if
   
   put the stackfile_Array of stack homeStackStackPath into stackFileArray  
   delete variable stackFileArray [stackName]
   set the stackfile_Array of stack homeStackStackPath to stackFileArray
   
   if pDontSave is true then return stackFileArray
   save stack homeStackStackPath
   return stackFileArray
end project_RemoveFromStackFiles

command project_AddToStackFiles stackName, projectName, pDontSave
   local commonPath   
   if exists (stack projectName) is true then
      put the filename of stack projectName into homeStackStackPath
   else
      put project_GetHomeStackPath (projectName) into homeStackStackPath
   end if
   if exists (stack homeStackStackPath) is false then
      put the filename of stack "LCW" into homeStackStackPath
   end if
   
   put the stackfile_Array of stack homeStackStackPath into stackFileArray
   --
   put the effective filename of stack stackName into newFile
   put file_GetRelativePath (newFile, projectFolder, commonPath) into newRelativeFile
   put newRelativeFile into stackFileArray [stackName]
   --
   set the stackfile_Array of stack homeStackStackPath to stackFileArray
   
   if pDontSave is true then return stackFileArray
   save stack homeStackStackPath
   return stackFileArray
end project_AddToStackFiles


--> Private
-
private function _NewBehaviorName libraryStack
   put the short name of libraryStack into libStackName
   set the itemdelimiter to "_"
   put libStackName into newBehaviorStackName
   put "behavior" into item 1 of newBehaviorStackName
   return newBehaviorStackName
end _NewBehaviorName

private function _BehaviorPathFromLibraryStack newBehaviorStackName, projectFolder, moduleShortFolder
   # Work out behavior stack path
   put newBehaviorStackName & ".livecodescript" into behaviorShortFile
   put _ConstructModuleBehaviorPath (behaviorShortFile, moduleShortFolder, projectFolder) into moduleBehaviorPath
   
   # Check standard behavior folder exists
   if item 1 of moduleBehaviorPath is "Error" then
      return moduleBehaviorPath
   end if
   
   # Check it does not already exist
   if exists (stack moduleBehaviorPath) then
      breakpoint
      return merge ("Error, behavior stack '[[newBehaviorStackName]]' already exists!")
   end if
   return moduleBehaviorPath
end _BehaviorPathFromLibraryStack

private function _ConstructModuleBehaviorPath behaviorShortFile, moduleShortFolder, projectFolder
   put module_GetFolder (moduleShortFolder, projectFolder) into moduleFolder
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   if there is not a folder moduleBehaviorFolder then
      return merge ("Error, behavior folder '[[moduleBehaviorFolder]]' does not exist!")
   end if
   put moduleBehaviorFolder & behaviorShortFile into moduleBehaviorPath
   return moduleBehaviorPath
end _ConstructModuleBehaviorPath

private command _RenameKnown newStackName, oldStackName
   put the project_Name of stack newStackName into projectName
   put the project_RelativeFile of stack newStackName into newRelativeFile
   --
   put the stackfile_Array of stack projectName into stackFileArray
   delete variable stackFileArray [oldStackName]
   put newRelativeFile into stackFileArray [newStackName]
   set the stackfile_Array of stack projectName to stackFileArray
   --
   return stackFileArray
end _RenameKnown

private command _MoveStack oldStackPath, newStackPath, pLeaveAlias
   if exists (stack newStackPath) then
      return merge ("Error, stack '[[newStackPath]]' already exists!")
   end if
   
   put the short name of stack oldStackPath into oldStackName
   set the stack_IsKnown of stack oldStackPath to false
   --
   put oldStackName is among the lines of the stacksinuse into isUsed
   save stack oldStackName
   
   delete stack oldStackName
   rename file oldStackPath to newStackPath
   go to stack newStackPath
   
   if isUsed is true then
      start using stack newStackPath
   end if
   --
   set the stack_IsKnown of stack newStackPath to true
   
   if pLeaveAlias is true then
      create alias oldStackPath to file newStackPath
   end if
end _MoveStack
