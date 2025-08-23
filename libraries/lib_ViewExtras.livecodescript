script "lib_ViewExtras"
--> MetaData
-
license: GPLv3
name: lib_ViewExtras
type: library
version: 0.1

/*
A place for all the view scripts which we probably no longer need.
*/

--> Working on
-
getprop module_BehaviorScript
   -- similar to view_BehaviorScript, but for behavior_Objects
   -- combines, the view, behavior and library scripts (if they exist)
   put the long id of the target into someView
   
   put the script of someView into someScript
   put the behavior_Objects of someView into bObjects
   repeat for each line bObject in bObjects
      get word 1 to -1 of the script of bObject
      if it is not empty then
         put CR & CR & it after someScript
      end if
   end repeat
   return word 1 to -1 of someScript
end module_BehaviorScript

getprop view_BehaviorScript [whichScripts]
   -- combines, the view, behavior and library scripts (if they exist)
   put the long id of the target into someView
   
   put the script of someView into someScript
   if whichScripts is not "view" then
      put the behavior of someView into someBehavior
      if exists(someBehavior) then put CR & CR & the script of someBehavior after someScript
   end if
   
   if whichScripts is not among the items of "view,behavior" then
      put the view_TemplateStack of someView into someLibrary
      if exists(someLibrary) then put CR & CR & the script of someLibrary after someScript
   end if
   return someScript
end view_BehaviorScript

function view_NameToFile viewPath, pFileExt
   -- put view_PathToShortFile (viewPath, pFileExt) into shortFile
   -- put library_ViewFolder (shortFile) into viewFile
   put default_FirstStackControl(viewPath) into templateObject
   put the stack_File of templateObject into viewFile
   return viewFile
end view_NameToFile


--> View | PathIndex
-
function view_PathIndex
   put env_ListViewStackPaths() into stackPaths
   return stackPaths
end view_PathIndex


--> View | PathIndex | Old
-
function view_PathIndex includeStem
   -- see "env_ListViewStackPaths()"
   -- return view_ListNames (empty, includeStem)
   -- return view_ListNamesOfStandardFiles()
   put view_ShortFiles() into shortFiles
   
   put empty into viewPaths
   repeat for each line someFile in shortFiles
      put view_FileToPath (someFile, includeStem) into viewPath
      put viewPath & CR after viewPaths
   end repeat
   delete last char of viewPaths
   return viewPaths
end view_PathIndex

function view_ShortFiles
   put library_ViewFolder() into someFolder
   put file_ListShort(someFolder) into shortFiles
   return shortFiles
end view_ShortFiles

function view_FileToPath someFile, includeStem
   set the itemdelimiter to "/"
   put last item of someFile into viewPath
   
   replace "_" with "|" in viewPath
   set the itemdelimiter to "."
   if item -1 of viewPath is among the items of "livecode.rev.opml.html" then delete last item of viewPath
   if includeStem is true then view_NormalizeName viewPath
   return viewPath
end view_FileToPath


--> View | List
-
function view_ListNames pStartFilter, pIncludeStem
   -- return view_PathIndex (includeStem)
   put hArray_ListViewNames() into vNames
   if pIncludeStem is not true then put replacetext (vNames, "(View\|)\W*", empty) into vNames
   if pStartFilter is empty then return vNames
   
   view_NormalizeName pStartFilter
   if pIncludeStem is not true then
      set the itemdelimiter to "|"
      delete item 1 of pStartFilter
   end if
   filter vNames with (pStartFilter & "*")
   return vNames
end view_ListNames

function view_ListNamesOfStandardFiles
   put view_ShortFiles() into shortFiles
   
   put empty into viewPaths
   repeat for each line someFile in shortFiles
      put view_FileToPath (someFile, includeStem) into viewPath
      put viewPath & CR after viewPaths
   end repeat
   delete last char of viewPaths
   return viewPaths
end view_ListNamesOfStandardFiles


--> View | Props
-
getprop view_DisplayProperty [someProp]
   put the long id of the target into someView
   repeat
      put the view_Object of someView into someView
      if exists (someView) is false then return empty
      
      put the customproperties of someView into displayArray
      if someProp is among the lines of the keys of displayArray then -- allows returning empty if key is present
         return displayArray [someProp]
      end if
      
      delete word 1 to 4 of someView
      if word 1 of someView is among the items of "card,stack" then return empty -- recursion problem if someView = "card..." as a bg view will keep getting called
      if exists (someView) is false then return empty
   end repeat
end view_DisplayProperty

setprop view_DisplayProperty [someProp] someValue
   put the long id of the target into targetObject
   
   -- put the view_DisplayArray of targetObject into displayArray
   -- put someValue into displayArray [someProp]
   -- set the view_DisplayArray of targetObject to displayArray
   
   -- lock messages
   -- set the someProp of targetObject to someValue
   -- to avoid recursion possibility
   put the customproperties of targetObject into cArray
   put someValue into cArray [someProp]
   set the customproperties of targetObject to cArray
   
   repeat with cNum = 1 to the number of controls of targetObject
      put the long id of control cNum of targetObject into cObject
      custom_DeleteProperty someProp, cObject
   end repeat
   -- unlock messages
end view_DisplayProperty


--> View | Template | Files
-
function view_TemplateObjectFromFile longStackName
   -- was "view_GetLibraryObjectFromFile"
   if exists(control 1 of card 1 of stack longStackName) then
      put the long id of control 1 of card 1 of stack longStackName into libraryObject
      return libraryObject
      
      if the object_IsView of libraryObject is true then	# check (could do more)
         return libraryObject
      else
         return empty
      end if
   else
      return empty
   end if
end view_TemplateObjectFromFile

function view_TemplateFiles
   put library_ViewFolder() into someFolder
   put folder_FilesInside(someFolder) into viewFiles
   return viewFiles
end view_TemplateFiles

command view_SetTemplateNames vName
   -- utility to set the relevant names in a view stack
   put default_FirstStackControl (vName) into templateView
   if exists(templateView) is false then return empty
   
   -- set the view_Name
   set the view_Name of templateView to vName
   
   -- check the behavior
   put the behavior of templateView into templateBehavior
   if exists (templateBehavior) is false then return false
   if the stack_Object of templateView = the stack_Object of templateBehavior then
      set the view_Name of templateBehavior to vName
   else
      -- it is a linked behavior so keep the original name of the behavior
      answer warning "Have reset the views view_Name. However this view uses a linked behavior, sot the behaviors view_Name has not been set!"
   end if
end view_SetTemplateNames

getprop view_Library
   -- a default library stack associated with a view
   put the view_Name of the target into viewName
   set the itemdelimiter to "|"
   repeat with itemNum = the number of items of viewName down to 2
      put "libOPN_" & item itemNum of viewName into stackName
      if exists(stack stackName) then
         return the name of stack stackName
      end if
   end repeat
   return empty
end view_Library

