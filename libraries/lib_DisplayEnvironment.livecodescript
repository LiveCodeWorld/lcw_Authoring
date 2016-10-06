script "lib_DisplayEnvironment"
--> MetaData
-
license: GPLv3
name: lib_DisplayEnvironment
type: library
version: 0.4

/*
Here we gather all the handlers that make it easy to display handlers, stacks, projects, and the environment.

-- command display_EnvironmentProjects   
put library_ListProjectNames() into projectNames
put "List of Projects,Environment" into displayTitle
display_Index projectNames, displayTitle, "Global | Environment | Menu", "Global | Project | Tree | Line | Menu", empty, "mDouble_DisplayProject"
put the result into displayView
set the multiple_Hilites of displayView to false
return displayView
end display_EnvironmentProjects

*/

--> Working on
-
command display_Project homeStackName, pGoOrEdit
   if exists (stack homeStackName) is true then
      put the effective filename of stack homeStackName into homeStackPath
   else
      put library_FetchProjectHomeStackPath (homeStackName) into homeStackPath
      if exists (stack homeStackPath) is false then
         put homeStackName
         answer warning merge ("Cannot locate stack '[[homeStackName]]'")
         exit to top
      end if
   end if
   
   if pGoOrEdit is true then
      if the scriptonly of stack homeStackPath is true then
         edit the script of stack homeStackPath
      else
         go to stack homeStackPath
      end if
   end if
   
   display_LibrariesAndModels homeStackPath
   put the result into indexView
   set the menu_Target of indexView to homeStackName
   
   display_ProjectModules homeStackName
   
   -- could check to see if it is already loaded
   -- but here we just load again (may be useful)
   project_Start homeStackName
   
   return indexView
end display_Project


--> Display | ProjectList
-
command display_ProjectList pProjectNames, pIndexView, pStackTitle
   if pProjectNames is empty then put library_ListProjectNames() into pProjectNames
   if pStackTitle is empty then put "List of Projects,Environment" into pStackTitle
   
   put "mDouble_DisplayProject" into mDoubleUp
   
   put empty into mUp
   put "Global | Environment | Menu" into mTitle
   put "Global | Project | Tree | Line | Menu" into mLineTitle
   
   if exists (pIndexView) is false then
      put empty into mUp
      display_Index pProjectNames, pStackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to pProjectNames
      set the stack_Title of pIndexView to pStackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      set the title_Menu of pIndexView to mTitle
      set the line_Menu of pIndexView to mLineTitle
      unlock screen
      return pIndexView
   end if
end display_ProjectList


--> Display | Libraries
-
command display_LibrariesAndModels homeStackPath
   put the short name of stack homeStackPath into homeStackName
   put the project_UsedStackNames of stack homeStackPath into stackNames
   
   put merge ("[[homeStackName]],Model and Libraries") into someTitle
   put empty into mUp
   
   put project_ConstructMenuTitle (homeStackName) & tab & "submenu" after projectMenuTitles
   --
   put CR & "-" after projectMenuTitles
   put CR & "Global | Project | Display | Menu" & tab & "submenu" after projectMenuTitles
   put CR & "Global | Project | Create | Menu" & tab & "submenu" after projectMenuTitles
   put CR & "-" after projectMenuTitles
   put CR & "Global | Project | Tree | Menu" after projectMenuTitles
   
   display_Index stackNames, someTitle, projectMenuTitles, "Global | Project | Line | Menu", mUp, "mDouble_DisplayStackDeps"
   put the result into indexView
   set the multiple_Hilites of indexView to false
   return indexView
end display_LibrariesAndModels

command display_Libraries pIndexView, pProjectNames
   -- see also "display_Project" and "display_LibrariesAndModels"
   put env_ListUsedStackNames (pProjectNames) into activeUsedStackNames
   sort activeUsedStackNames
   
   put empty into mUp
   put "mDouble_DisplayStackDeps" into mDoubleUp
   put "Active Libraries,Environment" into stackTitle
   
   put "Global | Environment | Menu" into mTitle
   put "Global | Project | Tree | Line | Menu" into mLineTitle
   
   if exists (pIndexView) is false then
      display_Index activeUsedStackNames, stackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to activeUsedStackNames
      set the stack_Title of pIndexView to stackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      set the title_Menu of pIndexView to mTitle
      set the line_Menu of pIndexView to mLineTitle
      unlock screen
      return pIndexView
   end if
end display_Libraries


