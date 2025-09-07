script "lib_ViewUpdate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ViewUpdate
type: library
version: 0.8


--> Working on
-
command view_InsertFromPath viewPath, groupOrCard, pLocOrRect
   if word 1 of groupOrCard is not among the items of "group,background,card" then
      get merge ("Error: trying to insert view into wrong type of object [[name of the target]]!")
      return the script_Error [it] of me
   end if
   
   -- put view_NameToFile (viewPath) into viewFile
   put default_FirstStackControl (viewPath) into templateObject
   put the stack_File of templateObject into viewFile
   --
   if exists (templateObject) is false then
      get merge("Cannot find view template '[[viewPath]]'")
      return the script_Error [it] of me
   end if
   --
   view_InsertObject templateObject, groupOrCard, pLocOrRect
   put the result into createdView
   return createdView
end view_InsertFromPath

command view_InsertObject someObject, viewOrCard, pLocOrRect, pDontSelect
   if exists (someObject) is false then return merge ("error, [[someObject]] does not exist")
   if exists (viewOrCard) is false then return merge ("error, [[viewOrCard]] does not exist")
   if pLocOrRect = "mouse" then put the clickloc into pLocOrRect
   --
   lock screen
   copy someObject to viewOrCard
   put it into viewInstance
   
   # Set Position
   switch
      case pLocOrRect is empty
         put the loc of viewOrCard into oLoc
         set the loc of viewInstance to oLoc
         break
      case pLocOrRect is a rect
         set the rect of viewInstance to pLocOrRect
         break
      case pLocOrRect is a point
         set the topleft of viewInstance to pLocOrRect -- assume it is topleft
         break
      case word 1 of viewOrCard is card "card"
         put the loc of viewOrCard into oLoc
         set the loc of viewInstance to oLoc
         break
      case word 1 of viewOrCard is card "stack"
         return merge ("error, cannot insert into [[someObject]]")
      default
         -- pasting on top of a control
         put the rect of viewOrCard into oRect
         set the rect of viewInstance to oRect
   end switch
   --
   if pDontSelect is true then
      choose browse tool
   end if
   unlock screen
   return viewInstance
end view_InsertObject

setprop view_Swap [sendReplace] vName
   view_NormalizeName vName
   put module_GetObject (vName) into anotherView
   if exists (anotherView) is false then
      return "Error: cannot find view:" && vName
   end if
   --
   set the view_Replacement [sendReplace] of the target to anotherView
   put the result into copiedView
   return copiedView
end view_Swap

setprop view_Replacement [sendReplace] anotherView
   if exists (anotherView) is false then return empty
   put the long id of the target into viewToReplace
   put the long id of anotherView into anotherView
   if anotherView = viewToReplace then 
      return empty
   else if word 1 of viewToReplace is "stack" then
      return empty
   end if
   put viewToReplace into viewOwner
   delete word 1 to 4 of viewOwner
   
   put the rect of viewToReplace into oRect
   put the short name of viewToReplace into oName
   -- put the object_GroupLayer of viewToReplace into oGroupLayer
   put the view_StyleArray of viewToReplace into viewStyleArray
   put the view_CustomStyleArray of viewToReplace into bigStyleArray
   if word 1 of viewToReplace is "group" then set the cantdelete of viewToReplace to false
   
   put word 1 of viewOwner = "group" into ownerIsGroup
   if ownerIsGroup then  -- lock so that copied view does not change owner groups rect
      put the lockloc of viewOwner into oLock
      set the lockloc of viewOwner to true
   end if
   
   put revRuggedID (viewToReplace) into viewToReplace
   put revRuggedID (anotherView) into anotherView
   
   lock screen
   copy anotherView to viewOwner
   put it into copiedView
   
   relayer copiedView before viewToReplace
   
   try
      delete viewToReplace
   catch e
      send "delete viewToReplace" to viewToReplace in 2 ticks
   end try
   try
      put word 3 of viewToReplace into previousID
      set the id of copiedView to previousID
      put viewToReplace into copiedView
   catch e
      -- breakpoint
   end try
   set the name of copiedView to oName
   
   set the view_StyleArray of copiedView to bigStyleArray
   -- set the object_GroupLayer of copiedView to oGroupLayer
   if "view_Rect" is among the lines of the script_SetPropHandlers of copiedView then
      set the view_Rect of copiedView to oRect  -- this will force a redraw
   else
      set the rect of copiedView to oRect
   end if
   
   if ownerIsGroup then set the lockloc of viewOwner to oLock
   unlock screen
   -- get the view_UpdateIndex of copiedView
   put the long id of copiedView into copiedView
   return copiedView
end view_Replacement

command view_Insert viewPath, viewOrCard, pRect, pName
   put default_FirstStackControl (viewPath) into tObject
   if exists (tObject) is false then return empty
   --
   view_InsertObject tObject, viewOrCard, pRect
   return the result
