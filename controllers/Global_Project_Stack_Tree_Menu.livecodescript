script "Global | Project | Stack | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Stack | Tree | Menu
type: controller
version: 0.1


--> Menu | Props
-
private command _displayAndHilite
   put _rescueDisplayCard() into displayCard
   if exists(displayCard) is false then return empty
   
   lock screen
   set the hilite_Used of displayCard to true
   dispatch "display_ProjectArray" to displayCard
   unlock screen
   return displayCard
end _displayAndHilite

private function _indexView
   put menu_GetTopTargetObject() into tObject
   put the index_View of tObject into indexView
   return indexView
end _indexView

private function _rescueDisplayCard
   if there is a stack "Rescue livecode World" then
      put the long id of card 1 of stack "Rescue livecode World" into displayCard
      return displayCard
   else
      return empty
   end if
end _rescueDisplayCard


--> Global | Project | Stack | Tree | Menu
-
on menu_AddToThisProject stackObject
   if exists (stackObject) is false then
      answer warning merge ("I cannot locate [[stackObject]]. Please locate and add to the stackfiles.")
      exit to top
   end if
   
   put _indexView() into indexView
   put the displayed_project of indexView into projectName
   
   library_AddUsedStack stackObject, projectName
   
   put the short name of stackObject into stackName
   start using stack stackName
   start using stackObject -- seems to have changed
   
   dispatch "refresh" to indexView
   set the hilite_Used of indexView to true
end menu_AddToThisProject

on menu_AddToAllProjects stackObject
   put _indexView() into indexView
   
   start using stackObject
   put lcw_ListProjects() into projectNames
   repeat for each line projectName in projectNames   
      library_AddUsedStack stackObject, projectName
   end repeat
   
   dispatch "refresh" to indexView
   set the hilite_Used of indexView to true
end menu_AddToAllProjects

on _
end _

on menu_RemoveFromThisProject stackObject
   stop using stackObject 
   library_DeleteUsedStack stackObject
   _displayAndHilite
end menu_RemoveFromThisProject

on menu_RemoveFromAllProjects stackObject
   stop using stackObject 
   library_RemoveStackFromAllProjects stackObject
   _displayAndHilite
end menu_RemoveFromAllProjects

on _
end _

on menu_RefreshIndex
   dispatch "refresh" to _indexView() 
end menu_RefreshIndex