--> Display | Events
-
on mouse_EditHkey treeView, hTableLine
   if the optionKey is "Down" then breakpoint
   
   put the hilited_Element of treeView into hElement
   switch item 1 of hElement
      case "Missing"
         -- put hTableLine into parentTableLine
         put item -1 of hElement into missingTableLine
         put hTableLine into missingParent
         hkey_Edit missingParent
         put missingTableLine
         break
      case "Calls"  
         if the shiftKey is "Down" then
            put item 5 of hElement into hKeyLine
         else
            put item 4 of hElement into hKeyLine
         end if
         put item 3 of hElement into stackObject
         
         hkey_Edit hKeyLine
         
         put hkeyLine_FetchDuplicateArray (hKeyLine) into duplicateArray
         put keys (duplicateArray) into dupHkeys
         if the number of lines of dupHkeys > 1 then
            put merge ("[[hKeyLine]],duplicateArray") into someTitle
            put empty into mLineTitle
            display_Array duplicateArray, someTitle, "Global | Hkey | Duplicate | Menu", mLineTitle, "hkeyLine_TreeClick", "hkeyLine_TreeClick"
         end if
         break
      case "Handlers"
         put item -1 of hElement into hKeyLine
         hkey_Edit hKeyLine
         break
      default
         put item 1 of hElement into dObject
         put hTableLine into lineNums
         put the title_Text of treeView into hKeyLine
         -- put the displayed_Title of treeView into hTableLine
         -- put hKeyLine_Construct (shortHkeyLine, dObject) into hKeyLine
         hkey_Edit hKeyLine
   end switch
end mouse_EditHkey


--> Display | Events
-
on mDouble_EditHkey indexView, shortHkey
   put the displayed_Object of indexView into hObject
   put hKeyLine_Construct (shortHkey, hObject) into hKeyLine
   hkey_Edit hKeyLine
end mDouble_EditHkey

on mDouble_DisplayProject targetObject, stackName
   display_Project stackName
end mDouble_DisplayProject

on mDouble_DisplayStackDeps treeView, stackName
   if the controlkey is "Down" then return false
   
   put the name of stack stackName into stackObject
   if the optionKey is "Down" then
      display_StackDeps stackObject
   end if
   edit the script of stackObject
   return true
end mDouble_DisplayStackDeps

command mDouble_DisplayBehavior indexView, stackName
   mDouble_DisplayStack indexView, stackName
end mDouble_DisplayBehavior

command mDouble_DisplayStack indexView, stackName
   switch
      case exists (stack stackName) is false
         answer merge("Could not find stack '[[stackName]]'.")
         break
      case the scriptonly of stack stackName is true
         edit the script of stack stackName
         break
      default
         go to stack stackName
   end switch
end mDouble_DisplayStack


--> Display | Object
-
command display_ScriptObject scriptObject, someTitle, pHkeys
   put the project_Name of scriptObject into stackLabel
   if stackLabel is empty then put "Object" into stackLabel
   put merge ("[[the name of scriptObject]],[[stackLabel]]") into someTitle
   
   if pHkeys is empty then put the script_ShortHkeys of scriptObject into pHkeys
   put "mDouble_EditHkey" into mDoubleUp
   
   put empty into mUp
   put "Global | Script | Tree | Menu" into mTitle
   put "Global | Script | Tree | Line | Menu" into mLineTitle
   
   display_Index pHkeys, someTitle, mTitle, mLineTitle, mUp, mDoubleUp
   put the result into indexView
   set the displayed_Object of indexView to scriptObject
   set the multiple_Hilites of indexView to false
   return indexView
end display_ScriptObject

command display_Stacks stackNames, pIndexView, pStackTitle
   if pStackTitle is empty then put "Stacks,Environment" into pStackTitle
   
   put "mDouble_DisplayStack" into mDoubleUp
   
   if exists (pIndexView) is false then
      put empty into mUp
      display_Index stackNames, pStackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to stackNames
      set the stack_Title of pIndexView to pStackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      unlock screen
      return pIndexView
   end if
end display_Stacks

command display_ActiveViews pIndexView
   put env_ListViewStackNames() into activeViewStackNames
   
   put "Active Views,Environment" into stackTitle
   put "mDouble_DisplayStack" into mDoubleUp
   
   put empty into mUp
   put "Global | Environment | Menu" into mTitle
   put "Global | Project | Tree | Line | Menu" into mLineTitle
   
   if exists (pIndexView) is false then
      display_Index activeViewStackNames, stackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to activeViewStackNames
      set the stack_Title of pIndexView to stackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      set the title_Menu of pIndexView to mTitle
      set the line_Menu of pIndexView to mLineTitle
      unlock screen
      return pIndexView
   end if
end display_ActiveViews

