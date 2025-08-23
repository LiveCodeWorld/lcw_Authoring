script "Global | Stack | Snapshot | Menu"
--> MetaData
-
license: GPLv3
name: Global | Stack | Snapshot | Menu
type: controller
version: 0.1


--> Global | Stack | Snapshot | Menu
-
on menu_SnapCard scriptObject
   put the card_Object of scriptObject into cardObject
   if exists (cardObject) is false then
      answer warning "No card for this script object!"
      exit to top
   end if
   
   wireframe_SnapAndExport cardObject, false
   put the result into imageFile
   display_Image imageFile
   -- set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
   finder_Reveal imageFile
end menu_SnapCard

on menu_SnapStack scriptObject
   put the stack_Object of scriptObject into stackObject
   put the wireframe_StackSnap of stackObject into somePNG
   
   put somePNG into image 1 of cd 1 of stack "Test Wireframe Image"
   
   put the short name of stackObject into stackName
   replace quote with empty in stackName
   replace space with "-" in stackName
   put "stack_" & stackName & ".png" into shortFile
   
   localhost_SavePng somePNG, shortFile
   put the result into imageFile
   finder_Reveal imageFile
end menu_SnapStack

on menu_SnapImage scriptObject
   wireframe_SnapAndExport scriptObject, true
   put the result into imageFile
   set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
   finder_Reveal imageFile
end menu_SnapImage

on _
end _

on menu_RecordCard scriptObject, someBoolean
   put scriptObject into LocalArray ["scriptObject"]
   put someBoolean into LocalArray ["isRecoring"]
   export_SnapShot
end menu_RecordCard


--> Global | Stack | Snapshot | Menu | Props
-

--> Global | Stack | Snapshot | Menu | Disabled
-

--> Deps
-
command export_SnapShot
   put LocalArray ["scriptObject"] into scriptObject
   put LocalArray ["isRecoring"] into isRecoring
   
   if isRecoring is true then
      -- wireframe_SnapAndExport scriptObject, false - card changes we still record the card
      put the wireframe_StackSnap of scriptObject into somePNG
      
      set the text of image 1 of cd 1 of stack "Test Wireframe Image" to somePNG
      /*
      put the result into imageFile
      set the filename of image 1 of cd 1 of stack "Test Wireframe Image" to imageFile
      put filename
      */
      
      send "export_SnapShot" to me in 2 seconds
   end if
end export_SnapShot
