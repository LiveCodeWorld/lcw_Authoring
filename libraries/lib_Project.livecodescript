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


--> Props
-
getprop stack_IsKnown [projectName]
   put the stack_Name of the target into stackName
   put the effective filename of stack stackName into stackPath
   if stackPath is empty then return false
   if projectName is empty then put the project_Name of the target into projectName
   if projectName is empty then return false
   
   put project_FindHomeStackPath (stackPath) into homeStackStackPath
   
   put the stackfile_Array of stack homeStackStackPath into stackFileArray  
   put stackFileArray [stackName] into knownRelativeFile
   return knownRelativeFile is not empty
end stack_IsKnown

setprop stack_IsKnown [projectName] boolean
   -- adds or removes a stack from the projects stack files
   put the stack_Name of the target into stackName
   if projectName is empty then put the project_Name of the target into projectName
   
   if boolean is true then
      project_AddToStackFiles stackName, projectName, false
   else
      project_RemoveFromStackFiles stackName, projectName, false
   end if
   put the result into stackFileArray
   return stackFileArray
end stack_IsKnown

setprop project_Move toProjectName
   -- moves a stack to the same relative location in a new project folder
   -- put the stack_Name of the target into stackName
   put the short name of the defaultStack into stackName
   project_MoveStackRelative stackName, toProjectName
   put the result into newPath
   return newPath
end project_Move


--> Working on
-
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


--> Project | Create
-
command project_AskCreate
   put the stack_Folder of stack "LCW" into rootFolder
   set the itemdelimiter to slash
   delete item -1 of rootFolder
   
   set the itemdelimiter to comma
   answer folder "Select a root folder for your new project.." with rootFolder
   if it is empty then exit to top   
   
   put lcw_Ask ("What name do you want to give the new project?", "lcw_XXX") into newProjectName
   put library_ListProjectNames() into existingProjectNames
   if newProjectName is among the lines of existingProjectNames then
      answer warning merge ("You already have a project named '[[newProjectName]]'!")
      exit to top
   end if
   
   if exists (stack newProjectName) is true then
      answer warning merge ("There is already a stack named '[[newProjectName]]'!")
      exit to top
   end if
   
   text_AddTrailing rootFolder, slash
   put rootFolder & newProjectName & slash into newProjectFolder
   if there is a folder newProjectFolder then
      answer warning merge ("There is already a folder named '[[newProjectName]]' in this location!")
      exit to top
   end if
   
   project_Create newProjectFolder
   put the result into homeStackPath
   
   edit the script of stack homeStackPath
end project_AskCreate

command project_Create projectFolder
   project_CreateStandardFolders projectFolder
   put project_ConstructHomeStackPath (projectFolder) into homeStackPath
   
   put project_GetShortFolder (projectFolder) into homeStackName -- a clean default
   create script only stack homeStackName
   set the filename of stack homeStackName to homeStackPath
   
   put metadata_ConstructUripArray (homeStackName, "home") into uRipArray
   set the script_MetaData of stack homeStackName to uRipArray
   
   put scaffold_GetTemplate ("lcw_HomeStackScript") into templateScript
   put merge (templateScript) into lcwHomeStackScript
   set the script of stack homeStackName to lcwHomeStackScript
   
   save stack homeStackName
   
   library_StoreProjectFolder homeStackName, projectFolder
   env_SetProjectFolder homeStackName, projectFolder
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


--> Project | Move
-
command project_MoveStackRelative stackName, toProjectName
   -- moves a stack to the same relative location in a new project folder
   -- powerful but be careful!
   
   if exists (stack stackName) is false then
      breakpoint
      return empty
   end if
   
   put the name of stack stackName into stackObject
   -- put the short name of stackObject into stackName
   put the project_Folder of stackObject into fromProjectFolder
   if fromProjectFolder is empty then return empty
   
   put library_FetchProjectFolder (toProjectName) into toProjectFolder
   if toProjectFolder is empty then
      breakpoint
      return empty
   end if
   text_AddTrailing toProjectFolder, slash -- just in case
   
   -- move to same relative location
   put the filename of stackObject into fromPath
   set the itemdelimiter to slash
   put the number of items of fromProjectFolder into iNum
   put item (iNum + 1) to -1 of fromPath into relPath
   put toProjectFolder & relPath into toPath
   put toPath into toFolder
   put empty into item -1 of toFolder
   folder_CreateNested toFolder
   
   -- first let's make sure it is saved!
   save stack stackName
   
   if exists (stack stackName) then
      stop using stack stackName
      delete stack stackName -- should probably check script editor has not got unsaved edits?
   end if
   
   -- move
   rename file fromPath to toPath
   start using stack toPath
   
   -- need to fix the stackfiles
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
   if exists (stack oldStackPath) is false then
      answer warning "View does not exist!"
      breakpoint
      put oldStackPath
      exit to top
   end if
   if newStackPath = oldStackPath then
      answer warning "The paths are the same!"
      return false
   end if
   if there is a file newStackPath then
      answer warning "A file already exists in that location. Remove it first."
      put newStackPath
      finder_Reveal newStackPath
      exit to top
      return false
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
   return true