end view_Insert

setprop view_Insert [someRect] viewPath
   put the long id of the target into groupOrCard
   view_InsertFromPath viewPath, groupOrCard, someRect
   put the result into createdView
   return createdView
end view_Insert


--> Control
-
getprop control_IsTop
   put the long id of the target into targetObject
   put the long id of the owner of targetObject into targetOwner
   
   put the layer of targetOwner into targetOwnerLayer
   put the layer of targetObject into targetObjectLayer
   put targetObjectLayer = targetOwnerLayer + 1 into isTopLayer
   return isTopLayer
end control_IsTop

getprop child_ControlTypes
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID into someControl
      put the control_Type of someControl into controlType
      put controlType & CR after controlTypes
   end repeat
   delete char -1 of controlTypes
   return controlTypes
end child_ControlTypes

setprop child_ControlTypes controlTypes
   replace comma with CR in controlTypes
   put the long id of the target into layoutView
   
   put the childcontrolids of layoutView into topIDs
   repeat with lineNum = 1 to the number of lines of topIDs
      put line lineNum of controlTypes into controlType
      
      put line lineNum of topIDs into someID
      if someID is empty then
         breakpoint
         -- here we create new things
         put controlType into someName
         put toUpper (char 1 of someName) into char 1 of someName
         put control_ConstructCreateDoScript (controlType, someName, layoutView) into doScript
         if doScript is empty then next repeat
         do doScript
         put it into newControl
      else
         put the long id of control id someID into someControl
         set the control_Type of someControl to controlType
         put the result into newControl
      end if
      
      put newControl & CR after newControls
   end repeat
   delete char -1 of newControls
   return newControls
end child_ControlTypes

getprop control_Type
   put the long id of the target into targetObject
   
   put the view_Name of targetObject into vName
   switch
      case word 1 of targetObject = "widget"
         put the kind of targetObject into someKind
         set the itemdelimiter to "."
         return item -1 of someKind
      case vName is "Layout|Placeholder"
      case vName is "View|Layout|Placeholder"
         return "placeholder"
      case vName is not empty
         return vName
      default
         return word 1 of targetObject
   end switch
end control_Type

setprop control_Type [pClassOrViewName] controlType
   -- should not do this if they control_Type is already controlType
   lock screen
   -- 
   put the long id of the target into targetObject
   put the long id of the owner of targetObject into targetOwner
   
   put the short name of targetObject into oName
   put the short id of targetObject into originalID
   put the rect of targetObject into oRect
   put the backgroundcolor of targetObject into bColour
   
   put control_ConstructCreateDoScript (controlType, oName, targetOwner, pClassOrViewName) into doScript
   if doScript is empty then
      breakpoint
      put control_ConstructCreateDoScript (controlType, oName, targetOwner, pClassOrViewName) into doScript
      return targetObject
   else
      do doScript
      put it into tempCreatedObject
      if exists (tempCreatedObject) is false then
         breakpoint
         return empty
      end if
      
      set the rect of tempCreatedObject to oRect
      relayer tempCreatedObject before targetObject
      --
      switch
         case controlType is empty
         case controlType = "Layout|Placeholder"
         case controlType = "View|Layout|Placeholder"
         case controlType = "placeholder"
            if bColour is empty then put "random" into bColour
            --
            set the background_Colour of tempCreatedObject to bColour
            set the name of tempCreatedObject to oName
            set the urip_Type of tempCreatedObject to "view"
            break
         case controlType = "view"
            set the urip_Type of tempCreatedObject to "view"
            break
         case controlType contains "|"
            set the urip_Type of tempCreatedObject to "view"
            break
         default
            -- it's a standard Livecode control
            -- here we could look at "pClassOrViewName" and 
            -- add some customisation to things list list fields
      end switch
      
      try
         delete targetObject
      catch e
         object_Delete targetObject
      end try
      
      set the name of tempCreatedObject to oName
      show tempCreatedObject
      
      put "reset_ID" && originalID into pigeon
      send pigeon to tempCreatedObject in 20 ticks
      
      dispatch "LayoutControl" to targetOwner
      put the result into createdObject
      
      unlock screen
      return createdObject -- shoujd have the same id but may be a different control type
   end if
end control_Type

on reset_ID originalID
   put the long id of the target into tempCreatedObject
   try
      set the id of tempCreatedObject to originalID
      put the long id of control id originalID into createdObject
   catch e
      put tempCreatedObject into createdObject
      breakpoint
   end try
   return createdObject
end reset_ID

getprop control_Types
   return the child_ControlTypes of the target
end control_Types

setprop control_Types controlTypes
   set the child_ControlTypes of the target to controlTypes
   put the result into newControls
   return newControls
end control_Types


--> Handlers
-
getprop widget_Names
   -- useful for menus
   -- these names correspond to the case conditions of the "control_ConstructCreateDoScript" function below
   return "headerBar,navBar,segmented,browser,tree"
