script "lib_IdeHack"
--> MetaData
-
license: GPLv3
name: lib_IdeHack
type: library
version: 0.1


/*
This stack is a list of hacks for the IDE that needs sorting.
The organised ones I've put in model_IDE
This one needs some serious tidying.


These functions were introduced in v5.5

revEnvironmentUserExternalsPath()  -- The location of the folder to use for additional externals. 
revEnvironmentUserPluginsPath()  -- The location of the folder to use for additional plugins. 
revEnvironmentUserResourcesPath() -- The location of the folder to use for additional resources.

revEnvironmentCustomizationPath()  -- The location of the IDE customization folder.
revEnvironmentUserCachePath()  -- The location of the folder to use for caching files.
revEnvironmentUserPreferencesPath()  -- The location of the folder to use for preference files.

revEnvironmentToolsPath() -- The location containing the main IDE files.
revEnvironmentToolsetPath()  -- The location of the main IDE stacks.
revEnvironmentExternalsPath()  -- The location of the externals that come with the IDE. 
revEnvironmentPluginsPath()  -- The location of the plugins that come with the IDE.
revEnvironmentRuntimePath()  -- The location of the standalones that come with the IDE. 

revEnvironmentDocumentationPath()  -- The location of the documentation files.
revEnvironmentResourcesPath()  -- The location of the resources that come with the IDE. 

refreshTabStates
revSERestoreEditors
put revListScriptEditors()
*/


--> Working on
-
command display_Props sObject
   -- was "object_Inspect"
   revIDEInspectObjects sObject
   return the result
end display_Props

command display_ObjectProperties sObject
   display_Props sObject
end display_ObjectProperties


--> Rev | Script Editor | Search Results
-
function rev_FormatHkeySearchResult shortHKeys, scriptObject, searchText
   #   Format of pResultsString is a list of search results, one per line, where each search result is in the following form:
   #      <object long id> <line number> <start char> <end char> <matched text with context>
   #       (all fields are separated by tabs).
   #   pResultsString also contains a header, this makes up the first two lines of the string. Line 1 is the search term and line 2 is the search scope.
   
   put searchText & CR into tFormattedResults
   put "for handlers" & CR after tFormattedResults
   
   repeat for each line shortHKey in shortHKeys 
      put hArray_FindHkeyInHierarchy (shortHKey, scriptObject) into foundHkey
      if foundHkey is empty then
         -- not sure what to do
         put "Missing" & tab & 0 & tab & 0 & tab & 0 & tab & "Cannot find" && shortHKey & CR after tFormattedResults
         next repeat
      end if
      
      put hArray_GetHandlerArray (foundHkey) into hkeyInfoArray
      if hkeyInfoArray is an array then
         put hkeyInfoArray ["handlerLine"] into handlerLine
         put hkeyInfoArray ["startLineNum"] into startLineNum
         put item 3 of foundHkey into foundObject
         
         -- here if we had also stored char nums this would be much faster (only required for search results so far)
         try
            put the script of foundObject into someScript
            put the number of chars of line 1 to (startLineNum - 1) of someScript into startCharNum
            add 1 to startCharNum
            put startCharNum + the number of chars of handlerLine into endCharNum
         catch e
            breakpoint
         end try
      else
         -- it should be (broken database)
         put shortHKey && "(broken handler array)" into handlerLine
         put 1 into startLineNum
         put 0 into startCharNum
         put 0 into endCharNum
      end if
      
      put foundObject into resultLine
      put tab & startLineNum after resultLine
      put tab & startCharNum after resultLine  
      put tab & endCharNum after resultLine
      put tab & handlerLine after resultLine
      put resultLine & CR after tFormattedResults
   end repeat
   delete char -1 of tFormattedResults
   return tFormattedResults
end rev_FormatHkeySearchResult

command rev_SetScriptEditorSearchResults tFormattedResults
   -- ignoreCall: sePrefSet,c
   -- ignoreCall: setCurrentTab,c
   -- ignoreCall: expandCurrentPane,c
   -- ignoreCall: refreshCurrentPane,c
   
   # Parameters
   #   pResultsString : A list of search results, one per line. Format described below
   # Description
   #   Displays the specified results. If pResultsString is empty then displays nothing.
   #   Format of pResultsString is a list of search results, one per line, where each search result is in the following form:
   #      <object long id> <line number> <start char> <end char> <matched text with context>
   #       (all fields are separated by tabs).
   #   pResultsString also contains a header, this makes up the first two lines of the string. Line 1 is the search term and line 2 is the search scope.
   
   put revTopMostScriptEditor() into topScriptEditorStack
   
   dispatch "sePrefSet" to stack "revNewScriptEditor" with "editor,lastsearchresults",tFormattedResults
   send "setCurrentTab Search Results" to group "Pane Tabs" of topScriptEditorStack
   send "expandCurrentPane" to group "Panes" of topScriptEditorStack
   send "refreshCurrentPane" to group "Panes" of topScriptEditorStack
end rev_SetScriptEditorSearchResults


--> Object | Revolution
-
function object_FilterRev objectIndex
    repeat for each line someObject in objectIndex
        get the stack_Name of someObject
        if char 1 to 3 of it is not "rev" then
            put someObject & CR after nonRevObjects
        end if
    end repeat
    delete last char of nonRevObjects
    return nonRevObjects
