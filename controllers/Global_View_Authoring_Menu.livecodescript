script "Global | View | Authoring | Menu"
--> MetaData
-
license: GPLv3
name: Global | View | Authoring | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
private command _InitMenu tObject
   -- called only once 
   put the display_View of tObject into displayView
   if exists (displayView) is true then
      -- a view palette
      put displayView into LocalArray ["displayView"]
      put the view_Index of displayView into LocalArray ["viewProps"]
      
      put the displayed_ProjectName of displayView into LocalArray ["projectName"]
      put the displayed_ProjectFolder of displayView into LocalArray ["projectFolder"]
      put the displayed_ModuleFolder of displayView into LocalArray ["moduleFolder"]
      put the displayed_ModuleName of displayView into LocalArray ["moduleName"]
      put the displayed_ModuleHomeStackPath of displayView into LocalArray ["moduleHomeStackPath"]   
      --
      put the title_Text of tObject into viewName
   else
      -- a view stack
      put the view_Name of tObject into viewName
      -- put the stack_Name of tObject into viewName
   end if
   --
   if there is not a stack viewName then return empty
   --
   put viewName into LocalArray ["viewName"] -- should be same as moduleName
   put the long id of control 1 of cd 1 of stack viewName into viewObject
   put viewObject into LocalArray ["viewObject"]
   --
   return viewObject
end _InitMenu

getprop menu_Target [tObject]
   _InitMenu tObject
   put the result into viewObject
   return viewObject
end menu_Target

getprop menu_CheckTarget [viewObject]
   put the module_Folder of viewObject into mFolder
   return there is not a folder mFolder
end menu_CheckTarget

getprop decorations_Param [viewObject]
   put the stack_Name of viewObject into sName
   put the decorations of stack sName into sDecoration
   if sDecoration is empty then return "empty"
   if sDecoration = "title,menu,minimize,maximize,close" then return "default"
   return sDecorations
end decorations_Param

getprop decorations_Params
   /*
   You can specify one or more of the following decorations:
   
   title: Shows the window's title bar
   minimize: Shows the minimize (iconify) box in the title bar
   maximize: Shows the maximize (zoom) box in the title bar
   close: Shows the close box in the title bar
   menu: Shows the menu bar in the window (Unix and Windows only)
   system: Shows the window as a system window (OS X, Unix, and Windows only)
   noShadow: Remove the window's drop shadow (OS X only)
   metal: Shows the window with a textured appearance (OS X only)
   */
   
   return "default,empty,-,title,minimize,maximize,close,system,noShadow,metal"
end decorations_Params

getprop resizable_Param [someView]
   if exists (someView) is false then return false
   --   
   put the stack_Name of someView into stackName
   put the resizable of stack stackName into someBoolean
   return someBoolean
end resizable_Param

getprop resizable_Params
   return "true,false"
end resizable_Params

getprop disabled_CreateViewMenu [someView]
   if exists (someView) is false then return false
   --   
   put the view_GlobalMenuTitle of someView into gMenuTitle
   put menu_Exists (gMenuTitle) into mExists
   if mExists is true then
      return true
   else
      return false
   end if
end disabled_CreateViewMenu

getprop disabled_FixView [someView]
   if exists (someView) is false then return false
   --   
   put the stack_Name of someView into stackName
   if the scriptonly of stack stackName is true then
      return false
   else
      return "delete"
   end if
end disabled_FixView

getprop disabled_EditViewMenus [templateView]
   if exists (templateView) is false then return true
   --   
   put the module_Controllers of templateView into menuStackObjects
   return menuStackObjects is empty
end disabled_EditViewMenus

getprop disabled_EditViewBehaviors [templateView]
   if exists (templateView) is false then return true
   --   
   put the module_Behaviors of templateView into moduleBehaviors
   return moduleBehaviors is empty
end disabled_EditViewBehaviors

getprop disabled_SetCardViewBehavior [templateView]
   if exists (templateView) is false then return true
   --   
   put the card_Object of templateView into cardObject
   put the behavior of cardObject into bObject
   put the name of stack "behavior_ViewTemplateCard" into cardViewBehavior
   if the name of bObject = cardViewBehavior then
      return true
   else
      return false
   end if
end disabled_SetCardViewBehavior

getprop disabled_SetViewMetadata [templateView]
   if exists (templateView) is false then return true
   --   
   put the view_Name of templateView into viewName
   put the stack_Name of templateView into stackName
   if stackName = viewName then
      return true
   else
      return false
   end if
end disabled_SetViewMetadata

private function _AskMenuTitle projectName
   put line 1 of the clipboarddata ["text"] into maybeMenuTitle
   if word -1 of maybeMenuTitle = "Menu" then
      put maybeMenuTitle into suggestedAnswer
   else
      set the itemdelimiter to "_"
      put "Global |" && item -1 of projectName && "| Menu" into suggestedAnswer
   end if
   
   put "What is the name of your global menu...." into someQuestion
   put lcw_Ask (someQuestion, suggestedAnswer) into globalMenuTitle
   return globalMenuTitle
end _AskMenuTitle

getprop disabled_ConvertToModule [dView]
   put the is_Module of dView into isModule
   return isModule
end disabled_ConvertToModule