end widget_Names

function control_ConstructCreateDoScript controlType, someName, targetOwner, pClassOrViewName
   switch
      case controlType is empty
      case controlType = "placeholder"
         put default_FirstStackControl ("Layout|Placeholder") into templateObject
         -- put default_FirstStackControl ("View|Layout|Placeholder") into templateObject
         if exists (templateObject) is false then return empty
         put "copy" && templateObject && "to" && targetOwner into doScript
         return doScript
      case controlType = "view"
         put default_FirstStackControl (pClassOrViewName) into templateObject 
         if exists (templateObject) is false then return empty
         put "copy" && templateObject && "to" && targetOwner into doScript
         return doScript
      case controlType contains "|"
         put controlType into viewName
         put default_FirstStackControl (viewName) into templateObject 
         if exists (templateObject) is false then return empty
         put "copy" && templateObject && "to" && targetOwner into doScript
         return doScript
      case controlType = "headerBar"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.headerBar", targetOwner) into doScript
         return doScript
      case controlType = "navBar"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.navBar", targetOwner) into doScript
         return doScript
      case controlType = "segmented"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.segmented", targetOwner) into doScript
         return doScript
      case controlType = "browser"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.browser", targetOwner) into doScript
         return doScript
      case controlType = "treeView"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.treeView", targetOwner) into doScript
         return doScript
      case controlType begins with "com.livecode.widget."
         put controlType into pClassOrViewName
         put widget_ConstructCreateDoScript (someName, pClassOrViewName, targetOwner) into doScript
         return doScript
      case controlType = "widget"
         put widget_ConstructCreateDoScript (someName, pClassOrViewName, targetOwner) into doScript
         return doScript
      case controltype is among the items of "field,button,graphic,player,image"
         if word 1 of targetOwner is "group" then
            put "create invisible" && controlType && quote & someName & quote && "in" && targetOwner into doScript
         else
            put "create invisible" && controlType && quote & someName & quote into doScript
         end if
         return doScript
         break
      default
         breakpoint
         return empty
   end switch
end control_ConstructCreateDoScript

function widget_ConstructCreateDoScript someName, widgetClass, pTargetOwner
   if word 1 of pTargetOwner is "group" then
      put "create invisible widget" && quote & someName & quote && "as" && quote & widgetClass & quote && "in" && pTargetOwner into doScript
   else
      put "create invisible widget" && quote & someName & quote && "as" && quote & widgetClass & quote into doScript
   end if
   return doScript
end widget_ConstructCreateDoScript

command object_Delete pObjects
   if pObjects is empty then put the long id of the target into pObjects
   lock screen
   repeat for each line someObject in pObjects
      if exists(someObject) then
         try
            delete someObject
         catch e
            -- in case the script is executing in the context of the object itself
            send "delete someObject" to someObject in 2 ticks
         end try
      end if
   end repeat
   unlock screen
end object_Delete


--> View | Update
-
command view_Update viewObject, pSendReplace
   -- replaces a view with a library version if the library version is more up-to-date
   -- wraps the "view_Replacement"
   if exists (viewObject) is false then
      return merge ("Error: object does not exist")
   end if
   put the long id of viewObject into viewObject
   /*
   get the view_Object of viewObject
   if it is not viewObject then
      return merge ("Error: object is not a view")
   end if
   */
   put pSendReplace is not false into pSendReplace
   
   -- put the view_Template of pSomeView into libraryView -- returns the top view if it is in a view / module stack
   put the view_Name of viewObject into viewName
   put default_FirstStackControl (viewName) into viewTemplate
   if exists (viewTemplate) is false then
      return "Error: cannot locate a view template for this object"
   end if
   
   set the view_Replacement [pSendReplace] of viewObject to viewTemplate
   return the result
end view_Update


--> Object
-
setprop object_Replacement [sendReplace] anotherView
   put the long id of the target into viewToReplace
   put the long id of anotherView into anotherView
   if anotherView = viewToReplace then 
      log_Error "Cannot replace a view with itself!", the params, true
      return empty
   else if word 1 of viewToReplace is "stack" then
      log_Error merge("Cannot replace a [[viewToReplace]] with the script 'view_Replace'!"), the params, true
      return empty
   end if
   
   put viewToReplace into viewOwner
   delete word 1 to 4 of viewOwner
   
   put the rect of viewToReplace into oRect
   put the short name of viewToReplace into oName
   
   lock screen
   copy anotherView to viewOwner
   put it into copiedView
   
   if sendReplace is true then
      send "delete viewToReplace" to viewToReplace in 2 ticks
   else
      delete viewToReplace
   end if	# but this is prettier!
   
   set the rect of copiedView to oRect
   set the name of copiedView to oName
   unlock screen
   
   return copiedView
end object_Replacement
