script "Global | Behavior | View | Menu"
--> MetaData
-
license: GPLv3
name: Global | Behavior | View | Menu
type: controller
version: 0.2

--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_CheckTarget [scriptObject]
   -- menu_Target is not set in "menu_Init"
   -- so check it here
   put the object_MetaData ["type"] of scriptObject into mObectType
   put mObectType contains "view" into viewOrViewBehavior
   
   put mObectType into LocalArray ["mObectType"]
   put viewOrViewBehavior into LocalArray ["viewOrViewBehavior"]
   return viewOrViewBehavior is true
end menu_CheckTarget

getprop disabled_SetViewCardBehavior [someView]
   put the card_Object of someView into templateCardObject
   put the behavior of templateCardObject into bObject
   put bObject = the name of stack "behavior_ViewTemplateCard" into behaviorIsSet
   return behaviorIsSet
end disabled_SetViewCardBehavior

getprop disabled_SetModuleBehaviors [viewObject]
   put the behavior_Objects of viewObject into bObjects
   put the module_Behaviors of viewObject into mObjects
   return bObjects = mObjects
end disabled_SetModuleBehaviors

getprop disabled_GoToView [scriptObject]
   put the object_MetaData ["type"] of scriptObject into mObectType
   put mObectType contains "view" into viewOrViewBehavior
   return viewOrViewBehavior is false
end disabled_GoToView

--> Global | Behavior | View | Menu
-
-- see also "Global | View | Script | Menu"

on menu_FixViewBehaviors someView
   put the card_Object of someView into cardObject
   display_BrokenBehaviors cardObject, true
end menu_FixViewBehaviors

on menu_SetViewCardBehavior someView
   put the card_Object of someView into templateCardObject
   set the behavior of templateCardObject to the long id of stack "behavior_ViewTemplateCard"
end menu_SetViewCardBehavior

on menu_EditBehavior someView
   put the behavior of someView into bObject
   switch
      case empty
         answer "The view does not have a behavior!"
         exit to top 
         breakpoint
      case exists (bObject) is false
         put the view_Name of someView into viewName
         answer "Cannot find the behavior of '[[viewName]]'" 
         exit to top
      default
         edit the script of bObject
   end switch
end menu_EditBehavior

on _
end _

on menu_GoToView scriptObject
   put the object_MetaData ["name"] of scriptObject into viewName
   put view_GetTemplateObject (viewName) into templateObject
   switch
      case templateObject = empty
         answer warning merge ("The view '[[viewName]]' is not in the database!")
         break
      case exists (templateObject) is false
         put templateObject
         answer warning merge ("I cannot find the view template for view '[[viewName]]'")
         break
      default
         object_GoTo templateObject
   end switch
end menu_GoToView

on _
end _

on menu_SetModuleBehaviors scriptObject
   put the module_Behaviors of scriptObject into moduleBehaviors
   set the behavior_Objects of scriptObject to moduleBehaviors
   
   repeat for each line someObject in moduleBehaviors
      put the short name of someObject into bName
      put "Set the view behavior of" && the mobile_Name of scriptObject && "to" && kwote (bName) into someMessage
      lcw_Notify someMessage
      
      edit the script of someObject
   end repeat
end menu_SetModuleBehaviors

on menu_EditModuleBehaviors scriptObject
   put the module_Behaviors of scriptObject into moduleBehaviors 
   repeat for each line moduleBehavior in moduleBehaviors
      edit the script of moduleBehavior
   end repeat
end menu_EditModuleBehaviors