end object_FilterRev


--> Rev | App Browser
-
command rev_RefreshAppBrowser
   dispatch "revRefreshTree" to stack "revApplicationOverview"
end rev_RefreshAppBrowser


--> Rev | Save
-
command rev_SaveStack stackName
   if the effective fileName of stack stackName is not empty then
      revSave stackName
   else 
      revSaveAs stackName
   end if
   return the result
end rev_SaveStack

command rev_SaveAs pShortName, pDefaultFilePath, pAskComment, pSubstackOnly
   -- slightly modified from revSaveAs of revBackScript
   local tMakeMainStack, tMainStackName, tStackName
   global gREVMessageDispatch
   
   -- allows specifying a default file path to save and customising the ask file message
   -- otherwise should be the same
   if pAskComment is empty then put "Save stack" && pShortName && "as:" into pAskComment
   
   if the platform is not "MacOS" then
      put revFixPath (pShortName) into tStackName
   else
      put pShortName into tStackName
      if char -4 to -1 of tStackName is not ".rev" and revExtensionShow() then
         put ".rev" after tStackName
      end if
   end if
   
   switch
      case pDefaultFilePath is empty
         put tStackName into pDefaultFilePath
         break
      case char -1 of pDefaultFilePath = "/"
         put tStackName after pDefaultFilePath
         break
      default
         -- leave user specified default path as is
   end switch
   --
   
   put the short name of stack pShortName into pShortName
   
   put the name of stack pShortName into stackObject
   repeat for each line l in gREVMessageDispatch [revSaveStackRequest]
      dispatch "revSaveStackRequest" to this cd of stack l with stackObject -- not sends stackObject not stackName as param
   end repeat
   
   if "id 1230" is in the frontScripts and "revTools" is in the frontScripts then
      select empty
      send "revSetMarkers true" to btn "revReshape" of stack "revTools"
      remove script of btn "revReshape" of stack "revTools" from front
   end if
   
   put the defaultStack into tDefaultStackBackup
   put pShortName into pShortNameBackup
   
   put true into tMakeMainStack
   put the mainStack of stack pShortName into tMainStackName
   if tMainStackName is not pShortName and tMainStackName is not "Home" then
      if not pSubStackOnly then
         put false into tMakeMainStack
         put tMainStackName into pShortName
      end if
   end if
   
   if the systemFileSelector then
      switch the platform
         case "Win32"
            put "Revolution Stacks" & cr & "*.rev" & cr & "MetaCard Stacks" & cr & "*.mc" & cr & "All Files" & cr & "*.*" into tFilterString
            break
         case "MacOS"
            put "MSTK" into tFilterString
            break
         default
            put "*.rev" into tFilterString
      end switch
   else put "*.rev" into tFilterString
   
   ask file pAskComment with pDefaultFilePath with filter tFilterString
   
   if it is empty then
      put "edited" into gREVStackStackStatus [pShortName]
      return empty
   end if
   
   if the platform is not "MacOS" and char -4 to -1 of it is not ".rev" then
      put ".rev" after it
   end if
   put it into tFilePath
   if the platform is not in "Win32,MacOS" and there is a file tFilePath then
      answer warning "File exists.  Overwrite?" with "Cancel" or "OK"
      if it is "Cancel" then return empty
      else delete file tFilePath
   end if
   
   if tMakeMainStack and pShortName is not tMainStackName then
      put the colors of stack pShortName into tStackColors
      put the colors of stack "Home" into tHomeColors
      repeat with i = 1 to 8
         if line i of tStackColors is empty
         then put line i of tHomeColors into line i of tStackColors
      end repeat
      set the colors of stack pShortName to tStackColors
      set mainStack stack pShortName to pShortName
      set the cursor to watch
      save stack tMainStackName
   end if
   
   set the cursor to watch
   lock messages
   save stack pShortName as tFilePath
   if the result is not empty then
      answer "Can't save stack" && l && "due to an error:" & cr & the result
      unlock messages
      return empty
   else
      put empty into gREVStackStatus [pShortName]
      put the mainStack of stack pShortName into tMainStackList
      put CR & the substacks of stack pShortName after tMainStackList
      repeat for each line xy in tMainStackList
         if xy is empty then next repeat
         put empty into gREVStackStatus [xy]
      end repeat
      revUpdateRecentFiles pShortName
      revKillAllLinkedPalettes
      unlock messages
      return tFilePath
   end if
end rev_SaveAs

function rev_FixPath pPath
   -- copy of revFixPath from revbackScript
   put pPath into tReturnPath
   if the platform is "MacOS" then
      put ":" & tab into tRemoveChars
   else if the platform is "Win32" then
      put "\/:*?<>|" & quote & tab into tRemoveChars
      if char -4 to -1 of tReturnPath is not ".rev" and revExtensionShow() then
         put ".rev" after tReturnPath
      end if
   else
      put " :?*<>/\()[]{}|'`" & quote & tab into tRemoveChars
      if char -4 to -1 of tReturnPath is not ".rev" then
         put ".rev" after tReturnPath
      end if
      put tolower(pPath) into tReturnPath
   end if
   repeat for each char c in tRemoveChars
      replace c with "_" in tReturnPath
   end repeat
   return tReturnPath