getprop convertToModule_Param [dView]
   put the project_Name of dView into projectName
   return projectName
end convertToModule_Param

getprop convertToModule_Params
   put env_ListActiveProjects() into projectNames
   sort projectNames
   return projectNames
end convertToModule_Params


--> Global | View | Authoring | Menu
-
on menu_ConvertToModule dView, projectName
   put the view_Name of dView into viewName
   put lcw_Ask ("Choose a new name for the module", viewName, "Not This Name", dView) into moduleName
   --
   module_CreateWithObject moduleName, projectName, dView
   put the result into resultArray
   --
   put resultArray ["moduleHomeStackPath"] into moduleHomeStackPath
   put resultArray ["moduleBehaviorStackPath"] into moduleBehaviorStackPath
   put resultArray ["moduleControllerStackPath"] into moduleControllerStackPath
   
end menu_ConvertToModule

on menu_ObjectInspector dView
   display_ObjectProperties dView
end menu_ObjectInspector

on menu_DisplayViewProject dView
   put the project_Name of dView into projectName
   --
   display_Project projectName
end menu_DisplayViewProject

private on __
end __

on menu_ProjectFolder someView
   put the project_Folder of someView into projectFolder
   finder_Reveal projectFolder
end menu_ProjectFolder

on menu_ProjectAssetFolder someView
   put the project_AssetFolder of someView into moduleAssetFolder
   finder_Reveal moduleAssetFolder
end menu_ProjectAssetFolder

on subMenu_Frame
   return "Global | Frame | Menu"
end subMenu_Frame

on _SetViewMetadata viewObject
   get the view_Name of viewObject
   put the stack_Name of viewObject into viewName
   put metadata_ConstructArray (viewName, "view") into uRipArray
   --
   -- set the view_Name ["view"] of viewObject to viewName
   set the script_MetaData of viewObject to uRipArray
   put the result into uRipArray
   --
   edit the script of viewObject
end _SetViewMetadata

on _
end _

on _TestClose viewObject
   put the project_Folder of viewObject into projectFolder
   put the module_Folder of viewObject into moduleFolder
   put the module_Name of viewObject into moduleName
   --
   module_CloseStacks moduleName, projectFolder
   put revLoadedStacks()
   --
   project_InitialiseFolder moduleFolder
end _TestClose

on _
end _

on _SetCardMargin someView
   put the card_Margin of someView into cardMargin
   put lcw_Ask ("What value do you want for the card space around the view?", cardMargin) into cardMargin
   set the card_Margin of someView to cardMargin
end _SetCardMargin

on _DisplayView someView
   put the stack_Name of someView into stackName
   go to stack stackName
   show stack stackName
   
   put the mouseloc into mLoc
   put globalloc (mLoc) into gLoc
   add 30 to item 1 of gLoc
   add 20 to item 2 of gLoc
   
   set the topleft of stack stackName to gLoc
end _DisplayView

on _DisplayViewTemplate someView
   put the template_View of someView into templateView
   put the stack_Name of templateView into stackName
   go to stack stackName
end _DisplayViewTemplate

on _
end _

on _CreateViewMenu someView
   put the view_GlobalMenuTitle of someView into gMenutitle
   --
   put the project_Name of someView into projectName
   ask_CreateProjectmenu projectName, gMenuTitle
   put the result into controllerStackObject
   edit the script of controllerStackObject
end _CreateViewMenu

on _EditViewMenus someView
   put the template_View of someView into templateView
   put the module_Controllers of templateView into menuStackObjects
   repeat for each line menuStackObject in menuStackObjects
      edit the script of menuStackObject 
   end repeat
end _EditViewMenus

on _EditViewBehaviors someView
   put the template_View of someView into templateView
   put the module_Behaviors of templateView into moduleBehaviors
   repeat for each line moduleBehavior in moduleBehaviors
      edit the script of moduleBehavior 
   end repeat
end _EditViewBehaviors

on _ReindexMenus someView
   -- should figure out how to update the displayView menu
   put the template_View of someView into templateView
   
   module_ReIndexMenus templateView
   put the result into moduleMenuTitleArray
   
   display_Array moduleMenuTitleArray, "Module Menu Title Array", "module_ReIndexMenus"
   lcw_Notify "Indexed all module menus!"
end _ReindexMenus

on _
end _

on _SetCardViewBehavior someView
   put the stack_Name of someView into viewName
   module_SetCardBehavior viewName
end _SetCardViewBehavior

on _
end _

on _FixView someView
   put the stack_Name of someView into stackName
   
   put merge ("The stack for the view '[[stackName]]' is a scriptonly stack! would you like to create a full Livecode version?") into someComment
   answer warning someComment with "Cancel" or "Yes"
   if it is "Cancel" then exit to top
   
   menu_DisplayView someView
   
   put the script of cd 1 of stack stackName into oCardScript
   
   stack_ConvertScriptOnly stackName
   put the result into tempStackFileName
   
   set the script of cd 1 of stack stackName to oCardScript
   set the behavior of cd 1 of stack stackName to the name of stack "behavior_ViewTemplateCard"
   save stack stackName
   
   answer "Copy everything to the new stack and then close the old one to destroy it!"
end _FixView
