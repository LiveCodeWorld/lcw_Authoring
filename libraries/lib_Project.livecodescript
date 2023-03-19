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
getprop stack_IsKnown [projectName]
   put the stack_Name of the target into stackName
   put the effective filename of stack stackName into stackPath
   if stackPath is empty then return false
   if projectName is empty then put the project_Name of the target into projectName
   if projectName is empty then return false
   
   put project_FindHomeStackPath (stackPath) into homeStackStackPath
   if homeStackStackPath is empty then
      put the filename of stack "LCW" into homeStackStackPath
   end if
   --
   put the stackfile_Array of stack homeStackStackPath into stackFileArray  
   put stackFileArray [stackName] into knownRelativeFile
   return knownRelativeFile is not empty
end stack_IsKnown

setprop stack_IsKnown [projectName] boolean
   put the stack_Name of the target into stackName
   if projectName is empty then put the project_Name of the target into projectName
   
   # Add or remove from the project home stackfiles
   if boolean is true then
      project_AddToStackFiles stackName, projectName, false
   else
      project_RemoveFromStackFiles stackName, projectName, false
   end if
   put the result into stackFileArray
   
   # Export Project JSON
   put the project_Array of the target into projectArray
   -- put project_FetchArray (projectFolder) into projectArray
   put stackFileArray into projectArray ["stackFileArray"]
   set the project_Array of the target to projectArray
   --
   return stackFileArray
end stack_IsKnown


--> Ask
-
command ask_RenameProjectStack stackName
   put "Renamme model '[[stackName]]'?" into someQuestion
   put ask_Question (someQuestion, stackName, "Rename Model", stackName) into newStackName
   --
   project_RenameStack stackName, newStackName
   put the result into newStackPath
   return newStackPath
end ask_RenameProjectStack

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


--> Props
-
setprop project_Move toProjectName
   -- moves a stack to the same relative location in a new project folder
   -- put the stack_Name of the target into stackName
   put the short name of the defaultStack into stackName
   project_MoveStackRelative stackName, toProjectName
   put the result into newPath
   return newPath
end project_Move

getprop project_RelativeFile
   put the stack_Name of the target into stackName
   put the effective filename of stack stackName into sFile
   put the project_Folder of stack stackName into pFolder
   put file_GetRelativePath (sFile, pFolder, commonPath) into rPath
   return rPath
end project_RelativeFile


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
   
   put project_ConstructHomeStackPath (fromProjectFolder) into fromHomePath
   put project_ConstructHomeStackPath (toProjectFolder) into toHomePath
   
   set the stackFile_AddPaths of stack toHomePath to toPath
   set the stackFile_RemovePaths of stack fromHomePath to toPath
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
   
   -- let's set the default values of the scripts metadata
   put metadata_ConstructArray (pStackName, pLibType) into uRipArray
   script_SetMetadataArray pScript, uRipArray
   --
   put project_Construct (pStackName, projectFolder, pShortFolder, pLibType) into newStackPath
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

function project_Construct stackName, projectFolder, pShortFolder, pLibType
   if pShortFolder is empty then
      put project_NameToShortFolder (stackName) into pShortFolder
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
end project_Construct


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

function project_ConstructShortFile stackName
   put project_NameToShortFolder (stackName) & ".livecodescript" into stackName
   return stackName
end project_ConstructShortFile

function project_NameToShortFolder moduleName
   -- factor this out. This is only a hack for menu naming
   set the itemdelimiter to "|"
   repeat for each item someItem in moduleName
      put word 1 to -1 of someItem & "_" after shortFolder
   end repeat
   delete char -1 of shortFolder
   return shortFolder
end project_NameToShortFolder

function project_ShortFolderToName moduleFolderName
   replace "_" with "|" in moduleFolderName
   return moduleFolderName
end project_ShortFolderToName

function project_ConstructStandardFile stackName, projectFolder, pShortFolder, pExtension, pCreateFolder
   -- here we normalize short file and folder names (replace "|" with "_")
   if pExtension is empty then put "livecodescript" into pExtension
   put project_NameToShortFolder (stackName) into shortFileBit
   put project_NameToShortFolder (pShortFolder) into shortFolder
   --
   put folder_AddShort (projectFolder, pShortFolder) into standardFolder
   if pCreateFolder is true then folder_CreateNested standardFolder
   --
   put shortFileBit & "." & pExtension into shortFile
   put standardFolder & shortFile into standardFile
   return standardFile
end project_ConstructStandardFile


--> Project | Create
-
command project_Create projectFolder
   project_CreateStandardFolders projectFolder
   put project_ConstructHomeStackPath (projectFolder) into homeStackPath
   
   put project_GetShortFolder (projectFolder) into projectName -- a clean default
   create script only stack projectName
   set the filename of stack projectName to homeStackPath
   
   put metadata_ConstructArray (projectName, "project") into uRipArray
   set the script_MetaData of stack projectName to uRipArray
   
   put scaffold_GetTemplate ("lcw_HomeStackScript") into templateScript
   put merge (templateScript) into lcwHomeStackScript
   set the script of stack projectName to lcwHomeStackScript
   
   save stack projectName
   
   library_StoreProjectFolder projectName, projectFolder
   env_SetProjectFolder projectName, projectFolder
   return homeStackPath
end project_Create

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
private command _MoveStack oldStackPath, newStackPath, pLeaveAlias
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