end rev_FixPath


--> Repository | Counter | Model
-
*/
This model is here as it is used by the front script (which can depend on it being there!), 
and therefore any controls can access it.
*/

function repository_GetSaveNowCount
   put the uOPN ["repository_SaveNowCount"] of me into someNum
   if someNum is not a number then put 3 into someNum
   return someNum
end repository_GetSaveNowCount

command repository_SetSaveNowCount someNum
   if someNum is not a number then put empty into someNum
   set the uOPN ["repository_SaveNowCount"] of me to someNum
   return someNum
end repository_SetSaveNowCount

function repository_GetArchiveNowCount
   put the uOPN ["repository_ArchiveNowCount"] of me into someNum
   if someNum is not a number then put 8 into someNum
   return someNum
end repository_GetArchiveNowCount

command repository_SetArchiveNowCount someNum
   if someNum is not a number then put empty into someNum
   set the uOPN ["repository_ArchiveNowCount"] of me to someNum
   return someNum
end repository_SetArchiveNowCount


--> Field | Script
-
setprop field_ScriptScheme [startAndEnd] someScheme
   -- sets the colourisation to that of the users preference setting
   -- someScheme is not currently working.
   
   if someScheme is not among the lines of rev_ListColourizationSchemes() then return empty
   
   -- put the stack_IsKnown of stack "revNewScriptEditor" -- it is not known - but it is open :)
   -- dispatch "revSEColorize" to stack "revNewScriptEditor" with pScript,pScheme -- can't get this working???
   
   put rev_GetColourizationScheme() into oScheme
   rev_SetColourizationScheme someScheme
   
   put the long id of the target into pField
   if startAndEnd is empty then
      put the text of pField into someScript
      put the number of chars of someScript into pEnd
      put 1 into pStart
   else
      put item 1 of startAndEnd into pStart
      put item 2 of startAndEnd into pEnd
   end if
   
   dispatch "revSEColorizeField" to stack "revNewScriptEditor" with pField,pStart,pEnd
   put the result into someScheme
   switch it
      case "handled"
         -- great
   end switch
   
   rev_SetColourizationScheme oScheme
   return someScheme
end field_ScriptScheme

command rev_SetColourizationScheme schemeName
   -- sets the value
   rev_SetPref "colorization", "scheme", schemeName
   -- but does not update something so not really functioning???
end rev_SetColourizationScheme

function rev_ListColourizationSchemes
   put "seColorizationLoadScheme,c" into shortHkey
   put the hkey_CaseConditions [shortHkey] of stack "revNewScriptEditor" into colourConditions
   return colourConditions
end rev_ListColourizationSchemes


--> App Browser
-
function rev_GetAppBrowserSelectedControls
   -- reverse engineered fro the LiveCode IDE
   global gREVStackName, gREVControls
   if gREVControls is empty then return empty
   
   put the long id of cd "Cards and Controls" of stack "revApplicationOverview" into controlCard
   -- put value ("revSelControls()", controlCard) into tObjects
   if exists (field "Controls" of controlCard) is false then
      breakpoint
      return empty
   end if
   
   put the cCardID of stack "revApplicationOverview" into cardID
   put the long id of field "Controls" of controlCard into controlField
   put the hilitedLines of controlField into tLines
   
   put empty into someObjects
   repeat for each item i in tLines
      put item 4 of line i of gREVControls into cNum
      put the long id of control cNum of card id cardID of stack gREVStackName & CR after someObjects
   end repeat
   delete last char of someObjects
   return someObjects
end rev_GetAppBrowserSelectedControls


--> Script Editor | Documentation
-
command rev_SetScriptEditorShowDocumentation hKey, pUnlockField
   put hkey_FetchHelp (hKey) into someHtml
   
   lock screen
   if someHtml is empty then
      rev_SetLaunchDocButtonLabel
   else
      -- lcw_Notify ("Displayed" && hKey), true
      -- _autoSave hKey, someHtml
      
      rev_SetLaunchDocButtonLabel "Handler Doc"
      scriptEditor_SetActivePane "Documentation" -- this must be first as it also set's the htmltext
      rev_SetScriptEditorDocumentation someHtml
      
      if pUnlockField is true then
         rev_SetScriptEditorDocumentationLock true
      end if
   end if
   unlock screen
end rev_SetScriptEditorShowDocumentation

function rev_GetLaunchDocButtonLabel pEditorNum
   put rev_LaunchDocsButton (pEditorNum) into launchDocsButton
   put the label of launchDocsButton into someLabel
   if someLabel is "Launch Documentation" then return empty
   return someLabel
end rev_GetLaunchDocButtonLabel

command rev_SetLaunchDocButtonLabel someLabel, pEditorNum
   if someLabel is empty then put "Launch Documentation" into someLabel
   put rev_LaunchDocsButton (pEditorNum) into launchDocsButton
   set the label of launchDocsButton to someLabel
end rev_SetLaunchDocButtonLabel

function rev_GetScriptEditorDocumentation pEditorNum
   put rev_ScriptEditorDocField (pEditorNum) into scriptEditorDocField
   put the htmlText of scriptEditorDocField into someHtmlText
   return someHtmlText