command display_ActiveControllers pIndexView
   put env_ListControllerStackNames() into activeControllerStackNames
   
   put empty into mUp
   put "mDouble_DisplayStack" into mDoubleUp
   put "Active Controllers,Environment" into stackTitle
   
   put "Global | Environment | Menu" into mTitle
   put "Global | Project | Tree | Line | Menu" into mLineTitle
   
   if exists (pIndexView) is false then
      display_Index activeControllerStackNames, stackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to activeControllerStackNames
      set the stack_Title of pIndexView to stackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      set the title_Menu of pIndexView to mTitle
      set the line_Menu of pIndexView to mLineTitle
      unlock screen
      return pIndexView
   end if
end display_ActiveControllers

command display_ActiveModules pIndexView
   put env_ListModuleHomeStackNames() into activeModuleHomeStackNames
   
   put "Active Modules,Environment" into stackTitle
   put "mDouble_DisplayModule" into mDoubleUp  
   
   put empty into mUp
   put "Global | Environment | Menu" into mTitle
   put "Global | Project | Tree | Line | Menu" into mLineTitle
   
   if exists (pIndexView) is false then
      display_Index activeModuleHomeStackNames, stackTitle, mTitle, mLineTitle, mUp, mDoubleUp
      put the result into displayView
      return displayView
   else
      lock screen
      set the view_Index of pIndexView to activeModuleHomeStackNames
      set the stack_Title of pIndexView to stackTitle
      set the mouse_DoubleUpEvent of pIndexView to mDoubleUp
      set the title_Menu of pIndexView to mTitle
      set the line_Menu of pIndexView to mLineTitle
      unlock screen
      return pIndexView
   end if
end display_ActiveModules


--> Display | Environment
-
function project_ConstructMenuTitle homeStackName
   set the itemdelimiter to "_"
   put item -1 of homeStackName into menuBit
   put toupper (char 1 of menuBit) into char 1 of menuBit
   put "Global |" && menuBit && "| Menu" into gMenuTitle
   return gMenuTitle
end project_ConstructMenuTitle


--> Display | StackDeps
-
command display_StackDeps stackObject
   put the project_Name of stackObject into projectName
   put the stack_PlaceArray of stackObject into pDepArray
   
   put merge ("[[stackObject]],[[projectName]]") into someTitle
   
   put "Global | HkeyArray | Tree | Deps | Menu" into mTitle
   put "Global | HkeyArray | Menu" into mLineTitle
   display_Array pDepArray, someTitle, mTitle, mLineTitle, "mouse_EditHkey", "mouse_EditHkey"
   put the result into indexView
   set the displayed_Object of indexView to stackObject
   set the multiple_Hilites of indexView to false
   return indexView
end display_StackDeps


--> Display | HandlerDeps
-
command display_HandlerDeps hKeyLine
   put hkeyLine_WalkExportedHkeyArray (hKeyLine) into hKeyArray
   put hkeyArray_ToProjectDependencyArray (hKeyArray) into projectDependencyArray
   
   put merge ("[[hKeyLine]],display_HandlerDeps") into someTitle
   put empty into mLineTitle
   display_Array projectDependencyArray, someTitle, "Global | HkeyArray | Tree | Menu", mLineTitle, "hkeyLine_TreeClick", "hkeyLine_TreeClick"
   put the result into treeView
   set the displayed_Hkey of treeView to hKeyLine
   
   set the view_Data of treeView to hKeyArray
   set the displayed_Style of treeView to "Project Dependency Array"
   return treeView
end display_HandlerDeps


--> Deps
-
getprop stack_PlaceArray
   /*
   -- see also "hkeyLine_WalkExportedHkeyArray"
   
   This only looks at calls, and hkeys in the actual object.
   It does not walk the dependency tree.
   usefull for a quicl look at first level dependencies.
   */
   
   local pDepArray
   
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   put the data_Folder of tObject into dataFolder
   put revRuggedID (tObject) into rObject
   put script_FetchHkeyPlaceArray() into hkeyPlaceArray
   
   repeat for each line hTableLine in hTable
      put word 1 to 2 of hTableLine into shortHkey
      put hKeyLine_Construct (shortHkey, rObject) into pHkey
      put handler_FetchCalls (shortHkey, dataFolder) into shortCalls
      put shortCalls into pDepArray ["Handlers"][pHkey]
      
      set the wholematches to false
      repeat for each line shortCall in shortCalls
         put shortCall & space into searchString
         if lineOffset (searchString, hTable) > 0 then
            next repeat
         end if
         
         put hkey_GetPlace (shortCall, hkeyPlaceArray) into cObject
         if exists (cObject) is false then
            put empty into pDepArray ["Missing"][rObject][shortCall][pHkey]
         else
            put the project_Name of cObject into cProjectName
            put hKeyLine_Construct (shortCall, cObject) into cHkey
            put empty into pDepArray ["Calls"][cProjectName][cObject][cHkey][pHkey]
         end if
      end repeat
   end repeat
   return pDepArray