function view_TemplateBehaviors pObjectFormat
   put view_TemplateFiles() into viewFiles
   
   put the mainstacks into oMainStacks
   set the wholematches to true
   repeat for each line someFile in viewFiles
      set the cursor to busy
      if exists (control 1 of card 1 of stack someFile) then
         put the long id of control 1 of card 1 of stack someFile into viewObject
         put the behavior of viewObject into libraryObject
         if exists (libraryObject) is false then next repeat
         
         switch pObjectFormat
            case "mobile_Name"
               put the long name of libraryObject into libraryObject
               object_SetShortStackName libraryObject, mainStackStart, mainStackEnd
               put libraryObject & CR after libraryObjects
               break
            case "mobile_ID"
               object_SetShortStackName libraryObject, mainStackStart, mainStackEnd
               put libraryObject & CR after libraryObjects
               break
            case "long id"
               put libraryObject & CR after libraryObjects
               break
            default -- case "rugged_ID"
               put the rugged_ID of libraryObject & CR after libraryObjects
         end switch
         
         if the short name of stack someFile is not among the lines of oMainStacks then
            -- re-release previously unloaded stack from memory
            delete stack someFile
         end if
      end if
   end repeat
   delete last char of libraryObjects
   return libraryObjects
end view_TemplateBehaviors

function view_TemplateNames
   return view_PathIndex (true)
end view_TemplateNames

function view_StackNames
   return view_PathIndex (true)
end view_StackNames

function view_ShortFiles
   put library_ViewFolder() into someFolder
   put file_ListShort(someFolder) into shortFiles
   return shortFiles
end view_ShortFiles

command view_TrimFirstViewNameItem @vNames
   put replacetext (vNames, "(View\|)\W*", empty) into vNames
   return empty
   
   set the itemdelimiter to "|"
   repeat with lineNum = 1 to the number of lines of vNames
      delete item 1 of line lineNum of vNames 
   end repeat
end view_TrimFirstViewNameItem

function view_FilteredPaths vName, pIncludeStem
   return view_ListNames (vName, pIncludeStem)
   
   view_NormalizeName vName
   put view_PathIndex (pIncludeStem) into viewPathIndex
   if vName is empty then return viewPathIndex
   if pIncludeStem is not true then put replacetext (vName, "View\W*", empty) into vName
   filter viewPathIndex with (vName & "*")
   return viewPathIndex
end view_FilteredPaths

function view_FileToPath someFile, includeStem
   set the itemdelimiter to "/"
   put last item of someFile into viewPath
   
   replace "_" with "|" in viewPath
   set the itemdelimiter to "."
   if item -1 of viewPath is among the items of "livecode.rev.opml.html" then delete last item of viewPath
   if includeStem is true then view_NormalizeName viewPath
   return viewPath
end view_FileToPath

function view_LongFiles
   -- was "view_GetLibraryStackFiles"
   put library_ViewFolder() into someFolder
   put file_ListShort(someFolder) into shortFiles
   file_ShortToLong shortFiles, someFolder
   return shortFiles
end view_LongFiles

function view_PathToShortFile viewName, pFileExt
   view_NormalizeName viewName
   
   set the itemdelimiter to "|"
   if item 2 of viewName = "Compound" then
      put ".html" into someExension
   else if pFileExt is empty then
      put ".livecode" into someExension
      -- put ".rev" into someExension
   else
      put "." & pFileExt into someExension
   end if
   put rev_FixPath (viewName) into shortFile
   delete item 1 of shortFile
   replace "|" with "_" in shortFile
   put someExension after shortFile
   return shortFile
end view_PathToShortFile


--> TemplateStack | Props
-
/*
The "view_TemplateArray" is stored in the stack of the library object, as this makes it more portable / easier to send.
Use for default values for all views, or default behaviors of tools for views that require common data to work.
*/

getprop template_DisplayArray
   put the template_Array of the target into viewArray
   put viewArray ["display"] into displayArray
   return displayArray
end template_DisplayArray

setprop template_DisplayArray displayArray
   put the template_Array of the target into viewArray
   put displayArray into viewArray ["display"]
   set the template_Array of the target to viewArray
end template_DisplayArray

getprop template_MetaData [pPropName]
   put the template_Array of the target into templateArray
   if pPropName is empty then
      put templateArray ["metadata"] into mData
   else
      put templateArray ["metadata"][pPropName] into mData
   end if
   return mData
end template_MetaData

setprop template_MetaData [pPropName] mData
   put the template_Array of the target into templateArray
   if pPropName is empty then
      put mData into templateArray ["metadata"]
   else
      put mData into templateArray ["metadata"][pPropName]
   end if
   set the template_Array of the target to templateArray
   return templateArray
end template_MetaData

getprop template_DataArray
   -- used for default values (ie in newly created objects)
   put the long id of the target into someView 
   put the template_Array of someView into viewArray
   return viewArray ["data"]
end template_DataArray

setprop template_DataArray [modelType] dataArray
   -- store default values (ie in newly created objects) with this script 
   put the long id of the target into someView 
   put the template_Array of someView into viewArray
   put dataArray into viewArray ["data"]
   set the template_Array of someView to viewArray
end template_DataArray

getprop template_CardBehavior
   put behavior_GetObject ("Card View Behavior") into someObject
   return someObject
end template_CardBehavior

getprop template_Card
   put the view_ModuleObject of mTarget into templateObject
   put the the card_Object of templateObject into someObject
   return someObject
end template_Card

getprop template_Model
   put the view_Object of the target into viewObject
   if exists (viewObject) is false then return empty
   put the view_Name of viewObject into vName
   if exists (stack vName) is false then return empty
   put the name of stack vName into templatePropertyModel
   return templatePropertyModel
end template_Model

getprop template_Array
   -- a structural mirror of "view_Array"
   put the template_Model of the target into templateModel
   if exists (templateModel) is false then return empty
   lock messages -- so as not to trigger custom prop
   put the view_Array of templateModel into templateArray
   unlock messages
   return templateArray
end template_Array

setprop template_Array templateArray
   -- a structural mirror of "view_Array"
   put the template_Model of the target into templateModel
   
   lock messages -- so as not to trigger custom prop
   set the view_Array of templateModel to templateArray
   unlock messages
   
   return templateModel
end template_Array

getprop view_TemplateName
   -- could distinguish between view_Names and the original name of compound views
   return the view_Name of the target
end view_TemplateName

getprop templateStack_View
   -- a behavior of a template stack
   if the stack_IsTemplate of the target is false then return empty -- for now lets check
   
   -- a sensible default that can be overridden
   put the stack_Name of the target into vName
   if exists (control 1 of card 1 of stack vName) is false then return empty
   put the long id of control 1 of card 1 of stack vName into templateObject
   return templateObject
end templateStack_View

getprop stack_IsTemplate
   put the stack_Name of the target into vName
   put the filename of stack vName into viewStackFile
   put library_ViewFolder () into viewFolder
   return viewStackFile begins with viewFolder
end stack_IsTemplate

getprop template_DefaultScript [pObjectType]
   put the long id of the target into scriptObject
   
   -- get variables for merge script
   if pObjectType is empty then put "view template" into pObjectType
   put the view_Name of the target into ViewName
   put objectType into UripType
   put lcw_GetAuthor() into AuthorName
   put the template_ObjectDefScript of scriptObject into DefScript
   
   put scaffold_Get ("View Template") into templateScript
   put merge (templateScript) into someScript
   return someScript
end template_DefaultScript