end rev_GetScriptEditorDocumentation

command rev_SetScriptEditorDocumentation someHtmlText, pEditorNum
   put rev_ScriptEditorDocField (pEditorNum) into scriptEditorDocField
   set the htmlText of scriptEditorDocField to someHtmlText
   return scriptEditorDocField
end rev_SetScriptEditorDocumentation

function rev_GetScriptEditorDocumentationLock pEditorNum
   put rev_ScriptEditorDocField (pEditorNum) into scriptEditorDocField
   put the locktext of scriptEditorDocField into someBoolean
   return someBoolean
end rev_GetScriptEditorDocumentationLock

command rev_SetScriptEditorDocumentationLock someBoolean, pEditorNum
   put rev_ScriptEditorDocField (pEditorNum) into scriptEditorDocField
   set the locktext of scriptEditorDocField to someBoolean
end rev_SetScriptEditorDocumentationLock

function rev_ScriptEditorDocFieldRect pEditorNum
   put rev_ScriptEditorDocField (pEditorNum) into scriptEditorDocField
   if exists(scriptEditorDocField) is false then return empty
   return the rect of scriptEditorDocField
end rev_ScriptEditorDocFieldRect


--> Rev
-
function rev_GetIcon hType
   -- ignoreCall: uIconMap,g
   
   # Parameters
   #   pTag : A single letter tag that refers to certain property of a handler
   #   Possible values:
   #     C - command
   #     M - message
   #     F - function
   #     G - getProp
   #     S - setprop
   #     B - before
   #     A - after
   #   pIsPrivate : whether or not the handler is private (commands and functions only)
   # Returns
   #   The id of a suitable image to represent the property pTag of a handler. Note: this function
   #   may return empty if no image is required to represent this.
   
   local tTag
   put "handler" into tTag
   
   if char 1 of hType = "p" then
      put "Private" after tTag
      delete char 1 of hType
   end if
   
   switch pTag
      case "C"
         put "Command" after tTag
         break
      case "M"
         put "Message" after tTag
         break
      case "F"
         put "Function" after tTag
         break
      case "G"
         put "Getprop" after tTag
         break
      case "S"
         put "Setprop" after tTag
         break
      case "B"
         put "Before" after tTag
         break
      case "A"
         put "After" after tTag
         break
   end switch
   
   -- return seGetIcon(tTag)
   put the uIconMap [tTag] of stack "revSETemplate" into someIcon
   return someIcon
end rev_GetIcon

command rev_SetScriptEditorInfo @hKey, @someHandler, @suiteTitle, @scriptSuite, @scriptObject
   -- should select the clickline
   
   put rev_HandlerTreeField() into handlerTreeField
   put scriptEditor_Object() into scriptObject
   
   -- put item 1 of the hilitedLine of handlerTreeField into lineNum
   put word 2 of the clickline into lineNum
   put word 1 to -1 of line lineNum of the text of handlerTreeField into handlerName
   -- lcw_Notify handlerName, true
   
   -- have to get suite title from script
   get the htmltext of line lineNum of handlerTreeField
   switch 
      case it contains ("<img src=" & kwote(205023) & ">")
         put "f" into handlerType
         break
      case it contains ("<img src=" & kwote(205026) & ">")
         put "g" into handlerType
         break
      case it contains ("<img src=" & kwote(205024) & ">")
         put "s" into handlerType
         break
      case it contains ("<img src=" & kwote(205025) & ">")
         put "c" into handlerType
         break
   end switch
   
   put handlerName,handlerType into shortHKey
   put hkey_Construct (handlerName, handlerType, scriptObject) into hKey
   
   put the script of scriptObject into someScript
   -- put script_ExtractHandlerType(handlerName, someScript, handlerType) into someHandler
   put handler_ConvertType (handlerType) into onWord
   script_SetHandlerOffsets startHandler, endHandler, handlerName, onWord, someScript
   put char startHandler to endHandler of someScript into someHandler
   
   -- Suite stuff
   get char 1 to startHandler of someScript
   put script_GetSuiteTitles (someScript) into suiteTitles
   put line -1 of suiteTitles into suiteTitle
end rev_SetScriptEditorInfo

function rev_ConstructHkeyTitle someText
   put line 1 of someText into hkey
   put line 2 of someText into extraText
   hkey_Deconstruct hkey, hName, hType, hObject, hNum
   put rev_GetIcon (hType) into someIcon
   -- put "<p><sub><img src=" & someIcon & "></img></sub>  " & hName & "</p>" into someHtml -- LiveCode does not use xHtml
   put "<p><sub><img src=" & kwote (someIcon) & "></sub>  " & hName & extraText & "</p>" into someHtml
   -- put "<i>" & hName & "</i>" into someHtml
   return someHtml
end rev_ConstructHkeyTitle

function rev_GetSelectedHandlerTreeLineNum pHkey
   put rev_HandlerTreeField() into handlerField
   
   if pHkey is not empty then
      put scriptEditor_Object() into hObject
      put the revAvailableHandlers of hObject into hTable
      hTable_FlexibleLineOffsets pHkey, hTable, startLineNum, endLineNum
      return startLineNum
   else
      put the hilitedLine of handlerField into lineNum
   end if
   return lineNum
