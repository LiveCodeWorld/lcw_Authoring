script "Global | Stack | Tidy | Menu"
--> MetaData
-
license: GPLv3
name: Global | Stack | Tidy | Menu
type: controller
version: 0.2

/*This menu contains a collection of handlers that have been used for deling with git, and stack versions.
Deleting, renaming, and reverting to earlier versions.

Take a look at them and use the ones that are valuable.*/


--> Menu | Props
-
getprop menu_Target [tObject]
   put the displayed_Object of tObject into sView
   return sView
end menu_Target

getprop menu_CheckTarget [sView]
   return exists (sView)
end menu_CheckTarget

getprop disabled_SpotlightFileInfo [stackObject]
   return the platform is not "MacOS"
end disabled_SpotlightFileInfo

command display_StackBehaviorArray sObject
   -- ad a menu to the display
   -- put the search_BehaviorArray of sObject into stackBehaviorArray
   put the stack_BehaviorArray of sObject into stackBehaviorArray
   
   put the stack_Object of sObject into stackObject
   put merge ("the stack_BehaviorArray,[[stackObject]]") into someTitle
   
   display_Array stackBehaviorArray, someTitle
end display_StackBehaviorArray


--> Global | Stack | Tidy | Menu
-
on menu_AlreadyKnown sObject
   put the stack_IsKnown of sObject into someBoolean 
   set the stack_IsKnown of stackObject to (someBoolean is false)
end menu_AlreadyKnown

getprop checked_AlreadyKnown [sObject]
   return _IsKnown (sObject)
end checked_AlreadyKnown

private function _IsKnown sObject
   put the stack_IsKnown of sObject into someBoolean
   return someBoolean
end _IsKnown

private on _
end _

on menu_RevertStack sObject
   put the stack_Object of sObject into stackObject
   put the effective filename of stackObject into someFile
   put git_GetLastRevision (someFile, 0)
end menu_RevertStack

on menu_SaveStack sObject
   put the stack_Object of sObject into stackObject
   save stackObject
   lcw_Notify "Saved" && stackObject
end menu_SaveStack

on menu_DeleteFile sObject
   put the stack_Object of sObject into stackObject
   stack_DeleteFile stackObject
end menu_DeleteFile

private on __
end __

on menu_OpenRevision sObject, backNum
   put the git_RelativeFile of sObject into relativePath
   put git_GetCommitFileHash (relativePath, backNum) into commitHash
   if commitHash is empty then
      answer warning "Cannot find commit hash for this stack!"
      exit to top
   end if
   
   git_DisplayTempStackRevision sObject, commitHash
end menu_OpenRevision

on menu_DiffStackBinaries treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put the effective filename of stackObject into stackPath   
   git_ExportFileRevision stackPath, commitHash
   put the result into toFile
   
   diff_Files thisFile, toFile
end menu_DiffStackBinaries

private on ___
end ___

on menu_CloneRevertedStack treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   git_DisplayTempStackRevision stackObject, commitHash
end menu_CloneRevertedStack

on menu_RevertStack treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   /*
   put the git_RelativeFile of mTarget into relativeFile
   put git_GetLastRevision (relativeFile, 1) into binaryStackData
   display_Text binaryStackData
   */
   
   -- put the long id of stackObject into stackObject
   -- delete stackObject
   git_RevertStack stackObject, commitHash
   -- go to stackObject
end menu_RevertStack

on menu_RevertCommit
   put "git revert --no-edit HEAD" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   git_RefreshDisplay true, "Git Status"
   
   if shellResult is not empty then
      beep
      lcw_Notify shellResult
   end if
end menu_RevertCommit

on menu_ThrowAwayUncommittedChanges
   /*
   Note: git revert is used to record a new commit to reverse the effect of an earlier commit (often a faulty one). If you want to throw away all uncommitted changes in your working directory, you should see git-
   reset(1), particularly the --hard option. If you want to extract specific files as they were in another commit, you should see git-checkout(1), specifically the git checkout <commit> -- <filename> syntax. Take care
   with these alternatives as both will discard uncommitted changes in your working directory.
   */
   
   put "git reset --hard HEAD" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   git_RefreshDisplay true, "Git Status"
   
   if shellResult is not empty then
      lcw_Notify shellResult, true
   end if