getprop template_ObjectDefScript
   local defScript
   put the long id of the target into scriptObject
   
   repeat with cNum = 1 to the number of controls of scriptObject
      put the long id of control cNum of scriptObject into someObject
      put word 1 of someObject into objectType
      put the short name of someObject into someName
      put the view_Name of someObject into vName
      
      put text_InitialCaps (someName) into hName
      replace space with empty in hName
      put tolower (char 1 of hName) into char 1 of hName
      
      if word 1 someObject = "group" then
         put "_View" after hName
         put "return the long id of group" && kwote(someName) && "of me" into scriptLine
         put script_ConstructGetPropHandler (hName, scriptLine) & CR & CR after defScript
      else if vName is not empty then
         put "_View" after hName
         put "return the long id of" && objectType && kwote(someName) && "of me" into scriptLine
         put script_ConstructGetPropHandler (hName, scriptLine) & CR & CR after defScript
      else
         put "Object" after hName
         put "return the long id of" && objectType && kwote(someName) && "of me" into scriptLine
         put "private" && script_ConstructFunctionHandler (hName, scriptLine) & CR & CR after defScript
      end if
   end repeat
   
   delete char -2 to -1 of defScript
   return defScript
end template_ObjectDefScript

getprop template_Icons
   put the template_IconGroup of the target into templateIconGroup
   if exists (templateIconGroup) is false then return empty
   repeat with imageNum = 1 to the number of images of templateIconGroup
      put the short id of image imageNum of templateIconGroup into imageID
      put imageID & CR after imageIDs
   end repeat
   return imageIDs
end template_Icons

getprop template_IconGroup
   if word 1 of the target = "stack" then
      put the short name of the target into vName
      set the wholematches to true
      if vName is not among the lines of view_TemplateNames() then
         return empty
      end if
   else
      put the view_Name of the target into vName
   end if
   put view_FindTemplateIconGroup (vName) into templateIconGroup
   return templateIconGroup
end template_IconGroup

getprop view_Paths [viewName]
   return view_GetFolderOutline(viewName)
end view_Paths

getprop view_TemplateCard
   put the view_Name of the target into vName
   put view_GetTemplateCard (vName) into viewTemplateCard
   return viewTemplateCard
end view_TemplateCard

getprop template_Instances
   put the view_Name of the target into vName
   put view_GetInstances (vName) into vNames
   return vNames
end template_Instances

setprop view_TemplateName newName
   if word 1 of the target = "stack" then
      put the short name of the target into oldName
   else
      put the view_Name of the target into oldName
   end if
   view_RenameTemplate oldName, newName
   return the result
end view_TemplateName

function view_TemplateObjects pObjectFormat
   put view_TemplateFiles() into viewFiles
   
   put the mainstacks into oMainStacks
   set the wholematches to true
   repeat for each line someFile in viewFiles
      set the cursor to busy
      if exists (control 1 of card 1 of stack someFile) then
         put the long id of control 1 of card 1 of stack someFile into libraryObject
         
         switch pObjectFormat
            case "mobile_Name"
               put the long name of libraryObject into libraryObject
               object_SetShortStackName libraryObject, mainStackStart, mainStackEnd
               put libraryObject & CR after libraryObjects
               break
            case "mobile_ID"
               object_SetShortStackName libraryObject, mainStackStart, mainStackEnd
               put libraryObject & CR after libraryObjects
               break
            case "long id"
               put libraryObject & CR after libraryObjects
               break
            default -- case "rugged_ID"
               put the rugged_ID of libraryObject & CR after libraryObjects
         end switch
      end if
      
      if the short name of stack someFile is not among the lines of oMainStacks then
         -- re-release previously unloaded stack from memory
         -- breakpoint
         delete stack someFile
      end if
   end repeat
   delete last char of libraryObjects
   return libraryObjects
end view_TemplateObjects

function view_GetTemplateCard vName
   if vName is empty then return empty
   view_NormalizeName vName
   put view_NameToFile (vName, "rev") into longStackName
   if exists (stack longStackName) is false then put view_NameToFile (vName, "livecode") into longStackName
   if exists (stack longStackName) is false then return empty
   put the long id of card 1 of stack longStackName into viewTemplateCard 
   return viewTemplateCard
end view_GetTemplateCard


--> View Template | Icons
-
/*
A view_ModuleObject is a view library stack, that uses a behavior shared with other view library stacks.
These other view library stacks should share the same view (the view_ModuleObject),
but differ only in exposed public properites of the view.
*/

function view_FindTemplateIconGroup vName
   if vName is emtpy then return empty
   put default_FirstStackControl (vName) into templateObject
   if exists (templateObject) is false then return empty
   put the stack_Object of templateObject into stackObject
   if exists (group "Icons" of cd 2 of stackObject) is false then return empty
   
   put the long id of group "Icons" of cd 2 of stackObject into templateIconGroup
   return templateIconGroup
end view_FindTemplateIconGroup

command view_CreateTemplateIconGroup viewTemplate
   if exists (viewTemplate) is false then return empty
   put the stack_Object of viewTemplate into viewTemplateStack
   put the defaultstack into oDefaultStack
   set the defaultstack to viewTemplateStack
   
   if exists (card "View Behavior") then
      go to card "View Behavior"
   else
      create card "View Behavior"
   end if
   
   put the card_View ["View|Image|Icons"] of card "View Behavior" into iconView
   if exists (iconView) then return iconView
   
   put the rect of this card into someRect
   put rect_Subtract ("12,80,12,12", someRect) into someRect
   
   set the view_Insert [someRect] of card "View Behavior" to "View|Image|Icons" 
   put the result into createdView
   return createdView
end view_CreateTemplateIconGroup


--> View | Props | Back Property
-
/*
These handlers implement back behavior like properties that can be overidden by props placed higher up the hierarchy
*/

getprop back_Property [propName]
   put the long id of the target into tObject
   
   put the customproperties of tObject into propArray
   put propArray [propName] into titlePosistion
   if titlePosistion is empty then
      put object_GetOwner (tObject) into tOwner
      put the propName of tOwner into propValue
   end if
   return propValue
end back_Property

setprop back_Property [propName] someValue
   -- place in behavior (references "me")
   set the view_DisplayProperty [propName] of the target to someValue
   -- dispatch "LayoutControl" to me -- changes the target (allowing lower level control use)
   return the result
end back_Property


--> View | Swap
-
getprop title_ViewName
   put the title_View of the target into titleView
   put the view_Name of titleView into vName
   return vName
end title_ViewName
 
setprop title_ViewName vName
   put the title_View of the target into titleView
   set the view_Swap of titleView to vName
   return the result
end title_ViewName

getprop body_ViewName
   put the body_View of the target into bodyView
   put the view_Name of bodyView into vName
   return vName
end body_ViewName
 
setprop body_ViewName vName
   put the body_View of the target into bodyView
   set the view_Swap of bodyView to vName
   return the result
end body_ViewName

--> View | Hierarchy
-
getprop object_Views
   local vObjects
   put the long id of the target into targetObject
   
   put the view_Name of targetObject into vName
   if vName is not empty then put targetObject & CR after vObjects
   
   repeat with cNum = 1 to the number of controls of targetObject
      put the long id of control cNum of targetObject into innerObject
      put the view_Name of innerObject into vName
      if vName is not empty then
         put innerObject & CR after vObjects
      end if
   end repeat
   delete char -1 of vObjects
   return vObjects
end object_Views