end rev_GetSelectedHandlerTreeLineNum

function rev_GetHandlerTreeCallbackTarget
   put rev_HandlerTree() into handlerTree
   put the cCallbackTarget of handlerTree into callBackTarget
   return callBackTarget
end rev_GetHandlerTreeCallbackTarget

function rev_GetHandlerTreeCallback
   put rev_HandlerTree() into handlerTree
   put the cCallback of handlerTree into handlerTreeCallBack
   return handlerTreeCallBack
end rev_GetHandlerTreeCallback

function rev_GetHandlerTreeChoice
   put rev_HandlerTree() into handlerTree
   put the cChoice of handlerTree into handlerChoice
   return handlerChoice
end rev_GetHandlerTreeChoice

command rev_SelectTopScriptEditorTreeLineNum hHkeyOrLineNum
   put rev_HandlerTreeField() into handlerField
   if hHkeyOrLineNum is a number then
      put hHkeyOrLineNum into hLineNum
   else
      put hHkeyOrLineNum into hKey
      
   end if
   
   set the hilitedline of handlerField to hLineNum
   dispatch "closeAccept" to handlerField
end rev_SelectTopScriptEditorTreeLineNum

function rev_GetSelectedHandlerType
   put scriptEditor_GetHkeyLine() into hInfo
   return word 1 of hInfo
end rev_GetSelectedHandlerType

function rev_GetSelectedHandlerName
   put scriptEditor_GetHkeyLine() into hInfo
   return word 2 of hInfo
end rev_GetSelectedHandlerName

function rev_GetSelectedHandlerScriptStartLineNum
   put scriptEditor_GetHkeyLine() into hInfo
   return word 3 of hInfo
end rev_GetSelectedHandlerScriptStartLineNum

function rev_GetSelectedHandlerScriptEndLineNum
   put scriptEditor_GetHkeyLine() into hInfo
   return word 4 of hInfo
end rev_GetSelectedHandlerScriptEndLineNum

function rev_GetFirstScriptEditorSelectedHkey
   put scriptEditor_GetHkeyLine() into hInfo
   put word 2 of hInfo into hName
   put word 1 of hInfo into hType
   if hType = "M" then put "c" into hType
   put toLower(hType) into hType
   put scriptEditor_Object() into hObject
   
   put hName,hType,hObject,1 into hKey
   return hKey
end rev_GetFirstScriptEditorSelectedHkey


--> Rev | 4.0
-
function rev_DictionaryDataGrid
   if exists(grp "Grid" of card "Index" of stack "revDictionary") then
      return the long id of grp "Grid" of card "Index" of stack "revDictionary"
   else
      return empty
   end if
end rev_DictionaryDataGrid


--> Rev | 3.5
-
function rev_DictionaryDataTableField
   if exists (fld "Data" of card "Index" of stack "revDictionary") then
      return the long id of fld "Data" of card "Index" of stack "revDictionary"
   else
      --/Applications/Revolution Enterprise/3.5.0-gm-2/Toolset/revdictionary.rev
      put the filename of stack "Home" into someFile
      set the itemdelimiter to "/"
      put "revdictionary.rev" into item -1 of someFile
      if exists (stack someFile) then
         if exists (fld "Data" of card "Index" of stack someFile) then
            put the long id of fld "Data" of card "Index" of stack someFile into tableField
            return tableField
         else
            go to stack someFile
            exit to top
            -- return the long id of fld "Data" of card "Index" of stack someFile
         end if
      else
         breakpoint
      end if
   end if
end rev_DictionaryDataTableField

function rev_DictionaryIndexField
    -- was "rev_ScriptIndexField"
    return the long id of fld "Entry" of card "Index" of stack "revDictionary"
end rev_DictionaryIndexField

-- getprop rev_DataGrid
   put the object_Hierarchy of the target into objectHierarchy
   filter objectHierarchy with "group *"
   repeat with lineNum = the number of lines of objectHierarchy down to 1
      put line lineNum of objectHierarchy into testObject
      -- if the asdf of testObject
      return testObject
   end repeat
   return empty
end rev_DataGrid

function rev_DataGridStack
    return the name of stack "revDataGridLibrary"
end rev_DataGridStack

function rev_DataGridBehavior
    -- can simply get the beahvior of a datagrid
    -- however if one is ot around...
    put rev_DataGridStack() into dataGridStack
    return the long id of of btn "Data Grid" of group "Behaviors" of cd 1 of dataGridStack
end rev_DataGridBehavior

command rev_SetScriptEditorField pScript
   -- ignoreCall: textSetScript,c
   
   put rev_ScriptEditorGroup() into revScriptEditorGroup
   send "textSetScript pScript" to revScriptEditorGroup
   put the result into someError
   
   #   pMode : the mode to set to, either "edit" or "debug"
   #   Sets the mode of this script editor.
   put "edit" into pMode
   send "revSESetMode pMode" to revScriptEditorGroup
   return the result
end rev_SetScriptEditorField

function rev_GetHandlerList
   # Description
   #   Returns the handler list for the current object, in the same format as the revAvailableHandlers.
   put rev_ScriptEditorGroup() into revScriptEditorGroup
   dispatch "revSEGetHandlerList" to revScriptEditorGroup
   return the result
end rev_GethandlerList

