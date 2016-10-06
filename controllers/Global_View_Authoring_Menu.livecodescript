script "Global_View_Authoring_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Authoring_Menu
type: controller
version: 0.1


--> Menu | Props
-


--> Global | View | Authoring | Menu
-
on menu_Clone someView
   put the stack_Name of someView into stackName
   stack_Clone stackName
   put it into clonedStack
end menu_Clone

on submenu_Assets
   return "Global | View | Assets | Menu"
end submenu_Assets

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
   -- should figure out how to update the indexView menu
   put the template_View of someView into templateView
   
   module_ReIndexMenus templateView
   put the result into moduleMenuTitleArray
   
   display_Array moduleMenuTitleArray, "Module Menu Title Array,module_ReIndexMenus"
   lcw_Notify "Indexed all module menus!"
end menu_ReindexMenus

on _
end _

on menu_SetCardViewBehavior someView
   put the stack_Name of someView into viewName
   module_SetCardBehavior viewName
end menu_SetCardViewBehavior

on menu_SetViewMetadata someView
   breakpoint
   put the stack_Name of someView into viewName
   put metadata_ConstructUripArray (viewName, "view") into uRipArray
   
   if word 1 of someView = "card" then
      put someView into templateCardView
      if exists (control 1 of templateCardView) is false then
         breakpoint
         answer warning "There is not control on the template card!"
         exit to top
      end if
      
      put the long id of control 1 of templateCardView into someView
   end if
   
   -- put the template_View of someView into templateView
   set the script_MetaData of someView to uRipArray
   edit the script of someView
end menu_SetViewMetadata

on menu_CreateViewMenu templateView
   breakpoint
   put the module_Folder of templateView into moduleFolder
   put the view_Name of templateView into viewName
   
   put menu_GlobalTitleFromViewName (viewName) into globalMenuTitle
   put "What is the name of your global menu...." into someQuestion
   put lcw_Ask (someQuestion, globalMenuTitle) into globalMenuTitle
   
   module_CreateController globalMenuTitle, moduleFolder
   put the result into moduleControllerPath
   edit the script of stack moduleControllerPath
end menu_CreateViewMenu

on _
end _

on menu_FixView someView
   put the stack_Name of someView into stackName
   
   put merge ("The stack for the view '[[stackName]]' is a scriptonly stack! would you like to create a full Livecode version?") into someComment
   answer warning someComment with "Cancel" or "Yes"
   if it is "Cancel" then exit to top
   
   menu_DisplayView someView
   
   put the filename of stack stackName into oFileName
   put the script of stack stackName into oStackScript
   put the rect of stack stackName into oRect
   put the script of cd 1 of stack stackName into oCardScript
   
   breakpoint
   
   set the destroystack of stack stackName to true
   set the destroywindow of stack stackName to true
   put the tempname & ".livecodescript" into tempFileName
   set the filename of stack stackName to tempFileName
   set the name of stack stackName to ("temp_" & stackName)
   
   create invisible stack stackName
   set the rect of stack stackName to oRect
   set the filename of stack stackName to oFileName
   set the script of stack stackName to oStackScript
   set the script of cd 1 of stack stackName to oCardScript
   set the behavior of cd 1 of stack stackName to the name of stack "behavior_ViewTemplateCard"
   save stack stackName
   
   answer "Copy everything to the new stack and then close the old one to destroy it!"
end menu_FixView

on submenu_Wireframe
   return "Global | View | Wireframe | Menu"
end submenu_Wireframe


--> Global | View | Authoring | Menu | Disabled
-
getprop disabled_FixView [someView]
   put the stack_Name of someView into stackName
   if the scriptonly of stack stackName is true then
      return false
   else
      return "delete"
   end if
end disabled_FixView

getprop disabled_EditViewMenus [templateView]
   put the module_Controllers of templateView into menuStackObjects
   return menuStackObjects is empty
end disabled_EditViewMenus

getprop disabled_EditViewBehaviors [templateView]
   put the module_Behaviors of templateView into moduleBehaviors
   return moduleBehaviors is empty
end disabled_EditViewBehaviors

getprop disabled_SetCardViewBehavior [templateView]
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
   put the view_Name of templateView into viewName
   put the stack_Name of templateView into stackName
   if stackName = viewName then
      return true
   else
      return false
   end if
end disabled_SetViewMetadata