getprop object_ViewNames
   local objectViews
   put the long id of the target into targetObject
   
   put the view_Name of targetObject into vName
   if vName is not empty then put vName & CR after vNames
   
   repeat with cNum = 1 to the number of controls of targetObject
      put the view_Name of control cNum of targetObject into vName
      if vName is not empty then
         put vName & CR after vNames
      end if
   end repeat
   delete char -1 of vNames
   return vNames
end object_ViewNames

getprop view_OrCard
   -- searches for a view in the objects hierarchy
   -- considers a view to be either something markey with either:
   -- uRIP "view", a group with the selectGroupedControls on, or the card
   put the long id of the target into targetObject
   repeat
      switch word 1 of targetObject
         case "card"
            return targetObject
         case "stack"
            return empty
         case empty
            return empty
         default
            if the uRIP ["type"] of targetObject is "view" then return targetObject
            if word 1 of targetObject = "group" and the selectGroupedControls of targetObject then return targetObject 
            
            delete word 1 to 4 of targetObject -- does not work for substacks
      end switch
   end repeat
end view_OrCard

function view_GetStackBackgroundID vName, stackName
   put the backgroundids of stack stackName into bgIDs
   repeat for each line bgID in bgIDs
      put the view_Name of bg id bgID of stack stackName into testViewName
      if testViewName is empty then next repeat
      
      if testViewName = vName then
         return bgID
      end if
   end repeat
   return empty
end view_GetStackBackgroundID

getprop view_TopObject
   -- which is the top (highest) someView in the current layout
   put the long id of the target into testGroup
   put view_ConstructHierarchy(testGroup) into viewHierarchy
   return line 1 of viewHierarchy
end view_TopObject

getprop view_Parent
   -- was "view_Above" and "view_Owner"
   put the long id of the target into someObject
   if word 1 of someObject is "stack" then
      -- a stack cant be a view?
      return empty
   else
      delete word 1 to 4 of someObject
      put the view_Object of someObject into someView
      return someView
   end if
end view_Parent

getprop view_HierarchyPath
   /*
   ??? not really working as a class hierarchy!
   A path is constructed based on the object hierarchy of the views.
   */
   
   put the long id of the target into someView
   put view_ConstructHierarchy(someView) into viewHierarchy
   
   set the itemdelimiter to "|"
   put line -1 of viewHierarchy into bottomView
   put item -1 of the uRIP ["name"] of bottomView into bottomViewShortName
   
   put "View" into nestedPath
   repeat for each line hierarchyView in viewHierarchy
      put the uRIP ["name"] of hierarchyView into hierarchyViewPath
      if item 1 of hierarchyViewPath is "View" then delete item 1 of hierarchyViewPath
      delete item -1 of hierarchyViewPath
      if hierarchyViewPath is not empty then
         put "|" & hierarchyViewPath after nestedPath
      end if
   end repeat
   get nestedPath & "|" & bottomViewShortName
   return it
end view_HierarchyPath

getprop view_Hierarchy
   put the long id of the target into targetObject
   put view_ConstructHierarchy (targetObject) into viewObjects
   return viewObjects
end view_Hierarchy

function view_ConstructHierarchy targetObject
   -- ignoreCall: view_Object,g
   local groupHierarchy
   repeat
      if word 1 of targetObject is "card" then
         -- background groups can cause infinite loops
         -- so have to stop hierarchy check at the card level
         -- which means this will not work for views etc which are at the card level or above!
         return word 1 to -1 of groupHierarchy
      else
         put the view_Object of targetObject into someView
         if someView is empty then return word 1 to -1 of groupHierarchy
         
         put someView & CR before groupHierarchy
         
         put someView into targetObject
         delete word 1 to 4 of targetObject
         if targetObject is empty then return word 1 to -1 of groupHierarchy
      end if
   end repeat
   return groupHierarchy
end view_ConstructHierarchy


--> View | Hierarchy | Children
-
/*
Returns the nested views referenced by the containing views script.
This default script can be over-ridden by a local script in the view.
Depends on a well structured script using a "View | Object | Children" script suite
to list the getprop references to the child views.
*/

getprop view_Children
   put the view_Object of the target into someView
   if exists(someView) is false then return empty
   
   put the view_ChildReferences of someView into childReferences
   put empty into viewChildren
   repeat for each line childReference in childReferences
      put the childReference of someView & CR after viewChildren
   end repeat
   delete char -1 of viewChildren
   return viewChildren
end view_Children

setprop view_Children newViews
   put default_FirstStackControl ("View|Layout|Placeholder") into placeHolderView
   
   put the view_Children of the target into viewChildren
   repeat with viewNum = 1 to the number of lines of viewChildren
      put line viewNum of viewChildren into childView
      put line viewNum of newViews into newView
      if newView is empty then put placeHolderView into newView
      
      if exists(childView) and exists(newView) then
         set the view_Replacement of childView to newView
      else
         breakpoint
      end if
   end repeat
end view_Children

getprop view_ChildReferences
   -- put the script_Suite ["View | Object | Children"] of the target into suiteScript
   
   put the script_AndBehavior of the target into someScript
   put script_GetSuiteTitles(someScript) into suiteTitles
   filter suiteTitles with "View * Children"
   put line 1 of suiteTitles into suiteTitle
   if suiteTitle is empty then return empty
   put script_GetSuite(suiteTitle, someScript) into suiteScript
   
   put script_ExtractGetPropHandlers(suiteScript) into objectPropertyNames
   return objectPropertyNames
end view_ChildReferences


--> View | Menu
-
getprop view_ChildToolMenus
   put the long id of the target into targetObject
   put the mobile_Name of targetObject into targetObject
   
   put menu_GetSentPath() into oTextPath
   put menu_GetSentTitlePath() into oTitlePath
   
   set the itemdelimiter to tab
   put the view_Children of targetObject into viewChildren
   repeat for each line viewChild in viewChildren
      put the mobile_Name of viewChild into viewChild
      put the menu_ToolTitle of viewChild into mTitle
      
      put mTitle_ConstructText (mTitle) into subPathBit
      put oTextPath & "/" & subPathBit into mTextPath
      put oTitlePath into mTitlePath
      
      put the menu_Table [mTitle] of viewChild into mTable
      put menu_ConvertTable (mTable, viewChild, mTitlePath, mTextPath, viewChild) into mText
      
      put subPathBit & CR & outline_IncreaseIndent (mText) into mText
      
      put mText & CR & "-" & CR after someMenu
   end repeat
   delete line -2 to -1 of someMenu
   put word 1 to -1 of someMenu into someMenu
   return someMenu
end view_ChildToolMenus

command view_DoParamProp someView, publicProp, publicParam
   put publicProp & "[" & publicParam & "]" into cProp
   put the cProp of someView into oldValue
   
   put "Change public property" && cProp & "?" into someQuestion
   put view_AskPublicValue (cProp, someView, someQuestion) into publicValue
   
   set the cProp of someView to publicValue
end view_DoParamProp


--> View | Hierarchy | Class
-
getprop view_IsTemplate [vName]
   put the long id of the target into targetObject
   if vName is empty then
      put the view_ModuleObject of targetObject into templateObject
   else
      put default_FirstStackControl (vName) into templateObject
   end if
   return templateObject = targetObject