end menu_ThrowAwayUncommittedChanges

on menu_ResetHard
   git_HardReset
end menu_ResetHard

private on ____
end ____

on menu_SpotlightFileInfo sObject
   put the stack_Object of sObject into stackObject
   put the filename of stackObject into someFile
   put spotlight_GetFileInfo (someFile) into stackInfo
   --
   put the name of stackObject into sTitle
   display_Lines stackInfo, "Spotlight file info for" && sTitle
end menu_SpotlightFileInfo

on menu_StackData treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put the git_StackTreeish [commitHash] of stackObject into treeish
   put "git show" && kwote (treeish) into someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   put shellResult into stackData
   
   display_Text stackData
end menu_StackData

on menu_DisplayCommitInfo treeField
   put the tree_SelectedLink of treeField into commitHash
   put git_HashInfo (commitHash) into hashInfo   
   put "git show" && kwote (commitHash) into someShell
   display_Text hashInfo, someShell
end menu_DisplayCommitInfo

on menu_ListCommitInfo treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put git_List (commitHash) into logText
   
   put "git ls-tree" && commitHash into someShell
   display_Lines logText, someShell
end menu_ListCommitInfo

on menu_StackHashLog treeField
   -- a log of all the previous commits of a version specified by commitHash
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put the git_StackHashLog [commitHash] of stackObject into logText
   
   display_Lines logText, ("the git_ObjectHashLog [" & commitHash & "] of" && stackObject)
end menu_StackHashLog

private on _____
end _____

on submenu_Dev
   return menu_DevTitle ("Global | Stack | Tidy | Menu")
end submenu_Dev

on menu_RenameStack sObject
   -- could reuse "project_MoveStack oldStackPath, newStackPath"
   -- stack_Rename oldName
   
   put the stack_Name of sObject into stackName
   put lcw_Ask ("Rename this stack...", stackName) into newStackName
   if there is a stack newStackname then
      answer warning merge ("A stack called '[[newStackName]]' already exists!")
      exit to top
   end if
   if stackName = newStackName then
      answer warning ("Not renamed. No point renaming a stack to the same name!")
      exit to top
   end if
   
   breakpoint
   put the filename of stack stackName into oldStackPath
   set the itemdelimiter to slash
   put item -1 of oldStackPath into oldShortFile
   put lcw_Ask ("Rename this stacks file on disk...", oldShortFile) into newShortFile
   put oldStackPath into newStackPath
   put newShortFile into item -1 of newStackPath
   
   breakpoint
   set the stack_IsKnown of stack stackName to false
   --
   put stackName is among the lines of the stacksinuse into isUsed
   set the name of stack stackName to newStackName
   save stack newStackName
   
   if newStackPath is not oldStackPath then
      delete stack stackName
      rename file oldStackPath to newStackPath
      go to stack newStackPath
   end if
   
   if isUsed is true then
      start using stack newStackName
   end if
   --
   set the stack_IsKnown of stack newStackName to true
end menu_RenameStack

on menu_GitRename sObject, someBoolean
   put the stack_Object of sObject into stackObject
   put the short name of stackObject into oldName
   
   set the itemdelimiter to "/"
   put the filename of stack oldName into oldFile
   put item -1 of oldFile into oldShortFile
   
   put oldFile into newFile
   put oldName & ".rev" into newShortFile
   
   put merge("What do you want to rename this stack '[[oldShortFile]]' to?") into someQuestion
   put lcw_Ask (someQuestion, newShortFile) into newShortFile
   put newShortFile into item -1 of newFile
   
   git_RenameFile oldFile, newFile
   -- rename file fromFile to toFile
   return newFile
end menu_GitRename

on menu_DisplayStackBehaviorArray sObject 
   display_StackBehaviorArray sObject, someTitle
end menu_DisplayStackBehaviorArray

on menu_FixStackBehaviors mTarget
   put the stack_Name of mTarget into stackName
   stack_FixBrokenBehaviors stackName
   put the result into displayArray
   display_Array displayArray, "Behaviors of stack", kwote(stackName)
end menu_FixStackBehaviors