end stack_PlaceArray

function hkeyArray_ToProjectDependencyArray hTableLineArray
   local pDepArray
   repeat for each key hTableLine in hTableLineArray
      -- not strictly need. Skip for speed?
      put hkeyArray_FindParentArray (hTableLine, hTableLineArray) into parentArray
      put keys (parentArray) into parentkeys
      
      addTableLine pDepArray, hTableLine, parentArray
      put hTableLineArray [hTableLine] into hTableLineCallArray
      repeat for each key hTableLineCall in hTableLineCallArray
         addTableLine pDepArray, hTableLineCall, hTableLine
      end repeat
   end repeat
   return pDepArray
end hkeyArray_ToProjectDependencyArray


--> hkeyLine | Walk
-
getprop exported_HandlerHkeyArray [shortHkey]
   put the long id of the target into tObject
   hkey_Deconstruct shortHkey, hName, hType, hObject, hNum
   put revRuggedID (tObject) into hObject
   put hKeyLine_FromTripple (hName, hType, hObject) into hKeyLine
   put hkeyLine_WalkExportedHkeyArray (hKeyLine) into hKeyArray
   return hKeyArray
end exported_HandlerHkeyArray

function hkeyLine_WalkExportedHkeyArray hKeyLine, pProjectName
   /*
   Works out dependecy array from flat namespace of all hkeys in hkeyPlaceArray library.
   Does not look at pProjectName at the moment (for that need to return different arrays with "script_FetchHkeyPlaceArray (pProjectName)")
   */
   
   local hKeyLinkArray
   
   put script_FetchHkeyPlaceArray (pProjectName) into hkeyPlaceArray
   put hkeyLine_FetchCalls (hKeyLine) into shortCallHkeyLines
   repeat for each line shortCallHkeyLine in shortCallHkeyLines 
      hkeyLine_WalkExportedHkeyArray shortCallHkeyLine, hKeyLine, hKeyLinkArray, hkeyPlaceArray
   end repeat
   return hKeyLinkArray
end hkeyLine_WalkExportedHkeyArray

private command hkeyLine_WalkExportedHkeyArray shortCallHkeyLine, parentHKeyLine, @hKeyLinkArray, hkeyPlaceArray
   hKeyLine_Deconstruct shortCallHkeyLine, cName, cType, hObject
   put hkey_GetPlace (shortCallHkeyLine, hkeyPlaceArray) into cObject -- find it
   
   if exists (cObject) is false then 
      put hKeyLine_Construct (shortCallHkeyLine, "Missing") into missingCall
      put true into hKeyLinkArray [parentHKeyLine][missingCall]
      return empty
   end if
   
   put hKeyLine_Construct (shortCallHkeyLine, cObject) into foundCall
   if hKeyLinkArray [parentHKeyLine][foundCall] is true then
      return empty -- already indexed (don't recurse)
   end if
   
   -- add it to the array
   put true into hKeyLinkArray [parentHKeyLine][foundCall]
      
   -- now lets repeat and recurse for each call found
   put hkeyLine_FetchCalls (foundCall) into childShortHkeyLines   
   repeat for each line childShortHkeyLine in childShortHkeyLines
      hkeyLine_WalkExportedHkeyArray childShortHkeyLine, foundCall, hKeyLinkArray, hkeyPlaceArray
   end repeat
   
   return empty
end hkeyLine_WalkExportedHkeyArray

private command addTableLine @pDepArray, hTableLine, parentTableLine
   hKeyLine_Deconstruct hTableLine, cName, cType, cObject
   if exists (cObject) is false then
      put parentTableLine into pDepArray ["Missing"][hTableLine]
   else
      put the project_Name of cObject into cProjectName
      put parentTableLine into pDepArray ["Calls"][cProjectName][cObject][hTableLine]
   end if
end addTableLine

function hkeyArray_FindParentArray hTableLine, hTableLineArray
   repeat for each key testTableLine in hTableLineArray
      put hTableLineArray [testTableLine] into hTableLineCallArray
      if hTableLineCallArray  [hTableLine] is true then
         put true into parentArray [testTableLine]
      end if
   end repeat
   return parentArray
end hkeyArray_FindParentArray
