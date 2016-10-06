script "Global_Script_Folders_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Folders_Menu
type: controller
version: 0.2


--> Global | Script | Folders | Menu
-
on menu_ProjectArrayFile scriptObject
   put the project_Array of scriptObject into projectArray
   put the project_Name of scriptObject into projectName
   put merge ("the project_Array,[[projectName]]") into someTitle
   display_Array projectArray, someTitle
end menu_ProjectArrayFile

getprop disabled_ProjectArrayFile [scriptObject]
   put the project_ArrayFile of scriptObject into projectArrayFile
   put there is not a file projectArrayFile into fileIsMissing
   return fileIsMissing
end disabled_ProjectArrayFile

on _
end _

on menu_ProjectFolder scriptObject
   put the project_Folder of scriptObject into projectFolder
   display_Folder projectFolder
end menu_ProjectFolder

on menu_ObjectFolder scriptObject
   put the data_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_ObjectFolder

on menu_OverlayFolder scriptObject
   put the overlay_Folder of scriptObject into someFolder
   display_Folder someFolder
end menu_OverlayFolder

on menu_TextStackMetadataFolder scriptObject
   put the textStack_MetadataFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_TextStackMetadataFolder

on menu_ProjectOverlayFolder scriptObject
   put the project_OverlayFolder of scriptObject into someFolder
   display_Folder someFolder
end menu_ProjectOverlayFolder

on menu_RevealTextStackFolder scriptObject
   put the textStack_Folder of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_RevealTextStackFolder
   
on menu_RevealTextStackOverlayFolder scriptObject
   put the textStackOverlay_Folder [false] of scriptObject into overlayFolder
   display_Folder overlayFolder
end menu_RevealTextStackOverlayFolder

on _
end _

on menu_RevealScriptFile mTarget
   put the script_File of mTarget into someFile
   display_File someFile
end menu_RevealScriptFile

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_RevealMainstackDotText scriptObject
   put the textStackOverlay_Folder [true] of scriptObject into overlayFolder
   put overlay_ConstructFile ("dot", overlayFolder, "Mainstack Structure") into someFile
   
   display_File someFile
end menu_RevealMainstackDotText

on menu_OpenHandlerLibraryFolder
   put library_HkeyFolder (empty, false) into hkeyFolder
   display_Folder hkeyFolder
end menu_OpenHandlerLibraryFolder


--> Deps
-
command display_File someFile
   put someFile
   if there is a file someFile then
      finder_Reveal someFile
      lcw_Notify "Here is the file..."
   else
      answer warning "File does not exist!"
   end if
end display_File

command display_Folder someFolder
   put someFolder
   if there is a folder someFolder then
      finder_Reveal someFolder
      lcw_Notify "Here is the folder..."
   else
      answer warning "Folder does not exist!"
   end if
end display_Folder