command rev_SearchScripts pQuery, pTarget, pCallback, pCallbackTarget
   # Parameters
   #   pQuery : the string to search for
   #   pIsRegExp : whether or not pQuery is a regular expression
   #   pUseWildCards : whether or not to treat *s as wildcards
   #   pIgnoreCase : whether to do a case sensitive search or not
   #   pTarget : whether to search in all tabs or just the current tab
   #   pCallback : optional. The name of a command to send with a message saying what state the search is in
   # Description
   #   Searches for all matches for the specified search and displays them in the "Search Results" pane.
   
   put false into pIsRegExp
   put false into pUseWildCards
   
   put true into pWholeMatches
   put true into pIgnoreCase
   
   put rev_ScriptEditorGroup() into revScriptEditorGroup
   dispatch "revSEFindAll" to revScriptEditorGroup with pQuery,pIsRegExp,pUseWildCards,pWholeMatches,pIgnoreCase,pTarget,pCallback,pCallbackTarget
end rev_SearchScripts

function rev_GetCachedScript pObject
   -- ignoreCall: scriptGet,c
   send "scriptGet pObject" to rev_ScriptEditorGroup()
   return the result
end rev_GetCachedScript

function rev_FormatScript pScript
   -- ignoreCall: scriptFormatSnippet,c
   call "scriptFormatSnippet pScript" of rev_ScriptEditorGroup()
   return the result
end rev_FormatScript

function rev_ScriptEditorGroup
   return the long id of group "Editor" of card "Main" of stack "revNewScriptEditor 1"
end rev_ScriptEditorGroup


--> Rev | Preferences
-
function rev_GetColourizationScheme
   put rev_GetPref ("colorization", "scheme") into schemeName
   if schemeName is empty then return "default"
   return schemeName
end rev_GetColourizationScheme

function rev_ListPrefArray
   local prefArray
   
   put rev_ListPrefs() into someTable
   repeat for each line someLine in someTable
      put item 1 of someLine into someKey
      put item 2 of someLine into someValue
      
      indexArray_Add someValue, someKey, prefArray
   end repeat
   return prefArray
end rev_ListPrefArray

function rev_ListPrefOutline
   local tabbedOutline
   
   put rev_ListPrefArray () into prefArray
   put array_ToOutline (prefArray, true) into tabbedOutline
   return tabbedOutline
   
   put rev_ListPrefs() into someTable
   repeat for each line someLine in someTable
      put item 1 of someLine into someKey
      put item 2 of someLine into someValue
      
      indexArray_Add someValue, someKey, prefArray
      outline_AddTitle someValue, someKey, tabbedOutline
   end repeat
   return tabbedOutline
end rev_ListPrefOutline

function rev_ListPrefTypes
   put rev_ListPrefs() into someTable
   repeat for each line someLine in someTable
      put item 2 of someLine into prefArray [item 1 of someLine]
   end repeat
   put keys (prefArray) into prefTypes
   sort prefTypes
   return prefTypes
end rev_ListPrefTypes

function rev_GetEditorPref revEditorPref
   get rev_GetPref ("editor", revEditorPref)
   return it
end rev_GetEditorPref

command rev_SetEditorPref revEditorPref, revEditorValue
   rev_SetPref "editor", revEditorPref, revEditorValue
   return the result
end rev_SetEditorPref

function rev_ListEditorPrefs
   put rev_ListPrefs("editor") into prefItems
   set the columndelimiter to comma
   split prefItems by column
   put prefItems [2] into revEditorPrefs
   return revEditorPrefs
end rev_ListEditorPrefs

function rev_GetPref prefType, revEditorPref   
   put prefType,revEditorPref into prefRecord
   put "sePrefGet(" & kwote(prefRecord) &")" into someExpression
   put the name of stack "revNewScriptEditor" into someObject
   get value (someExpression, someObject)
   return it
end rev_GetPref

command rev_SetPref prefType, revEditorPref, revEditorValue
   put prefType,revEditorPref into prefRecord
   dispatch "sePrefSet" to stack "revNewScriptEditor" with prefRecord,revEditorValue
   switch it
      case "handled"
   end switch
   return the result
end rev_SetPref

function rev_ListPrefs pPrefType
   if pPrefType is not empty then
      -- could put a comma here
   end if
   put "*" after pPrefType
   
   put "sePrefList(" & kwote (pPrefType) & ")" into someExpression
   put the name of stack "revNewScriptEditor" into someObject
   get value (someExpression, someObject)
   return it
end rev_ListPrefs


--> IDE | More
-
function rev_ScriptAsHtmlText
   -- ignoreCall: scriptGetHtmlText,c
   
   # Description
   #   This command returns the current script as *real* html. The result of this command
   #   is suitable for displaying in a browser, not in Revolution fields as htmlText. This command
   #   requires the colorization scheme "Revolution Classic" to be used as it contains hard-coded 
   #   replacements. For html suitable for printing or displaying in a Revolution field see scriptGetHtmlText.
   
   send "scriptGetHtmlText" to rev_ScriptEditorGroup()
   return the result
end rev_ScriptAsHtmlText