end view_IsTemplate

getprop view_IsClass [classPath]
   put the view_Name of the target into viewName
   put view_IsMemberOfClass (viewName, classPath) into someBoolean
   return someBoolean
end view_IsClass

function view_InheritsClass viewName, classPath
   view_NormalizeName classPath
   return viewName begins with viewName
end view_InheritsClass

function view_IsMemberOfClass viewName, classPath
   view_NormalizeName classPath
   set the itemdelimiter to "|"
   if viewName is empty then return false
   if char -1 of classPath = "|" then delete char -1 of classPath
   get item 1 to (the number of items of classPath) of viewName -- no "|" on the end
   return it = classPath
end view_IsMemberOfClass


--> View | Hierarchy
-
private function _ViewOutlineBit someView, outlineType, vName, someIndent
   switch outlineType 
      case "names"
         put someIndent & the short name of someView into osLine
         break
      case "view names"
         if vName is not empty then
            put someIndent & vName into osLine
         end if
         break
      case "name links"
         put the short name of someView into shortName
         put someIndent & html_ConstructNameLink (shortName, ruggedID) into osLine
         break
      default --case "view name links"
         if viewName is not empty then
            put someIndent & html_ConstructNameLink (vName, ruggedID) into osLine
         end if
         break
   end switch
   return osLine
end _ViewOutlineBit

getprop view_HierarchyPath
    /*
    script and possibly "concept" is a bit of an ugly  hack - improve!
    
    This property acts like a class reference.
    A path is constructed based on the object hierarchy of the views.
    */
    
    put the long id of the target into someView
    put view_HierarchyObjects(someView) into viewHierarchy
    
    set the itemdelimiter to "|"
    put line -1 of viewHierarchy into bottomView
    put item -1 of the object_Name of bottomView into bottomViewShortName
     
    put "View" into nestedPath
    repeat for each line hierarchyView in viewHierarchy
        put the object_Name of hierarchyView into hierarchyViewPath
        if item 1 of hierarchyViewPath is "View" then delete item 1 of hierarchyViewPath
        delete item -1 of hierarchyViewPath
        if hierarchyViewPath is not empty then
            put "|" & hierarchyViewPath after nestedPath
        end if
    end repeat
    get nestedPath & "|" & bottomViewShortName
    return it
end view_HierarchyPath



--> View | Geometry
-
/*
getprop view_Height
   -- dangerous to put in a library in this general way
   -- allow views to define them
   -- returning empty is the same as undefined.
   return the height of the target	# a default (can over-ride locally)
end view_Height

setprop view_Height someHeight
   set the height of the target to someHeight	# a default (can over-ride locally)
   return the result
end view_Height

getprop view_Width
   return the width of the target	# a defaults  (can over-ride locally)
end view_Width

setprop view_Width someWidth
   set the width of the target to someWidth	# a defaults  (can over-ride locally)
   return the result
end view_Width

getprop view_Height
    return the height of the target	# a default (can over-ride locally)
end view_Height

getprop view_Width
    return the width of the target	# a defaults  (can over-ride locally)
end view_Width

getprop formatted_Width
    -- defaults to formattedWidth (can over-ride locally)
    return the formattedwidth of the target
end formatted_Width

-- getprop view_Spacing
    -- defaults to the "view_StackPadding" of the target
    -- which in turn defaults to the value below!
    
    put the long id of the target into targetObject
    return the view_StackPadding of targetObject
end view_Spacing
*/

getprop view_Rect
   -- a simple default (override locally)
   if word 1 of the target is among the items of "field,button,image,player,graphic,scrollbar" then
      return the rect of the target
   else
      return empty
   end if
end view_Rect

setprop view_Rect someRect
   -- a simple default (override locally)
   if word 1 of the target is among the items of "field,button,image,player,graphic,scrollbar" and someRect is a rect then
      set the rect of the target to someRect
   end if
end view_Rect

getprop view_StackPadding
    -- a default
    return 20
end view_StackPadding

setprop view_StackMinMaxHeight minMaxList
    put item 1 of minMaxList into maxStackHeight
    if maxStackHeight is empty then put 65535 into maxStackHeight
    
    put item 2 of minMaxList into minStackHeight
    if minStackHeight is empty then put 32 into minStackHeight
    
    set the maxheight of this stack to maxStackHeight
    set the minheight of this stack to minStackHeight
end view_StackMinMaxHeight

getprop view_StackHeight [someView]
    put the long id of the target into targetObject
    if someView is empty then
        put object_ExtractStack(targetObject) into stackObject
        if exists(group 1 of stackObject) then 
            put the long id of group 1 of stackObject into someView
        else
            return empty
        end if
    end if
    put the view_StackPadding of someView into stackPadding
    put (the formattedheight of someView) + 2 * stackPadding into goodHeight
    return goodHeight
end view_StackHeight

getprop view_IsResizeable
    put the long id of the target into targetObject
    put the script_SetPropHandlers of targetObject into setPropHandlerIndex
    set the wholematches to true
    return "view_Rect" is among the lines of setPropHandlerIndex
end view_IsResizeable

command view_ResizeToCard pMargin, pName
   if pName is empty then put 1 into pName
   
   put the card_Object of the target into cardObject
   if pName is empty then put 1 into pName
   if exists (control pName of cardObject) is false then
      return empty -- could look for card_View
   end if
   
   if pMargin is empty then
      put the card_Margin of cardObject into pMargin
   else
      set the card_Margin of cardObject to pMargin
      -- set the uOPN ["card_Margin"] of cardObject to pMargin -- only needed for authoring
   end if
   
   put the rect of cardObject into someRect
   if pMargin is not 0 then put rect_Subtract (pMargin, someRect) into someRect
   
   put the long id of control pName of cardObject into someView
   -- set the rect of someView to someRect
   dispatch "LayoutControl" to someView with someRect
   return someView
end view_ResizeToCard

on object_ResizeToCard pMargin, pResizeObject, pDimensions
   -- if the object_ContainsMessageHandler ["resizeControl"] of pResizeObject is true then
   put the card_ViewRect [pMargin] of pResizeObject into someRect
   switch
      case pDimensions is empty
         set the rect of pResizeObject to someRect
         break
      default
         set the media_Rect [pDimensions] of pResizeObject to someRect
         break
   end switch
   return the result
end object_ResizeToCard

getprop formatted_Width
   -- default (can over-ride locally)
   if word 1 of the target is not among the items of "button,field,image,player,group,card" then return empty
   return the formattedwidth of the target
end formatted_Width

getprop formatted_Height
   -- default (can over-ride locally)
   if word 1 of the target is not among the items of "button,field,image,player,group,card" then return empty
   return the formattedheight of the target
end formatted_Height

getprop view_ChildRect [shortID]
    -- a default
    -- can override at card level for specific viewNames
    -- also just use "card_Margin"
    -- viewResize sent to the card so the target is usually the card
    put the long id of the target into cardObject
    
    -- could return different rects for different views
    -- put the long id of control id shortID into childView
     
    -- can use the card_margin
    put the card_Margin [shortID] of cardObject into someMargin
    put the rect of cardObject into someRect
    return rect_Subtract(someMargin, someRect)
end view_ChildRect