end project_MoveStack

command project_FixStackFiles projectName
   -- was "library_FixStackFiles"
   put library_FetchProjectHomeStackObject (projectName) into projectHomeStack
   stackFile_FixStackFiles projectHomeStack
   put the result into resultArray
   return resultArray
end project_FixStackFiles


--> Project | Names
-
/*
These should work with modules as well as they are considered to be subprojects with the same structure.

A project or modules name is named after the home stacks name.
So projectName of moduleName = homeStackname
We look to naming folders the same, but allow (for now) stacks to use the pipe convention,
which maps a stack name such as "View | Group | Test" or "View|Group|Test" <=> View_Group_Test
The reasons for this are partly legacy and partly readability.
*/

function project_ConstructSingularType shortFolder
   switch shortFolder
      case "libraries"
         return "library"
      default
         if char -1 of shortFolder = "s" then
            delete char -1 of shortFolder
         end if
         return shortFolder
   end switch
end project_ConstructSingularType

function project_NameToShortFile moduleName
   put project_NameToShortFolder (moduleName) into shortFolder
   put shortFolder & ".livecodescript" into shortFile
   return shortFile
end project_NameToShortFile


--> Project | Stackfiles
-
command project_RemoveFromStackFiles stackName, projectName, pDontSave
   local commonPath
   if exists (stack projectName) is true then
      put the filename of stack projectName into homeStackStackPath
   else
      put project_GetHomeStackPath (projectName) into homeStackStackPath
   end if
   if exists (stack homeStackStackPath) is false then return empty
   
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
   if exists (stack homeStackStackPath) is false then return empty
   
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


--> Project | Create
-
command project_CreateScriptOnlyStack shortFolder, pQuestion, pExample, pProjectName
   -- this handler creates a script only stack in the corresponding folder of the Livecode World Library
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   if pQuestion is empty then put "Give your library a name" into pQuestion
   if pExample is empty then put "lib_Example" into pExample
   put lcw_Ask (pQuestion, pExample) into stackName
   
   put project_GetFolder (pProjectName) into projectFolder
   
   project_CreateStack projectFolder, stackName, shortFolder
   put the result into newStackPath
   
   switch shortFolder
      case "libraries"
      case "models"
         start using stack stackName
         lcw_Notify ("Stack" && kwote (stackName) && "is now known and used!")
         break
   end switch
   
   edit the script of stack stackName
   return newStackPath
end project_CreateScriptOnlyStack

command project_CreateStack projectFolder, pStackName, pShortFolder, pLibType, pScript, pNotScriptOnly
   if pStackName is empty then put project_GetShortFolder (projectFolder) into pStackName -- for creating a homeStack with folder and name the same
   if pShortFolder is empty then
      put project_NameToShortFolder (pStackName) into pShortFolder
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
   
   put project_ConstructStandardFile (pStackName, projectFolder, pShortFolder, someExtension) into newStackPath
   
   _CheckCreateStack pStackName, projectFolder
   
   if pNotScriptOnly is true then
      create stack pStackName
   else
      create script only stack pStackName   -- revIDENewScriptOnlyStackWithScript pName, pScript
      show stack pStackName
   end if
   
   set the filename of stack pStackName to newStackPath
   
   put metadata_ConstructUripArray (pStackName, pLibType) into uRipArray
   -- set the script_MetaData of stack pStackName to uRipArray
   script_SetMetadataArray pScript, uRipArray
   set the script of stack pStackName to pScript
   -- set the customproperties ["uRIP"] of tObject to uRipArray
   
   save stack pStackName
   
   set the stack_IsKnown of stack pStackName to true -- this also saves the stack
   return newStackPath
end project_CreateStack

function project_ConstructStandardFile stackName, projectFolder, pShortFolder, pExtension
   -- here we normalize short file and folder names
   -- to replace "|" with "_"
   if pExtension is empty then put "livecodescript" into pExtension
   put project_NameToShortFolder (stackName) into shortFileBit
   put project_NameToShortFolder (pShortFolder) into shortFolder
   
   put project_ConstructFolder (pShortFolder, projectFolder) into standardFolder
   -- folder_CreateNested standardFolder
   put shortFileBit & "." & pExtension into shortFile
   put standardFolder & shortFile into standardFile
   return standardFile
end project_ConstructStandardFile


--> Private
-
private command _CheckCreateStack stackName, stackFolder
   if stackFolder is empty then
      answer warning merge ("The project folder is empty!")
      breakpoint 
      exit to top
   end if
   if there is a stack stackName then
      put the filename of stack stackName
      go to stack stackName
      show stack stackName
      answer warning "Already a stack with that name!"
      edit the script of stack stackName
      exit to top
   end if
end _CheckCreateStack

private command template_StackAlreadyExists viewName
   if there is a stack viewName then
      put "There is already a view template stack" && kwote (viewName) & "!" into someComment
      answer warning someComment
      show stack viewName
      go to stack viewName
      exit to top
   end if
end template_StackAlreadyExists
