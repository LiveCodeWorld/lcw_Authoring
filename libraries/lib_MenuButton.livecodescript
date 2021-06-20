script "lib_MenuButton"
--> MetaData
-
license: GPLv3
name: lib_MenuButton
type: library
version: 0.9

/*
Not sure if any of this is needed.
*/

/*
This fancy default searching etc can be achieved by adding a virtual custom property to the target
Or by adding a before handler in a behavior of this script.

Consequenlty none of this code in this section is needed.
*/

/*
Views can have attached menus. 
These menus are defined and controlled by scripts that reside in a revolution object. 
The object that contains this script is a "menu_Controller", and we store the link to this menu_Controller
as a view_Value. 
If not value is set then we return a default value, which for views is the card the view is on.

It is possible to set the "menu_Controller" to another object, and so move the scripts controlling the menu arround.
This is often simpler to do with a "global menu".
*/

--> Working on
-
-- Getting rid of all uneeded code.


/*
--> Menu | Utils
-

--> Menu | Controller | Default
-
getprop menu_DefaultController [mTitle]
   put the long id of the target into targetObject
   put menu_GetDefaultController (mTitle, targetObject, false) into mController
   return mController
end menu_DefaultController

-- getprop menu_Titles [pUseMenuTables]
put the long id of the target into scriptObject
if pUseMenuTables is false then
   put the menu_ScriptTitles of scriptObject into mTitles
else
   put menu_ListCustomPropertyTitles (scriptObject) into mTitles
end if
return mTitles
end menu_Titles

setprop menu_Title mTitle
   set the menu_BurntTitle of the target to mTitle
   return the result
end menu_Title

-- getprop menu_ScriptTitles
   put the long id of the target into mController
   put the script of mController into someScript
   put script_ExtractMenuSuiteTitles (someScript) into scriptMenuTitles
   return scriptMenuTitles
end menu_ScriptTitles

setprop menu_Controller [pMenuTitle] mController
   if mController is empty then
      put the long id of the target into targetObject
      put the view_Object of targetObject into someView
      if exists(someView) is false then put targetObject into someView
      custom_DeleteProperty "menu_Title", someView
      custom_DeleteProperty pMenuTitle, someView, "menu_Controller"
   else
      set the burnt_MenuController [pMenuTitle] of the target to mController
   end if
   return the result
end menu_Controller


--> Menu | Checks
-
function menu_CheckTitleController mTitle, mController
   put menu_ListCustomPropertyTitles (mController) into mTitles
   return mTitle is among the lines of mTitles
end menu_CheckTitleController


--> Deps | Menu | Controller
-
getprop burnt_MenuController [pMenuTitle]
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   if pMenuTitle is empty then put the menu_Title of targetObject into pMenuTitle
   
   set lockmessages to true
   put the menu_Controller [pMenuTitle] of someView into mController
   set lockmessages to false
   return mController
end burnt_MenuController

setprop burnt_MenuController [pMenuTitle] mController
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   if pMenuTitle is empty then
      put the menu_Title of targetObject into pMenuTitle
   else
      -- for convenience lets switch the menu_Title as well!
      set the menu_BurntTitle of targetObject to pMenuTitle
   end if
   
   if mController is empty then
      custom_DeleteProperty "menu_Controller", someView
   else
      set lockmessages to true
      set the menu_Controller [pMenuTitle] of someView to mController
      set lockmessages to false
   end if
   return pMenuTitle
end burnt_MenuController


--> Deps | Menu
-
function menu_GetItemTargetOveride sentMenuItemPath
   -- search for exact match in each item of path
   -- will return empty if match does not exist perhaps because stack is not known.
   global gLCW
   
   -- if the overide is an exact path return any match immediately
   put gLCW ["activeMenuArray"]["overide"]["mItem"][sentMenuItemPath]["mTarget"] into mItemTarget
   if exists(mItemTarget) then return mItemTarget
   
   -- faster to search through any stored overides
   put gLCW ["activeMenuArray"]["overide"]["mItem"] into itemMatchArray
   set the itemdelimiter to "/"
   repeat for each key mItemToMatch in itemMatchArray
      if mItemToMatch is among the items of sentMenuItemPath then
         put itemMatchArray [mItemToMatch]["mTarget"] into mItemTarget
         if exists(mItemTarget) then return mItemTarget
      end if
   end repeat
   return empty
end menu_GetItemTargetOveride

function menu_GetTopTitle
   global gLCW
   put gLCW ["activeMenuArray"]["top"]["mTitlePath"] into mTopTitle
   return mTopTitle
end menu_GetTopTitle

function menu_LineNumFromPath mPath, mText
   menu_CleanCheckMarks mText
   put outline_PathOffset (mPath, mText, "|") into lineNum
   return lineNum
end menu_LineNumFromPath

command menu_SetTopTitle mTopTitle
   global gLCW
   put mTopTitle into gLCW ["activeMenuArray"]["top"]["mTitlePath"]
end menu_SetTopTitle


--> Menu | Deps
-
command menu_DeleteTables mController
   put the custompropertysets of mController into setNames
   line_Delete "uOPN_MenuTable", setNames
   set the custompropertysets of mController to setNames
end menu_DeleteTables
*/