getprop card_ViewRect [someMargin]
    -- a default
    put the card_Object of the target into cardObject
    if exists(cardObject) is false then return empty
    
    if someMargin is empty then
        put the card_Margin of cardObject into someMargin
        if not(someMargin is a number or someMargin is a rect) then
            --  put the opn_Error ["The stored card margin is not a number or rect!"] of me
            put 0 into someMargin
            set the card_Margin of cardObject to 0
        end if
    else if someMargin is a number or someMargin is a rect then
        -- lets store it
        set the card_Margin of cardObject to someMargin
    else
        put the opn_Error ["Margin is not a number or rect!"] of me
        put 0 into someMargin
    end if
    
    put the rect of cardObject into someRect
    put rect_Subtract(someMargin, someRect) into viewRect
    return viewRect
end card_ViewRect

getprop view_StackHeight [someView]
    put the long id of the target into targetObject
    if someView is empty then
        put object_ExtractStack(targetObject) into stackObject
        if exists(group 1 of stackObject) then 
            put the long id of group 1 of stackObject into someView
        else
            return empty
        end if
    end if
    put the card_Margin of someView into stackPadding
    put (the formattedheight of someView) + 2 * stackPadding into goodHeight
    return goodHeight
end view_StackHeight

getprop view_ResizeStackScript [viewName]
    if viewName is empty then put "default" into viewName
    put the uOPN["ViewResizeStack_Script"] of me into templateScript
    put merge(templateScript) into newScript
    return newScript
end view_ResizeStackScript


--> View | Props | Default
-
getprop view_Text
   if word 1 of the target is "field" then
      return the text of the target
   else
      return the uOPN ["text"] of the target
   end if
end view_Text

setprop view_Text [someTitle] someText
   if word 1 of the target is "field" then
      set the text of the target to someText
   else
      set the uOPN ["text"] of the target to someText
   end if
end view_Text

getprop view_Html
   if word 1 of the target is "field" then
      return the htmltext of the target
   else
      return the uOPN ["html"] of the target
   end if
end view_Html

setprop view_Html [someTitle] someHtml
   if word 1 of the target is "field" then
      set the htmltext of the target to someHtml
   else
      set the uOPN ["html"] of the target to someHtml
   end if
end view_Html

getprop view_Utf8 [someTitle]
   if word 1 of the target is "field" then
      put the unicodetext of the target into someU16
      put unidecode(someU16, "UTF8") into someUtf8
   else
      return the uOPN ["utf8"] of the target
   end if
end view_Utf8

setprop view_Utf8 [someTitle] someUtf8
   if word 1 of the target is "field" then
      put uniencode(someUtf8, "UTF8") into someU16
      set the unicodetext of the target to someU16
   else
      set the uOPN ["utf8"] of the target to someUtf8
   end if
end view_Utf8

getprop view_Colour
   put the view_Object of the target into someView
   if exists(someView) is false then return empty
   return the effective backgroundcolor of someView
end view_Colour

getprop view_TextColour
   return "black"
end view_TextColour


--> View | Name
-
/*
Properties of all views.

Views are uniquely named in a way in which they can be orgaised into a hierarchy.
These names are stored as custom properties of the view.

Views are also usually associated with 2 models, the "data model" and the "display model".
By default both models are named according to the views "stem name".

For example a "tree" view has the stem "Tree",
the (data) model_Name "uOPN_DisplayTable" and
the view_DisplayModelName "uOPN_TreeDisplayTable".

This hierarchy allows the view to not only be displayed as part of a hierarchy,
but for generic scripts to use this hierarchical information to simulate "inheretance".
*/

getprop component_Name [pComponentType]
   put the uRIP ["name"] of the target into vName
   if the dgProps ["style"] of the target is among the items of "table,form" then -- it is a datagrid
      if vName is empty then -- in case it is not named (ie a vanilla Rev control)
         return "View|Rev|Datagrid"
      else
         return vName
      end if
   else if pComponentType is empty then
      return vName
   else if the uRIP ["type"] of the target is not pComponentType then
      return empty
   else
      return vName
   end if
end component_Name

setprop component_Name [pComponentType] uRipName
   -- same as "view_Name"
   put the long id of the target into tObject
   component_SetName tObject, uripName, pComponentType
   put the result into someScript
   return someScript
end component_Name