function rev_ScriptAsHtml
   -- ignoreCall: scriptGetAsHtml,c
   
   # Description
   #   This command returns the current script as *real* html. The result of this command
   #   is suitable for displaying in a browser, not in Revolution fields as htmlText. This command
   #   requires the colorization scheme "Revolution Classic" to be used as it contains hard-coded 
   #   replacements. For html suitable for printing or displaying in a Revolution field see scriptGetHtmlText.
   
   send "scriptGetAsHtml" to rev_ScriptEditorGroup()
   return the result
end rev_ScriptAsHtml


--> Windows
-
function windows_Version
   if the platform is not "Win32" then return empty
   
   put word 2 of the systemversion into vNum
   if word 2 of the systemversion = "Windows" then
      switch
         case vNum >= 4.0 and vNum < 4.1
            return "Windows 95"
         case vNum >= 4.1 and vNum < 4.9
            return "Windows 98"
         case vNum >= 4.9
            return "Windows Me"
      end switch
   else
      switch
         case vNum >= 4.0 and vNum < 5.0
            return "Windows NT 4"
         case vNum >= 5.0 and vNum < 5.1
            return "Windows 2000"
         case vNum >= 5.1 and vNum < 5.6
            return "Windows XP"
         case vNum >= 5.6
            return "Windows Vista"
      end switch
   end if
end windows_Version

function windows_Versions
   return "Windows 95,Windows 98,Windows Me,Windows NT 4,Windows 2000,Windows XP,Windows Vista"
   
   put windows_SystemVersionArray() into versionArray
   put array_Reverse(versionArray) into versionArray
   put keys(versionArray) into versionKeys
   sort versionKeys
   replace CR with comma in versionKeys
   return versionKeys
end windows_Versions

function windows_SystemVersionArray
   /*
   on Windows systems, the systemVersion returns the internal Windows version designation.
      The internal designations for several windows versions are as follows:
      
      get word 2 of the systemversion
      if it >= 4.1 and it < 4.9 then answer "Windows 98!"
      */
      
      put "Windows 95" into windowsVersionArray ["Windows 4.0"]
      put "Windows 98" into windowsVersionArray ["Windows 4.10"] -- (may return other numbers)
      put "Windows Me" into windowsVersionArray ["Windows 4.90"] -- (may return other numbers)
      put "Windows NT 4" into windowsVersionArray ["NT 4.0"]
      put "Windows 2000" into windowsVersionArray ["NT 5.0"]
      put "Windows XP" into windowsVersionArray ["NT 5.1"]
      put "Windows Vista" into windowsVersionArray ["NT 6.0"]
      
      return windowsVersionArray
end windows_SystemVersionArray


--> Rev
-
getprop stack_BackgroundNames
   local bgNames
   put the stack_Object of the target into stackObject
   repeat with bgNum = 1 to the number of bgs of stackObject
      put the short name of bg bgNum of stackObject & CR after bgNames
   end repeat
   delete char -1 of bgNames
   return bgNames
end stack_BackgroundNames

getprop stack_BackgroundObjects
   local bgObjects
   put the stack_Object of the target into stackObject
   repeat with bgNum = 1 to the number of bgs of stackObject
      put the long id of bg bgNum of stackObject & CR after bgObjects
   end repeat
   delete char -1 of bgObjects
   return bgObjects
end stack_BackgroundObjects

getprop stack_NestedBackgroundNames
   -- list all the groups (including nested ones) in a stack
   put the stack_name of the target into stackName
   put revBackgroundNames (stackName) into bgNames
   return bgNames
end stack_NestedBackgroundNames

getprop stack_NestedBackgroundObjects
    -- list all the groups (including nested ones) in a stack
  put the stack_name of the target into stackName
   put revBackgroundIDs (stackName) into bgNames
   return bgNames
end stack_NestedBackgroundObjects

function rev_LoadedStackNames
   -- returns an index of short stack names
   switch searchScope
      case "all"
         return revLoadedStacks (searchScope)  -- includes stacks such as message box
      case "application"
         return revLoadedStacks (searchScope) -- only includes non-Rev stacks
      case "-"
      case "known"
         put revLoadedStacks ("application") into stackNames
         put opn_GetStackNameIndex() into opnStackNames -- only those known to opn
         line_Add stackNames, opnStackNames
         return stackNames
      case "-"
      case "preferences"
         return revLoadedStacks() -- respects current preference setting
   end switch
end rev_LoadedStackNames

getprop rev_PropertyNames
   return the model_ArrayKeys ["cREVGeneral"] of the target
end rev_PropertyNames

command rev_RestartIDE
   show menubar
   set the topleft of stack "revMenuBar" to 0,22
   go to stack "revMenubar"
   show stack "revMenubar"
   go to stack "revTools"
   show stack "revTools"
   unlock cursor
end rev_RestartIDE

function rev_Platforms
   put rev_PlatformArray() into revPlatformArray
   put keys(revPlatformArray) into revPlatforms
   sort revPlatforms
   return revPlatforms
end rev_Platforms

