script "Global_Stack_Menu"
--> MetaData
-
license: GPLv3
name: Global_Stack_Menu
type: controller
version: 0.3

--> Variables
-
local LocalArray

/*
Some basic tools for manipulating stacks, and windows. 
*/

--> Currently working On
-

--> Global | Stack | Menu
-
on menu_DisplayStackBehaviorArray scriptObject 
   display_StackBehaviorArray scriptObject, someTitle
end menu_DisplayStackBehaviorArray

command display_StackBehaviorArray scriptObject
   -- put the search_BehaviorArray of scriptObject into stackBehaviorArray
   put the stack_BehaviorArray of scriptObject into stackBehaviorArray
   
   put the stack_Object of scriptObject into stackObject
   put merge ("the stack_BehaviorArray,[[stackObject]]") into someTitle
   display_Array stackBehaviorArray, someTitle
end display_StackBehaviorArray

on menu_EditOpenStack scriptObject, openStackName
   put the name of stack openStackName into stackObject
   object_Inspect stackObject
   edit the script of stack openStackName
end menu_EditOpenStack

on menu_RenameStack scriptObject
   -- could reuse "project_MoveStack oldStackPath, newStackPath"
   
   put the stack_Name of scriptObject into stackName
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

on _
end _

on menu_PaceOnScreen scriptObject, whichScreen
   put the stack_Name of scriptObject into stackName
   put system_GetScreenRect (whichScreen) into pScreenRect
   stack_SetToMainScreen stackName, pScreenRect
end menu_PaceOnScreen

on menu_PlaceOnMainScreen mTarget, openStackName
   switch openStackName
      case "LiveCode Dictionary"
         stack_SetToMainScreen "revDictionary"
         go to stack "revDictionary"
         break
      case "Script Editors"
         put the openstacks into stackNames
         filter stackNames with "revNewScriptEditor *"
         repeat for each line stackName in stackNames
            stack_SetToMainScreen stackName
         end repeat
         break
      case "All open stacks"
         put the openstacks into stackNames
         stack_SetToMainScreen stackNames
         break
      default
         stack_SetToMainScreen openStackName
         show stack openStackName
   end switch
end menu_PlaceOnMainScreen

on menu_Shrink scriptObject
   if the shiftKey is down then
      put lcw_Ask ("What scalefactor do you want to use?", 0.75) into someFactor
   else
      put 0.75 into someFactor
   end if
   stack_Shrink scriptObject, someFactor
end menu_Shrink

on menu_Unshrink scriptObject
   if the shiftKey is down then
      put the stack_Name of scriptObject into stackName
      put the scalefactor of stack stackName into oFactor
      put lcw_Ask ("What scalefactor do you want to use?", oFactor) into someFactor
   else
      put 1 into someFactor
   end if
   stack_Shrink scriptObject, someFactor
end menu_Unshrink

on _
end _

on menu_SnapCard scriptObject
   put the card_Object of scriptObject into cardObject
   if exists (cardObject) is false then
      answer warning "No card for this script object!"
      exit to top
   end if
   
   wireframe_SnapAndExport cardObject, false
   put the result into imageFile
   display_Image imageFile
   -- set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
   finder_Reveal imageFile
end menu_SnapCard

on menu_SnapStack scriptObject
   put the stack_Object of scriptObject into stackObject
   put the wireframe_StackSnap of stackObject into somePNG
   
   put somePNG into image 1 of cd 1 of stack "Test Wireframe Image"
   
   put the short name of stackObject into stackName
   replace quote with empty in stackName
   replace space with "-" in stackName
   put "stack_" & stackName & ".png" into shortFile
   
   localhost_SavePng somePNG, shortFile
   put the result into imageFile
   finder_Reveal imageFile
end menu_SnapStack

on menu_SnapImage scriptObject
   wireframe_SnapAndExport scriptObject, true
   put the result into imageFile
   set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
   finder_Reveal imageFile
end menu_SnapImage

on _
end _

on menu_RevertStack scriptObject
   put the stack_Object of scriptObject into stackObject
   put the effective filename of stackObject into someFile
   put git_GetLastRevision (someFile, 0)
end menu_RevertStack

on _
end _

on menu_RevealStack mTarget
   put the stack_Name of mTarget into stackName
   stack_RevealInFinder stackName
end menu_RevealStack

on menu_FixStackBehaviors mTarget
   put the stack_Name of mTarget into stackName
   stack_FixBrokenBehaviors stackName
   put the result into displayArray
   display_Array displayArray, ("Behaviors of stack" && kwote(stackName))