--> View | Behaviors
-
getprop object_ViewBehavior
   -- this assumes that the behavior has a custom property uRIP ["name']
   -- which is the same as the view_Name
   
   put the behavior of the target into someBehavior
   return the view_Name of someBehavior
end object_ViewBehavior

setprop object_ViewBehavior viewName
   put view_GetTemplateBehavior (viewName) into templateBehavior
   return templateBehavior
end object_ViewBehavior

function view_GetTemplateBehavior viewName
   put default_FirstStackControl (viewName) into templateObject
   if exists (templateObject) is false then return empty
   put the behavior of templateObject into templateBehavior
   return templateBehavior
end view_GetTemplateBehavior

getprop view_Alternatives [viewName]
   -- a default in cases whem it is not intercepted by the view
   if viewName is empty then
      put the view_Name of the target into viewName
      if viewName is empty then return empty
      set the itemdelimiter to "|"
      delete item -1 of viewName
   end if
   
   put view_FilteredPaths (viewName) into viewNames
   return viewNames
end view_Alternatives

function view_ListBehaviors vName
   -- first line will be the top view behavior if it has one
   put default_FirstStackControl (vName) into templateObject
   put the object_Behaviors of templateObject into vBehaviors
   return vBehaviors
end view_ListBehaviors


--> View | Tests
-
getprop view_IsResizeable
   put the long id of the target into targetObject
   put the script_SetPropHandlers of targetObject into setPropHandlerIndex
   set the wholematches to true
   return "view_Rect" is among the lines of setPropHandlerIndex
end view_IsResizeable

getprop view_IsOld
   put the long id of the target into someView
   
   put the object_Version of someView into thisVersion
   put the view_ModuleObject of someView into libraryObject
   if exists (libraryObject) is false then return "Error: library object does not exist. Maybe target is not a view?"
   
   put the object_Version of libraryObject into libraryVersion
   if thisVersion > libraryVersion then
      return false
   else if thisVersion = libraryVersion then
      return empty
   else
      return true
   end if
end view_IsOld


--> View | Name | References
-
-- getprop datagrid_View
   return the long id of me
end datagrid_View

getprop view_InsideViews [viewStem]
   put the long id of the target into containerObject
   put the number of chars of viewStem into maxNum
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long id of control controlNum of containerObject into testObject
      if char 1 to maxNum of the view_Name of testObject =  viewStem then
         put testObject & CR after foundObjects
      end if
   end repeat
   delete char -1 of foundObjects
   return foundObjects
end view_InsideViews

getprop view_Reference
   -- assumes a view has a behavior, and an object reference is in the Metadata suite.
   put the view_Object of the target into someView
   if exists(someView) is false then return empty
   put the behavior of someView into viewBehavior
   if exists(viewBehavior) is false then put someView into viewBehavior
   put the script of viewBehavior into someScript
   
   put script_GetSuite("Metadata", someScript) into suiteScript
   put script_ExtractGetPropHandlers(suiteScript) into viewReferences
   line_Delete "view_Object", viewReferences
   return viewReferences
end view_Reference

getprop view_DisplayModelName
   -- the default based on the views stem
   -- return "uOPN_TreeDisplayTable"
   
   put the view_Object of the target into someView
   put the view_Stem of someView into viewStem
   put toupper(char 1 of viewStem) into char 1 of viewStem
   put "uOPN_" & viewStem & "DisplayTable" into modelName
   return modelName
end view_DisplayModelName

getprop view_Stem
   put the view_Object of the target into someView
   -- put the long id of the target into someView
   if exists(someView) is false then return empty
   
   put the uOPN ["view_Stem"] of someView into viewStem
   if viewStem is not empty then
      return viewStem
   else
      put the uRIP ["name"] of someView into viewName
      put view_StemFromName(viewName) into viewStem 
      set the view_Stem of someView to viewStem
      return viewStem
   end if
end view_Stem

function view_StemFromName viewName
   if viewName is empty then return "event"
   
   set the itemdelimiter to "|"
   put word 1 to -1 of item 2 of viewName into viewStem 
   replace space with empty in viewStem
   put tolower(viewStem) into viewStem
   return viewStem
end view_StemFromName

setprop view_Stem viewStem
   put the long id of the target into someView
   set the uOPN ["view_Stem"] of someView to viewStem
end view_Stem


--> View | Top
-
/*
A number of similar scripts here - needs rationalising.
*/

getprop top_CardView
   return the card_View of the target
end top_CardView

on card_SpaceControls someRect, viewSpacer
   if someRect is empty then put the the rect of me into someRect
   lock screen 
   
   if viewSpacer is empty then put 4 into viewSpacer
   put rect_Subtract (viewSpacer, someRect) into innerRect
   
   put item 1 of innerRect into innerLeft
   put item 2 of innerRect into lastTop
   put item 3 of innerRect into innerRight
   put item 4 of innerRect into innerBottom
   
   put 0 into rowHeight
   put innerLeft into lastLeft
   put item 3 of innerRect - item 1 of innerRect into innerWidth
   put the top_Controls of this card into topControls
   repeat for each line topControl in topControls      
      put the formatted_Width of topControl into fWidth
      if fWidth is empty then put the formattedWidth of topControl into fWidth
      if fWidth is empty then put the width of topControl into fWidth
      
      put the formattedHeight of topControl into fHeight
      if fHeight is empty then put the formatted_Height of topControl into fHeight
      if fHeight is empty then put the height of topControl into fHeight
     
      put lastLeft + fWidth into imageRight
      
      if imageRight > innerRight then
         -- lets move it down a row
         add rowHeight + viewSpacer to lastTop
         put 0 into rowHeight
         put innerLeft into lastLeft
         put lastLeft + fWidth into imageRight
      end if
      
      put lastLeft,lastTop into cRect
      put imageRight into item 3 of cRect
      put lastTop + fHeight into lastBottom
      put lastBottom into item 4 of cRect
      put rect_Add (4, cRect) into cRect
        
      set the rect of topControl to cRect
      
      put max (rowHeight, fHeight) into rowHeight
      add fWidth + viewSpacer to lastLeft
   end repeat
   unlock screen
end card_SpaceControls

getprop card_ViewOutline [withLinks]
   put withLinks is true into withLinks
   put the card_TopViews of the target into cardViews
   repeat for each line cardView in cardViews
      put the view_NameOutline [withLinks] of cardView & CR after cardViewOutline
      -- put the view_ReferenceOutline [onlyViewNames] of cardView & CR after cardViewOutline
   end repeat
   delete char -1 of cardViewOutline
   return cardViewOutline
end card_ViewOutline

getprop card_TopView
   -- return the card if there are no top views, or more than 1 top view
   put the long id of the target into targetObject
   put the card_Object of targetObject into cardObject
   put the card_TopViews of cardObject into topViews
   if the number of lines of topViews = 1 then
      return topViews
   else
      return cardObject
   end if
end card_TopView

function card_GetTopView
   return the card_TopView of the topstack
end card_GetTopView

function card_ListOtherViews cardObject, pNotTheseViewNames
   local foundObjects
   view_NormalizeName viewName
   repeat with cNum = 1 to the number of controls in cardObject
      put the long id of control cNum of cardObject into testObject
      put the view_Name of testObject into testViewName
      if testViewName is empty then next repeat
      
      if testViewName is not among the items of pNotTheseViewNames then
         put testObject & CR after foundObjects
      end if
   end repeat
   return foundObjects
end card_ListOtherViews

function card_ListViews cardObject, pViewName
   local foundObjects
   view_NormalizeName viewName
   repeat with cNum = 1 to the number of controls in cardObject
      put the long id of control cNum of cardObject into testObject
      put the view_Name of testObject into testViewName
      if pViewName is empty or testViewName is pViewName then
         put testObject & CR after foundObjects
      end if
   end repeat
   return foundObjects
end card_ListViews

getprop card_Views
   -- in any order
   put the card_Object of the target into cardObject
   repeat with controlNum = 1 to the number of controls in cardObject
      put the long id of control controlNum of cardObject into someControl
      put the view_Name of someControl into vName
      if vName is empty then next repeat
      put someControl & CR after cardViews
   end repeat
   delete char -1 of cardViews
   return cardViews
end card_Views

getprop card_TopViews [viewName]
   put the card_Object of the target into cardObject
   put the top_Controls of cardObject into topControls
   repeat for each line someControl in topControls
      put the view_Name of someControl into testViewName
      if viewName is empty and testViewName is not empty then
         put someControl & CR after topCardViews
      else if viewName = testViewName then
         put someControl & CR after topCardViews
      end if
   end repeat
   delete char -1 of topCardViews
   return topCardViews
end card_TopViews


--> View | Find
-
getprop card_View [vNames]
   -- a guess (makes views "sticky")
   -- first it looks "inside" the target view
   -- next it looks "up" the target view hirarchy
   -- then it looks down from the card view
   
   if vNames is empty then
      return line 1 of the card_TopViews of the target
   else
      put the long id of the target into targetObject
      
      if word 1 of targetObject is not "card" then
         -- first search inside the target view
         put the view_LazyFindInside [vNames] of targetObject into foundView
         if exists(foundView) then return foundView
         
         -- next search up from the target view
         put the view_Above [vNames] of targetObject into foundView
         if exists(foundView) then return foundView
         
      end if
      
      put the card_Object of targetObject into cardObject
      
      -- lets do a strict match for each vName in turn for every view from the card down
      put the card_ViewMatch [vNames] of cardObject into foundView
      if exists(foundView) then return foundView
      
      -- finally lets search lazily from the card down
      put the view_LazyFindInside [vNames] of cardObject into foundView
      if exists(foundView) then
         return foundView
      else
         return empty
         
         get the card_TopViews of the target
         return line 1 of it
      end if
   end if
end card_View

getprop card_ViewMatch [vNames]
   -- maybe change for "view_Match"
   put the card_Object of the target into cardObject
   put the view_Match [vNames] of cardObject into cardViewMatch
   return cardViewMatch
end card_ViewMatch

getprop view_Match [vNames]
   -- lets do a strict match for each vName in turn for every view from the card down
   -- does not search top to bottom but in control order
   -- consider changeing to top down search (slower)
   put the long id of the target into targetObject
   if word 1 of targetObject is not among the items of "card,stack" then
      put the view_Name of targetObject into vName
      if vName is not empty and strictViewNameMatch (matchName, vName) is true then
         return targetObject
      end if
   end if
   
   -- should go down from the top (most unusual match)
   repeat for each line matchName in vNames
      repeat with controlNum = 1 to the number of controls in targetObject
         put the long id of control controlNum of targetObject into someControl
         put the view_Name of someControl into vName
         if vName is empty then next repeat
         if strictViewNameMatch (matchName, vName) is true then
            return someControl
         end if
      end repeat
   end repeat
   return empty
end view_Match

getprop view_FindInside [vNames]
   replace "/" with CR in vNames
   put line 1 of vNames into vName
   put the view_Inside [vName] of the target into foundView
   if exists(foundView) is false then return empty
   put the view_MatchInside [vNames] of foundView into matchedView
   return matchedView
end view_FindInside

getprop view_Inside [vNameOrStem]
   -- works with any control or card
   put the long id of the target into targetObject
   
   -- first lets check the target to see if there is a match
   put the view_Name of targetObject into vName
   if lazyViewNameMatch (vNameOrStem, vName) is true then return targetObject
   
   -- now lets recurse the children
   put the top_Controls of targetObject into topControls
   repeat for each line topControl in topControls
      put the view_Inside [vNameOrStem] of topControl into foundView
      if exists(foundView) then return foundView
   end repeat
   return empty
end view_Inside

getprop view_LazyFindInside [vNames]
   replace "/" with CR in vNames
   put line 1 of vNames into vName
   put the view_Inside [vName] of the target into foundView
   if exists(foundView) is false then return empty
   
   put the view_SlightlyLazyMatchInside [vNames] of foundView into matchedView
   return matchedView
end view_LazyFindInside

getprop view_SlightlyLazyMatchInside [vNames]
   -- first lets look for a strict match
   put the view_MatchInside [vNames] of the target into strictMatch
   if exists(strictMatch) then return strictMatch
   
   -- then get slightly lazy
   repeat (the number of lines of vNames - 1)
      put the view_LazyMatchInside [vNames] of the target into lazyMatch
      if exists(lazyMatch) then return lazyMatch
      delete line -1 of vNames
   end repeat
   return empty
end view_SlightlyLazyMatchInside
   
getprop view_VeryLazyMatchInside [vNames]
   repeat the number of lines of vNames
      put the view_LazyMatchInside [vNames] of the target into lazyMatch
      if exists(lazyMatch) then return lazyMatch
      delete line -1 of vNames
   end repeat
   return empty
end view_VeryLazyMatchInside

getprop view_LazyMatchInside [vNames]
   -- a recursive function
   -- a match where if the target is matched by the top vName
   -- then it looks for a match for the next vName in the index among the top controls (one level down)
   -- and continues for all lines of vNames
   -- any mismatch and it returns the last (deepest) match found
   -- calling this property on a control which has no view_Name or the wrong view_Name returns empty
   
   put the long id of the target into targetObject
   replace "/" with CR in vNames   
   put line 1 of vNames into viewNameOrStem
   
   -- first lets check the top level object
   put the view_Name of targetObject into vName
   if vName is empty then return empty
   if lazyViewNameMatch(viewNameOrStem, vName) is true then
      -- found a match so lets move down a view and a vName
      delete line 1 of vNames
      if vNames is empty then
         -- no more vNames to search so lets return the found object
         return targetObject
      else
         put the top_Controls of targetObject into topControls
         repeat for each line testControl in topControls
            put the view_LazyMatchInside [vNames] of testControl into foundView
            if exists(foundView) then return foundView
         end repeat
         return empty
      end if
   end if
end view_LazyMatchInside

getprop view_MatchInside [vNames]
   -- a recursive function
   -- a strict match where if the target is matched by the top vName
   -- then it looks for a match for the next vName in the index among the top controls (one level down)
   -- and continues for all lines of vNames
   -- any mismatch and it returns false (stem matches are allowed)
   -- calling this property on a control which has no view_Name or the wrong view_Name returns empty
   
   put the long id of the target into targetObject
   replace "/" with CR in vNames
   put line 1 of vNames into viewNameOrStem
   
   -- first lets check the top level object
   put the view_Name of targetObject into vName
   if vName is empty then return empty
   if strictViewNameMatch(viewNameOrStem, vName) is true then
      -- found a match
      delete line 1 of vNames
      if vNames is empty then
         -- no more vNames to search so lets return the found object
         return targetObject
      else
         put the top_Controls of targetObject into topControls
         repeat for each line testControl in topControls
            put the view_MatchInside [vNames] of testControl into foundView
            if exists(foundView) then return foundView
         end repeat
         return empty
      end if
   end if
end view_MatchInside

getprop view_Above [vNameOrStem]
   -- search for a named view in the hierarchy above the target
   -- including the target itself
   
   put the long id of the target into targetObject
   if vNameOrStem is empty then
      delete word 1 to 4 of targetObject
      if exists(targetObject) is false then return empty
      put the view_Object of targetObject into viewAbove
      return viewAbove
   end if
   
   repeat
      if word 1 of targetObject is "card" then
         return empty
      else
         put the view_Object of targetObject into someView
         if exists (someView) is false then return empty
         
         -- lets check for a match
         put the view_Name of someView into vName
         if lazyViewNameMatch (vNameOrStem, vName) is true then
            return someView
         else
            -- return empty here forces a match only if the named view is one level up
            -- doing nothing allows the named view to be several levels up
         end if
         
         -- go up one level and try again
         put someView into targetObject
         delete word 1 to 4 of targetObject
         if targetObject is empty then return empty
      end if
   end repeat
   return empty
end view_Above

private function lazyViewNameMatch vNameOrStem, vName
   -- test to see if a view_Name is a lazy match with a vNameOrStem
   -- as long as vNameOrStem is an item within the view_Name it returns true
   view_NormalizeName vNameOrStem
   view_NormalizeName vName
   
   set the itemdelimiter to "|"
   delete item 1 of vName
   delete item 1 of vNameOrStem
   if char -1 of vNameOrStem = "|" then delete char -1 of vNameOrStem
   return vNameOrStem is among the items of vName
   
   --old
   -- if the last match fails the match chops of last item and tries again until a match succeeds
   -- so "Tree" will match the vName "View|Tree|Simple Tree"
   repeat the number of items of vName
      if vName = vNameOrStem then
         return true
      end if
      delete item - 1 of vName
   end repeat
   return false
end lazyViewNameMatch

private function strictViewNameMatch vNameOrStem, vName
   if char -1 of vNameOrStem is "|" then
      put true into isStem
      delete char -1 of vNameOrStem
   else
      put false into isStem
   end if
   view_NormalizeName vNameOrStem
   view_NormalizeName vName
   
   set the itemdelimiter to "|"
   delete item 1 of vName
   delete item 1 of vNameOrStem
   
   switch
      case vNameOrStem is empty
         -- return the first named view
         return true
      case isStem is true and (item 1 to (the number of items of vNameOrStem) of vName = vNameOrStem)
         -- stem match
         return true
      case isStem is false and vName = vNameOrStem
         -- exact match
         return true
      default
         -- no match (so lets try recursing)
         return false
   end switch
end strictViewNameMatch
