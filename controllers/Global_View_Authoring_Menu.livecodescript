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
on menu_Init tObject
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
      put the stack_Name of tObject into viewName
   end if
   --
   if there is not a stack viewName then return empty
   --
   put viewName into LocalArray ["viewName"] -- should be same as moduleName
   put the long id of control 1 of cd 1 of stack viewName into viewObject
   put viewObject into LocalArray ["viewObject"]
   --
   pass menu_Init
end menu_Init

getprop menu_Target [tObject]
   -- called once per menu
   return LocalArray ["viewObject"]
end menu_Target

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


--> Global | View | Authoring | Menu
-
on menu_RenameModule viewObject
   put the view_Name of viewObject into oldModuleName
   --
   put the project_Folder of stack oldModuleName into projectFolder
   put the project_Name of stack oldModuleName into projectName
   put lcw_Ask ("Give this module a new name...", oldModuleName) into newModuleName
   --
   module_Rename oldModuleName, newModuleName, projectName
   --
   display_ProjectLibs projectName
   display_ProjectModules projectName
end menu_RenameModule

on menu_TestClose viewObject
   put the project_Folder of viewObject into projectFolder
   put the module_Folder of viewObject into moduleFolder
   put the module_Name of viewObject into moduleName
   --
   module_CloseStacks moduleName, projectFolder
   put revLoadedStacks()
   --
   project_InitialiseFolder moduleFolder
end menu_TestClose

on _
end _

on menu_AddToStackfiles dView
   put the module_Folder of dView into moduleFolder
   put project_ConstructFoundStackFileArray (moduleFolder) into newStackFileArray
   --
   put the stackfile_Array of dView into stackfileArray
   union stackfileArray with newStackFileArray
   set the stackfile_Array of dView to stackfileArray
   --
   put the stack_Name of dView into stackName
   display_Data stackFileArray, stackName, "Stackfile Array"
end menu_AddToStackfiles

on menu_ExportModuleJson viewObject
   put the module_Folder of viewObject into moduleFolder
   --
   project_ExportMenusAndStackFiles moduleFolder
   put the result into projectArray
   --
   put the view_Name of viewObject into moduleName
   display_Data projectArray, moduleName, "Module Array"  
end menu_ExportModuleJson

on _
end _

on menu_DisplayTools dView
   put the view_Name of dView into viewName
   --
   display_ModuleTools viewName
end menu_DisplayTools

on menu_ObjectInspector dView
   display_ObjectProperties dView
end menu_ObjectInspector

on _
end _

on subMenu_Frame
   return "Global | Frame | Menu"
end subMenu_Frame

on submenu_Assets
   return "Global | View | Assets | Menu"
end submenu_Assets

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _
end _

on menu_RevealModuleFolder someView
   put the module_Folder of someView into moduleFolder
   finder_Reveal moduleFolder
end menu_RevealModuleFolder

on menu_ModuleAssetFolder someView
   put the project_AssetFolder of someView into moduleAssetFolder
   finder_Reveal moduleAssetFolder
end menu_ModuleAssetFolder

on _
end _

on menu_SetCardMargin someView
   put the card_Margin of someView into cardMargin
   put lcw_Ask ("What value do you want for the card space around the view?", cardMargin) into cardMargin
   set the card_Margin of someView to cardMargin
end menu_SetCardMargin

on menu_DisplayView someView
   put the stack_Name of someView into stackName
   go to stack stackName
   show stack stackName
   
   put the mouseloc into mLoc
   put globalloc (mLoc) into gLoc
   add 30 to item 1 of gLoc
   add 20 to item 2 of gLoc
   
   set the topleft of stack stackName to gLoc
end menu_DisplayView

on menu_DisplayViewTemplate someView
   put the template_View of someView into templateView
   put the stack_Name of templateView into stackName
   go to stack stackName
end menu_DisplayViewTemplate

on _
end _

on menu_CreateViewMenu someView
   put the view_GlobalMenuTitle of someView into gMenutitle
   --
   put the project_Name of someView into projectName
   display_AskCreateMenu projectName, gMenuTitle
   put the result into controllerStackObject
   edit the script of controllerStackObject
end menu_CreateViewMenu

on menu_EditViewMenus someView
   put the template_View of someView into templateView
   put the module_Controllers of templateView into menuStackObjects
   repeat for each line menuStackObject in menuStackObjects
      edit the script of menuStackObject 
   end repeat
end menu_EditViewMenus

on menu_EditViewBehaviors someView
   put the template_View of someView into templateView
   put the module_Behaviors of templateView into moduleBehaviors
   repeat for each line moduleBehavior in moduleBehaviors
      edit the script of moduleBehavior 
   end repeat
end menu_EditViewBehaviors

on menu_ReindexMenus someView
   -- should figure out how to update the displayView menu
   put the template_View of someView into templateView
   
   module_ReIndexMenus templateView
   put the result into moduleMenuTitleArray
   
   display_Array moduleMenuTitleArray, "Module Menu Title Array", "module_ReIndexMenus"
   lcw_Notify "Indexed all module menus!"
end menu_ReindexMenus

on _
end _

on menu_SetCardViewBehavior someView
   put the stack_Name of someView into viewName
   module_SetCardBehavior viewName
end menu_SetCardViewBehavior

on _
end _

on menu_FixView someView
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
end menu_FixView

on submenu_Wireframe
   return "Global | View | Wireframe | Menu"
end submenu_Wireframe


--> Private
-
private function _askMenuTitle projectName
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
end _askMenuTitle