end menu_FixStackBehaviors

on _
end _

on menu_StackStyle scriptObject, stackStyle
   put the stack_Object of scriptObject into stackObject
   set the style of stackObject to stackStyle
end menu_StackStyle

on menu_StackResizable scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
   set the resizable of stackObject to someBoolean
end menu_StackResizable

on menu_StackTitleStyle scriptObject, stackTitleStyle
   put the stack_Object of scriptObject into stackObject
   set the stack_TitleStyle of stackObject to stackTitleStyle
end menu_StackTitleStyle

on _
end _

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Stack | Menu | Props
-
getprop which_Screens
   put system_ListScreenNames() into screenNames
   return screenNames
end which_Screens

getprop record_Card
   return LocalArray ["isRecoring"] is true
end record_Card

getprop stack_Resizable [scriptObject]
   put the stack_Object of scriptObject into stackObject
   put the resizable of stackObject into someBoolean
   return someBoolean
end stack_Resizable

getprop open_StackName [mTarget]
   put the stack_Name of mTarget into openStackName
   return openStackName
end open_StackName

getprop open_StackNames [mTarget]
   put the openstacks into stackNames
   -- filter stackNames without "rev*"
   sort stackNames
   return stackNames
end open_StackNames

getprop stack_Style [mTarget]
   if exists(mTarget) is false then return empty
   put the stack_Object of mTarget into stackObject
   return the style of stackObject
end stack_Style

getprop stack_Styles
   return "topLevel,modeless,modal,palette"
end stack_Styles

getprop already_Known [stackObject]
   if exists (stackObject) is false then return empty
   put the stack_IsKnown of stackObject into someBoolean
   return someBoolean
end already_Known


--> Global | Stack | Menu | Disabled
-
getprop disabled_Shrink [scriptObject]
   put the stack_Name of scriptObject into stackName
   put the scaleFactor of stack stackName into someFactor
   if someFactor = 1 then
      return false
   else
      return "delete"
   end if
end disabled_Shrink

getprop disabled_UnShrink [scriptObject]
   put the stack_Name of scriptObject into stackName
   put the scaleFactor of stack stackName into someFactor
     if someFactor = 1 then
      return "delete"
   else
      return false
   end if
end disabled_UnShrink

getprop disabled_SpotlightFileInfo [stackObject]
   return the platform is not "MacOS"
end disabled_SpotlightFileInfo


--> Dev | Menu
-
on menu_RecordCard scriptObject, someBoolean
   put scriptObject into LocalArray ["scriptObject"]
   put someBoolean into LocalArray ["isRecoring"]
   export_SnapShot
end menu_RecordCard

on menu_SpotlightFileInfo scriptObject
   put the stack_Object of scriptObject into stackObject
    put the filename of stackObject into someFile
    put spotlight_GetFileInfo (someFile) into stackInfo
    display_Lines stackInfo, "Spotlight file info for" && stackObject
end menu_SpotlightFileInfo

on _
end _

on menu_GitRename scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
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

on menu_DeleteFile scriptObject
   put the stack_Object of scriptObject into stackObject
   stack_DeleteFile stackObject
end menu_DeleteFile     

on _
end _

on menu_SaveStack scriptObject
   put the stack_Object of scriptObject into stackObject
   save stackObject
   lcw_Notify "Saved" && stackObject
end menu_SaveStack

on menu_RenameStack mTarget
   put the stack_Object of mTarget into stackObject
   put the short name of stackObject into oldName
   
   stack_Rename oldName
   -- save stackObject
   -- lcw_Notify "Saved" && stackObject
end menu_RenameStack

on menu_GoToStack scriptObject
   put the stack_Object of scriptObject into stackObject
   go to stackObject
   if the result is not empty then beep
end menu_GoToStack

on menu_AlreadyKnown scriptObject, someBoolean
   put the stack_Object of scriptObject into stackObject
   set the stack_IsKnown of stackObject to someBoolean
end menu_AlreadyKnown



--> Menu | Props
-

--> Deps
-
command export_SnapShot
   put LocalArray ["scriptObject"] into scriptObject
   put LocalArray ["isRecoring"] into isRecoring
   
   if isRecoring is true then
      -- wireframe_SnapAndExport scriptObject, false - card changes we still record the card
      put the wireframe_StackSnap of scriptObject into somePNG
      
      set the text of image 1 of cd 1 of stack "Test Wireframe Image" to somePNG
      /*
      put the result into imageFile
      set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
      put filename
      */
      
      send "export_SnapShot" to me in 2 seconds
   end if
end export_SnapShot