function rev_PlatformArray
   put "windows (any version post-3.1)" into platformArray ["Win32"]
   put "Mac OS, OS X, or Darwin system" into platformArray ["MacOS"]
   put "Linux for Intel or PowerPC architecture" into platformArray ["Linux"]
   
   put "BSD UNIX (BSDI, FreeBSD)" into platformArray ["BSD"]
   put "HP-UX" into platformArray ["HP-9000/700"]
   put "Silicon Graphics IRIX" into platformArray ["SGI IRIS"]
   put "Silicon Graphics IRIX" into platformArray ["SGI IRIS"]
   put "AIX" into platformArray ["IBM RS/6000"]
   put "SCO open DeskTop" into platformArray ["Intel SCO"]
   put "Solaris for x86 architecture" into platformArray ["Intel SVR4"]
   put "SPARC SunOS" into platformArray ["SPARC"]
   put "SPARC Solaris" into platformArray ["SPARC Solaris"]
   
   return platformArray
end rev_PlatformArray


--> Rev | Application Version
-
function rev_VersionIsLaterOrEqual someVersion
   -- ie this RunRev engine version > someVersion?
   -- 3.5.0-dp-2
   put the version into thisVersion
   
   set the itemdelimiter to "-"
   put item 1 of thisVersion into thisNumber
   put item 1 of someVersion into someNumber
   
   set the itemdelimiter to "."
   repeat with itemNum = 1 to 3
      put item itemNum of thisNumber into testThis
      if testThis is empty then put 0 into testThis
      put item itemNum of someNumber into testSome
      if testSome is empty then put 0 into testSome
      
      if testThis >= testSome then
         return true
      end if
   end repeat
   return false
end rev_VersionIsLaterOrEqual

function rev_VersionIsLater someVersion
   -- ie this RunRev engine version > someVersion?
   -- 3.5.0-dp-2
   put the version into thisVersion
   
   set the itemdelimiter to "-"
   put item 1 of thisVersion into thisNumber
   put item 1 of someVersion into someNumber
   
   set the itemdelimiter to "."
   repeat with itemNum = 1 to 3
      put item itemNum of thisNumber into testThis
      if testThis is empty then put 0 into testThis
      put item itemNum of someNumber into testSome
      if testSome is empty then put 0 into testSome
      
      if testThis > testSome then
         return true
      end if
   end repeat
   return false
end rev_VersionIsLater

function rev_VersionIsEarlier someVersion
   return rev_VersionIsLater(someVersion) is false
end rev_VersionIsEarlier


--> Rev | Libraries
-
function rev_ImageLibraries
    put the mainstacks into allLoaded
    filter allLoaded with "revLib*"
    line_Delete "revLibrary", allLoaded
    -- line_Delete "revLibStandardButtons", allLoaded
    return allLoaded
end rev_ImageLibraries

function rev_ImageLibraryIcons libraryName
    put the long id of stack libraryName into libraryObject
    return icon_GetImageLibraryTable(libraryObject)
end rev_ImageLibraryIcons
 
function rev_GetImageLibPath libName
    put rev_GetImageLibFolder() into revImageFolder
    return revImageFolder & libName
end rev_GetImageLibPath

function rev_GetImageLibFolder
    put rev_ApplicationFolder() into revImageFolder
    put "/components/save/usericons/" after revImageFolder
    return revImageFolder
end rev_GetImageLibFolder

function rev_GetPluginFolder
   if the version < 2.7 then
      put rev_ApplicationFolder() into revpluginFolder
      put "plugins/" after revpluginFolder
   else
      return revEnvironmentUserPluginsPath() & "/"
   end if
end rev_GetPluginFolder

function rev_ApplicationFolder
   switch
      case the version < 2.7
         -- return folder_AboveFile(homeStack)
         put the filename of stack "Home" into homeStack
         set the itemdelimiter to "/"
         delete item -1 of homeStack
         return homeStack & "/"
         break
      case the version > 5.5
         return revEnvironmentToolsPath() & "/"
      default
         put the filename of stack "Home" into homeStack
         set the itemdelimiter to "/"
         delete item -2 to -1 of homeStack
         return homeStack & "/"
   end switch
end rev_ApplicationFolder

function rev_IsRevStack theStackName
    if there is a stack theStackName then
        put the mainstack of stack theStackName into theMainStack
        put char 1 to 3 of theMainStack is "rev" or \
                theMainStack is among the items of "Message Box,Home,answer dialog,ask dialog,script debugger,file selector" into isRevStack
        return isRevStack
    else
        return false
    end if
end rev_IsRevStack


--> ScriptEditor | Private
-
private command _autoSave hKey, someHtml
   -- in development, not tested or working
   breakpoint
   
   _setMyLastHkey hKey
   
   if someHtml = "<p></p>" then
      put empty into someHtml
      hkey_StoreHelp hKey, someHtml
   end if
   put _getMyLastHkey() into lastHkey
   if lastHkey is not empty then
      put rev_GetScriptEditorDocumentation() into lastHtmlText
      put "Save" && lastHkey & CR & lastHtmlText into someComment
      -- lcw_Notify someComment, true
   end if
end _autoSave

private function _getMyLastHkey
   put the behavior of me into reallyMe
   set lockmessages to true
   put the displayed_Hkey of reallyMe into hKey
   set lockmessages to false
   return hKey
end _getMyLastHkey

private command _setMyLastHkey hKey
   put the behavior of me into reallyMe
   set lockmessages to true
   set the displayed_Hkey of reallyMe to hKey
   set lockmessages to false
end _setMyLastHkey
