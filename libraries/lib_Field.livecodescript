script "lib_Field"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Field
type: library
version: 0.1


--> Working on
-


--> Field
-
getprop field_Locked
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   return the lockText of fieldObject
end field_Locked

setprop field_Locked someBoolean
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   set the lockText of fieldObject to someBoolean
   return someBoolean
end field_Locked

getprop field_TextSize
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   return the textSize of fieldObject
end field_TextSize

setprop field_TextSize someSize
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   set the textSize of fieldObject to someSize
end field_TextSize

getprop field_TextSizes
   return"6,8,9,10,11,12,14,18,14,36,48,72"
end field_TextSizes

getprop field_Style
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   put the uOPN ["field_Style"] of fieldObject into fieldStyle
   return fieldStyle
end field_Style

setprop field_Style fieldStyle
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   set the uOPN ["field_Style"] of fieldObject to fieldStyle
   
   switch fieldStyle
      case "Transparent"
         set the style of fieldObject to "transparent"
         break
      case "Scrolling"
         lock screen
         put the rect of fieldObject into oRect
         set the listBehavior of fieldObject to false
         set the dontWrap of fieldObject to false
         if the style of fieldObject is "scrolling" then
            set the style of fieldObject to "plain"
         else
            set the style of fieldObject to "scrolling"
         end if
         set the view_Rect of fieldObject to oRect
         unlock screen
         break
      case "Index"
         set the dontWrap of fieldObject to true
         if the listBehavior of fieldObject is true then
            set the listBehavior of fieldObject to false
         else
            set the listBehavior of fieldObject to true
         end if
         break
      case "Wide margins"
         set the wideMargins of fieldObject to not the wideMargins of fieldObject 
         break
      case "Small scrollbar"
         get the scrollbarWidth of fieldObject
         lcw_Notify it
         break
   end switch
end field_Style

getprop field_Styles
   return "Transparent,Scrolling,Index,Wide margins,Small scrollbar"
end field_Styles

getprop field_SelectedIndex
   put the long ID of the target into fieldObject
   if word 1 of fieldObject is not "field" then return empty
   return the selectedText of fieldObject
end field_SelectedIndex

setprop field_SelectedIndex someIndex
   put the long ID of the target into fieldObject
   if word 1 of fieldObject is not "field" then return empty
   
   set the wholeMatches to true
   put the text of fieldObject into fullIndex
   repeat for each line someLine in someIndex
      put lineOffset(someLine, fullIndex) into lineNum
      if lineNum is not 0 then put lineNum & comma after litLines
   end repeat
   delete char -1 of litLines
   set the hilitedlines of fieldObject to litLines
   return litLines
end field_SelectedIndex

command field_SelectText startChar, endChar, someField
   put merge("select char [[startChar]] to [[endChar]] of [[someField]]") into doScript
   do doScript
   return the result
end field_SelectText

command field_SelectLines startLineNum, endLineNum, someField
   put merge("select line [[startLineNum]] to [[endLineNum]] of [[someField]]") into doScript
   do doScript
   return the result
end field_SelectLines

command field_DeleteText startChar, endChar, someField
   put merge("delete char [[startChar]] to [[endChar]] of [[someField]]") into doScript
   do doScript
   return the result
end field_DeleteText

command field_DeleteLine lineNum, someField
   put merge("delete line [[lineNum]] of [[someField]]") into doScript
   do doScript
   return the result
end field_DeleteLine

function field_GetLinkText lineNum, someField
   -- also works with trees and selections that include tabs and spaces
   if word 1 of someField is not "field" then return empty
   
   put the short ID of someField into fieldID
   put the stack_Object of someField into stackObject
   get the linkText of word 1 to -1 of line lineNum of field ID fieldID of stackObject
   
   -- in case quotes have been encoded
   -- replace "'" with quote in it
   replace "&quot;" with quote in it
   return it
end field_GetLinkText

command field_HyperText someLink, targetObject
   if targetObject is empty then put the long ID of the target into targetObject
   set the itemDelimiter to ":"
   switch item 1 of someLink
      case "http"
         opn_GoUrl someLink
         break
      default
         if the script_CheckSafe [someLink] of targetObject is not false then
            try
               -- do someLink
               send someLink to targetObject
            catch errorNum
               get the opn_Error [errorNum] of me
            end try
         end if
   end switch
end field_HyperText

command field_HyperMenu
   put the long ID the target into targetObject
   
   if the selection is empty then
      select the clickChunk
   end if
   
   if the selection is empty then
      put the clickLoc into somelocation
      put the textStyle of the clickChunk into selectedStyle
      put the field_Menu [""] of targetObject into menuTitle	# ???
   else
      put the formattedRect of the selectedChunk into selectedRect
      if selectedRect is empty then return false
      
      if loc_WithinRect(the clickLoc, selectedRect) then
         put the field_Menu ["Inside"] of targetObject into menuTitle
      else
         select the clickChunk
         put the formattedRect of the selectedChunk into selectedRect
         if selectedRect is empty then return false
         
         put the field_Menu ["Outside"] of targetObject into menuTitle
      end if
      
      put item 1 of selectedRect into someLocation
      put item 4 of selectedRect + 6 into item 2 of someLocation
      
      put the textStyle of the selectedChunk into selectedStyle
   end if
   
   put the linkText of the selectedChunk into someLink
   switch someLink
      case ""
         put the long id of the target into tObject
         put the menu_Button of tObject into mButton
         mArray_MouseDown menuTitle, mButton, tObject
         popup mButton
         return true
      default
         if word 1 of someLink is "menu_Option" then
            -- this sets the text of the menu
            -- field_HyperText someLink, targetObject
            send someLink to targetObject
            
            put the menu_Button of the target into mButton
            menu_ClearTargetGlobals
            -- should set other stuff here mTitle and mTarget???
            menu_SetTopTargetObject targetObject
            
            popup mButton at someLocation
            set the menu_Action of mButton to empty
            return true
         else
            return false
         end if
   end switch
end field_HyperMenu


--> Deps
-
