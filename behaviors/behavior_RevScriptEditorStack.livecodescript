script "behavior_RevScriptEditorStack"
--> MetaData
-
license: GPLv3
name: behavior_RevScriptEditorStack
type: behavior
version: 0.1

/*
This behavior is designed to intercept certain handlers of stack "revSEStackBehavior"

It is designed to replace the current functions:

- seAvailablePanes()
- seVisiblePanes()

and needs to be set on thePane Tabs group to have an effect.
Because before handlers cannot be used for functions.
*/

function seAvailablePanes
   put rev_ScriptEditorPaneTabsGroup() into scriptEditorPanesGroup
   if exists (scriptEditorPanesGroup) is false then return "Errors,Variables,Documentation,Breakpoints,Search Results"
   
   put the group_ButtonNameList of scriptEditorPanesGroup into panelNames
   return panelNames
end seAvailablePanes

--> Pane
-
command paneResizeControl
   -- this has to be somewhere 
   -- due to " call "paneResizeControl" to group sActivePane of me"
   --in resize handler of group "Panes"
end paneResizeControl
